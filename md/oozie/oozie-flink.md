# 使用oozie提交flink任务

## 准备

- hadoop集群中的nodemanager安装flink客户端，用来提交任务到yarn
- 配置环境变量

```bash
export VHDP_HOME=/usr/hdp/3.1.0.0-78
export HADOOP_HOME=/usr/hdp/3.1.0.0-78/hadoop
export HADOOP_CLASSPATH=$HADOOP_HOME/lib/*:$VHDP_HOME/hadoop/*:$VHDP_HOME/hadoop-yarn/*:$VHDP_HOME/hadoop-hdfs/*:$VHDP_HOME/hadoop-mapreduce/*:$VHDP_HOME/hadoop-yarn/lib/*:$VHDP_HOME/hadoop-hdfs/lib/*:$VHDP_HOME/hadoop-mapreduce/lib/*
```

## 编写shell脚本用来提交flink任务

- flink-submit.sh

```shell
#!/bin/bash

export HDP_HOME=$HDP_HOME
export HADOOP_HOME=HDP_HOME/hadoop
export HADOOP_CLASSPATH=$HADOOP_HOME/lib/*:$HDP_HOME/hadoop/*:$HDP_HOME/hadoop-yarn/*:$HDP_HOME/hadoop-hdfs/*:$HDP_HOME/hadoop-mapreduce/*:$HDP_HOME/hadoop-yarn/lib/*:$HDP_HOME/hadoop-hdfs/lib/*:$HDP_HOME/hadoop-mapreduce/lib/*
export FLINK_CONF_DIR=$FLINK_HOME/conf

echo $FLINK_HOME/bin/flink run $FLINK_OPT $FLINK_APP_JAR $FLINK_APP_OPT
$FLINK_HOME/bin/flink run $FLINK_OPT $FLINK_APP_JAR $FLINK_APP_OPT
```

## 编写任务运行配置

- workflow.xml

```xml
<workflow-app xmlns="uri:oozie:workflow:0.4" name="shell-flink">
    <start to="shell-node"/>
    <action name="shell-node" retry-max="${retryMax}" retry-interval="${retryInterval}">
        <shell xmlns="uri:oozie:shell-action:0.2">
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <prepare>
            </prepare>
            <configuration>
                <property>
                    <name>mapred.job.queue.name</name>
                    <value>${queueName}</value>
                </property>
                <property>
                    <name>oozie.launcher.mapreduce.map.memory.mb</name>
                    <value>${oozieMemory}</value>
                </property>
                <property>
                    <name>oozie.launcher.mapreduce.reduce.memory.mb</name>
                    <value>${oozieMemory}</value>
                </property>
                <property>
                    <name>oozie.launcher.mapreduce.map.cpu.vcores</name>
                    <value>${oozieVcores}</value>
                </property>
                <property>
                    <name>oozie.launcher.mapreduce.reduce.cpu.vcores</name>
                    <value>${oozieVcores}</value>
                </property>
            </configuration>
            <exec>${exec}</exec>
            <env-var>HADOOP_USER_NAME=${wf:user()}</env-var>
            <env-var>HDP_HOME=${hdpHome}</env-var>
            <env-var>FLINK_HOME=${flinkHome}</env-var>
            <env-var>FLINK_OPT=${flinkOpt}</env-var>
            <env-var>FLINK_APP_OPT=${flinkAppOpt}</env-var>
            <env-var>FLINK_APP_JAR=${appJar}</env-var>
            <file>${exec}#${exec}</file>
            <file>${appJar}#${appJar}</file>
            <capture-output/>
        </shell>
        <ok to="end"/>
        <error to="fail"/>
    </action>
    <kill name="fail">
        <message>Shell action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
    </kill>
    <end name="end"/>
</workflow-app>
```

## 编写任务参数配置

- job.properties

```properties
#任务在hdfs中的路径
oozie.wf.application.path=hdfs://vrv203:8020/apps/flink/job
#resourcemanager地址
jobTracker=vrv203:8050
nameNode=hdfs://vrv203:8020
queueName=default
#mapreduce使用内存（MB）
oozieMemory=512
#mapreduce使用cpu核心数
oozieVcores=1

#失败重试次数
retryMax=2
#失败重试间隔
retryInterval=1

#任务提交脚本
exec=flink-submit.sh
#flink任务jar
appJar=flink-test-1.10.2-1.0-SNAPSHOT-uber.jar
#hdp安装目录
hdpHome=/usr/hdp/3.1.0.0-78
#flink安装目录
flinkHome=/usr/vmp/flink-1.10.2
#flink提交任务参数
flinkOpt=-ys 2 -m yarn-cluster -yqu flink -c xw.test.flink.AbnormalFlow
#任务所需参数
flinkAppOpt=yarn-cluster
```

## 提交任务

- 将flink-submit.sh、flink-test-1.10.2-1.0-SNAPSHOT-uber.jar、workflow.xml上传到hdfs的/apps/flink/job目录下

> sudo -u hdfs hdfs dfs -put -f /data/oozie/job/* /apps/flink/job

- 使用oozie提交任务

```bash
oozie job -oozie http://vrv207:11000/oozie -config /data/oozie/job/job.properties -run
```