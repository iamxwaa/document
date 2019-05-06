# search guard 安装

----------

## 安装

- 在线安装:
  - 执行以下命令

   ```shell
   bin/elasticsearch-plugin install -b com.floragunn:search-guard-6:<version>
   ```

- 离线安装:
  - 下载es对应版本 [search guard](https://docs.search-guard.com/latest/search-guard-versions "search guard")
 
  - 执行以下命令
   
   ```shell
   bin/elasticsearch-plugin install -b file:///path/to/search-guard-6-<version>.zip
   ```

## 生成TLS证书

- 下载search guard提供的证书生成工具[search-guard-tlstool-1.5.zip](https://search.maven.org/search?q=a:search-guard-tlstool)

- 该工具可用来做以下配置
  
  - Generating Root and Intermediate CAs
  
  - Generating Node, Client and Admin certificates
  
  - Generating CSRs
  
  - Validating certificates

- 生成证书

  - 将压缩包放到es/plugins/search-guard-6下

  - 解压缩

   ```shell
   unzip search-guard-tlstool-1.5.zip
   ```

  - tools/sgtlstool.sh配置说明详见[表1](#table1)

  - 复制而配置模板

   ```shell
   cp search-guard-6/config/template.yml search-guard-6/config/tlsconfig.yml
   ```
  
  - 修改tlsconfig.yml配置,详见[表2](#table2)
  
  - 生成证书
  
   ```shell
   cd search-guard-6/tools
   ./sgtlstool.sh -c ../config/tlsconfig.yml -ca -crt
   ```

  - 在search-guard-6/tools/out文件夹下可以找到生成的证书相关文件
    - client-certificates.readme
    - root-ca.key //Private key of the Root CA
    - root-ca.pem //Root certificate
    - signing-ca.key
    - signing-ca.pem
    - vrv218_client.key
    - vrv218_client.pem
    - vrv218_node_elasticsearch_config_snippet.yml
    - vrv218_node_http.key
    - vrv218_node_http.pem
    - vrv218_node.key
    - vrv218_node.pem

### 配置elasticsearch

- 将生成的文件复制到es/config文件夹下

```shell
mv out/* ../../../config/
```

- 合并vrv218_node_elasticsearch_config_snippet.yml中的配置到es的配置中

```shell
cat vrv218_node_elasticsearch_config_snippet.yml >> elasticsearch.yml
```

- 关闭search guard企业版功能

```shell
echo searchguard.enterprise_modules_enabled: false >> elasticsearch.yml
```

- 启动sgadmin

```shell
cd search-guard-6/tools
./sgadmin.sh 
-cd ../sgconfig/  #search guard配置文件目录
-icl #忽略集群名称
-nhnv #关闭hostname验证
-cacert ../../../config/root-ca.pem 
-cert ../../../config/vrv218_client.pem #配置的admin所生成证书文件
-key ../../../config/vrv218_client.key #配置admin所生成的证书私钥
-p 9330 #es tcp端口
-keypass 123456 #因为tlsconfig.yml配置了密码,所以这里指定配置密码
```

输出以下信息表示成功,后续访问es需要使用**https**协议。
> 修改elasticsearch.yml，设置searchguard.ssl.http.enabled: false可以关闭https访问

```shell
Search Guard Admin v6
Will connect to localhost:9330 ... done
ES Config path is not set
Open SSL not available (this is not an error, we simply fallback to built-in JDK SSL) because of java.lang.ClassNotFoundException: io.netty.internal.tcnative.SSL
No config directory, key- and truststore files are resolved absolutely
AES-256 not supported, max key length for AES is 128 bit. (That is not an issue, it just limits possible encryption strength. To enable AES 256 install 'Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files')
TLS Transport Client Provider : JDK
TLS Transport Server Provider : JDK
TLS HTTP Provider             : null
Enabled TLS protocols for transport layer : [TLSv1.2, TLSv1.1]
Enabled TLS protocols for HTTP layer      : [TLSv1.2, TLSv1.1]
Clustername: elasticsearch
no modules loaded
loaded plugin [com.floragunn.searchguard.SearchGuardPlugin]
loaded plugin [org.elasticsearch.transport.Netty4Plugin]
Elasticsearch Version: 6.1.3
Search Guard Version: 6.1.3-22.3
Connected as CN=vrv218_client.ca.vrv.com,OU=CA,O=vrv Com\, Inc.,DC=vrv,DC=Com
Contacting elasticsearch cluster 'elasticsearch' and wait for YELLOW clusterstate ...
Clustername: test-xw6
Clusterstate: GREEN
Number of nodes: 1
Number of data nodes: 1
searchguard index does not exists, attempt to create it ... done (0-all replicas)
Populate config from /data/xw/elasticsearch-6.1.3/plugins/search-guard-6/sgconfig
Will update 'sg/config' with ../sgconfig/sg_config.yml 
   SUCC: Configuration for 'config' created or updated
Will update 'sg/roles' with ../sgconfig/sg_roles.yml 
   SUCC: Configuration for 'roles' created or updated
Will update 'sg/rolesmapping' with ../sgconfig/sg_roles_mapping.yml 
   SUCC: Configuration for 'rolesmapping' created or updated
Will update 'sg/internalusers' with ../sgconfig/sg_internal_users.yml 
   SUCC: Configuration for 'internalusers' created or updated
Will update 'sg/actiongroups' with ../sgconfig/sg_action_groups.yml 
   SUCC: Configuration for 'actiongroups' created or updated
Done with success
```

- 访问 https://192.168.119.218:9200 会提示输入账号密码,输入admin/admin即可

## 权限配置

- 创建账号

  - 使用search-guard-6/tools/hash.sh生成密码

   ```shell
   ./hash.sh -p 123456
   $2y$12$gFHRiNGzli7HEhK1J56FwebOupUX97reBtb4hHXYXB9rTPSRACay6
   ```
  
  - 修改search-guard-6/sgconfig/sg_internal_users.yml

   ```shell
      #账号
      vrv218:
      readonly: true
      #填写hash.sh生成的密码123456
      hash: $2y$12$gFHRiNGzli7HEhK1J56FwebOupUX97reBtb4hHXYXB9rTPSRACay6
      roles: //配置角色
         - admin
   ```

  - 重新执行sgadmin.sh更新配置

- 配置角色

   ```shell
   ...
   ```

## 附录

### table1

Name|	Description
--|--
-c,–config|	Relative or absolute path to the configuration file. Required.
-t,–target|	Relative or absolute path to the output directory. Optional, default: out
-v,–verbose|	Enable detailed output, default: false
-f,–force|	Force certificate generation despite of validation errors. default: false
-o,–overwrite|	Overwrite existing node-, client and admin certificates if they are already present. default: false
-ca,–create-ca|	Create new Root and Intermediate CAs
-crt,–create-cert|	Create certificates using an existing or newly created local certificate authority

### table2

```yml
###
### Self-generated certificate authority
### 
# 
# If you want to create a new certificate authority, you must specify its parameters here. 
# You can skip this section if you only want to create CSRs
#
ca:
   root:
      # The distinguished name of this CA. You must specify a distinguished name.
      # example: dn: CN=root.ca.example.com,OU=CA,O=Example Com\, Inc.,DC=example,DC=com
      dn: CN=root.ca.vrv.com,OU=CA,O=vrv Com\, Inc.,DC=vrv,DC=Com

      # The size of the generated key in bits
      keysize: 2048
      
      # The validity of the generated certificate in days from now
      validityDays: 3650
      
      # Password for private key
      #   Possible values: 
      #   - auto: automatically generated password, returned in config output; 
      #   - none: unencrypted private key; 
      #   - other values: other values are used directly as password   
      pkPassword: 123456 
      
      # The name of the generated files can be changed here
      file: root-ca.pem
      
      # If you have a certificate revocation list, you can specify its distribution points here
      # crlDistributionPoints: URI:https://raw.githubusercontent.com/floragunncom/unittest-assets/master/revoked.crl
       
   # If you want to use an intermediate certificate as signing certificate,
   # please specify its parameters here. This is optional. If you remove this section,
   # the root certificate will be used for signing.   
   intermediate:
      # The distinguished name of this CA. You must specify a distinguished name.
      # example: dn: CN=root.ca.example.com,OU=CA,O=Example Com\, Inc.,DC=example,DC=com
      dn: CN=root.ca.vrv.com,OU=CA,O=vrv Com\, Inc.,DC=vrv,DC=Com

      # The size of the generated key in bits
      keysize: 2048
      
      # The validity of the generated certificate in days from now
      validityDays: 3650
      
      # Password for private key  
      pkPassword: 123456 
      
      # The name of the generated files can be changed here
      file: signing-ca.pem
      
      # If you have a certificate revocation list, you can specify its distribution points here
      # crlDistributionPoints: URI:https://raw.githubusercontent.com/floragunncom/unittest-assets/master/revoked.crl

### 
### Default values and global settings
###
defaults:

      # The validity of the generated certificate in days from now
      validityDays: 3650 
      
      # Password for private key
      #   Possible values: 
      #   - auto: automatically generated password, returned in config output; 
      #   - none: unencrypted private key; 
      #   - other values: other values are used directly as password   
      pkPassword: 123456      

      # Specifies to recognize legitimate nodes by the distinguished names
      # of the certificates. This can be a list of DNs, which can contain wildcards.
      # Furthermore, it is possible to specify regular expressions by
      # enclosing the DN in //. 
      # Specification of this is optional. The tool will always include
      # the DNs of the nodes specified in the nodes section.
      # 
      # Examples:      
      # - "CN=*.example.com,OU=Ops,O=Example Com\\, Inc.,DC=example,DC=com"
      # - 'CN=node.other.com,OU=SSL,O=Test,L=Test,C=DE'
      # - 'CN=*.example.com,OU=SSL,O=Test,L=Test,C=DE'
      # - 'CN=elk-devcluster*'
      # - '/CN=.*regex/' 

      # nodesDn:

      # If you want to use OIDs to mark legitimate node certificates, 
      # the OID can be included in the certificates by specifying the following
      # attribute
      
      # nodeOid: "1.2.3.4.5.5"
      
      # The length of auto generated passwords
      generatedPasswordLength: 12
      
      # Set this to true in order to generate config and certificates for 
      # the HTTP interface of nodes
      httpsEnabled: true
      
      # Set this to true in order to re-use the node transport certificates
      # for the HTTP interfaces. Only recognized if httpsEnabled is true
      
      # reuseTransportCertificatesForHttp: false
      
      # Set this to true to enable hostname verification
      #verifyHostnames: false
      
      # Set this to true to resolve hostnames
      #resolveHostnames: false
      
      
###
### Nodes
###
#
# Specify the nodes of your ES cluster here
#
nodes:
    # The node name is just used as name of the generated files
  - name: vrv218_node

    # The distinguished name of this node
    dn: CN=vrv218_node.ca.vrv.com,OU=CA,O=vrv Com\, Inc.,DC=vrv,DC=Com
 
    # DNS names of this node. Several names can be specified as list
       
    # dns: 
    # - node1.example.com
    # - node1.exampleinc.com
    
    # The IP addresses of this node. Several addresses can be specified as list
    
    ip: 192.168.119.218
    
    # If you want to override the keysize, pkPassword or validityDays values from
    # the defaults, just specify them here.
    
###
### Clients
###
#
# Specify the clients that shall access your ES cluster with certificate authentication here
#
# At least one client must be an admin user (i.e., a super-user). Admin users can
# be specified with the attribute admin: true    
#    
clients:
    # The client name is just used as name of the generated files
  - name: vrv218_client
  
    # The distinguished name of the client
    dn: CN=vrv218_client.ca.vrv.com,OU=CA,O=vrv Com\, Inc.,DC=vrv,DC=Com
    
    # To mark the client as super-user
    admin: true
    
    # If you want to override the keysize, pkPassword or validityDays values from
    # the defaults, just specify them here.    
 
```