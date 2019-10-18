# ambari 2.7 服务集成准备

---------

## 环境及安装包

- 系统 CentOS 7
- Java JDK 1.8 以上
  > jdk1.8.0_20.tar.gz
- Mysql 数据库
  > MySQL-client-5.5.50-1.linux2.6.x86_64.rpm
MySQL-server-5.5.50-1.linux2.6.x86_64.rpm
- 连接mysql的jar包  
  > mysql-connector-java-5.1.23.jar
- httpd 服务
  > httpd-tools-2.4.6-88.el7.centos.x86_64.rpm
httpd-2.4.6-88.el7.centos.x86_64.rpm
- ambari 相关包
  > 根据 linux arch 版本下载对应版本编译的ambari,此处下载的是**x86**版本,官网默认是**ppc64le**

  名称|说明|备注
  ---|---|---
  ambari|ambari 2.7 的安装包|<http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.1.0/ambari-2.7.1.0-centos7.tar.gz>
  HDP|HDP 3.0 组件|<http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.0.1.0/HDP-3.0.1.0-centos7-rpm.tar.gz>
  HDP-GPL|-|<http://public-repo-1.hortonworks.com/HDP-GPL/centos7/3.x/updates/3.0.1.0/HDP-GPL-3.0.1.0-centos7-gpl.tar.gz>
  HDP-UTILS|-|<http://64.123.28.138/files/80630000008F9217/public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.22/repos/centos7/HDP-UTILS-1.1.0.22-centos7.tar.gz>

## 安装 ambari

- 配置host

```shell
echo public-repo-1.hortonworks.com > /etc/hostname
echo 192.168.118.148 public-repo-1.hortonworks.com >> /etc/hosts
systemctl restart network
```

- 关闭防火墙

```shell
systemctl stop firewalld
systemctl disable firewalld
```

- 配置免秘钥登录

```shell
[root@public-repo-1 html]# ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
43:11:86:d6:06:2f:98:11:e2:72:0b:92:79:71:c0:a9 root@public-repo-1.hortonworks.com
The key's randomart image is:
+--[ RSA 2048]----+
| .+o+..++.       |
| +o+ +ooo.       |
|*.+ o...o        |
|E= .   o         |
|  .     S        |
|         .       |
|                 |
|                 |
|                 |
+-----------------+
[root@public-repo-1 html]# cd ~/.ssh
[root@public-repo-1 .ssh]# ls
id_rsa  id_rsa.pub
[root@public-repo-1 .ssh]# cat id_rsa.pub > authorized_keys
[root@public-repo-1 .ssh]# ssh root@192.168.118.148
The authenticity of host '192.168.118.148 (192.168.118.148)' can't be established.
ECDSA key fingerprint is bd:ad:07:a7:76:dd:4c:79:bf:4f:ca:a6:8a:13:0c:9b.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.118.148' (ECDSA) to the list of known hosts.
Last login: Fri Apr 19 03:39:52 2019 from 192.168.118.139
[root@public-repo-1 ~]# exit
logout
Connection to 192.168.118.148 closed.
[root@public-repo-1 .ssh]# 
```

- 安装 jdk

```shell
cd /data
tar -xvf jdk1.8.0_20.tar.gz
```

- 配置 JAVA_HOME

```shell
vi /etc/profile

export JAVA_HOME=/data/jdk1.8.0_20
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar

source /etc/profile
```

> [root@public-repo-1 data]# java -version 
java version "1.8.0_20"
Java(TM) SE Runtime Environment (build 1.8.0_20-b26)
Java HotSpot(TM) 64-Bit Server VM (build 25.20-b23, mixed mode)
[root@public-repo-1 ~]# echo $JAVA_HOME
/data/jdk1.8.0_20

- 安装 Mysql

```shell
rpm -ivh MySQL-client-5.5.50-1.linux2.6.x86_64.rpm
rpm -ivh MySQL-server-5.5.50-1.linux2.6.x86_64.rpm
```

> mysql和mariadb冲突,卸载maridb
rpm -e --nodeps `rpm -qa | grep mariadb`

- 启动 Mysql

```shell
systemctl start mysql
systemctl enable mysql
```

- 配置 Mysql
设置 root 账号密码

```shell
/usr/bin/mysqladmin -u root password 'root'
```

> [root@public-repo-1 ~]# mysql -uroot -proot
> Welcome to the MySQL monitor.  Commands end with ; or \g.
> Your MySQL connection id is 6
> Server version: 5.5.50 MySQL Community Server (GPL)
>
> Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.
>
> Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.
>
> Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
>
> mysql>

- 安装 httpd

```shell
yum install httpd
systemctl start httpd
systemctl enable httpd
```

- 修改打开文件数

```shell
echo "* soft nofile 65535" >> /etc/security/limits.conf
echo "* hard nofile 65535" >> /etc/security/limits.conf
```

- 配置 ambari yum 源

在 /etc/yum.repos.d 创建 ambari.repo(**文件名不能修改**), 写入以下内容

```shell
[ambari-2.7.1.0]
name=ambari Version - ambari-2.7.1.0
baseurl=http://public-repo-1.hortonworks.com/ambari/centos7/2.7.1.0-169
path=/
enabled=1
gpgcheck=0

[HDP-3.0.1.0]
name=HDP - version-3.0.1.0
baseurl=http://public-repo-1.hortonworks.com/HDP/centos7/3.0.1.0-187
path=/
enabled=1
gpgcheck=0

[HDP-GPL-3.0.1.0]
name=HDP-GPL - version-3.0.1.0
baseurl=http://public-repo-1.hortonworks.com/HDP-GPL/centos7/3.0.1.0-187
path=/
enabled=1
gpgcheck=0

[HDP-UTILS-3.0.1.0]
name=HDP-UTILS - version-3.0.1.0
baseurl=http://public-repo-1.hortonworks.com/HDP-UTILS/centos7/1.1.0.22
path=/
enabled=1
gpgcheck=0
```

将下载的 ambari 的包和 HDP 相关包放在 /var/www/html 下解压

```shell
cd /var/www/html/

tar -xvf HDP-UTILS-1.1.0.22-centos7.tar.gz
tar -xvf HDP-GPL-3.0.1.0-centos7-gpl.tar.gz
tar -xvf HDP-3.0.1.0-centos7-rpm.tar.gz
tar -xvf ambari-2.7.1.0-centos7.tar.gz
```

进入每个解压后的目录,删除里面包含的 html 文件和 *.repo 文件,此时在浏览器查看 ambari.repo 中配置 baseurl
应该可以看见解压后的文件目录

```html
Index of /HDP-UTILS/centos7/1.1.0.22
[ICO]    Name    Last modified    Size    Description
[PARENTDIR]    Parent Directory         -     
[DIR]    RPM-GPG-KEY/    2018-08-13 06:28    -     
[   ]    hdp-utils.repo    2018-08-13 06:28    197     
[DIR]    openblas/    2018-08-13 06:28    -     
[DIR]    repodata/    2018-08-13 06:28    -     
[DIR]    snappy/    2018-08-13 06:28    -    
```

更新 yum 源

```shell
[root@public-repo-1 html]# yum clean all
Loaded plugins: fastestmirror
Cleaning repos: HDP-3.0.1.0 HDP-GPL-3.0.1.0 HDP-UTILS-3.0.1.0 ambari-2.7.1.0 base extras updates
Cleaning up everything
Cleaning up list of fastest mirrors
[root@public-repo-1 html]# yum repolist
Loaded plugins: fastestmirror
HDP-3.0.1.0                                                                  | 2.9 kB  00:00:00     
HDP-GPL-3.0.1.0                                                              | 2.9 kB  00:00:00     
HDP-UTILS-3.0.1.0                                                            | 2.9 kB  00:00:00     
ambari-2.7.1.0                                                               | 2.9 kB  00:00:00     
base                                                                         | 3.6 kB  00:00:00     
extras                                                                       | 3.4 kB  00:00:00     
updates                                                                      | 3.4 kB  00:00:00     
(1/8): HDP-GPL-3.0.1.0/primary_db                                            | 2.9 kB  00:00:00     
(2/8): HDP-3.0.1.0/primary_db                                                |  88 kB  00:00:00     
(3/8): HDP-UTILS-3.0.1.0/primary_db                                          | 8.5 kB  00:00:00     
(4/8): ambari-2.7.1.0/primary_db                                             |  25 kB  00:00:00     
(5/8): base/7/x86_64/group_gz                                                | 166 kB  00:00:00     
(6/8): extras/7/x86_64/primary_db                                            | 188 kB  00:00:00     
(7/8): updates/7/x86_64/primary_db                                           | 3.4 MB  00:00:00     
(8/8): base/7/x86_64/primary_db                                              | 6.0 MB  00:00:00     
Determining fastest mirrors
 * base: mirrors.nju.edu.cn
 * extras: mirrors.njupt.edu.cn
 * updates: mirrors.nju.edu.cn
repo id                                 repo name                                             status
HDP-3.0.1.0                             HDP - version-3.0.1.0                                    197
HDP-GPL-3.0.1.0                         HDP-GPL - version-3.0.1.0                                  4
HDP-UTILS-3.0.1.0                       HDP-UTILS - version-3.0.1.0                               16
ambari-2.7.1.0                          ambari Version - ambari-2.7.1.0                           13
base/7/x86_64                           CentOS-7 - Base                                       10,019
extras/7/x86_64                         CentOS-7 - Extras                                        386
updates/7/x86_64                        CentOS-7 - Updates                                     1,513
repolist: 12,148
[root@public-repo-1 html]# 
```

- 安装 ambari server

```shell
yum install ambari-server
```

- 配置 ambari server
  - 数据库配置

    ```sql
    CREATE USER 'ambari'@'%' IDENTIFIED BY 'ambari';
    GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%';
    CREATE USER 'ambari'@'localhost' IDENTIFIED BY 'ambari';
    GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'localhost';
    FLUSH PRIVILEGES;

    mysql -uambari -pambari

    CREATE DATABASE ambari;
    USE ambari;
    SOURCE /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql;
    ```

  - mysql 连接 jar 包配置

    ```shell
    cp /data/mysql-connector-java-5.1.23.jar /usr/share/java/mysql-connector-java-5.1.23.jar
    ```

  - ambari server 配置

    ```shell
    [root@public-repo-1 ~]# ambari-server setup
    Using python  /usr/bin/python
    Setup ambari-server
    Checking SELinux...
    SELinux status is 'enabled'
    SELinux mode is 'enforcing'
    Temporarily disabling SELinux
    WARNING: SELinux is set to 'permissive' mode and temporarily disabled.
    OK to continue [y/n] (y)? y
    Customize user account for ambari-server daemon [y/n] (n)?    
    Adjusting ambari-server permissions and ownership...
    Checking firewall status...
    WARNING: iptables is running. Confirm the necessary Ambari ports are accessible. Refer to the Ambari documentation for more details on ports.
    OK to continue [y/n] (y)? 
    Checking JDK...
    [1] Oracle JDK 1.8 + Java Cryptography Extension (JCE) Policy Files 8
    [2] Custom JDK
    ==============================================================================
    Enter choice (1): 2
    WARNING: JDK must be installed on all hosts and JAVA_HOME must be valid on all hosts.
    WARNING: JCE Policy files are required for configuring Kerberos security. If you plan to use Kerberos,please make sure JCE Unlimited Strength Jurisdiction Policy Files are valid on all hosts.
    Path to JAVA_HOME: /data/jdk1.8.0_20
    Validating JDK on Ambari Server...done.
    Check JDK version for Ambari Server...
    JDK version found: 8
    Minimum JDK version is 8 for Ambari. Skipping to setup different JDK for Ambari Server.
    Checking GPL software agreement...
    GPL License for LZO: https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
    Enable Ambari Server to download and install GPL Licensed LZO packages [y/n] (n)? 
    Completing setup...
    Configuring database...
    Enter advanced database configuration [y/n] (n)? y
    Configuring database...
    ==============================================================================
    Choose one of the following options:
    [1] - PostgreSQL (Embedded)
    [2] - Oracle
    [3] - MySQL / MariaDB
    [4] - PostgreSQL
    [5] - Microsoft SQL Server (Tech Preview)
    [6] - SQL Anywhere
    [7] - BDB
    ==============================================================================
    Enter choice (1): 3
    Hostname (localhost):
    Port (3306): 
    Database name (ambari): 
    Username (ambari): 
    Enter Database Password (bigdata): 
    Re-enter password: 
    Passwords do not match
    Enter Database Password (bigdata): 
    Re-enter password: 
    Configuring ambari database...
    Enter full path to custom jdbc driver: /usr/share/java/mysql-connector-java-5.1.23.jar
    Configuring remote database connection properties...
    WARNING: Before starting Ambari Server, you must run the following DDL against the database to create the schema: /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql
    Proceed with configuring remote database connection properties [y/n] (y)? y
    Extracting system views...
    ambari-admin-2.7.1.0.169.jar
    ....
    Ambari repo file doesn't contain latest json url, skipping repoinfos modification
    Adjusting ambari-server permissions and ownership...
    Ambari Server 'setup' completed successfully.
    [root@public-repo-1 ~]# 
    ```

- 启动 ambari-server

```shell
ambari-server start
```

## 补充

ambari 涉及到组件的表

- serviceconfigmapping
- clusterconfig
- clusterconfigmapping
- hostcomponentdesiredstate
- hostcomponentstate
- servicecomponentdesiredstate
- servicedesiredstate
- clusterservices
- serviceconfig