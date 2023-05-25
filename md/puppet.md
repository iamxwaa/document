# puppet安装使用

Puppet 是 Linux、Unix 和 Windows 系统的自动管理引擎，它根据集中式规范执行管理任务（例如添加用户、安装软件包和更新服务器配置）。

Puppet 的简单陈述规范语言的能力提供了强大的 classing 制定了主机之间的相似之处，同时使他们能够提供尽可能具体的必要的，它依赖的先决条件和对象之间的关系清楚和明确。

## 配置puppet yum仓库

- [仓库地址][yum]

```bash
wget http://yum.puppet.com/puppet6-release-el-7.noarch.rpm

rpm -Uvh puppet6-release-el-7.noarch.rpm

yum repolist
```

## 安装

- 主机列表

hostname|ip|备注
---|---|---
bigtop|192.168.122.204|server、bigtop
puppet1|192.168.122.205|agent
puppet2|192.168.122.206|agent

- 在server节点安装puppet server

```bash
#安装
yum install puppetserver -y
#启动
systemctl start puppetserver
#验证
#exec bash
puppetserver --version
```

- 在agent节点安装puppet agent

```bash
#安装
yum install puppet-agent -y
#验证
#exec bash
puppet --version
```

- 配置puppet agent

```bash
#设置puppet server地址
puppet config set server bigtop --section main
```

- 配置puppet agent认证

```bash
#各个agent节点执行
puppet ssl bootstrap
#server节点生成对应agnet的证书
puppetserver ca sign --certname <agent hostname>
#各个agent节点再次执行验证结果
puppet ssl bootstrap
#测试agent是否与server联通
puppet agent -t
```

[yum]: http://yum.puppet.com/
