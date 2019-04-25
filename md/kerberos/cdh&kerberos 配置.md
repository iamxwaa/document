# hadoop集群添加kerberos认证

--------

**以下均为为CDH版本配置说明**

## CDH配置

进入 管理->安全->kerberos凭据 
- 开启kerberos认证
- 选择导入kerberos account manager凭据
  - 填写kadmin的管理员账号及密码
- 选择生成丢失kerberos凭据

## hdfs开启kerberos

进入hdfs配置页面
- 修改hadoop.security.authentication为kerberos
- 修改hadoop.security.authorization为true
- 修改dfs.datanode.address为1004
- 修改dfs.datanode.http.address为1006

## hbase开启kerberos

进入hbase配置页面
- 修改hbase.security.authentication为kerberos
- 修改hbase.security.authorization为true

## zookeeper开启kerberos

进入zookeeper配置页面
- 修改 enableSecurity为true

## 错误与处理

ERROR:

```
kadmind[6924]: No dictionary file specified, continuing without one.
kadmind[6924]: setting up network...
kadmind[6924]: Permission denied - Cannot bind server socket to port 464 address 0.0.0.0
kadmind[6924]: setsockopt(6,IPV6_V6ONLY,1) worked
kadmind[6924]: Permission denied - Cannot bind server socket to port 464 address ::
kadmind[6924]: skipping unrecognized local address family 17
kadmind[6924]: skipping unrecognized local address family 17
kadmind[6924]: Permission denied - Cannot bind server socket to port 464 address 192.168.165.145
kadmind[6924]: setsockopt(6,IPV6_V6ONLY,1) worked
kadmind[6924]: Permission denied - Cannot bind TCP server socket on ::.464
kadmind[6924]: Permission denied - Cannot bind RPC server socket on 0.0.0.0.749
kadmind[6924]: set up 0 sockets
kadmind[6924]: no sockets set up?
Reason (provided by tlyu): It is trying to bind to a privileged port. you need to give it a different port number. actually, two different port numbers: one for password changing and one for normal kadmin.
```

SOLUTION:

```
In kdc.conf inserted the last two lines here
kdc_ports = 8888
kpasswd_port = 8887
kadmind_port = 8886
In krb5.conf modify/insert the lines:
admin_server = yourComputerName.domain:8886
kpasswd_server = yourComputerName.domain:8887
```