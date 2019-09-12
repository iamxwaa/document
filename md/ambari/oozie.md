# oozie

--------------

## extjs 安装

- 下载 <http://archive.cloudera.com/gplextras/misc/ext-2.2.zip>
- 复制压缩包到 /usr/hdp/current/oozie-client/libext/
- 运行/usr/hdp/current/oozie-server/bin/oozie-setup.sh prepare-war

```bash
wget http://archive.cloudera.com/gplextras/misc/ext-2.2.zip

sudo cp ext-2.2.zip /usr/hdp/current/oozie-client/libext/
sudo chown oozie:hadoop /usr/hdp/current/oozie-client/libext/ext-2.2.zip
sudo -u oozie /usr/hdp/current/oozie-server/bin/oozie-setup.sh prepare-war
```

## spark 任务提交1

spark action 提交python

```xml
<workflow-app name="Batch job for PySpark Pi Estimator Job" xmlns="uri:oozie:workflow:0.5">
    <start to="spark2-0079"/>
    <kill name="Kill">
        <message>Action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
    </kill>
    <action name="spark2-0079">
        <spark xmlns="uri:oozie:spark-action:0.2">
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <master>yarn</master>
            <mode>client</mode>
            <name>BatchSpark2</name>
            <jar>pi.py</jar>
            <file>/user/hue/oozie/workspaces/lib/pi.py#pi.py</file>
        </spark>
        <ok to="End"/>
        <error to="Kill"/>
    </action>
    <end name="End"/>
</workflow-app>
```

## spark 任务提交2

spark action 提交jar

```xml
<workflow-app name="Batch job for spark-test" xmlns="uri:oozie:workflow:0.5">
    <start to="spark2-6b7b"/>
    <kill name="Kill">
        <message>Action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
    </kill>
    <action name="spark2-6b7b">
        <spark xmlns="uri:oozie:spark-action:0.2">
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <master>yarn</master>
            <mode>client</mode>
            <name>BatchSpark2</name>
              <class>com.vrv.vap.audit.Statistic</class>
            <jar>vap-audit-statistic.jar</jar>
              <arg>rpt.UrlFound</arg>
              <arg>2190506</arg>
              <arg>2190506</arg>
            <file>/user/spark/vap-audit-statistic.jar#vap-audit-statistic.jar</file>
            <file>/user/spark/mysql-connector-java-5.1.23.jar#mysql-connector-java-5.1.23.jar</file>
        </spark>
        <ok to="End"/>
        <error to="Kill"/>
    </action>
    <end name="End"/>
</workflow-app>
```

## spark 任务提交3

ssh action 调用spark-submit提交

```xml
<workflow-app xmlns="uri:oozie:workflow:0.4" name="shell-spark">
    <start to="shell-node"/>
    <action name="shell-node">
        <ssh xmlns="uri:oozie:ssh-action:0.1">
            <host>localhost</host>
            <command>/opt/cloudera/parcels/CDH-5.7.6-1.cdh5.7.6.p0.6/bin/spark-submit</command>
            <args>--class</args>
            <args>${clazz}</args>
            <args>--master</args>
            <args>${master}</args>
            <args>--driver-class-path</args>
            <args>${opt}</args>
            <args>${jarPath}</args>
            <args>${input}</args>
        </ssh>
        <ok to="end"/>
        <error to="fail"/>
    </action>
    <kill name="fail">
        <message>Shell action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
    </kill>
    <end name="end"/>
</workflow-app>
```

## spark 任务提交4

shell action 调用spark-submit提交

```xml
<workflow-app xmlns="uri:oozie:workflow:0.4" name="shell-spark">
    <start to="shell-node"/>
    <action name="shell-node">
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
            </configuration>
            <exec>spark-submit</exec>
            <argument>--class</argument>
            <argument>${clazz}</argument>
            <argument>--master</argument>
            <argument>${master}</argument>
            <argument>--driver-class-path</argument>
            <argument>${opt}</argument>
            <argument>${jarPath}</argument>
            <argument>${input}</argument>
            <env-var>HADOOP_USER_NAME=${wf:user()}</env-var>
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
