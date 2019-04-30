# CDH 安装

---------

## 下载

- 下载CDH Manager
  <http://archive.cloudera.com/cm5/cm/5/>
- 下载组件包
  <http://archive.cloudera.com/cdh5/parcels/latest/>

## 准备环境

ip|hostname|remark
--|--|--
192.168.118.145|vrv145|master
192.168.118.147|vrv147|slave
192.168.118.148|vrv148|slave

- 每台机器安装jdk

- master节点安装mysql

  - 创建以下数据库

  ```sql
  create database hive DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
  create database oozie DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
  create database amon DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
  create database hue DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
  create database cm DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
  ```

- 每台机器配置免秘钥登录

  - 每台机器执行

  ```shell
  ssh-keygen
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  ```

  - 将每台机器生成的authorized_keys合并到一个authorized_keys中

  - 复制合并后的authorized_keys到每台机器上
  
- /etc/hosts写入

```shell
192.168.118.145 vrv145
192.168.118.147 vrv147
192.168.118.148 vrv148
```

- /etc/hostname配置对应的hostname

## 解压安装

- cloudera manager的目录默认位置在/opt下

- 解压：tar xzvf cloudera-manager*.tar.gz

- 将解压后的cm-5.15.1和cloudera目录放到/opt目录下

- 复制mysql-connector-java-*.jar到目录/usr/share/java和/opt/cm-5.15.1/share/cmf/lib/并改名成mysql-connector-java.jar

- 复制Agent到其他所有节点：

```shell
scp -r /opt/cm-5.15.1 root@vrv147:/opt/
scp -r /opt/cm-5.15.1 root@vrv148:/opt/
```

- 准备Parcels，用以安装CDH5

- 将CHD5相关的Parcel包放到主节点的/opt/cloudera/parcel-repo/目录中

- 相关的文件如下：

  - CDH-5.15.1-1.cdh5.15.1.p0.34-el6.parcel

  - CDH-5.15.1-1.cdh5.15.1.p0.34-el6.parcel.sha1#复制后,后缀sha1改为sha
  
  - manifest.json

- 创建用户cloudera-scm,每台机器上执行

```shell
useradd --system --no-create-home --shell=/bin/false --comment "Cloudera SCM User" cloudera-scm
```

- master节点，修改/opt/cm-5.15.1/etc/cloudera-scm-agent/config.ini中的server_host为主节点的主机名:vrv145

- master节点，初始化数据库

```shell
/opt/cm-5.15.1/share/cmf/schema/scm_prepare_database.sh -h vrv145 --scm-host vrv145 mysql cm root 123456
```

## 启动

- master节点执行

```shell
/opt/cm-5.15.1/etc/init.d/cloudera-scm-server start
```

- 所有节点

```shell
/opt/cm-5.15.1/etc/init.d/cloudera-scm-agent start
```