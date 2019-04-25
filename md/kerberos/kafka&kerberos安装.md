# kafka 安装

------------

## kafka开启kerber认证

- 添加kafka认证账号

```
sudo /usr/sbin/kadmin.local -q 'addprinc -randkey kafka/vrv145@VRV.COM.CN'
sudo /usr/sbin/kadmin.local -q 'addprinc -randkey zookeeper/vrv145@VRV.COM.CN'
```

- 生成票据文件

```
sudo /usr/sbin/kadmin.local -q "ktadd -k /etc/security/keytabs/kafka.keytab kafka/vrv145@VRV.COM.CN"
sudo /usr/sbin/kadmin.local -q "ktadd -k /etc/security/keytabs/zookeeper.keytab zookeeper/vrv145@VRV.COM.CN"
```

> 错误: 
> kadmin.local: Key table file '/etc/security/keytabs/kafka.keytab' not found while adding key to keytab
>/etc/security/keytabs目录可能不存在需要手动创建

- 配置kafka brokers,每个broker的keytab需要单独生成

  - 创建jaas文件/data/kafka_2.11-0.10.1.0/config/kakfa-jaas.conf

  ```
  KafkaServer {
        com.sun.security.auth.module.Krb5LoginModule required
        useKeyTab=true
        storeKey=true
        keyTab="/etc/security/keytabs/kafka.keytab"
        principal="kafka/vrv145@VRV.COM.CN";
    };

    // Zookeeper client authentication
    Client {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    storeKey=true
    keyTab="/etc/security/keytabs/zookeeper.keytab"
    principal="kafka/vrv145@VRV.COM.CN";
    };
  ```

 - 复制krb5.conf和kakfa-jaas.conf到每台kafka broker对应的目录下

 - 修改/data/kafka_2.11-0.10.1.0/bin/kafka-run-class.sh

 ```
	# JVM performance options
	if [ -z "$KAFKA_JVM_PERFORMANCE_OPTS" ]; then
	  KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+DisableExplicitGC -Djava.awt.headless=true -Djava.security.krb5.conf=/etc/krb5.conf -Djava.security.auth.login.config=/data/kafka_2.11-0.10.1.0/config/kakfa-jaas.conf -Dsun.security.krb5.debug=true"
	fi
 ```

 - 配置SASL，修改/data/kafka_2.11-0.10.1.0/config/server.properties

 ```
	listeners=SASL_PLAINTEXT://192.168.118.145:9092
	security.inter.broker.protocol=SASL_PLAINTEXT
	sasl.mechanism.inter.broker.protocol=GSSAPI
	sasl.enabled.mechanisms=GSSAPI
	sasl.kerberos.service.name=kafka(票据里面账号是kafka/vrv145@VRV.COM.CN所以名称是kafka)
 ```

- 修改zookeeper

  - zoo.cfg或config/zookeeper.properties添加

  ```
  authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
  requireClientAuthScheme=sasl
  jaasLoginRenew=3600000
  ```


- 启动kafka集群

> 错误:
Caused by: KrbException: Encryption type AES256 CTS mode with HMAC SHA1-96 is not supported/enabled
> jdk加密算法不支持,下载jce_policy-8将jar包放在$JAVA_HOME/jre/lib/security下

## producer编程

```
object Producer {

  System.setProperty("java.security.krb5.conf",
    "D:\\IdeaProjects\\kafka-acl\\kerberos\\krb5.conf")
  System.setProperty("java.security.auth.login.config",
    "D:\\IdeaProjects\\kafka-acl\\kerberos\\producer_jaas.conf")
  System.setProperty("javax.security.auth.useSubjectCredsOnly", "true")
  System.setProperty("sun.security.krb5.debug", "true")

  def main(args: Array[String]): Unit = {
    val props = new Properties
    props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "vrv145:9092")
    props.put(ProducerConfig.ACKS_CONFIG, "all")
    props.put(ProducerConfig.RETRIES_CONFIG, Integer.valueOf(0))
    props.put(ProducerConfig.BATCH_SIZE_CONFIG, Integer.valueOf(16384))
    props.put(ProducerConfig.LINGER_MS_CONFIG, Integer.valueOf(1))
    props.put(ProducerConfig.BUFFER_MEMORY_CONFIG, Integer.valueOf(33554432))
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer")
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer")
    props.put("security.protocol", "SASL_PLAINTEXT")
    //service.name填写kafka集群配置(server.properties)中对应的值
    props.put("sasl.kerberos.service.name", "kafka")
    props.put("sasl.mechanisms", "GSSAPI")


    val producer = new KafkaProducer[String, String](props)
    var i = 10000
    while (i > 0) {
      println(i)
      producer.send(new ProducerRecord[String, String]("acl1", Integer.toString(i), Integer.toString(i)),new Callback {
        override def onCompletion(metadata: RecordMetadata, exception: Exception): Unit = {
          exception.printStackTrace()
        }
      })
      i = i - 1
      Thread.sleep(100)
    }
    producer.close()
  }
}
```

producer_jaas.conf

```
KafkaClient {
  com.sun.security.auth.module.Krb5LoginModule required
  useKeyTab=true
  storeKey=true
  keyTab="D:/IdeaProjects/kafka-acl/kerberos/producer.keytab"
  principal="producer/vrv145@VRV.COM.CN"
  useTicketCache=true
  debug=true;
};
```

> 错误
> Client Principal = producer/vrv145@VRV.COM.CN
Server Principal = producer/vrv145@VRV.COM.CN <=应该是kafka/vrv145@VRV.COM.CN
Session Key = EncryptionKey: keyType=18 keyBytes (hex dump)=
0000: 48 75 42 26 77 D6 46 D3   27 38 D4 DD E2 FB B4 45  HuB&w.F.'8.....E
0010: 57 AC 5A 9F 06 15 A8 05   81 A4 FC 8B E8 0F C6 81  W.Z.............
> Server Principal的值应该对应kafka集群中sasl.kerberos.service.name配置的名称

## consumer编程

```
object Consumer {

  System.setProperty("java.security.krb5.conf",
    "D:\\IdeaProjects\\kafka-acl\\kerberos\\krb5.conf")
  System.setProperty("java.security.auth.login.config",
    "D:\\IdeaProjects\\kafka-acl\\kerberos\\consumer_jaas.conf")
  System.setProperty("javax.security.auth.useSubjectCredsOnly", "true")
  System.setProperty("sun.security.krb5.debug", "true")

  def main(args: Array[String]): Unit = {
    val props = new Properties
    props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "vrv145:9092")
    props.put(ConsumerConfig.GROUP_ID_CONFIG, "test")
    props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true")
    props.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, "1000")
    props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer")
    props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer")
    props.put("security.protocol", "SASL_PLAINTEXT")
    //填写kafka集群配置(server.properties)中对应的值
    props.put("sasl.kerberos.service.name", "kafka")
    props.put("sasl.mechanisms", "GSSAPI")
    val consumer = new KafkaConsumer[String, String](props)
    consumer.subscribe(util.Arrays.asList("acl1"))
    while (true) {
      consumer.poll(100).foreach(record => {
        printf("offset = %d, key = %s, value = %s%n", record.offset(), record.key(), record.value())
      })
    }
  }
}
```

consumer_jaas.conf

```
KafkaClient {
  com.sun.security.auth.module.Krb5LoginModule required
  useKeyTab=true
  storeKey=true
  keyTab="D:/IdeaProjects/kafka-acl/kerberos/consumer.keytab"
  principal="consumer/vrv145@VRV.COM.CN"
  useTicketCache=true
  debug=true;
};
```

## kafka ACL权限配置

- 启用配置,添加超级用户,修改config/server.properties

```
authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer
super.users=User:kafka(此处kafka这个值对应service.name的值)
```

- 启用配置后，默认所有未添加权限的producer和consumer无法访问kafka，修改config/server.properties
可以默认全部可访问kafka

```
allow.everyone.if.no.acl.found=true
```

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

```
bin/kafka-acls.sh --list --authorizer-properties zookeeper.connect=localhost:2181
```

- 添加producer权限

  - 指定principal可访问

  ```
  bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:producer --operation Read --operation Write --topic acl1
  ```

 - 指定ip可访问,--allow-host的值只能为ip

 ```
 bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-host 192.168.118.139 --allow-principal User:* --operation Read --operation Write --topic acl1
 ```

- 添加consumer权限

  - 指定principal和group id可访问
  
  ```
  bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:consumer --consumer --group-test --topic acl1
  ```

## 其他

- sasl.jaas.config动态配置格式

```
com.sun.security.auth.module.Krb5LoginModule required useKeyTab=true storeKey=true keyTab="D:/IdeaProjects/git/kafka-manager/kerberos/kmanager.keytab" principal="kmanager/vrv145@VRV.COM.CN" useTicketCache=false serviceName=kmanager debug=false;
```