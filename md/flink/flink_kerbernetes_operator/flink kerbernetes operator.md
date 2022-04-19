# 通过flink operator在kubernetes部署flink

## 部署operator

- 首选安装证书管理器,用来支持webhook的安装 (每个k8s集群只需安装一次):

```bash
kubectl create -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml
```

> 万一证书管理器安装失败,可以通过在helm命令中加入--set webhook.create=false来禁用webhook

- 通过Helm chart来安装最新的Flink Kubernetes Operator

```bash
helm repo add flink-operator-repo https://downloads.apache.org/flink/flink-kubernetes-operator-0.1.0/
helm install flink-kubernetes-operator flink-operator-repo/flink-kubernetes-operator
```

> 默认的镜像地址为ghcr.io/apache/flink-kubernetes-operator，如果连接有问题可以使用
--set image.repository=apache/flink-kubernetes-operator修改镜像地址来代替

- 安装完毕后通过以下命令来验证安装情况

```bash
kubectl get pods
NAME READY STATUS RESTARTS AGE
flink-kubernetes-operator-fb5d46f94-ghd8b 2/2 Running 0 4m21s
```

```bash
helm list
NAME NAMESPACE REVISION UPDATED STATUS CHART APP VERSION
flink-kubernetes-operator default 1 2022-03-09 17 (tel:12022030917):39:55.461359 +0100 CET deployed flink-kubernetes-operator-0.1.0 0.1.0
```

## 提交flink任务

- 安装成功后可以使用以下命令来提交flink任务

```bash
kubectl create -f https://raw.githubusercontent.com/apache/flink-kubernetes-operator/release-0.1/examples/basic.yaml
```

- 任务成功提交后可以通过以下命令来查看任务日志

```bash
kubectl logs -f deploy/basic-example

2022-03-11 21:46:04,458 INFO  org.apache.flink.runtime.checkpoint.CheckpointCoordinator    [] - Triggering checkpoint 206 (type=CHECKPOINT) @ 1647035164458 for job a12c04ac7f5d8418d8ab27931bf517b7.
2022-03-11 21:46:04,465 INFO  org.apache.flink.runtime.checkpoint.CheckpointCoordinator    [] - Completed checkpoint 206 for job a12c04ac7f5d8418d8ab27931bf517b7 (28509 bytes, checkpointDuration=7 ms, finalizationTime=0 ms).
2022-03-11 21:46:06,458 INFO  org.apache.flink.runtime.checkpoint.CheckpointCoordinator    [] - Triggering checkpoint 207 (type=CHECKPOINT) @ 1647035166458 for job a12c04ac7f5d8418d8ab27931bf517b7.
2022-03-11 21:46:06,483 INFO  org.apache.flink.runtime.checkpoint.CheckpointCoordinator    [] - Completed checkpoint 207 for job a12c04ac7f5d8418d8ab27931bf517b7 (28725 bytes, checkpointDuration=25 ms, finalizationTime=0 ms).
```

- 通过以下命令对外暴露flink管理页面

```bash
kubectl port-forward svc/basic-example-rest 8081
Now the Flink Dashboard is accessible at localhost:8081.
```

- 通过以下命令来关闭任务

```bash
kubectl delete flinkdeployment/basic-example
```
