#!/bin/bash
mysql_ip=192.168.137.2
httpd_ip=192.168.137.2
image=192.168.118.145:5000/amabri-wh:7
docker run -d --name ambari-server --add-host mysql:$mysql_ip --add-host httpd:$httpd_ip --network=host $image /data/start.sh