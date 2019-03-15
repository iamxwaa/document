#!/bin/bash
base="/root/docker/"
iso="/iso/"
echo -e "\n###################################\n"
mkdir -v $base
mkdir -v $iso
chmod 755 $base
chmod 755 $iso
echo -e "\n###################################\n"
\cp -vr docker/mysql/ $base/
echo -e "\n###################################\n"
rpm -ivh package/jdk-8u131-linux-x64.rpm
yum localinstall package/docker/*.rpm
rpm -ivh package/ambari-postgresql/*.rpm
rpm -ivh package/hdfs-snappy-devel/*.rpm
rpm -ivh package/metrics-python/*.rpm
echo -e "\n###################################\n"
\cp -vr repo/* /etc/yum.repos.d/
echo -e "\n###################################\n"
tar -xzvf www.tar -C $iso
echo -e "\n###################################\n"
chmod 755 docker-ce-17.09.1.ce-1.el7.centos.x86_64.rpm
rpm -ivh docker-ce-17.09.1.ce-1.el7.centos.x86_64.rpm
\cp -v usr/local/bin/docker-compose /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose
echo -e "\n###################################\n"
docker -v
systemctl start docker
docker load -i ambari.tar
docker images
echo "###################################"
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=18080/tcp --permanent
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-port=8440/tcp --permanent
firewall-cmd --zone=public --add-port=8441/tcp --permanent
firewall-cmd --reload
echo -e "\n###################################\n"
chmod 755 start/all-start.sh