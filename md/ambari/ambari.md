# ambari安装

1. 创建/data文件夹，放置所有的安装包

2. 配置集群host
 
		vi /etc/hosts
		192.168.119.201 vrv201
		192.168.119.202 vrv202
		192.168.119.203 vrv203
		192.168.119.204 vrv204
		192.168.119.205 vrv205
		192.168.119.206 vrv206
		192.168.119.207 vrv207
		192.168.119.208 vrv208

3. 方便安装，关闭防火墙，根据需要后面开启
		
		systemctl stop firewalld.service;systemctl disable firewalld.service


4. 卸载openjdk

		[root@localhost ~]# rpm -qa | grep java
		java-1.8.0-openjdk-headless-1.8.0.65-3.b17.el7.x86_64
		javapackages-tools-3.4.1-11.el7.noarch
		java-1.8.0-openjdk-1.8.0.65-3.b17.el7.x86_64
		tzdata-java-2015g-1.el7.noarch
		java-1.7.0-openjdk-1.7.0.91-2.6.2.3.el7.x86_64
		java-1.7.0-openjdk-headless-1.7.0.91-2.6.2.3.el7.x86_64
		python-javapackages-3.4.1-11.el7.noarch
		[root@localhost ~]# rpm -e --nodeps java-1.8.0-openjdk-headless-1.8.0.65-3.b17.el7.x86_64
		[root@localhost ~]# rpm -e --nodeps javapackages-tools-3.4.1-11.el7.noarch
		[root@localhost ~]# rpm -e --nodeps java-1.8.0-openjdk-1.8.0.65-3.b17.el7.x86_64
		[root@localhost ~]# rpm -e --nodeps tzdata-java-2015g-1.el7.noarch
		[root@localhost ~]# rpm -e --nodeps java-1.7.0-openjdk-1.7.0.91-2.6.2.3.el7.x86_64
		[root@localhost ~]# rpm -e --nodeps java-1.7.0-openjdk-headless-1.7.0.91-2.6.2.3.el7.x86_64

5. 安装sunjdk
 - tar -xvf /data/jdk1.8.0_20.tar.gz -C /data/
 - 设置java home
 
			vi /etc/profiel
			export  JAVA_HOME=/data/jdk1.8.0_20
			export  JRE_HOME=$JAVA_HOME/jre
			export  CLASSPATH=.:$CLASSPATH:$JAVA_HOME/bin:$JRE_HOME/lib
			export  PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin

 - 配置生效
		 	
			/source /etc/profile

6. 删除mariadb后面换成mysql

		rpm -qa | grep maria
		rpm -e --nodeps mariadb-libs-5.5.44-2.el7.centos.x86_64

7. 安装离线yum源
 - 安装httpd

			[root@localhost httpd]# ls
			apr-1.4.8-3.el7.x86_64.rpm
			apr-util-1.5.2-6.el7.x86_64.rpm
			httpd-2.4.6-40.el7.centos.4.x86_64.rpm
			httpd-tools-2.4.6-40.el7.centos.4.x86_64.rpm
			mailcap-2.1.41-2.el7.noarch.rpm
			[root@localhost httpd]# rpm -ivh ./*.rpm
			warning: ./apr-1.4.8-3.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
			Preparing...                          ################################# [100%]
			Updating / installing...
			   1:apr-1.4.8-3.el7                  ################################# [ 20%]
			   2:apr-util-1.5.2-6.el7             ################################# [ 40%]
			   3:httpd-tools-2.4.6-40.el7.centos.4################################# [ 60%]
			   4:mailcap-2.1.41-2.el7             ################################# [ 80%]
			   5:httpd-2.4.6-40.el7.centos.4      ################################# [100%]

 - 启动httpd
				
			systemctl start httpd.service
 - 设置开机启动

			systemctl enable httpd.service

 - 查看启动状态

			[root@localhost httpd]# systemctl status httpd.service
			● httpd.service - The Apache HTTP Server
			   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
			   Active: active (running) since Thu 2018-02-08 18:08:28 PST; 43s ago
			     Docs: man:httpd(8)
			           man:apachectl(8)
			 Main PID: 11445 (httpd)
			   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
			   CGroup: /system.slice/httpd.service
			           ├─11445 /usr/sbin/httpd -DFOREGROUND
			           ├─11456 /usr/sbin/httpd -DFOREGROUND
			           ├─11457 /usr/sbin/httpd -DFOREGROUND
			           ├─11458 /usr/sbin/httpd -DFOREGROUND
			           ├─11459 /usr/sbin/httpd -DFOREGROUND
			           └─11460 /usr/sbin/httpd -DFOREGROUND

			Feb 08 18:08:28 localhost.localdomain systemd[1]: Starting The Apache HTTP Se....
			Feb 08 18:08:28 localhost.localdomain httpd[11445]: AH00558: httpd: Could not ...
			Feb 08 18:08:28 localhost.localdomain systemd[1]: Started The Apache HTTP Server.
			Hint: Some lines were ellipsized, use -l to show in full.


8. 放置镜像
 - Httpd发布默认目录在/var/www/html。将CentOS-7-x86_64-DVD-1511.iso拷贝到服务器上
 - 将CentOS-7-x86_64-DVD-1511.iso挂载到/var/www/html目录
创建目录mkdir /var/www/html/centos
 - 挂载 mount -o loop /var/www/html/CentOS-7-x86_64-DVD-1511.iso /var/www/html/centos
 - 挂载成功，可访问http://192.168.119.203/centos/查看
 - 移动ambari所需资源mv /data/ambari/*.tar.gz /var/www/html/
			
			cd /var/www/html/
			tar -xvf HDP-UTILS-1.1.0.20-centos7.tar.gz
			tar -xvf HDP-2.4.0.0-centos7-rpm.tar.gz
			tar -xvf ambari-2.2.1.1-centos7.tar.gz


9. 修改该yum仓库地址

		/etc/yum.repos.d/CentOS-Base.repo
		# CentOS-Base.repo
		#
		# The mirror system uses the connecting IP address of the client and the
		# update status of each mirror to pick mirrors that are updated to and
		# geographically close to the client.  You should use this for CentOS updates
		# unless you are manually picking other mirrors.
		#
		# If the mirrorlist= does not work for you, as a fall back you can try the 
		# remarked out baseurl= line instead.
		#
		#
		
		[base]
		name=CentOS-$releasever - Base
		#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
		baseurl=http://192.168.119.203/centos/
		gpgcheck=1
		gpgkey=http://192.168.119.203/centos/RPM-GPG-KEY-CentOS-7
		
		#released updates 
		[updates]
		name=CentOS-$releasever - Updates
		#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates&infra=$infra
		baseurl=http://192.168.119.203/centos/
		gpgcheck=1
		gpgkey=http://192.168.119.203/centos/RPM-GPG-KEY-CentOS-7
		
		#additional packages that may be useful
		[extras]
		name=CentOS-$releasever - Extras
		#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra
		baseurl=http://192.168.119.203/centos/
		gpgcheck=1
		gpgkey=http://192.168.119.203/centos/RPM-GPG-KEY-CentOS-7
		
		#additional packages that extend functionality of existing packages
		[centosplus]
		name=CentOS-$releasever - Plus
		#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus&infra=$infra
		baseurl=http://192.168.119.203/centos/
		gpgcheck=1
		enabled=0
		gpgkey=http://192.168.119.203/centos/RPM-GPG-KEY-CentOS-7


10. 修改打开文件数
		
		vi /etc/security/limits.conf
		* soft nofile 65535 
		* hard nofile 65535 

11. 修改完毕后重启服务器生效


12. 免秘钥登录
 - 每台机器执行ssh-keygen

			[root@vrv203 ~]# cd .ssh
			[root@vrv203 .ssh]# ls
			id_rsa  id_rsa.pub  known_hosts
			[root@vrv203 .ssh]# cat id_rsa.pub > authorized_keys
			[root@vrv203 .ssh]# cat ~/.ssh/id_rsa.pub >> authorized_keys
			[root@vrv203 .ssh]# scp ~/.ssh/authorized_keys root@vrv204://root/.ssh/
			[root@vrv204 .ssh]# cat ~/.ssh/id_rsa.pub >> authorized_keys
			[root@vrv204 .ssh]# scp ~/.ssh/authorized_keys root@vrv205://root/.ssh/
			[root@vrv205 ~]# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
			[root@vrv205 ~]# scp ~/.ssh/authorized_keys root@vrv206://root/.ssh/
			[root@vrv206 ~]# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
			[root@vrv206 ~]# scp ~/.ssh/authorized_keys root@vrv207://root/.ssh/
			[root@vrv207 ~]# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
			[root@vrv207 ~]# scp ~/.ssh/authorized_keys root@vrv206://root/.ssh/
			[root@vrv207 ~]# scp ~/.ssh/authorized_keys root@vrv205://root/.ssh/
			[root@vrv207 ~]# scp ~/.ssh/authorized_keys root@vrv204://root/.ssh/
			[root@vrv207 ~]# scp ~/.ssh/authorized_keys root@vrv203://root/.ssh/
			[root@vrv203 .ssh]# ssh vrv204
			Last login: Thu Feb  8 18:51:25 2018 from 192.168.118.139
			[root@vrv204 ~]# exit
			logout
			Connection to vrv204 closed.
			[root@vrv203 .ssh]# ssh vrv205
			Last login: Thu Feb  8 18:51:18 2018 from 192.168.118.139
			[root@vrv205 ~]# exit
			logout
			Connection to vrv205 closed.
			[root@vrv203 .ssh]# ssh vrv206
			Last login: Thu Feb  8 18:51:20 2018 from 192.168.118.139
			[root@vrv206 ~]# exit
			logout
			Connection to vrv206 closed.
			[root@vrv203 .ssh]# ssh vrv207
			Last login: Thu Feb  8 19:13:47 2018 from vrv204
			[root@vrv207 ~]# exit
			logout
			Connection to vrv207 closed.


13. 启动ntpd时间同步

		systemctl is-enable ntpd
		systemctl enable ntpd
		systemctl start ntpd

14. 禁用SELINUX

 - setenforce 0
 - vi /etc/selinux/config
		
			SELINUX=disabled