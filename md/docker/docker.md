# docker

----------------------------

## 1. 下载docker

<https://download.docker.com/linux/centos/7/x86_64/stable/Packages/>

## 2. 安装docker

```shell
rpm -ivh docker-ce-17.09.1.ce-1.el7.centos.x86_64.rpm
```

> 使用docker不能禁用防火墙

如果报错

> error: Failed dependencies:
container-selinux >= 2.9 is needed by docker-ce-17.09.1.ce-1.el7.centos.x86_64

需要下载安装 container-selinux
<http://mirror.centos.org/centos/7/extras/x86_64/Packages/>

## 3. 创建私有仓库

3.1 下载私有仓库镜像

```shell
docker search registry

-------------------------------------
NAME                                    DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
registry                                The Docker Registry 2.0 implementation for...   1849                [OK]  
-------------------------------------

docker pull registry:latest
```

3.2 查看镜像是否下载成功

```shell
docker images
-------------------------------------
REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE<br>
registry                        latest              d1fd7d86a825        3 weeks ago         33.3MB<br>
```

3.3 启动私有仓库镜像

```shell
docker run -d -p 5000:5000 -v /root/docker/registry:/tmp/registry registry
```

> -d 镜像后台启动
-p 映射container和宿主机端口 <宿主机>:<容器>
-v 映射container和宿主机目录 <宿主机>:<容器>

## 4. 测试上传镜像到私有仓库

4.1 用刚才下载的registry做测试,给registry添加标签

```shell
docker tag registry 192.168.118.147:5000/registry
```

>docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
目标镜像需要带 私有仓库服务器的地址 服务器地址:绑定的宿主机端口/镜像名称

4.2 上传镜像到私有仓库

```shell
docker push 192.168.118.147:5000/registry
```

4.3 上传失败需要修改配置

> Get <https://192.168.118.147:5000/v2/:> http: server gave HTTP response to HTTPS client

- 查看/etc/sysconfig/docker有无该配置文件
- 如果没有该配置文件，需要修改/lib/systemd/system/docker.service
  - 添加参数EnvironmentFile=/etc/sysconfig/docker
- 手动创建/etc/sysconfig/docker文件,写入以下内容

```shell
# /etc/sysconfig/docker

# Modify these options if you want to change the way the docker daemon runs
OPTIONS=‘-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock‘
DOCKER_CERT_PATH=/etc/docker

# If you want to add your own registry to be used for docker search and docker
# pull use the ADD_REGISTRY option to list a set of registries, each prepended
# with --add-registry flag. The first registry added will be the first registry
# searched.
# ADD_REGISTRY=‘--add-registry registry.access.redhat.com‘<br>
# If you want to block registries from being used, uncomment the BLOCK_REGISTRY
# option and give it a set of registries, each prepended with --block-registry
# flag. For example adding docker.io will stop users from downloading images
# from docker.io
# BLOCK_REGISTRY=‘--block-registry‘

# If you have a registry secured with https but do not have proper certs
# distributed, you can tell docker to not look for full authorization by
# adding the registry to the INSECURE_REGISTRY line and uncommenting it.
INSECURE_REGISTRY=‘--insecure-registry dl.dockerpool.com:5000‘

# On an SELinux system, if you remove the --selinux-enabled option, you
# also need to turn on the docker_transition_unconfined boolean.
# setsebool -P docker_transition_unconfined 1

# Location used for temporary files, such as those created by
# docker load and build operations. Default is /var/lib/docker/tmp
# Can be overriden by setting the following environment variable.
# DOCKER_TMPDIR=/var/tmp

# Controls the /etc/cron.daily/docker-logrotate cron job status.
# To disable, uncomment the line below.
# LOGROTATE=false
```

- 创建完毕后添加配置

```shell
#CentOS 7系统，添加下面配置
OPTIONS='--selinux-enabled --insecure-registry 192.168.118.147:5000'  
#CentOS 6系统，添加下面配置
other_args='--selinux-enabled --insecure-registry 192.168.118.147:5000'
```

- 创建/etc/docker/daemon.json,写入以下内容

```shell
{ "insecure-registries":["192.168.119.218:2375"], "registry-mirrors": ["https://dftbcros.mirror.aliyuncs.com"] }
```

或

```bash
cat <<EOF > /etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://no1pfk8z.mirror.aliyuncs.com",
        "https://kfwkfulq.mirror.aliyuncs.com",
        "https://2lqq34jg.mirror.aliyuncs.com",
        "https://pee6w651.mirror.aliyuncs.com",
        "https://hub-mirror.c.163.com/",
        "https://reg-mirror.qiniu.com"
    ],
    "insecure-registries": ["192.168.56.101"]
}
EOF
```

- 重新提交成功

```shell
docker images
-------------------------------------
192.168.118.147:5000/registry   latest              d1fd7d86a825        3 weeks ago         33.3MB
registry                        latest              d1fd7d86a825        3 weeks ago         33.3MB
```

4.4 客户端下载(客户端配置参考以上步骤)

```shell
docker pull 192.168.118.147:5000/registry
docker images
-----------------------------------------------
REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
192.168.118.147:5000/registry   latest              d1fd7d86a825        8 days ago          557MB
```

### 5. 制作自己的镜像

5.1 下载镜像系统

```shell
docker pull centos:7.2.1511
docker images
------------------------------------
centos                          7.2.1511            0a2bad7da9b5        3 months ago        195MB
```

5.2 启动镜像系统

```shell
docker run -i -t -v /root/software/:/data/software/ 0a2bad7da9b5 /bin/bash
```

> docker run <相关参数> <镜像 ID> <初始命令>
> -i：表示以“交互模式”运行容器
> -t：表示容器启动后会进入其命令行
> -v：表示需要将本地哪个目录挂载到容器中，格式：-v <宿主机目录>:<容器目录>
> 退出系统输入exit
> 重新进入系统docker attach <容器 ID>

5.3 进入系统后创建一个包含前台web和后台server的镜像

- 进入后操作通普通linux操作
- 安装jdk
- 安装tomcat
- 部署war
- 部署jsw

    ```shell
    root@9179978164c9:/# ls
    bin  boot  data  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
    root@9179978164c9:/# cd data
    root@9179978164c9:/data# ls
    software
    root@9179978164c9:/data# cd software/
    root@9179978164c9:/data/software# ls
    jdk1.8.0_20.tar.gz  tomcat_web  vap_server
    ```

5.4 编写启动脚本

```shell
vi /data/start.sh
```

- 内容如下

```shell
#!/bin/bash
source /etc/profile
/data/vap_server/bin/vap_server start
/data/tomcat/bin/catalina.sh run
```

- 修改权限

```shell
chmod 755 start.sh
```

5.5 提交镜像

```shell
docker commit ffd99d9348fd 192.168.118.147:5000/vap
````

> docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]

5.6 上传自制镜像

- 查看刚提交的镜像

```shell
docker images
----------------------------------
REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
192.168.118.147:5000/vap        latest              3b8af4193f5d        18 seconds ago      743MB
```

- 上传到私有仓库供其他客户端下载

```shell
docker push 192.168.118.147:5000/vap
```

5.7 下载启动镜像

```shell
docker pull 192.168.118.147:5000/vap
docker run -d -p 8080:28080 --name vap 192.168.118.147:5000/vap /data/start.sh
```

5.8 检查结果

```shell
docker ps
-------------------------------
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                      NAMES
63e49d94e448        192.168.118.147:5000/vap   "/data/start.sh"         22 hours ago        Up 22 hours         0.0.0.0:28080->28080/tcp   vap
```
