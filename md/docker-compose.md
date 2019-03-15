##样例

	version: '3'
	
	services:
	  redis:
	    image: redis:2.8
	    expose:
	      - "6379"
	  dataflow-server:
	    image: springcloud/spring-cloud-dataflow-server-local:1.6.0.M2
	    container_name: dataflow-server
	    extra_hosts:
	      - "kafka:192.168.119.203"
	      - "zookeeper:192.168.119.204"
	      - "mysql:192.168.119.208"
	    ports:
	      - "9393:9393"
	    volumes:
	      - "/root/docker:/root/docker"
	    environment:
	      - spring.cloud.dataflow.applicationProperties.stream.spring.cloud.stream.kafka.binder.brokers=kafka:6667
	      - spring.cloud.dataflow.applicationProperties.stream.spring.cloud.stream.kafka.binder.zkNodes=zookeeper:2181
	      - spring.cloud.dataflow.features.streams-enabled=false
	      - spring.cloud.dataflow.features.schedules-enabled=true
	      - spring.datasource.url=jdbc:mysql://mysql:3306/dataflow?useSSL=false
	      - spring.datasource.username=root
	      - spring.datasource.password=root
	      - spring.datasource.driver-class-name=org.mariadb.jdbc.Driver
	      - spring.cloud.config.uri=http://192.168.119.208:8765
	      - spring.cloud.dataflow.applicationProperties.stream.spring.redis.host=redis
	      - spring_redis_host=redis
	    depends_on:
	      - redis
	  app-import:
	    image: alpine:3.7
	    depends_on:
	      - dataflow-server
	    command: >
	      /bin/sh -c "
	        while ! nc -z dataflow-server 9393;
	        do
	          sleep 1;
	        done;
	        wget -qO- 'http://dataflow-server:9393/apps' --post-data='uri=http://repo.spring.io/libs-release/org/springframework/cloud/stream/app/spring-cloud-stream-app-descriptor/Celsius.SR1/spring-cloud-stream-app-descriptor-Celsius.SR1.stream-apps-kafka-10-maven&force=true';
	        echo 'Stream apps imported'
	        wget -qO- 'http://dataflow-server:9393/apps'  --post-data='uri=http://repo.spring.io/libs-snapshot/org/springframework/cloud/task/app/spring-cloud-task-app-descriptor/Clark.RELEASE/spring-cloud-task-app-descriptor-Clark.RELEASE.task-apps-maven&force=true';
	        echo 'Task apps imported'"


###command
1. 使用 command 可以覆盖容器启动后默认执行的命令

		command: bundle exec thin -p 3000
		command: [bundle, exec, thin, -p, 3000]
###container_name
1. 指定docker容器的名字
		
		container_name: app
###depends_on
1. depends_on 确定容器的启动顺序

		depends_on:
      		- db
      		- redis
###dns
1. dns配置
		
		dns: 8.8.8.8
		dns:
  			- 8.8.8.8
  			- 9.9.9.9
2. dns_search 的配置也类似：

		dns_search: example.com
		dns_search:
  			- dc1.example.com
  			- dc2.example.com
###tmpfs
1. 挂载临时目录到容器内部

		tmpfs: /run
		tmpfs:
		  - /run
		  - /tmp
###entrypoint
1. 指定接入点,覆盖 Dockerfile 中的定义
		
		entrypoint: /code/entrypoint.sh
		entrypoint:
		    - php
		    - -d
		    - zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so
		    - -d
		    - memory_limit=-1
		    - vendor/bin/phpunit
###env_file
1. docker-compose.yml 中定义变量的文件。如果有变量名称与 environment 指令冲突，则以后者为准。

		env_file: .env
		env_file:
		  - ./common.env
		  - ./apps/web.env
		  - /opt/secrets.env
###environment
1. 设置镜像变量，保存变量到镜像里面

		environment:
		  - RACK_ENV=development
		  - SHOW=true
		  - SESSION_SECRET
###expose
1. 指定暴露的端口，但是只是作为一种参考，实际上docker-compose.yml的端口映射还得ports这样的标签。

		expose:
		 - "3000"
		 - "8000"
###external_links
1. 连接不在docker-compose.yml中定义的容器

		external_links:
		 - redis_1
		 - project_db_1:mysql
		 - project_db_1:postgresql
###extra_hosts
1. 往/etc/hosts文件中添加host配置

		extra_hosts:
		 - "somehost:162.242.195.82"
		 - "otherhost:50.31.209.229"
###labels
1. 向容器添加元数据，同Dockerfile的LABEL指令

		labels:
		  com.example.description: "Accounting webapp"
		  com.example.department: "Finance"
		  com.example.label-with-empty-value: ""
labels:
  - "com.example.description=Accounting webapp"
  - "com.example.department=Finance"
  - "com.example.label-with-empty-value"
##links
1. 与Docker client的--link一样效果，会连接到其它服务中的容器。

		links:
		 - <容器名>:<别名>
		 - db
		 - db:database
		 - redis
###logging
1. 配置日志服务
		
		logging:
		  driver: syslog
		  options:
		    syslog-address: "tcp://192.168.0.42:123"
###pid
1. 将PID模式设置为主机PID模式，跟主机系统共享进程命名空间。容器使用这个标签将能够访问和操纵其他容器和宿主机的名称空间。

		pid: "host"
###ports
1. 端口映射

		ports:
		 - "3000"
		 - "8000:8000"
		 - "49100:22"
		 - "127.0.0.1:8001:8001"
###security_opt
1. 为每个容器覆盖默认的标签。简单说来就是管理全部服务的标签。比如设置全部服务的user标签值为USER。

		security_opt:
		  - label:user:USER
		  - label:role:ROLE
###stop_signal
1. 设置另一个信号来停止容器。在默认情况下使用的是SIGTERM停止容器。设置另一个信号可以使用stop_signal标签。

		stop_signal: SIGUSR1
###volumes
1. 挂载一个目录或者一个已存在的数据卷容器

		volumes:
		  - /var/lib/mysql ##容器内创建
		  - /opt/data:/var/lib/mysql ##容器内:宿主机
		  - ~/configs:/etc/configs/:ro ##只读
###volumes_from
从其它容器或者服务挂载数据卷，可选的参数是 :ro或者 :rw。

		volumes_from:
		  - service_name
		  - service_name:ro
		  - container:container_name
		  - container:container_name:rw
###extends
1. 扩展另一个服务，扩展内容可以是来自在当前文件，也可以是来自其他文件，相同服务的情况下，后来者会有选择地覆盖原有配置。

		extends:
		  file: common.yml
		  service: webapp
###network_mode
1. 网络模式

		network_mode: "bridge"
		network_mode: "host"
		network_mode: "none"
		network_mode: "service:[service name]"
		network_mode: "container:[container name/id]"
###networks
1. 加入指定网络

		services:
		  some-service:
		    networks:
		     - some-network
		     - other-network
		------------------------------------------------
		services:
		  some-service:
		    networks:
		      some-network:
		        aliases:
		         - alias1
		         - alias3
		      other-network:
		        aliases:
		         - alias2
