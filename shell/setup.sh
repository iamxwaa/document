#!/bin/bash
. ./config.sh

base="/root/docker/install/docker/"

hosts[0]=$host_name:$host_ip
for((i=0;i<${#other_hosts[@]};i++))
do
	hosts[i+1]=${other_hosts[i]}
done
#########################################
len=${#hosts[@]}
p=~/.ssh
t=$(ls ~/.ssh|grep authorized_keys)
if [ "$t" == "" ]
then
	ssh-keygen
	cat $p/id_rsa.pub >> $p/authorized_keys
fi

for((i=0;i<len;i++))
do
	host_ip=${hosts[i]#*:}
	echo "scp ~/.ssh/authorized_keys root@$host_ip://$p/"
	ssh root@$host_ip "mkdir $p/"
	scp ~/.ssh/authorized_keys root@$host_ip://$p/
done

for((i=1;i<len;i++))
do
	host_ip=${hosts[i]#*:}
	host_name=${hosts[j]%:*}
	tp=$(cat $p/authorized_keys|grep root@$host_ip)
	tp+=$(cat $p/authorized_keys|grep root@$host_name)
	if [ "" == "$tp" ]
	then
		ssh root@$host_ip "ssh-keygen"
		echo $(ssh root@$host_ip "cat $p/id_rsa.pub") >> $p/authorized_keys
	fi
done

for((i=1;i<len;i++))
do
	host_ip=${hosts[i]#*:}
	scp ~/.ssh/authorized_keys root@$host_ip://$p/
done

for((i=0;i<len;i++))
do
	host_ip=${hosts[i]#*:}
	for((j=0;j<len;j++))
	do
		host_name2=${hosts[j]%:*}
		host_ip2=${hosts[j]#*:}
		if [ "$host_ip" == "$host_ip2" ]
		then
			echo "ssh root@$host_ip echo $host_name2 > /etc/hostname"
			ssh root@$host_ip "echo $host_name2 > /etc/hostname"
		fi
		tp=$(ssh root@$host_ip "cat /etc/hosts|grep $host_ip2")
		if [ "" == "$tp" ]
		then
			echo "ssh root@$host_ip echo $host_ip2 $host_name2 >> /etc/hosts"
			ssh root@$host_ip "echo $host_ip2 $host_name2 >> /etc/hosts"
		else
			echo "skip echo $host_ip"
		fi
	done
done

for((i=1;i<len;i++))
do
	host_ip=${hosts[i]#*:}
	ssh root@$host_ip "mkdir -p $base/package/"
	scp -r $base/package/ root@$host_ip://$base/
	tp=$(ssh root@$host_ip "rpm -qa | grep openjdk")
	OLD_IFS="$IFS" 
	IFS=" " 
	arr=($tp) 
	IFS="$OLD_IFS" 
	for s in ${arr[@]} 
	do 
		ssh root@$host_ip "rpm -e --nodeps $s"
	done
	ssh root@$host_ip "rpm -ivh $base/package/jdk-8u131-linux-x64.rpm"
	ssh root@$host_ip "rpm -ivh $base/package/ambari-postgresql/*.rpm"
	ssh root@$host_ip "rpm -ivh $base/package/hdfs-snappy-devel/*.rpm"
	ssh root@$host_ip "rpm -ivh $base/package/metrics-python/*.rpm"
done