#!/bin/bash
#
# 将该脚本置于安装包同目录，执行即可
# 安装包列表：
# mysql-community-client-5.7.30-1.el7.x86_64.rpm
# mysql-community-common-5.7.30-1.el7.x86_64.rpm
# mysql-community-devel-5.7.30-1.el7.x86_64.rpm
# mysql-community-libs-5.7.30-1.el7.x86_64.rpm
# mysql-community-server-5.7.30-1.el7.x86_64.rpm
#

base=`dirname $0`
base=`cd $base;pwd`

export MYSQL_PWD=root123456
export DEFAULT_REMOTE_PWD=root123456789

echo Remove mariadb
rpm -e --nodeps `rpm -qa | grep mariadb`

echo install mysql from $base

yum localinstall -y $base/*.rpm
if [ -f "/etc/my.cnf" ];then
    echo "set skip-grant-tables"
    echo "skip-grant-tables" >> /etc/my.cnf
else
    echo "Create /etc/my.cnf"
    touch /etc/my.cnf
    echo "# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
skip-grant-tables
" > /etc/my.cnf
fi

echo start mysql
systemctl start mysqld
sleep 2s

echo 'set root user'
mysql -uroot << EOF
use mysql;
update user set authentication_string=password("$MYSQL_PWD"),password_expired="N" where user='root' and host='localhost';
flush privileges;
EOF

echo "Remove skip-grant-tables"
sed -i 's/^skip-grant-tables//' /etc/my.cnf

echo restart mysql
systemctl restart mysqld
systemctl enable mysqld

echo Grant privileges
mysql -uroot -N << EOF
set global validate_password_policy=0;
CREATE USER 'root2'@'%' IDENTIFIED BY '$DEFAULT_REMOTE_PWD';
GRANT ALL PRIVILEGES ON *.* TO 'root2'@'%';
FLUSH PRIVILEGES;
EOF

echo default account: root, password: $MYSQL_PWD
echo default remote account: root2, password: $DEFAULT_REMOTE_PWD