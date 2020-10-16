# 部署tomcat

测试使用kubernets部署一个tomcat

- 创建服务部署配置tomcat.yml

```bash
cat <<EOF > tomcat.yml
apiVersion: v1
kind: Service
metadata:
  name: tomcat
  namespace: default
  labels:
    app: tomcat
spec:
  type: NodePort
  ports:
  - port: 8080
    nodePort: 30808
  selector:
    app: tomcat
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tomcat
  labels:
    app: tomcat
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tomcat
  template:
    metadata:
      labels:
        app: tomcat
    spec:
      containers:
      - name: tomcat
        image: docker.io/library/tomcat
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
EOF
```

- 部署服务`kubectl apply -f tomcat.yml`
- 删除服务`kubectl delete -f tomcat.yml`
- 查看访问端口

```bash
[root@xw101 ~]# kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
tomcat       NodePort    10.110.135.172   <none>        8080:30808/TCP   3h26m
```

- 访问页面[http://任意一个Worker节点的IP地址:38080/]