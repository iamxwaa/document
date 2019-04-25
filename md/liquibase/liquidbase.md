# liquidbase 使用说明

---------

## 功能说明

- 支持代码的分支与合并
- 支持多个开发者同时维护
- 支持多种数据库类型
- 支持 [XML](#xml-format), [YAML](#yaml-format), [JSON](#json-format) 和 [SQL](#formatted-sql-changelogs) 的格式定义
- 支持 context-dependent logic
- 集群安全的数据库升级
- 生成数据库[说明文档](http://www.liquibase.org/dbdoc/index.html)
- 生成数据库[变更文档](#diffs)
- 可以在你构建的过程中使用，也可以嵌入到你的应用当中使用
- 自动生成sql脚本
- 不需要一直连接数据库

## 数据库重构

- 简单的命令如 Create Table and Drop Column
- 复杂的命令如 Add Lookup Table and Merge Columns
- 指定特定的SQL执行
- 能够生成和管理数据库的回滚逻辑

## 开源和扩展

- 开源协议: Apache 2.0 License
- 允许你自己继承或重写你所需要的liquidbase功能
- 提供Java APIs供你使用

## 数据库支持说明

数据库|类型名称|备注
--|--|--
MySQL|mysql|No Issues
PostgreSQL|postgresql|8.2+ is required to use the "drop all database objects" functionality.
Oracle|oracle|11g driver is required when using the diff tool on databases running with AL32UTF8 or AL16UTF16
Sql Server|mssql|No Issues
Sybase_Enterprise|sybase|ASE 12.0+ required. "select into" database option needs to be set. Best driver is JTDS. Sybase does not support transactions for DDL so rollbacks will not work on failures. Foreign keys can not be dropped which can break the rollback or dropAll functionality.
Sybase_Anywhere|asany|Since 1.9
DB2|db2|No Issues. Will auto-call REORG when necessary.
Apache_Derby|derby|No Issues
HSQL|hsqldb|No Issues
H2|h2|No Issues
Informix|informix|No Issues
Firebird|firebird|No Issues
SQLite|sqlite|No Issues

## 使用 liquidbase
- 命令行
 - [Command Line](http://www.liquibase.org/documentation/command_line.html)
 - [Ant](http://www.liquibase.org/documentation/ant/index.html)
 - [Maven](http://www.liquibase.org/documentation/maven/index.html)
- 集成
 - [Spring](http://www.liquibase.org/documentation/spring.html)
 - [Servlet Listener](http://www.liquibase.org/documentation/servlet_listener.html)
 - [CDI Environment](http://www.liquibase.org/documentation/cdi.html)
- 离线
 - [Using Offline Database Support](http://www.liquibase.org/documentation/offline.html)

## 内部表
- DATABASECHANGELOG
- DATABASECHANGELOGLOCK

## 配置格式
### XML Format

```
<?xml version="1.0" encoding="UTF-8"?>

<databaseChangeLog
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:ext="http://www.liquibase.org/xml/ns/dbchangelog-ext"
        xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.0.xsd
        http://www.liquibase.org/xml/ns/dbchangelog-ext http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-ext.xsd">

    <preConditions>
        <runningAs username="liquibase"/>
    </preConditions>

    <changeSet id="1" author="nvoxland">
        <createTable tableName="person">
            <column name="id" type="int" autoIncrement="true">
                <constraints primaryKey="true" nullable="false"/>
            </column>
            <column name="firstname" type="varchar(50)"/>
            <column name="lastname" type="varchar(50)">
                <constraints nullable="false"/>
            </column>
            <column name="state" type="char(2)"/>
        </createTable>
    </changeSet>

    <changeSet id="2" author="nvoxland">
        <addColumn tableName="person">
            <column name="username" type="varchar(8)"/>
        </addColumn>
    </changeSet>
    <changeSet id="3" author="nvoxland">
        <addLookupTable
            existingTableName="person" existingColumnName="state"
            newTableName="state" newColumnName="id" newColumnDataType="char(2)"/>
    </changeSet>

</databaseChangeLog>
```

### YAML Format

```
databaseChangeLog:
  - preConditions:
    - runningAs:
        username: liquibase

  - changeSet:
      id: 1
      author: nvoxland
      changes:
        - createTable:
            tableName: person
            columns:
              - column:
                  name: id
                  type: int
                  autoIncrement: true
                  constraints:
                    primaryKey: true
                    nullable: false
              - column:
                  name: firstname
                  type: varchar(50)
              - column:
                  name: lastname
                  type: varchar(50)
                  constraints:
                    nullable: false
              - column:
                  name: state
                  type: char(2)
  - ... ...
  - changeSet:
      id: 3
      author: nvoxland
      changes:
        - addLookupTable:
            existingTableName: person
            existingColumnName:state
            newTableName: state
            newColumnName: id
            newColumnDataType: char(2)
```

### JSON Format

```
{
    "databaseChangeLog": [
        {
            "preConditions": [
                {
                    "runningAs": {
                        "username": "liquibase"
                    }
                }
            ]
        },
        {
            "changeSet": {
                "id": "1",
                "author": "nvoxland",
                "changes": [
                    {
                        "createTable": {
                            "tableName": "person",
                            "columns": [
                                {
                                    "column": {
                                        "name": "id",
                                        "type": "int",
                                        "autoIncrement": true,
                                        "constraints": {
                                            "primaryKey": true,
                                            "nullable": false
                                        },
                                    }
                                },
                                {
                                    "column": {
                                        "name": "firstname",
                                        "type": "varchar(50)"
                                    }
                                },
                                {
                                    "column": {
                                        "name": "lastname",
                                        "type": "varchar(50)",
                                        "constraints": {
                                            "nullable": false
                                        },
                                    }
                                },
                                {
                                    "column": {
                                        "name": "state",
                                        "type": "char(2)"
                                    }
                                }
                            ]
                        }
                    }
                ]
            }
        },
		... ...
        {
            "changeSet": {
                "id": "3",
                "author": "nvoxland",
                "changes": [
                    {
                        "addLookupTable": {
                            "existingTableName": "person",
                            "existingColumnName":"state",
                            "newTableName": "state",
                            "newColumnName": "id",
                            "newColumnDataType": "char(2)",
                        }
                    }
                ]
            }
        }
    ]
}
```

### Formatted SQL Changelogs

- SQL 格式

 SQL文件使用注释来提供liquidbase所需要的元数据. 每个SQL文件第一行必须以如下注释开始:
```
	--liquibase formatted sql
```

- Changesets

 每个changeset必须以如下注释开始:
```
	--changeset author:id attribute1:value1 attribute2:value2 [...]
```
- Changeset 可用的配置属性

属性|描述
---|---
stripComments|Set to true to remove any comments in the SQL before executing, otherwise false. Defaults to true if not set
splitStatements|Set to false to not have liquibase split statements on ;'s and GO's. Defaults to true if not set
endDelimiter|Delimiter to apply to the end of the statement. Defaults to ";", may be set to "".
runAlways|Executes the change set on every run, even if it has been run before
runOnChange|Executes the change the first time it is seen and each time the change set has been changed
context|Executes the change if the particular context was passed at runtime. Any string can be used for the context name and they are checked case-insensitively.
logicalFilePath|Use to override the file name and path when creating the unique identifier of change sets. Required when moving or renaming change logs.
labels|Labels are general purpose way to categorize changeSets like contexts, but working in the opposite way. Instead of defining a set of contexts at runtime and then a match expression in the changeSet, you define a set of labels in the context and a match expression at runtime.
runInTransaction|Should the changeSet be ran as a single transaction (if possible)? Defaults to true. Warning: be careful with this attribute. If set to false and an error occurs part way through running a changeSet containing multiple statements, the Liquibase databasechangelog table will be left in an invalid state
failOnError|Should the migration fail if an error occurs while executing the changeSet?
dbms|The type of a database which that changeSet is to be used for. When the migration step is running, it checks the database type against this attribute. Valid database type names are listed on the 数据库支持说明章节
logicalFilePath|Sets a logical file path in databasechangelog table instead of physical file location of sql where the liquibase executed.

- 前置条件

 前置条件可以为每个changeset提供所需的配置.
```
	--preconditions onFail:HALT onError:HALT
	--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM my_table
```

- 回滚操作

 回滚操作是通过注释来实现的.每个changeset中可以使用如下配置实现回滚操作.
```
--rollback SQL STATEMENT
```

- 简单的 Change Log 样例
```
	--liquibase formatted sql
	
	--changeset nvoxland:1
	create table test1 (
	    id int primary key,
	    name varchar(255)
	);
	--rollback drop table test1;
	
	--changeset nvoxland:2
	insert into test1 (id, name) values (1, ‘name 1′);
	insert into test1 (id, name) values (2, ‘name 2′);
	
	--changeset nvoxland:3 dbms:oracle
	create sequence seq_test;
```
## Diffs
### Report Mode
```
Base Database: BOB jdbc:oracle:thin:@testdb:1521:latest
Target Database: BOB jdbc:oracle:thin:@localhost/XE
Product Name: EQUAL
Product Version:
     Base:   'Oracle Database 10g Enterprise Edition Release 10.2.0.1.0
With the Partitioning, OLAP and Data Mining options'
     Target: 'Oracle Database 10g Express Edition Release 10.2.0.1.0'
Missing Tables: NONE
Unexpected Tables: NONE
Missing Views: NONE
Unexpected Views: NONE
Missing Columns:
     CREDIT.MONTH
     CREDIT.COMPANY
     CMS_TEMPLATE.CLASSTYPE
     CONTENTITEM.SORTORDER
Unexpected Columns:
     CATEGORY.SORTORDER
Missing Foreign Keys: NONE
Unexpected Foreign Keys:
     FK_NAME (ID_VC -> STATUS_ID_VC)
Missing Primary Keys: NONE
Unexpected Primary Keys: NONE
Missing Indexes: NONE
Unexpected Indexes: NONE
Missing Sequences: NONE
Unexpected Sequences: NONE
```
### ChangeLog Mode
```
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog/1.1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog/1.1
        http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-1.1.xsd">
    <changeSet author="diff-generated" id="1185206820975-1">
        <addColumn tableName="CREDIT">
            <column name="MONTH" type="VARCHAR2(10)"/>
        </addColumn>
    </changeSet>
    <changeSet author="diff-generated" id="1185206820975-2">
        <addColumn tableName="CREDIT">
            <column name="COMPANY" type="NUMBER(22,0)"/>
        </addColumn>
    </changeSet>
    <changeSet author="diff-generated" id="1185206820975-3">
        <addColumn tableName="CMS_TEMPLATE">
            <column name="CLASSTYPE" type="VARCHAR2(255)"/>
        </addColumn>
    </changeSet>
    <changeSet author="diff-generated" id="1185206820975-4">
        <addColumn tableName="CONTENTITEM">
            <column name="SORTORDER" type="NUMBER(22)"/>
        </addColumn>
    </changeSet>
    <changeSet author="diff-generated" id="1185206820975-5">
        <dropColumn columnName="SORTORDER" tableName="CATEGORY"/>
    </changeSet>
    <changeSet author="diff-generated" id="1185206820975-6">
        <dropForeignKeyConstraint baseTableName="CMS_STATUS"
                     constraintName="FK_NAME"/>
    </changeSet>
</databaseChangeLog>
```

## 命令行
liquidbase 命令行格式如下:
```
	liquibase [options] [command] [command parameters]
```
也可以使用
```
	java -jar <path-to-liquibase-jar> [options] [command] [command parameters]
```

### 数据库更新命令

命令|描述
---|---
update|Updates database to current version.
updateCount &lt;value>|Applies the next <value> change sets.
updateSQL|Writes SQL to update database to current version to STDOUT.
updateCountSQL &lt;value>|Writes SQL to apply the next <value> change sets to STDOUT.


### 数据库回滚命令

命令|描述
---|---
rollback &lt;tag>|Rolls back the database to the state it was in when the tag was applied.
rollbackToDate &lt;date/time>|Rolls back the database to the state it was in at the given date/time.
rollbackCount &lt;value>|Rolls back the last <value> change sets.
rollbackSQL &lt;tag>|Writes SQL to roll back the database to the state it was in when the tag was applied to STDOUT.
rollbackToDateSQL &lt;date/time>|Writes SQL to roll back the database to the state it was in at the given date/time version to STDOUT.
rollbackCountSQL &lt;value>|Writes SQL to roll back the last <value> change sets to STDOUT.
futureRollbackSQL|Writes SQL to roll back the database to the current state after the changes in the changeslog have been applied.
updateTestingRollback|Updates the database, then rolls back changes before updating again.
generateChangeLog|generateChangeLog of the database to standard out. v1.8 requires the dataDir parameter currently.

### Diff 命令

命令|描述
---|---
diff [diff parameters]|Writes description of differences to standard out.
diffChangeLog [diff parameters]|Writes Change Log XML to update the base database to the target database to standard out.

### 文档命令

命令|描述
---|---
dbDoc &lt;outputDirectory>|Generates Javadoc-like documentation based on current database and change log.

### 维护命令

命令|描述
---|---
tag &lt;tag>|"Tags" the current database state for future rollback.
tagExists &lt;tag>|Checks whether the given tag is already existing.
status|Outputs count (list if --verbose) of unrun change sets.
validate|Checks the changelog for errors.
changelogSync|Mark all changes as executed in the database.
changelogSyncSQL|Writes SQL to mark all changes as executed in the database to STDOUT.
markNextChangeSetRan|Mark the next change set as executed in the database.
listLocks|Lists who currently has locks on the database changelog.
releaseLocks|Releases all locks on the database changelog.
dropAll|Drops all database objects owned by the user. Note that functions, procedures and packages are not dropped (limitation in 1.8.1).
clearCheckSums|Removes current checksums from database. On next run checksums will be recomputed.

### 必要参数

选项|描述
---|---
--changeLogFile=&lt;path and filename>|The changelog file to use.
--username=&lt;value>|Database username.
--password=&lt;value>|Database password.
--url=&lt;value>|Database JDBC URL.
--driver=&lt;jdbc.driver.ClassName>|Database driver class name.

### 可选参数

选项|描述
---|---
--classpath=&lt;value>|Classpath containing migration files and JDBC Driver.
--contexts=&lt;value>|ChangeSet contexts to execute.
--defaultSchemaName=&lt;schema>|Specifies the default schema to use for managed database objects and for Liquibase control tables.
--databaseClass=&lt;custom.DatabaseImpl>|Specifies a custom Database implementation to use
--defaultsFile=&lt;/path/to/file>|File containing default option values. (default: ./liquibase.properties)
--includeSystemClasspath=&lt;true or false>|Include the system classpath in the Liquibase classpath. (default: true)
--promptForNonLocalDatabase=&lt;true or false>|Prompt if non-localhost databases. (default: false)
--currentDateTimeFunction=&lt;value>|Overrides current date time function used in SQL. Useful for unsupported databases.
--logLevel=&lt;level>|Execution log level (debug, info, warning, severe, off).
--help|Output command line parameter help.
--exportDataDir|Directory where insert statement csv files will be kept (required by generateChangeLog command).
--propertyProviderClass=&lt;properties.ClassName>|custom Properties implementation to use

### Diff 命令必要参数

选项|描述
---|---
--referenceUsername=&lt;value>|Base Database username.
--referencePassword=&lt;value>|Base Database password.
--referenceUrl=&lt;value>|Base Database URL.

### Diff 命令可选参数

选项|描述
---|---
--referenceDriver=&lt;jdbc.driver.ClassName>|Base Database driver class name.

### Change Log 配置

选项|描述
---|---
-D&lt;property.name>=&lt;property.value>|Pass a name/value pair for substitution of ${} blocks in the change log(s).

如果不想每次都在命令行中输入配置参数,也可以使用liquibase.properties文件来代替，默认情况liquidbase会在当前工作空间中寻找liquidbase.properties文件,也可以使用--defaultsFile来指定配置文件路径
```
# liquibase.properties

driver: oracle.jdbc.OracleDriver
classpath: jdbcdriver.jar
url: jdbc:oracle:thin:@localhost:1521:oracle
username: scott
password: tiger
```

### 例子
更新数据库到最新版本
```
java -jar liquibase.jar 
      --driver=oracle.jdbc.OracleDriver 
      --classpath=\path\to\classes:jdbcdriver.jar 
      --changeLogFile=com/example/db.changelog.xml 
      --url="jdbc:oracle:thin:@localhost:1521:oracle" 
      --username=scott 
      --password=tiger 
      update
```
不执行changeset,将变更脚本写入到/tmp/script.sql
```
java -jar liquibase.jar 
        --driver=oracle.jdbc.OracleDriver 
        --classpath=jdbcdriver.jar 
        --url=jdbc:oracle:thin:@localhost:1521:oracle 
        --username=scott 
        --password=tiger 
        updateSQL > /tmp/script.sql
```
比对两个数据库之间的区别
```
java -jar liquibase.jar 
        --driver=oracle.jdbc.OracleDriver 
        --url=jdbc:oracle:thin:@testdb:1521:test
        --username=bob
        --password=bob
        --referenceUrl=jdbc:oracle:thin:@localhost/XE
        --referenceUsername=bob
        --referencePassword=bob
        diff
```