# 在kubernetes中部署flink

## 部署flink方式一 (Session Mode)

Flink Session cluster需要在kubernetes中部署以下组件:

- 部署JobManager
- 部署TaskManagers
- 对外暴露JobManager api和页面

通过以下kubectl命令完成部署

```bash
# 配置和定义服务
$ kubectl create -f flink-configuration-configmap.yaml
$ kubectl create -f jobmanager-service.yaml
# 创建和部署服务
$ kubectl create -f jobmanager-session-deployment.yaml
$ kubectl create -f taskmanager-session-deployment.yaml
```

通过以下命令销毁集群

```bash
# 销毁集群
$ kubectl delete -f jobmanager-service.yaml
$ kubectl delete -f flink-configuration-configmap.yaml
$ kubectl delete -f taskmanager-session-deployment.yaml
$ kubectl delete -f jobmanager-session-deployment.yaml
```

## 部署flink方式二 (Application Mode)

Flink Application Mode需要在kubernetes中部署以下组件:

- 部署JobManager
- 部署TaskManagers
- 对外暴露JobManager api和页面

修改jobmanager-job.yaml和taskmanager-job-deployment.yaml任务jar包路径(此处以TopSpeedWindowing.jar为例)

```yaml
- name: job-artifacts-volume
    hostPath:
      path: /nfs/k8s/flink/job #存放任务jar包的路径
```

修改jobmanager-job.yaml任务提交命令，args后面的参数修改为自己任务所需的参数

```yaml
containers:
- name: jobmanager
    image: apache/flink:1.14.4-scala_2.11
    env:
    args: ["standalone-job", "--job-classname", "org.apache.flink.streaming.examples.windowing.TopSpeedWindowing"] # optional arguments: ["--job-id", "<job id>", "--fromSavepoint", "/path/to/savepoint", "--allowNonRestoredState"]
```

通过以下kubectl命令完成部署

```bash
# 暴露服务端口
$ kubectl create -f jobmanager-service.yaml
# 提交任务
$ kubectl create -f jobmanager-job.yaml
# 分配任务资源
$ kubectl create -f taskmanager-job-deployment.yaml
```

通过以下命令销毁集群

```bash
# 销毁集群
$ kubectl delete -f taskmanager-job-deployment.yaml
$ kubectl delete -f jobmanager-job.yaml
$ kubectl delete -f jobmanager-service.yaml
```
