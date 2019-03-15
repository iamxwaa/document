#!/bin/bash
mysql_ip=192.168.137.2
httpd_ip=192.168.137.2

image=192.168.118.145:5000/amabri-wh:7

name=ambari-server

read opt
echo "aaaa$opt"

function startAmbariServer(){
	a=$(docker ps -a|grep $name|awk '{print $1}')
	b=${a[0]}

	if [ "" != "$b" ];
	then
		docker stop $b
		docker start $b
	else
		docker run -d --name $name --add-host mysql:$mysql_ip --add-host httpd:$httpd_ip --network=host $image /data/start.sh
	fi
}