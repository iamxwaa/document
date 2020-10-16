# kubernets安装

-------------

## 安装minikube

```bash
curl -Lo minikube http://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/releases/v1.13.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

rpm -ivh /data/VirtualBox-6.1-6.1.14_140239_el7-1.x86_64.rpm
yum install libICE SDL libSM libXcursor libXrender libXt fontconfig opus png15 libvpx -y
 yum install libGL libXext -y
```

minikube start
kubectl proxy --address='0.0.0.0' --port=8001 --disable-filter=true

kubectl create secret docker-registry docker-regsitry-auth --docker-username=admin --docker-password=Harbor1345 --docker-server=192.168.31.70

start --vm-driver=none --extra-config=kubelet.cgroup-driver=systemd --cpus=2 --memory=2048mb --image-mirror-country cn --registry-mirror=https://dftbcros.mirror.aliyuncs.com

start --vm-driver=virtualbox --cpus=2 --memory=2048mb --image-mirror-country cn --registry-mirror=https://dftbcros.mirror.aliyuncs.com

 sudo /usr/local/bin/minikube start --vm-driver=none --extra-config=kubelet.cgroup-driver=systemd --cpus=2 --memory=2048mb --image-mirror-country cn --registry-mirror=https://dftbcros.mirror.aliyuncs.com


sudo groupadd docker && usermod -aG docker $USER && newgrp docker

sudo -uxw /usr/local/bin/minikube start --extra-config=kubelet.cgroup-driver=systemd --driver=docker --cpus=2 --memory=2048mb --image-mirror-country cn


 vi /etc/docker/daemon.json
{"registry-mirrors": ["https://no1pfk8z.mirror.aliyuncs.com","https://kfwkfulq.mirror.aliyuncs.com", "https://2lqq34jg.mirror.aliyuncs.com", "https://pee6w651.mirror.aliyuncs.com","https://hub-mirror.c.163.com/","https://reg-mirror.qiniu.com"]}

#（1）临时关闭swap分区, 重启失效;
   swapoff  -a

#（2）永久关闭swap分区

 sed -ri 's/.*swap.*/#&/' /etc/fstab

 curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

 curl -Lo minikube http://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

 --exec-opt native.cgroupdriver=systemd

minikube start --driver=docker --extra-config=kubelet.cgroup-driver=cgroupfs --cpus=2 --memory=3072mb --image-mirror-country cn --registry-mirror=https://dftbcros.mirror.aliyuncs.com

kubectl create secret docker-registry docker-regsitry-auth --docker-username=xw --docker-password=123456 --docker-server=192.168.56.101

minikube start --driver=none --extra-config=kubelet.cgroup-driver=systemd --cpus=2 --memory=3072mb --image-mirror-country cn --registry-mirror=https://dftbcros.mirror.aliyuncs.com

/etc/sysconfig/docker

minikube start --vm-driver=none --extra-config=kubelet.cgroup-driver=systemd --image-mirror-country cn --registry-mirror=https://dftbcros.mirror.aliyuncs.com

echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables

yum install -y kubectl kubeadm kubelet



cat <<EOF > ./kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.19.0
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
controlPlaneEndpoint: "192.168.56.101:6443"
networking:
  podSubnet: "10.100.0.1/20"
EOF

#!/bin/bash
url=registry.cn-hangzhou.aliyuncs.com/google_containers
version=v1.19.0
images=(`kubeadm config images list --kubernetes-version=$version|awk -F '/' '{print $2}'`)
for imagename in ${images[@]} ; do
  docker pull $url/$imagename
  docker tag $url/$imagename k8s.gcr.io/$imagename
  docker rmi -f $url/$imagename
done

rm -rf /root/.kube/ && mkdir /root/.kube/ && cp -i /etc/kubernetes/admin.conf /root/.kube/config

wget https://docs.projectcalico.org/manifests/tigera-operator.yaml
wget https://docs.projectcalico.org/manifests/custom-resources.yaml

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

kubeadm init --config=kubeadm-config.yaml --upload-certs --pod-network-cidr=10.100.0.1/20

kubectl apply -f kube-flannel.yml

watch kubectl get pod -n kube-system

cat <<EOF >  ~/dashboard-svc-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard-admin
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard-admin
  namespace: kube-system
EOF