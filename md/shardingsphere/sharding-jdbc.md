# Shardingphere JDBC 使用说明

------------

- 依赖包

```xml
<dependency>
    <groupId>org.apache.shardingsphere</groupId>
    <artifactId>sharding-jdbc-core</artifactId>
    <version>4.1.1</version>
</dependency>
```

- 建表

```sql
CREATE TABLE t_alert_0 (
  id BIGINT  PRIMARY KEY  AUTO_INCREMENT,
  ip varchar(20) COMMENT 'ip地址',
  message varchar(100) COMMENT '报警信息',
  time DATETIME COMMENT '报警时间'
);

CREATE TABLE t_alert_1 (
  id BIGINT  PRIMARY KEY  AUTO_INCREMENT,
  ip varchar(20) COMMENT 'ip地址',
  message varchar(100) COMMENT '报警信息',
  time DATETIME COMMENT '报警时间'
);

CREATE TABLE t_alert_2 (
  id BIGINT  PRIMARY KEY  AUTO_INCREMENT,
  ip varchar(20) COMMENT 'ip地址',
  message varchar(100) COMMENT '报警信息',
  time DATETIME COMMENT '报警时间'
);
```

- 配置

datasource.yml

> 数据库使用Mysql，并添加主从配置
192.168.120.135:3306 为主数据库
192.168.120.134:3306 为从数据库

```yml
dataSources:
  ds_m_0: !!org.apache.commons.dbcp2.BasicDataSource
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://192.168.120.135:3306/sharding
    username: root2
    password: root123456789
  ds_m_1: !!org.apache.commons.dbcp2.BasicDataSource
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://192.168.120.134:3306/sharding
    username: root2
    password: root123456789
  # ds_1: !!org.apache.commons.dbcp2.BasicDataSource
  #   driverClassName: org.h2.Driver
  #   url: jdbc:h2:~/test1;MODE=MYSQL;AUTO_SERVER=TRUE
  #   username: sa
  #   password: '123456'
  # ds_2: !!org.apache.commons.dbcp2.BasicDataSource
  #   driverClassName: org.h2.Driver
  #   url: jdbc:h2:~/test2;MODE=MYSQL;AUTO_SERVER=TRUE
  #   username: sa
  #   password: '123456'

shardingRule:
  tables:
    t_alert:
      # actualDataNodes: ds_0.t_alert_${0..2} #,ds_1.t_alert_${0..2}
      actualDataNodes: ds.t_alert_${0..2}
      tableStrategy:
        standard:
          shardingColumn: id
          preciseAlgorithmClassName: com.vrv.test.MyShardingAlgorithmImpl
          rangeAlgorithmClassName: com.vrv.test.MyShardingAlgorithmImpl
      keyGenerator:
        type: SNOWFLAKE
        column: id
  masterSlaveRules:
    ds:
      loadBalanceAlgorithmType: ROUND_ROBIN
      masterDataSourceName: ds_m_0
      slaveDataSourceNames: ["ds_m_1"]

props:
  sql-show: true
```

- 主键分片算法实现

MyShardingAlgorithmImpl.java

```java
package com.vrv.test;

import java.util.Collection;

import org.apache.shardingsphere.api.sharding.standard.PreciseShardingAlgorithm;
import org.apache.shardingsphere.api.sharding.standard.PreciseShardingValue;
import org.apache.shardingsphere.api.sharding.standard.RangeShardingAlgorithm;
import org.apache.shardingsphere.api.sharding.standard.RangeShardingValue;

public class MyShardingAlgorithmImpl implements PreciseShardingAlgorithm<Long>, RangeShardingAlgorithm<Long> {

    @Override
    public String doSharding(Collection<String> availableTargetNames, PreciseShardingValue<Long> shardingValue) {
        Long index = shardingValue.getValue() % availableTargetNames.size();
        return shardingValue.getLogicTableName() + "_" + index;
    }

    @Override
    public Collection<String> doSharding(Collection<String> availableTargetNames,
            RangeShardingValue<Long> shardingValue) {
        System.out.println(shardingValue);
        return availableTargetNames;
    }

}
```

- 调用

```java
package com.vrv.test;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import javax.sql.DataSource;

import org.apache.shardingsphere.shardingjdbc.api.yaml.YamlShardingDataSourceFactory;

/**
 * Hello world!
 */
public final class App {
    private App() {
    }

    /**
     * Says hello to the world.
     *
     * @param args The arguments of the program.
     * @throws IOException
     * @throws SQLException
     */
    public static void main(String[] args) throws SQLException, IOException {
        // org.apache.shardingsphere.core.yaml.config.sharding.YamlRootShardingConfiguration
        File yamlFile = new File("D:\\vscode\\java\\demo1\\src\\main\\resources\\datasource.yml");
        DataSource dataSource = YamlShardingDataSourceFactory.createDataSource(yamlFile);
        System.out.println(dataSource);
        Connection connection = dataSource.getConnection();
        makeData(connection);
        query(connection);
        connection.close();
    }

    private static void makeData(Connection connection) throws SQLException {
        PreparedStatement pstmt = connection.prepareStatement("insert into t_alert (ip,message,time) values(?,?,?)");
        int j = 1000;
        List<Long> avg = new ArrayList<>();
        while (j > 0) {
            long start = System.currentTimeMillis();
            for (int i = 1; i < 2000; i++) {
                pstmt.setString(1, "192.168.118.139");
                pstmt.setString(2, "test" + i);
                pstmt.setString(3, new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
                pstmt.addBatch();
                if (i % 500 == 0) {
                    pstmt.executeBatch();
                    System.out.println("execute batch " + i);
                }
            }
            pstmt.executeBatch();
            long cost = System.currentTimeMillis() - start;
            System.out.println(j + "#insert cost: " + cost);
            avg.add(cost);
            j--;
        }
        Collections.sort(avg);
        avg.remove(0);
        avg.remove(avg.size() - 1);
        long avgn = avg.stream().reduce((a, b) -> {
            return a + b;
        }).get();
        System.out.println("insert avg cost: " + (avgn / avg.size()));
        pstmt.close();
    }

    private static void query(Connection connection) throws SQLException {
        int j = 10;
        List<Long> avg = new ArrayList<>();
        PreparedStatement pstmt2 = connection
                .prepareStatement("SELECT id, ip, message, time FROM t_alert limit 1000000,10");
        while (j > 0) {
            long start = System.currentTimeMillis();
            ResultSet resultSet = pstmt2.executeQuery();
            long cost = System.currentTimeMillis() - start;
            while (resultSet.next()) {
                System.out.printf("id=%d, ip=%s, message=%s, time=%s\n", resultSet.getLong(1), resultSet.getString(2),
                        resultSet.getString(3), resultSet.getString(4));
            }
            System.out.println(j + "#search cost: " + cost);
            avg.add(cost);
            j--;
        }
        Collections.sort(avg);
        avg.remove(0);
        avg.remove(avg.size() - 1);
        long avgn = avg.stream().reduce((a, b) -> {
            return a + b;
        }).get();
        System.out.println("search avg cost: " + (avgn / avg.size()));
        pstmt2.close();
    }
}
```
