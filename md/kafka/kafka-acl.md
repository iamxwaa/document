# kafka acl配置

> 以kafka内置的zookeeper为例
> 假设kakfa安装在这个目录`/root/kafka/kafka_2.11-0.10.1.1`

## 功能配置

- 配置zookeeper
修改config/zookeeper.properties，添加

```properties
authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
requireClientAuthScheme=sasl
jaasLoginRenew=3600000
```

- 配置kafka
修改config/server.properties，添加

```properties
listeners=SASL_PLAINTEXT://192.168.119.204:9092
advertised.listeners=SASL_PLAINTEXT://192.168.119.204:9092

security.inter.broker.protocol=SASL_PLAINTEXT
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN
authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer
# allow.everyone.if.no.acl.found=true

sasl.kerberos.service.name=kafka
#该用户为超级用户，有所有权限
super.users=User:admin
```

IP地址请根据实际情况修改

- 创建jaas文件
在config/目录下新建jaas.conf，添加

```properties
Server {
org.apache.kafka.common.security.plain.PlainLoginModule required
username="admin"
password="admin-secret"
//以下为提供给外部访问的账号，格式user_[用户名]=[密码]
user_admin="admin-sec"
user_kafka="kafka-sec"
user_producer="prod-sec"
user_consumer="consumer-sec";
};

KafkaServer {
org.apache.kafka.common.security.plain.PlainLoginModule required
username="admin"
password="admin-sec"
//以下为提供给外部访问的账号，格式user_[用户名]=[密码]
user_admin="admin-sec"
user_producer="prod-sec"
user_consumer="cons-sec";
};

Client {
org.apache.kafka.common.security.plain.PlainLoginModule required
username="kafka"
password="kafka-sec";
};
```

- 修改启动脚本
修改bin/kafka-run-class.sh，将jaas.conf文件路径配置进去
修改前

```sh
# JVM performance options
if [ -z "$KAFKA_JVM_PERFORMANCE_OPTS" ]; then
  KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+DisableExplicitGC -Djava.awt.headless=true"
fi
```

修改后

```sh
# JVM performance options
if [ -z "$KAFKA_JVM_PERFORMANCE_OPTS" ]; then
  KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+DisableExplicitGC -Djava.awt.headless=true -Djava.security.auth.login.config=/root/kafka/kafka_2.11-0.10.1.1/config/jaas.conf"
fi
```

- 先启动zookeeper`bin/zookeeper-server-start.sh config/zookeeper.properties`

- 再启动kafka`bin/kafka-server-start.sh config/zookeeper.properties`

## 权限配置

- 命令行

bin/kafka-acls.sh

选项|描述|默认|类型选择
---|---|---|---
--add|添加一个acl|-|Action
--remove|移除一个acl|-|Action
--list|列出acl|-|Action
--authorizer|authorizer的完全限定类名|kafka.security.auth.SimpleAclAuthorizer|Configuration
--authorizer-properties|key=val，传给authorizer进行初始化，例如zookeeper.connect=localhost:2181|-|Configuration
--cluster|指定集群作为资源。|-|Resource
--topic [topic-name]|指定topic作为资源。||Resource
--group [group-name]|指定 consumer-group 作为资源。|-|Resource
-allow-principal|添加到允许访问的ACL中，Principal是PrincipalType:name格式。你可以指定多个。|-|Principal
--deny-principal|添加到拒绝访问的ACL中，Principal是PrincipalType:name格式。你可以指定多个。|-|Principal
--allow-host|--allow-principal中的principal的IP地址允许访问。|如果--allow-principal指定的默认值是*，则意味着指定“所有主机”|Host
--deny-host|允许或拒绝的操作。有效值为：读，写，创建，删除，更改，描述，ClusterAction，全部|ALL|Operation
--operation|--deny-principal中的principals的IP地址拒绝访问。|如果 --deny-principal指定的默认值是 * 则意味着指定 "所有主机"|Host
--producer|为producer角色添加/删除acl。生成acl，允许在topic上WRITE, DESCRIBE和CREATE集群。|-|Convenience
--consumer|为consumer role添加/删除acl，生成acl，允许在topic上READ, DESCRIBE 和 consumer-group上READ。|-|Convenience
--force|假设所有操作都是yes，规避提示|-|Convenience

- 查看权限列表

```shell
bin/kafka-acls.sh --list --authorizer-properties zookeeper.connect=localhost:2181
```

- 示例

创建一个topic，名字叫acl1

```shell
bin/kafka-topics.sh --create --topic acl1 --partitions 1 --zookeeper localhost:2188 --replication-factor 1
```

给用户producer赋予topic名称为acl1的读写权限

```shell
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:producer --operation Read --operation Write --topic acl1
```

给指定ip，任意用户，赋予topic名称为acl1的读写权限

```shell
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-host 192.168.118.139 --allow-principal User:* --operation Read --operation Write --topic acl1
```

给用户名为consumer，gourp id为test的用户赋予topic名称为acl1的写权限
  
```shell
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:consumer --consumer --group test --topic acl1
```
