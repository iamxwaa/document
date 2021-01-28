# spark2.3 读取hive问题处理

- 读取不到hive中的数据库？

去掉spark引用的hive-site.xml中的这段配置

```xml
<property>
    <name>metastore.catalog.default</name>
    <value>spark</value>
</property>
```
 
- spark通过hive读取hbase外连表，报Class Not Found等异常？

手动指定spark.sql.hive.metastore的客户端版本和依赖包路径

```bash
./spark-shell \
--master yarn \
--driver-class-path /data/hiveonhbase/hive-hbase-handler-1.2.1.spark2.jar,/data/hiveonhbase/hbase-server-1.1.2.jar,/data/hiveonhbase/hbase-protocol-1.1.2.jar,/data/hiveonhbase/hbase-common-1.1.2.jar,/data/hiveonhbase/hbase-client-1.1.2.jar,/data/hiveonhbase/metrics-core-2.2.0.jar,/data/hiveonhbase/htrace-core-3.1.0-incubating.jar \
--jars /data/hiveonhbase/hive-hbase-handler-1.2.1.spark2.jar,/data/hiveonhbase/hbase-server-1.1.2.jar,/data/hiveonhbase/hbase-protocol-1.1.2.jar,/data/hiveonhbase/hbase-common-1.1.2.jar,/data/hiveonhbase/hbase-client-1.1.2.jar,/data/hiveonhbase/metrics-core-2.2.0.jar,/data/hiveonhbase/htrace-core-3.1.0-incubating.jar \
--conf spark.sql.hive.metastore.version=3.0 \
--conf spark.sql.hive.metastore.jars=/data/hiveonhbase/*
```
