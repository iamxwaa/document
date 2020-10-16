# kubernetes安装使用

## 测试环境

docker version: 1.13.1
kubernetes version: v1.19.0

CentOS Linux release 7.8.2003 (Core)

ip|hostname|cpu|内存|节点类型
--|--|--|--|--
192.168.56.101|xw101|2|4G|master
192.168.56.201|xw201|2|4G|worker

## 准备

- 在 master 节点和 worker 节点执行以下命令

```bash
#关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

#禁用selinux
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

#关闭swap
swapoff -a
yes | cp /etc/fstab /etc/fstab_bak
cat /etc/fstab_bak |grep -v swap > /etc/fstab
```

- master 节点和 worker 节点修改/etc/sysctl.conf，添加以下内容

```conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
```

- 配置各节点/etc/hostname
- 配置各节点/etc/hosts

## 安装docker

> 每台服务器都安装docker

- 执行安装命令`yum install docker -y`
- 修改镜像地址`vi /etc/docker/daemon.json`

```json
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
```

- 执行`docker info`确认cgroup

```bash
Cgroup Driver: systemd
```

## 安装kubernetses

> 没有特殊说明，则各个步骤需要在每台服务器上都执行

- 配置kubernetses yum源

```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

- 更新yum，`yum clean all && yum repolist`

- 开始安装，`yum install kubectl kubeadm kubelet`

- 修改/lib/systemd/system/kubelet.service.d/10-kubeadm.conf，添加--cgroup-driver=systemd

```conf
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --cgroup-driver=systemd"
```

- 提前下载k8s所需的docker镜像（只在master上执行）
从aliyun下载镜像，并修改tag为 k8s.gcr.io/***

```shell
#!/bin/bash
url=registry.cn-hangzhou.aliyuncs.com/google_containers
version=v1.19.0
images=(`kubeadm config images list --kubernetes-version=$version|awk -F '/' '{print $2}'`)
for imagename in ${images[@]} ; do
  docker pull $url/$imagename
  docker tag $url/$imagename k8s.gcr.io/$imagename
  docker rmi -f $url/$imagename
done
```

```bash
[root@xw101 ~]# docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/etcd                      3.4.13-0            0369cf4303ff        6 weeks ago         253 MB
k8s.gcr.io/kube-proxy                v1.19.0             bc9c328f379c        7 weeks ago         118 MB
k8s.gcr.io/kube-apiserver            v1.19.0             1b74e93ece2f        7 weeks ago         119 MB
k8s.gcr.io/kube-controller-manager   v1.19.0             09d665d529d0        7 weeks ago         111 MB
k8s.gcr.io/kube-scheduler            v1.19.0             cbdc8369d8b1        7 weeks ago         45.7 MB
k8s.gcr.io/coredns                   1.7.0               bfe3a36ebd25        3 months ago        45.2 MB
k8s.gcr.io/pause                     3.2                 80d28bedfe5d        8 months ago        683 kB
```

- 创建 kubeadm-config.yaml

```bash
# 只在 master 节点执行
cat <<EOF > ./kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.19.0
imageRepository: k8s.gcr.io
controlPlaneEndpoint: "192.168.56.101:6443"
networking:
  podSubnet: "10.244.0.0/16"
EOF
```

- 初始化api-server

```bash
# 只在 master 节点执行
# 安装失败使用kubeadm reset重新安装
kubeadm init --config=kubeadm-config.yaml --upload-certs
```

显示以下信息表示初始化成功

```bash
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 192.168.56.101:6443 --token d2s7qc.ejprftcnylfjsfyc \
    --discovery-token-ca-cert-hash sha256:6c923b504549e56e29db784d6dde65d0394870a84ab7914b34546a526e6d3cd5 \
    --control-plane --certificate-key ddd0b295c5ee78c4a3d580c2c6d205c579c2bd454e2949f6f8e46513115058a9

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.56.101:6443 --token d2s7qc.ejprftcnylfjsfyc \
    --discovery-token-ca-cert-hash sha256:6c923b504549e56e29db784d6dde65d0394870a84ab7914b34546a526e6d3cd5 
```

- 初始化root用户的kubectl配置

```bash
# 只在 master 节点执行
rm -rf /root/.kube/ && mkdir /root/.kube/ && cp -i /etc/kubernetes/admin.conf /root/.kube/config
```

- 安装 [flannel](!https://github.com/coreos/flannel
) 或 [calico](!https://docs.projectcalico.org/getting-started/kubernetes/quickstart)，这里安装的是flannel
  - 获取服务配置

  ```bash
    wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  ```

  - 确认kube-flannel.yml中的网段配置和kubeadm-config.yaml中的podSubnet一致

  ```yaml
    net-conf.json: |
    {
        "Network": "10.244.0.0/16",
        "Backend": {
        "Type": "vxlan"
        }
    }
  ```

  - 部署服务`kubectl apply -f kube-flannel.yml`

- 等待所有容器正常运行

  - status异常，问题定位
  - `kubectl describe pod kube-flannel-ds-n8j6d -n kube-system` 
  - `tailf -100 /var/log/message`
  - 如果服务镜像无法正常拉取，可以先手动docker pull ***

```bash
watch kubectl get pod -n kube-system

NAME                              READY   STATUS    RESTARTS   AGE
coredns-6c76c8bb89-tznk2        1/1     Running   0          2m26s
coredns-6c76c8bb89-v825v        1/1     Running   0          2m26s
etcd-xw101                      1/1     Running   0          2m35s
kube-apiserver-xw101            1/1     Running   0          2m35s
kube-controller-manager-xw101   1/1     Running   0          2m35s
kube-flannel-ds-p9qv6           1/1     Running   0          95s
kube-proxy-xb78n                1/1     Running   0          2m26s
kube-scheduler-xw101            1/1     Running   0          2m35s
```

- 查看安装结果

```bash
[root@xw101 ~]# kubectl get nodes
NAME    STATUS   ROLES    AGE     VERSION
xw101   Ready    master   4h30m   v1.19.2
```

- 初始化worker

获取join命令

```bash
# 只在 master 节点执行
kubeadm token create --print-join-command
```

使用生成的join命令，在各个worker节点上执行

```bash
kubeadm join 192.168.56.101:6443 --token 0r89q5.ozkrtnoo0s28yu4m     --discovery-token-ca-cert-hash sha256:6c923b504549e56e29db784d6dde65d0394870a84ab7914b34546a526e6d3cd5 
```

显示以下信息表示添加成功

```bash
[preflight] Running pre-flight checks
        [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

- worker初始化完毕后，查看安装结果

```bash
[root@xw101 ~]# kubectl get nodes
NAME    STATUS   ROLES    AGE     VERSION
xw101   Ready    master   4h34m   v1.19.2
xw201   Ready    <none>   4h32m   v1.19.2
```

- 如果需要删除worker节点，执行以下操作

```bash
# 在需要移除的worker节点上执行
kubeadm reset
```

```bash
# 在master节点上执行
kubectl delete node $hostname
```
