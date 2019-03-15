#!/bin/bash
. ../config.sh

image=192.168.118.145:5000/amabri-wh:7

name=ambari-server

function startAmbariServer(){
	a=$(docker ps -a|grep $name|awk '{print $1}')
	b=${a[0]}

	if [ "" != "$b" ];
	then
		docker stop $b
		docker start $b
	else
		hosts[0]="$host_name:$host_ip"
		hosts[1]="mysql:$host_ip"
		hosts[2]="httpd:$host_ip"

		ah=""
		for((i=0;i<${#hosts[*]};i++))
		do
			ah+="--add-host ${hosts[i]} "
		done
		for((i=0;i<${#other_hosts[*]};i++))
		do
			ah+="--add-host ${other_hosts[i]} "
		done
		echo "docker run -d --name $name $ah --network=host $image /data/start.sh"
		docker run -d --name $name $ah --network=host $image /data/start.sh
	fi
}

function stopAmbariServer(){
	a=$(docker ps -a|grep $name|awk '{print $1}')
	b=${a[0]}
	if [ "" != "$b" ];
	then
		docker stop $b
	fi
}
echo "========================"
cat /etc/hosts
echo "========================"
echo -e "mysql_ip:$mysql_ip\nhttpd_ip:$httpd_ip\n$host_name:$host_ip"
echo "========================"
echo "[1]: start mysql & httpd"
echo "[2]: start ambari-server"
echo "[3]: stop mysql & httpd"
echo "[4]: stop ambari-server"
echo "[5]: ambari-server logs"
echo "[6]: into ambari-server"
echo "========================"
read -p "please input :" opt

if [ $opt = 1 ];
then
	echo "start mysql & httpd ..."
	docker-compose -f docker-compose.yml up -d
elif [ $opt = 2 ];
then
	echo "start ambari-server ..."
	startAmbariServer
elif [ $opt = 3 ];
then
	echo "stop mysql & httpd ..."
	docker-compose -f docker-compose.yml down
elif [ $opt = 4 ];
then
	echo "stop ambari-server ..."
	stopAmbariServer
elif [ $opt = 5 ];
then
	docker logs -f $name
elif [ $opt = 6 ];
then
	docker exec -it $name bash
else
	echo wrong number "=>" $opt
fi