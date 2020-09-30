# flyway 使用说明

------

## Gradle 集成

- 依赖环境
  - Java 8, 9, 10 or 11 
  - Gradle 3.0 or newer

- 创建build.gradle,添加以下内容

```gradle
buildscript {
    dependencies {
        //依赖的数据库driver
        classpath 'com.h2database:h2:1.4.197'
    }
}

plugins {
    id "org.flywaydb.flyway" version "5.2.4"
}

flyway {
    //数据库连接
    url = 'jdbc:h2:file:./target/foobar'
    user = 'sa'
}
```

- 数据库脚本管理
  - 创建数据库建表脚本 src/main/resources/db/migration/V1__Create_person_table.sql
     
     ```sql
    create table PERSON (
        ID int not null,
        NAME varchar(100) not null
    );
    ```
    
  - 执行脚本

     ```shell
    > gradle flywayMigrate -i
    ```

    执行结果

    ```shell
    Creating schema history table: "PUBLIC"."flyway_schema_history"
    Current version of schema "PUBLIC": << Empty Schema >>
    Migrating schema "PUBLIC" to version 1 - Create person table
    Successfully applied 1 migration to schema "PUBLIC" (execution time 00:00.062s).
    ```

  - 创建数据库数据脚本 src/main/resources/db/migration/V2__Add_people.sql
     
    ```sql
    insert into PERSON (ID, NAME) values (1, 'Axel');
    insert into PERSON (ID, NAME) values (2, 'Mr. Foo');
    insert into PERSON (ID, NAME) values (3, 'Ms. Bar');
    ```

  - 执行脚本
  
    ```shell
    > gradle flywayMigrate -i
    ```

    执行结果

    ```shell
    Current version of schema "PUBLIC": 1
    Migrating schema "PUBLIC" to version 2 - Add people
    Successfully applied 1 migration to schema "PUBLIC" (execution time 00:00.090s).
    ```

- 说明
  - 数据库脚本命名规则

    ```shell
      双"_"  脚本描述     后缀".sql"
       ↓      ↓             ↓
    V1__Create_person_table.sql
    ↑
    版本(如V1 V1.1 V1.2 V2 V2.1 V2.1.1 ...)
    ```

    ```shell
    例:
    src/main/resources/db/migration
    ├─ V1__Create_Table.sql
    ├─ V1.1__Insert_Data.sql
    ├─ V2__Create_Table.sql
    ├─ V2.1__Fix_Table.sql
    └─ V2.2__Fix_Table.sql
    ```

  - 命令
    - 执行脚本 gradle flywayMigrate -i
    - 版本信息 gradle flywayInfo
    - 删除所有表 gradle flywayClean
    - 验证脚本 gradle flywayValidate
  - 执行过的脚本不能修改,如果需要对历史表进行修改,需要新建版本

## Maven 集成

- 修改 pom.xml

```xml
<project xmlns="...">
    ...
    <build>
        <plugins>
            <plugin>
                <groupId>org.flywaydb</groupId>
                <artifactId>flyway-maven-plugin</artifactId>
                <version>5.2.4</version>
                <configuration>
                    <url>jdbc:h2:file:./target/foobar</url>
                    <user>sa</user>
                </configuration>
                <dependencies>
                    <dependency>
                        <groupId>com.h2database</groupId>
                        <artifactId>h2</artifactId>
                        <version>1.4.197</version>
                    </dependency>
                </dependencies>
            </plugin>
        </plugins>
    </build>
</project>
```

- 创建脚本(参考gradle构建)
- 执行命令

```shell
mvn flyway:migrate
```

## 附录

- V1__Create_Table.sql

```sql
--测试表--
create table TEST (
    ID int not null,
    NAME varchar(100) not null
);

--正式表--
CREATE TABLE `server_info` (
  id INTEGER  PRIMARY KEY   AUTOINCREMENT,
  `name` varchar(128),
  `ip` varchar(32) ,
  `description` varchar(256),
  `create_time` DATETIME2 ,
  `update_time` DATETIME2
);

CREATE TABLE `cluster_info` (
  id INTEGER  PRIMARY KEY   AUTOINCREMENT,
  `name` varchar(128),
  `description` varchar(256),
  `create_time` DATETIME2 ,
  `update_time` DATETIME2
);
```

- V1.1__Insert_Data.sql

```sql
insert into TEST (ID, NAME) values (1, 'Axel');
insert into TEST (ID, NAME) values (2, 'Mr. Foo');
insert into TEST (ID, NAME) values (3, 'Ms. Bar');
```

- V2__Create_Table.sql

```sql
CREATE TABLE `cluster_info2` (
  id INTEGER  PRIMARY KEY   AUTOINCREMENT,
  `name` varchar(128),
  `description` varchar(256),
  `create_time` DATETIME2 ,
  `update_time` DATETIME2
);
```

- V2.1__Fix_Table.sql

```sql
ALTER TABLE "TEST" ADD COLUMN col6 INTEGER
```

- V2.2__Fix_Table.sql

```sql
drop table "cluster_info2"
```
