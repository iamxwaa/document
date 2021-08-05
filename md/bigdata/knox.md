# knox安装使用

## 安装及启动

- amabri直接添加knox服务
- 启动ldap服务
- 启动knox服务
- 通过ambari页面的链接进去knox管理平台

## 问题及处理 

### 默认管理员账号

admin/admin-password

### 页面能打开，进去后菜单无法加载？

浏览器F12查看请求，发现jquery获取不到
手动下载jquery依赖
打开/var/lib/knox/data-3.1.0.0-78/applications/admin-ui/app目录，修改index.html里面引用的文件路径

### 添加修改账号密码

下载[ldap客户端](https://www.ldapsoft.com/downloads74/LdapAdminTool-7.4.x-win-x64-Setup.exe)，可在客户端中直接配置

### knox管理界面进去后过30秒就session超时

amabri 页面打开Advanced knoxsso-topology，添加或修改knoxsso.token.ttl的值（单位毫秒）

```xml
<param>
    <name>knoxsso.token.ttl</name>
    <value>1800000</value>
</param>
```

### 添加服务代理

amabri 页面打开Advanced topology，在改配置中添加服务

```xml
<topology>
    <gateway>
        <provider>
            <role>authentication</role>
            <name>ShiroProvider</name>
            <enabled>true</enabled>
            <param>
                <name>sessionTimeout</name>
                <value>1800</value>
            </param>
            <param>
                <name>main.ldapRealm</name>
                <value>org.apache.hadoop.gateway.shirorealm.KnoxLdapRealm</value>
            </param>
            <param>
                <name>main.ldapRealm.userDnTemplate</name>
                <value>uid={0},ou=people,dc=hadoop,dc=apache,dc=org</value>
            </param>
            <param>
                <name>main.ldapRealm.contextFactory.url</name>
                <value>ldap://{{knox_host_name}}:33389</value>
            </param>
            <param>
                <name>main.ldapRealm.contextFactory.authenticationMechanism</name>
                <value>simple</value>
            </param>
            <param>
                <name>urls./**</name>
                <value>authcBasic</value>
            </param>
        </provider>
        <provider>
            <role>identity-assertion</role>
            <name>Default</name>
            <enabled>true</enabled>
        </provider>
        <provider>
            <role>authorization</role>
            <name>AclsAuthz</name>
            <enabled>true</enabled>
        </provider>
    </gateway>

    <service>
        <role>NAMENODE</role>
        <url>{{namenode_address}}</url>
    </service>

    <service>
        <role>JOBTRACKER</role>
        <url>rpc://{{rm_host}}:{{jt_rpc_port}}</url>
    </service>

    <service>
        <role>WEBHDFS</role>
        {{webhdfs_service_urls}}
    </service>

    <service>
        <role>HDFSUI</role>
        <url>http://xwxw1:50070</url>
        <version>2.7.0</version>
    </service>

    <service>
        <role>WEBHCAT</role>
        <url>http://{{webhcat_server_host}}:{{templeton_port}}/templeton</url>
    </service>

    <service>
        <role>OOZIE</role>
        <url>http://{{oozie_server_host}}:{{oozie_server_port}}/oozie</url>
    </service>

    <service>
        <role>OOZIEUI</role>
        <url>http://{{oozie_server_host}}:{{oozie_server_port}}/oozie/</url>
    </service>


    <service>
        <role>WEBHBASE</role>
        <url>http://{{hbase_master_host}}:{{hbase_master_port}}</url>
    </service>

    <service>
        <role>HIVE</role>
        <url>http://{{hive_server_host}}:{{hive_http_port}}/{{hive_http_path}}</url>
    </service>

    <service>
        <role>RESOURCEMANAGER</role>
        <url>http://{{rm_host}}:{{rm_port}}/ws</url>
    </service>

    <service>
        <role>YARNUI</role>
        <url>http://{{rm_host}}:{{rm_port}}</url>
    </service>

    <service>
        <role>DRUID-COORDINATOR-UI</role>
        {{druid_coordinator_urls}}
    </service>

    <service>
        <role>DRUID-COORDINATOR</role>
        {{druid_coordinator_urls}}
    </service>

    <service>
        <role>DRUID-OVERLORD-UI</role>
        {{druid_overlord_urls}}
    </service>

    <service>
        <role>DRUID-OVERLORD</role>
        {{druid_overlord_urls}}
    </service>

    <service>
        <role>DRUID-ROUTER</role>
        {{druid_router_urls}}
    </service>

    <service>
        <role>DRUID-BROKER</role>
        {{druid_broker_urls}}
    </service>

    <service>
        <role>ZEPPELINUI</role>
        {{zeppelin_ui_urls}}
    </service>

    <service>
        <role>ZEPPELINWS</role>
        {{zeppelin_ws_urls}}
    </service>
</topology>
```
