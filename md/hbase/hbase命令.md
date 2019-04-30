# hbase 命令

进入hbase shell console

```shell
$HBASE_HOME/bin/hbase shell
```

如果有kerberos认证,需要事先使用相应的keytab进行一下认证（使用kinit命令）,认证成功之后再使用hbase shell进入可以使用whoami命令可查看当前用户

```shell
hbase(main)> whoami
```

## 表的管理

- 查看有哪些表

```shell
hbase(main)> list
```

- 创建表

语法：create TABLE, {NAME => , VERSIONS => },例如：创建表t1,有两个family name：f1,f2,且版本数均为2

```shell
hbase(main)> create 't1',{NAME => 'f1', VERSIONS => 2},{NAME => 'f2', VERSIONS => 2}
```

- 删除表

分两步：首先disable,然后drop
例如：删除表t1

```shell
hbase(main)> disable 't1'hbase(main)> drop 't1'
```

- 查看表的结构

语法：describe# 例如：查看表t1的结构

```shell
hbase(main)> describe 't1'
```

- 修改表结构

修改表结构必须先disable
语法：alter 't1', {NAME => 'f1'}, {NAME => 'f2', METHOD => 'delete'}# 例如：修改表test1的cf的TTL为180天

```shell
hbase(main)> disable 'test1'hbase(main)> alter 'test1',{NAME=>'body',TTL=>'15552000'},{NAME=>'meta', TTL=>'15552000'}hbase(main)> enable'test1'
```

## 权限管理

- 分配权限

语法 : grant 参数后面用逗号分隔# 权限用五个字母表示： "RWXCA".# READ('R'), WRITE('W'), EXEC('X'), CREATE('C'), ADMIN('A')# 例如,给用户‘test'分配对表t1有读写的权限
 
```shell
hbase(main)> grant 'test','RW','t1'
```

- 

语法：user_permission# 例如,查看表t1的权限列表

```shell
hbase(main)> user_permission 't1'
```

- 收回权限

与分配权限类似,语法：revoke# 例如,收回test用户在表t1上的权限

```shell
hbase(main)> revoke 'test','t1'
```

## 表数据的增删改查

- 添加数据

语法：put ,,,,# 例如：给表t1的添加一行记录：rowkey是rowkey001,family name：f1,column name：col1,value：value01,timestamp：系统默认

```shell
hbase(main)> put 't1','rowkey001','f1:col1','value01'
```

- 查询数据
 
  - 查询某行记录
    
    语法：get ,[,....],# 例如：查询表t1,rowkey001中的f1下的col1的值
  
    ```shell 
    hbase(main)> get 't1','rowkey001', 'f1:col1'
    ```

    ```shell
    hbase(main)> get 't1','rowkey001', {COLUMN=>'f1:col1'} 
    ```

    ```shell
    hbase(main)> get 't1','rowkey001'
    ```

  - 扫描表
    
    语法：scan ,.... ], LIMIT => num}, {COLUMNS => [# 另外,还可以添加STARTROW、TIMERANGE和FITLER等高级功能# 例如：扫描表t1的前5条数据
    
    ```shell
    hbase(main)> scan 't1',{LIMIT=>5}
    ```

  - 查询表中的数据行数
    
    语法：count , {INTERVAL => intervalNum, CACHE => cacheNum}# INTERVAL设置多少行显示一次及对应的rowkey,默认1000；CACHE每次去取的缓存区大小,默认是10,调整该参数可提高查询速度# 例如,查询表t1中的行数,每100条显示一次,缓存区为500
    
    ```shell
    hbase(main)> count 't1', {INTERVAL => 100, CACHE => 500}
    ```

## 删除数据

- 删除行中的某个列值

语法：delete,必须指定列名,# 例如：删除表t1,rowkey001中的f1:col1的数据

```shell
hbase(main)> delete 't1','rowkey001','f1:col1'
```

> 注：将删除改行f1:col1列所有版本的数据

- 删除行

语法：deleteall,可以不指定列名,删除整行数据,# 例如：删除表t1,rowk001的数据

```shell
hbase(main)> deleteall 't1','rowkey001'
```

- 删除表中的所有数据

语法： truncate# 其具体过程是：disable table -> drop table -> create table# 例如：删除表t1的所有数据

```shell
hbase(main)> truncate 't1'
```

## Region管理

- 移动region

语法：move 'encodeRegionName', 'ServerName'# encodeRegionName指的regioName后面的编码,ServerName指的是master-status的Region Servers列表# 示例

```shell
hbase(main)>move '4343995a58be8e5bbc739af1e91cd72d', 'db-41.xxx.xxx.org,60020,1390274516739'
```

- 开启/关闭region

语法：balance_switch true|false

```shell
hbase(main)> balance_switch
```

- 手动split

语法：split 'regionName', 'splitKey'

- 手动触发major compaction

语法：
Compact all regions in a table:

```shell
hbase> major_compact 't1'
hbase> major_compact 'r1'
hbase> major_compact 'r1', 'c1'
hbase> major_compact 't1', 'c1'
```

## 配置管理及节点重启

- 修改hdfs配置

hdfs配置位置：/etc/hadoop/conf

同步hdfs配置cat/home/hadoop/slaves|xargs-i -t scp/etc/hadoop/conf/hdfs-site.xml hadoop@{}:/etc/hadoop/conf/hdfs-site.xml

关闭：cat/home/hadoop/slaves|xargs-i -t sshhadoop@{} "sudo /home/hadoop/cdh4/hadoop-2.0.0-cdh4.2.1/sbin/hadoop-daemon.sh --config /etc/hadoop/conf stop datanode"

启动：cat/home/hadoop/slaves|xargs-i -t sshhadoop@{} "sudo /home/hadoop/cdh4/hadoop-2.0.0-cdh4.2.1/sbin/hadoop-daemon.sh --config /etc/hadoop/conf start datanode"

- 修改hbase配置

hbase配置位置：

同步hbase配置cat/home/hadoop/hbase/conf/regionservers|xargs-i -t scp/home/hadoop/hbase/conf/hbase-site.xml hadoop@{}:/home/hadoop/hbase/conf/hbase-site.xml# graceful

重启cd~/hbasebin/graceful_stop.sh --restart --reload --debug inspurXXX.xxx.xxx.org
