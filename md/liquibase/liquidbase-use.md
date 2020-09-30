# liquidbase 集成说明

--------

## Maven Liquibase Plugin

- Goals Available
  - liquibase:changelogSync
  - liquibase:changelogSyncSQL
  - liquibase:clearCheckSums
  - liquibase:dbDoc
  - liquibase:diff
  - liquibase:dropAll
  - liquibase:generateChangeLog
  - liquibase:help
  - liquibase:listLocks
  - liquibase:releaseLocks
  - liquibase:rollback
  - liquibase:rollbackSQL
  - liquibase:status
  - liquibase:tag
  - liquibase:update
  - liquibase:updateSQL
  - liquibase:updateTestingRollback
  - liquibase:futureRollbackSQL
  - liquibase:migrate DEPRECATED use update instead
  - liquibase:migrateSQL DEPRECATED use updateSQL instead

## POM 配置

- 添加JDBC驱动

```xml
<project>
    <dependencies>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <!-- Replace with the version of the MySQL driver you want to use -->
            <version>${mysql-version}</version>
        </dependency>
    </dependencies>
</project>
```

- 添加liquidbase maven插件
  - properties文件模式 

  ```xml
  <project>
    <build>
        <plugins>
            <plugin>
                <groupId>org.liquibase</groupId>
                <artifactId>liquibase-maven-plugin</artifactId>
                <version>3.0.5</version>
                <configuration>
                    <propertyFile>src/main/resources/liquibase/liquibase.properties</propertyFile>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>update</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
  </project>
  ```

  - 直接写在pom.xml中

  ```xml
  <plugin>
      <groupId>org.liquibase</groupId>
      <artifactId>liquibase-maven-plugin</artifactId>
      <version>3.0.5</version>
      <configuration>
          <changeLogFile>src/main/resources/org/liquibase/business_table.xml</changeLogFile>
          <driver>oracle.jdbc.driver.OracleDriver</driver>
          <url>jdbc:oracle:thin:@tf-appserv-linux:1521:xe</url>
          <username>liquibaseTest</username>
          <password>pass</password>
      </configuration>
      <executions>
          <execution>
              <phase>process-resources</phase>
              <goals>
                  <goal>update</goal>
              </goals>
          </execution>
      </executions>
  </plugin>
  ```

- 执行命令

```shell
mvn liquibase:update
```

## Gradle Liquibase Plugin

build.gradle 文件中添加liquidbase插件

```groovy
plugins {
  id 'org.liquibase.gradle' version '2.0.1'
}
```

老版本的gradle可以使用以下配置

```groovy
buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath "org.liquibase:liquibase-gradle-plugin:2.0.1"
    }
}
apply plugin: 'org.liquibase.gradle'
```

在项目依赖中添加以下配置

```groovy
dependencies {
  // All of your normal project dependencies would be here in addition to...
  liquibaseRuntime 'org.liquibase:liquibase-core:3.6.1'
  liquibaseRuntime 'org.liquibase:liquibase-groovy-dsl:2.0.1'
  liquibaseRuntime 'mysql:mysql-connector-java:5.1.34'
}
```

编写liquidbase插件配置

```groovy
liquibase {
  activities {
    main {
      changeLogFile 'src/main/db/main.xml'
    //changeLogFile 'src/main/db/main.groovy'
      url project.ext.mainUrl
      username project.ext.mainUsername
      password project.ext.mainPassword
    }
    security {
      changeLogFile 'src/main/db/security.xml'
    //changeLogFile 'src/main/db/security.groovy'
      url project.ext.securityUrl
      username project.ext.securityUsername
      password project.ext.securityPassword
    }
    diffMain {
    changeLogFile 'src/main/db/main.xml'      
    //changeLogFile 'src/main/db/main.groovy'
      url project.ext.mainUrl
      username project.ext.mainUsername
      password project.ext.mainPassword
      difftypes 'data'
    }
  }
  runList = project.ext.runList
}
```

执行命令

```shell
gradle update -PrunList='main,security'
```
