##安装清单
安装包|说明
-|-
docker|包含mysql数据库
packge|包含相关依赖rpm
repo|yum源配置文件
start|启动相关脚本
usr|docker-compose安装文件
ambari.tar|ambari/mysql/httpd的镜像
docker-ce-17.09.1.ce-1.el7.centos.x86_64.rpm|docker安装包
www.tar|yum所需的镜像文件

##目录结构
	├─docker
	│  ├─ambari
	│  │  └─ssh
	│  └─mysql
	│      ├─conf
	│      ├─data
	│      │  ├─ambari
	│      │  ├─mysql
	│      │  └─performance_schema
	│      └─logs
	├─pakage
	│  ├─ambari-postgresql
	│  ├─docker
	│  ├─hdfs-snappy-devel
	│  └─metrics-python
	├─repo
	├─start
	└─usr
	    └─local
	        └─bin
##安装步骤
假设3台主机

host|ip|说明
-|-|-
vrv145|192.168.118.145|安装docker
vrv147|192.168.118.147|部署hadoop等
vrv148|192.168.118.148|部署hadoop等

1. 复制所有安装包到vrv145 /root/docker目录下
2. 在vrv145安装docker
 - 安装docker依赖，/packe/docker下为docker所需依赖包
	 	
			/package/docker
	 		rpm -ivh -U ./* 
 - 安装docker

			rpm -ivh /root/docker/docker-- ce-17.09.1.ce-1.el7.centos.x86_64.rpm
 - 安装docker-compose
 
			cp /root/docker/usr/local/bin/docker-compose /usr/local/bin
3. 输入`docker -v`查看是否安装成功
		Docker version 17.09.1-ce, build 19e2cf6
4. 解压www.tar到/iso目录下
5. 根据需要安装pakcge下文件
6. 加载离线镜像,输入`docker load -i /root/docker/ambari.tar`
7. 输入`docker images`查看镜像是否加载成功

		192.168.118.145:5000/amabri-wh          7                   36d3302042d7        31 hours ago        1.95GB
		192.168.118.145:5000/httpd-wh           latest              87cdd466ede4        2 days ago          177MB
		192.168.118.145:5000/mysql-wh           5.6                 b4b3b29bf65a        2 days ago          256MB
8. 复制yum配置到所有节点

		scp /root/docker/repo/* root@vrv145/etc/yum.repo.d/
		scp /root/docker/repo/* root@vrv147/etc/yum.repo.d/
		scp /root/docker/repo/* root@vrv148/etc/yum.repo.d/
9. 所有节点hosts添加

		192.168.1118.145 mysql
		192.168.1118.145 httpd
10. 在vrv145启动httpd和mysql

		docker-compose -f /root/docker/start/docker-compose.yml up -d

    输入`docker ps`查看启动情况

		e13ddf66ee83        192.168.118.145:5000/httpd-wh                  "httpd-foreground"       27 hours ago        Up 27 hours             0.0.0.0:18080->80/tcp    docker_httpd_1
		b7f850b641d0        192.168.118.145:5000/mysql-wh:5.6              "docker-entrypoint..."   27 hours ago        Up 27 hours             0.0.0.0:3306->3306/tcp   docker_mysql_1
11. 浏览器输入192.168.118.145:18080可以查看yum源的目录
12. 通过192.168.118.145:3306可以连接数据(不需要再建amabri的数据以及相关权限配置,docker中已经建立完毕)
13. 所有节点执行以下命令更新yum数据源

		yum clean all
		yum repolist
14. 启动amabri服务镜像
 - 修改/root/docker/start/ambari-init.sh中的ip为192.168.118.145
 - 修改完毕后启动服务/root/docker/start/ambari-init.sh(第一次使用ambari-init.sh启动,后面使用ambari-start.sh启动)
 - 查看启动情况 
 			
			docker ps
			f69ff02c6170        192.168.118.145:5000/amabri-wh:7               "/data/start.sh"         4 seconds ago       Up 2 seconds                                               ambari-server
15. 免秘钥登录
 - 进入ambari镜像内
 
			docker exec -it f69ff02c6170 bash
 - 输入 ssh-keygen
 - cd /root/.ssh
 - cat id_rsa.pub >> authorized_keys 
 - 将生产的秘钥scp出来，放到vrv147,vrv148的/root/.ssh目录下
16. 浏览器输入192.168.118.145:8080即可看到amabri的部署界面