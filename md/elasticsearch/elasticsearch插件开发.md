# elasticsearch 插件开发

## 插件类型

- 自定义配置读取
- 自定义解析脚本
- 自定义数据类型
- http请求处理
- 查询数据处理
- 安全控制
- ...

参考样例

<https://github.com/elastic/elasticsearch/tree/master/plugins/examples>

## 插件开发

elasticsearch 5.x以后的版本

### 插件包结构

```bash
elasticsearch-flume-avro-plugin-6x-6.1.3_1.0.zip
|____elasticsearch <-- 文件夹名称固定为elasticsearch
     |____   <arbitrary name1>.jar <-- 插件jar
     |____   ...
     |____   <arbitrary nameN>.jar <-- 其他依赖包
     |____   plugin-descriptor.properties <-- 插件描述文件
     |____   plugin-security.policy <-- 权限描述文件
```

### plugin-descriptor.properties 说明

```properties
#插件版本与es版本无关
version=6.1.3_1.0-SNAPSHOT
#es版本,版本不对应不能安装
elasticsearch.version=6.1.3
#java版本
java.version=1.8
#插件名称
name=flume-avro
#插件描述
description=Export index with flume avro agent
#插件入口
classname=org.knirxot.flume.FlumeAvroPlugin
```

### plugin-security.policy 说明

插件运行时需要一些权限,配置可参考java.policy

```properties
grant {
  permission javax.management.MBeanServerPermission "createMBeanServer";
  permission javax.management.MBeanServerPermission "findMBeanServer";
  permission javax.management.MBeanServerPermission "newMBeanServer";
  permission javax.management.MBeanServerPermission "releaseMBeanServer";
  permission javax.management.MBeanPermission "*", "registerMBean";
  permission javax.management.MBeanPermission "*", "queryMBeans";
  permission javax.management.MBeanPermission "*", "unregisterMBean";
  permission javax.management.MBeanTrustPermission "register";
  permission java.lang.reflect.ReflectPermission "suppressAccessChecks";
  permission java.lang.RuntimePermission "accessDeclaredMembers";
  permission java.lang.RuntimePermission "shutdownHooks";
  permission java.lang.RuntimePermission "getFileSystemAttributes";
  permission java.io.FilePermission "<<ALL FILES>>", "read,write";
  permission java.net.SocketPermission "*", "connect,resolve";
};
```

### 开发

- FlumeAvroPlugin.scala

```scala
class FlumeAvroPlugin extends Plugin with ActionPlugin {
  override def getRestHandlers(settings: Settings,
                               restController: RestController,
                               clusterSettings: ClusterSettings,
                               indexScopedSettings: IndexScopedSettings,
                               settingsFilter: SettingsFilter,
                               indexNameExpressionResolver: IndexNameExpressionResolver,
                               nodesInCluster: Supplier[DiscoveryNodes]): util.List[RestHandler] = {
    val list = new util.ArrayList[RestHandler]()
    list.add(new FlumeAvroPageHandler(settings, restController))
    list.add(new FlumeAvroRestHandler(settings, restController))
    list.add(new FlumeAvroResourceHandler(settings, restController))
    list
  }
}
```

- FlumeAvroBaseHandler.java

BaseRestHandler中有构造参数为final类型,scala无法继承实现,因此改为java编写

```java
public abstract class FlumeAvroBaseHandler extends BaseRestHandler {
    private final RestController restController;

    protected FlumeAvroBaseHandler(Settings settings, RestController restController) {
        super(settings);
        this.restController = restController;
    }

    /**
     * es会对请求参数做校验,所以要重新获取参数
     *
     * @param request
     * @return
     */
    protected Map<String, String> buildParamMap(RestRequest request) {
        Map<String, String> params = new HashMap<>(request.params().size());
        request.params().forEach((k, v) -> {
            request.param(k);
            params.put(k, v);
        });
        return params;
    }

    protected void registerHandler(String method, String path) {
        logger.info("regist " + method + "#" + path + "#" + this.getClass().getSimpleName());
        restController.registerHandler(RestRequest.Method.valueOf(method), path, this);
    }

    @Override
    public String getName() {
        return this.getClass().getSimpleName();
    }
}
```

- FlumeAvroPageHandler.java

```java
public class FlumeAvroPageHandler extends FlumeAvroBaseHandler {

    protected FlumeAvroPageHandler(Settings settings, RestController restController) {
        super(settings, restController);
        registerHandler("GET", "/_flume");
    }

    @Override
    protected RestChannelConsumer prepareRequest(RestRequest request, NodeClient client) throws IOException {
        return channel -> channel.sendResponse(new PageResponse(request));
    }
}
```

### 安装

```bash
bin/elasticsearch-plugin install file:///path/to/your/plugin
```

- 其他命令

    ```bash
    #查看安装的插件
    bin/elasticsearch-plugin list
    #卸载插件
    bin/elasticsearch-plugin remove 插件名称
    ```
