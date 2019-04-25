**hadoop 集群kerberos连接认证**
--
+ 设置系统环境变量

		System.setProperty("java.security.krb5.conf", PropertiesTools.getKerberosValue("krb5.conf"));
		System.setProperty("java.security.krb5.realm", PropertiesTools.getKerberosValue("krb5.realm"));
		System.setProperty("java.security.krb5.kdc", PropertiesTools.getKerberosValue("krb5.kdc"));
		System.setProperty("java.security.auth.useSubjectCredsOnly", "false");
		System.setProperty("java.security.krb5.debug", "true");
  设置java.security.krb5.conf后可以不设置java.security.krb5.realm和java.security.krb5.kdc,如果设置了，则两个属性都要设置

+ hdfs认证

		Configuration conf = new Configuration();
		//获取hdfs-site.xml和core-site.xml的文件路径
		String hdfs = PropertiesTools.getKerberosValue("hdfs.site");
		String core = PropertiesTools.getKerberosValue("core.site");
		conf.addResource(new FileInputStream(new File(hdfs)), "hdfs-site.xml");
		conf.addResource(new FileInputStream(new File(core)), "core-site.xml");

		UserGroupInformation.setConfiguration(conf);
		//填写认证账号以及票据文件路径
		UserGroupInformation.loginUserFromKeytab(PropertiesTools.getKerberosValue("keytab.user.hadoop"),
				PropertiesTools.getKerberosValue("keytab.hadoop"));

		FileSystem fs = FileSystem.get(conf);
		...

+ hbase认证

		Configuration conf = new Configuration();
		conf.set("hbase.zookeeper.property.clientPort", ZK_PORT);
		conf.set("hbase.zookeeper.quorum", ZK_QUORUM);
		conf.set("zookeeper.znode.parent", ZK_NODE);
		conf.set("hbase.master.kerberos.principal", PropertiesTools.getKerberosValue("hbase.master.princ"));
		conf.set("hbase.regionserver.kerberos.principal", PropertiesTools.getKerberosValue("hbase.region.princ"));
		conf.set("hadoop.security.authentication", "kerberos");
		conf.set("hbase.security.authentication", "kerberos");
		conf.set("kerberos.principal", PropertiesTools.getKerberosValue("keytab.user.hbase"));

		UserGroupInformation.setConfiguration(conf);
		UserGroupInformation.loginUserFromKeytab(PropertiesTools.getKerberosValue("keytab.user.hbase"),
				PropertiesTools.getKerberosValue("keytab.hbase"));

		Connection conn = ConnectionFactory.createConnection(conf);
		...

+ yarn认证

		YarnClient client = YarnClient.createYarnClient();

		Configuration conf = new Configuration();
		conf.set(YarnConfiguration.RM_ADDRESS, HDFSTools.RM);
		//获取yarn-site.xml和core-site.xml的文件路径
		String yarn = PropertiesTools.getKerberosValue("yarn.site");
		String core = PropertiesTools.getKerberosValue("core.site");
		conf.addResource(new FileInputStream(new File(yarn)), "yarn-site.xml");
		conf.addResource(new FileInputStream(new File(core)), "core-site.xml");

		UserGroupInformation.setConfiguration(conf);
		UserGroupInformation.loginUserFromKeytab(PropertiesTools.getKerberosValue("keytab.user.yarn"),
				PropertiesTools.getKerberosValue("keytab.yarn"));

		client.init(conf);
		client.start();
		...

+ hive认证

	`jdbc:hive2://vrv145:10000/bap;principal=hive/_HOST@me`

+ oozie认证

	- 使用jaas认证
	- 使用AuthOozieClient获取客户端连接

代码如下

		package com.vrv.vap.auth;

		import java.security.PrivilegedAction;

		import javax.security.auth.Subject;
		import javax.security.auth.login.LoginContext;
		import javax.security.auth.login.LoginException;

		import org.apache.oozie.client.AuthOozieClient;
		import org.apache.oozie.client.OozieClient;

		import com.vrv.vap.client.OzClient;

		/**
 		* oozie认证及操作
 		* 
 		* @author xw
 		*
 		*         2017年7月18日
 		*/
		public class OozieKerberosAuthClient<T> {
			private LoginContext loginContext;
			private Subject subject;
			private T result;

			/**
	 		* 读取jaas文件配置并登陆
	 		* 
	 		* @return
	 		* @throws LoginException
	 		*/
			public OozieKerberosAuthClient<T> login() throws LoginException {
				if (KerberosAuth.KERBEROS_SWITCH) {
					loginContext = new LoginContext("OzClient");
					loginContext.login();
					this.subject = loginContext.getSubject();
				}
				return this;
			}

			/**
	 		* 执行任务
	 		* 
	 		* @param action
	 		* @return
	 		*/
			public OozieKerberosAuthClient<T> run(PrivilegedAction<T> action) {
				if (KerberosAuth.KERBEROS_SWITCH) {
					this.result = Subject.doAs(this.subject, action);
				} else {
					this.result = action.run();
				}
				return this;
			}

			/**
	 		* 获取结果并退出登陆
	 		* 
	 		* @return
	 		* @throws LoginException
	 		*/
			public T getResult() throws LoginException {
				if (KerberosAuth.KERBEROS_SWITCH) {
					loginContext.logout();
				}
				return this.result;
			}

			/**	
	 		* 获取连接客户端
	 		* 
	 		* @return
	 		*/
			public OozieClient getOozieClient() {
				OozieClient client = new OozieClient(OzClient.OZ_URL);
				if (KerberosAuth.KERBEROS_SWITCH) {
					client = new AuthOozieClient(OzClient.OZ_URL);
				}
				return client;
			}
		}

+ jass.conf

		OzClient {
		com.sun.security.auth.module.Krb5LoginModule required
		useKeyTab=true
		keyTab="f:/kerberos/oozie.keytab"
		principal="oozie/vrv148@me"
		useTicketCache=false
		storeKey=true
		doNotPrompt=true
		debug=true;
		};