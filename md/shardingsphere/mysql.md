# Mysql 主从配置

## 环境

mysql 版本 5.7.30

IP|类型
---|---
192.168.120.133|master
192.168.120.134|slave

## 配置主库

- 修改主库配置文件my.cnf，在[mysqld]加入下面的内容

```conf
# 服务的唯一编号
server-id = 133
# 开启mysql binlog功能
log-bin = mysql-bin
# binlog记录内容的方式，记录被操作的每一行
binlog_format = ROW
# 减少记录日志的内容，只记录受影响的列
binlog_row_image = minimal
# 指定需要复制的数据库名
binlog-do-db = sharding
```

- 重启mysql

```bash
systemctl restart mysqld
```

- 创建从库同步数据的账号

```bash
mysql> grant replication slave on *.* to 'root2'@'192.168.120.134' identified by 'root123456789';
mysql> flush privileges;
```

- 查看主库状态

```bash
mysql> show master status\G;
*************************** 1. row ***************************
             File: mysql-bin.000001
         Position: 6357078
     Binlog_Do_DB: sharding
 Binlog_Ignore_DB: 
Executed_Gtid_Set: 
1 row in set (0.00 sec)

ERROR: 
No query specified
```

## 配置从库

- 修改从库配置文件my.cnf，在[mysqld]加入下面的内容

```conf
# 服务的唯一编号
server-id = 134
# 开启mysql binlog功能
log-bin = mysql-bin
# binlog记录内容的方式，记录被操作的每一行
binlog_format = ROW
# 减少记录日志的内容，只记录受影响的列
binlog_row_image = minimal
# 指定需要复制的数据库名
replicate-do-db = sharding
```

- 重启mysql

```bash
systemctl restart mysqld
```

- 执行同步命令

```bash
mysql> change master to master_host='192.168.120.133',master_user='root2',master_password='root123456789',master_log_file='mysql-bin.000001',master_log_pos=6357078;
mysql> start slave;
```

- 查看从库状态

```bash
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.120.133
                  Master_User: root2
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 6357078
               Relay_Log_File: 120134-relay-bin.000002
                Relay_Log_Pos: 6355240
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: sharding
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 6357078
              Relay_Log_Space: 6355451
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 135
                  Master_UUID: e491d56a-d300-11ea-8fd4-0800273ae2fe
             Master_Info_File: /var/lib/mysql/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
1 row in set (0.00 sec)

ERROR: 
No query specified
```

> 有以下两个属性表示启动成功
Slave_IO_Running: Yes
Slave_SQL_Running: Yes

## 验证

在主库创建数据库,同时从库会自动同步创建

```sql
create database sharding;
```

在主库创建表格，写入、修改数据等也会在从库同步执行
