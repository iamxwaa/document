# zabbix

--------

- 安装zabbix repo

```bash
rpm -Uvh https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
```

- 安装server和agent

```bash
yum clean all
yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-agent
```

- 创建zabbix数据库及账号

```bash
mysql -uroot -p

mysql> create database zabbix character set utf8 collate utf8_bin;
mysql> grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
mysql> quit;
```

- 初始化数据库

```bash
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
```

- 修改zabbix-server配置

```bash
vi /etc/zabbix/zabbix_server.conf
```

- 修改时区

```bash
vi /etc/httpd/conf.d/zabbix.conf

# php_value date.timezone Europe/Riga 改为 php_value date.timezone Asia/Shanghai
```

- 启动agent和server

```bash
systemctl restart zabbix-server zabbix-agent httpd
```

- 访问页面地址

<http://localhost/zabbix>
