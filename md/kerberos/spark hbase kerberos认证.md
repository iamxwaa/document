# spark读取kerberos认证的hbase集群

-----------

## 使用hbase api链接habse时

- spark-submit提交任务时添加以下参数

```
--conf "spark.executor.extraJavaOptions=-Djava.security.krb5.conf=/vrv/sparkbar/krb5.conf"
--conf "spark.driver.extraJavaOptions=-Djava.security.krb5.conf=/vrv/sparkbar/krb5.conf"
```

为driver和excutor设置kerberos认证配置的环境变量

- 将所需的票据文件上传到hdfs

```
hdfs://vrv203:8020/user/vrv/hbase.keytab
```

在spark初始完上下文后将票据文件读取进来，分发到每个excutor的工作目录下

```
val sc: SparkContext = new SparkContext(SparkCfg.getSpkConfig(this.getClass.getName))
sc.addFile("hdfs://vrv203:8020/user/vrv/hbase.keytab")
```

后续获取票据文件使用spark的api获取文件位置

```
SparkFiles.get("hbase.keytab")
```

- 连接时设置一下参数

```
val conf = new Configuration
conf.set("hbase.zookeeper.property.clientPort", "2181")
conf.set("hbase.zookeeper.quorum", "vrv145,vrv147,vrv148")
conf.set("zookeeper.znode.parent", "/hbase")
conf.set("hbase.master.kerberos.principal", "hbase/_HOST@me")
conf.set("hbase.regionserver.kerberos.principal", "hbase/_HOST@me")
conf.set("hadoop.security.authentication", "kerberos")
conf.set("hbase.security.authentication", "kerberos")
conf.set("kerberos.principal", "hbase/vrv145@me")
```

- 认证

```
val path = SparkFiles.get("hbase.keytab")
UserGroupInformation.setConfiguration(conf)
UserGroupInformation.loginUserFromKeytabAndReturnUGI("hbase/vrv145@me",path)
```

- 认证后获取ugi用来创建habse连接

```
val conn = ugi.doAs(new PrivilegedAction[Connection] {
	override def run(): Connection = ConnectionFactory.createConnection(conf)
})
```
后续使用获取的conn连接hbase操作即可

## spark rdd api读取kerberos认证的hbase

- 因为rdd是分布的，所以每个获取rdd的机器需要对hbase进行认证才能获取到数据，所以需要重写rdd对hbase进行认证。
> 网上也有说通过hbase的token进行认证,没搜到相关资料故放弃

- 重写代码如下

```
package org.apache.spark.rdd

import java.io.{EOFException, IOException}
import java.security.PrivilegedExceptionAction
import java.text.SimpleDateFormat
import java.util.Date

import com.vrv.scas.extend.StringExtend
import com.vrv.scas.hbase.HbaseClient.{getHbaseConf, getUserGroupInfomation}
import org.apache.hadoop.conf.{Configurable, Configuration}
import org.apache.hadoop.io.Writable
import org.apache.hadoop.mapred.JobConf
import org.apache.hadoop.mapreduce._
import org.apache.hadoop.mapreduce.lib.input.{CombineFileSplit, FileSplit}
import org.apache.spark._
import org.apache.spark.annotation.DeveloperApi
import org.apache.spark.deploy.SparkHadoopUtil
import org.apache.spark.executor.DataReadMethod
import org.apache.spark.mapreduce.SparkHadoopMapReduceUtil
import org.apache.spark.rdd.NewHadoopRDD.NewHadoopMapPartitionsWithSplitRDD
import org.apache.spark.storage.StorageLevel
import org.apache.spark.util.{SerializableConfiguration, ShutdownHookManager}

import scala.reflect.ClassTag

/**
* 重写的rdd类用来读取kerberos认证的hbase集群
*
* @param sc
* @param inputFormatClass
* @param keyClass
* @param valueClass
* @param _conf
* @tparam K
* @tparam V
*/
class HBaseScanRDD[K, V](
	sc: SparkContext,
	inputFormatClass: Class[_ <: InputFormat[K, V]],
	keyClass: Class[K],
	valueClass: Class[V],
	@transient private val _conf: Configuration)
	extends RDD[(K, V)](sc, Nil)
		with SparkHadoopMapReduceUtil
		with Logging {
	// A Hadoop Configuration can be about 10 KB, which is pretty big, so broadcast it
	private val confBroadcast = sc.broadcast(new SerializableConfiguration(_conf))
	// private val serializableConf = new SerializableWritable(_conf)
	private val jobTrackerId: String = {
		val formatter = new SimpleDateFormat("yyyyMMddHHmm")
		formatter.format(new Date())
	}
	@transient protected val jobId = new JobID(jobTrackerId, id)
	private val shouldCloneJobConf = sparkContext.conf.getBoolean("spark.hadoop.cloneConf", false)
	private val ignoreCorruptFiles =
		sparkContext.conf.getBoolean("spark.files.ignoreCorruptFiles", true)

	def getConf: Configuration = {
		val conf: Configuration = confBroadcast.value.value
		if (shouldCloneJobConf) {
			// Hadoop Configuration objects are not thread-safe, which may lead to various problems if
			// one job modifies a configuration while another reads it (SPARK-2546, SPARK-10611).  This
			// problem occurs somewhat rarely because most jobs treat the configuration as though it's
			// immutable.  One solution, implemented here, is to clone the Configuration object.
			// Unfortunately, this clone can be very expensive.  To avoid unexpected performance
			// regressions for workloads and Hadoop versions that do not suffer from these thread-safety
			// issues, this cloning is disabled by default.
			NewHadoopRDD.CONFIGURATION_INSTANTIATION_LOCK.synchronized {
				logDebug("Cloning Hadoop Configuration")
				// The Configuration passed in is actually a JobConf and possibly contains credentials.
				// To keep those credentials properly we have to create a new JobConf not a Configuration.
				if (conf.isInstanceOf[JobConf]) {
					new JobConf(conf)
				} else {
					new Configuration(conf)
				}
			}
		} else {
			conf
		}
	}

	override def getPartitions: Array[Partition] = {
		val inputFormat = inputFormatClass.newInstance
		inputFormat match {
			case configurable: Configurable =>
				configurable.setConf(_conf)
			case _ =>
		}
		val jobContext = newJobContext(_conf, jobId)
		val rawSplits = HBaseUtil.ugiDoAs(() => {
			inputFormat.getSplits(jobContext).toArray
		}: Array[Object])
		val result = new Array[Partition](rawSplits.size)
		for (i <- 0 until rawSplits.size) {
			result(i) = new NewHadoopPartition(id, i, rawSplits(i).asInstanceOf[InputSplit with Writable])
		}
		result
	}

	override def compute(theSplit: Partition, context: TaskContext): InterruptibleIterator[(K, V)] = {
		val iter = new Iterator[(K, V)] {
			val split = theSplit.asInstanceOf[NewHadoopPartition]
			logInfo("Input split: " + split.serializableHadoopSplit)
			val conf = getConf
			val inputMetrics = context.taskMetrics
				.getInputMetricsForReadMethod(DataReadMethod.Hadoop)
			// Sets the thread local variable for the file's name
			split.serializableHadoopSplit.value match {
				case fs: FileSplit => SqlNewHadoopRDDState2.setInputFileName(fs.getPath.toString)
				case _ => SqlNewHadoopRDDState2.unsetInputFileName()
			}
			// Find a function that will return the FileSystem bytes read by this thread. Do this before
			// creating RecordReader, because RecordReader's constructor might read some bytes
			val bytesReadCallback = inputMetrics.bytesReadCallback.orElse {
				split.serializableHadoopSplit.value match {
					case _: FileSplit | _: CombineFileSplit =>
						SparkHadoopUtil.get.getFSBytesReadOnThreadCallback()
					case _ => None
				}
			}
			inputMetrics.setBytesReadCallback(bytesReadCallback)
			val format = inputFormatClass.newInstance
			format match {
				case configurable: Configurable =>
					configurable.setConf(conf)
				case _ =>
			}
			val attemptId = newTaskAttemptID(jobTrackerId, id, isMap = true, split.index, 0)
			val hadoopAttemptContext = newTaskAttemptContext(conf, attemptId)
			private var reader = HBaseUtil.ugiDoAs(() => {
				val _reader = format.createRecordReader(
					split.serializableHadoopSplit.value, hadoopAttemptContext)
				_reader.initialize(split.serializableHadoopSplit.value, hadoopAttemptContext)
				_reader
			}: RecordReader[K, V])
			// Register an on-task-completion callback to close the input stream.
			context.addTaskCompletionListener(context => close())
			var havePair = false
			var finished = false
			var recordsSinceMetricsUpdate = 0

			override def hasNext: Boolean = {
				if (!finished && !havePair) {
					try {
						finished = !reader.nextKeyValue
					} catch {
						case _: EOFException if ignoreCorruptFiles => finished = true
					}
					if (finished) {
						// Close and release the reader here; close() will also be called when the task
						// completes, but for tasks that read from many files, it helps to release the
						// resources early.
						close()
					}
					havePair = !finished
				}
				!finished
			}

			override def next(): (K, V) = {
				if (!hasNext) {
					throw new java.util.NoSuchElementException("End of stream")
				}
				havePair = false
				if (!finished) {
					inputMetrics.incRecordsRead(1)
				}
				(reader.getCurrentKey, reader.getCurrentValue)
			}

			private def close() {
				if (reader != null) {
					SqlNewHadoopRDDState2.unsetInputFileName()
					// Close the reader and release it. Note: it's very important that we don't close the
					// reader more than once, since that exposes us to MAPREDUCE-5918 when running against
					// Hadoop 1.x and older Hadoop 2.x releases. That bug can lead to non-deterministic
					// corruption issues when reading compressed input.
					try {
						reader.close()
					} catch {
						case e: Exception =>
							if (!ShutdownHookManager.inShutdown()) {
								logWarning("Exception in RecordReader.close()", e)
							}
					} finally {
						reader = null
					}
					if (bytesReadCallback.isDefined) {
						inputMetrics.updateBytesRead()
							} else if (split.serializableHadoopSplit.value.isInstanceOf[FileSplit] ||
						split.serializableHadoopSplit.value.isInstanceOf[CombineFileSplit]) {
						// If we can't get the bytes read from the FS stats, fall back to the split size,
						// which may be inaccurate.
						try {
							inputMetrics.incBytesRead(split.serializableHadoopSplit.value.getLength)
						} catch {
							case e: java.io.IOException =>
								logWarning("Unable to get input size to set InputMetrics for task", e)
						}
					}
				}
			}
		}
		new InterruptibleIterator(context, iter)
	}

	/** Maps over a partition, providing the InputSplit that was used as the base of the partition. */
	@DeveloperApi
	def mapPartitionsWithInputSplit[U: ClassTag](
																								f: (InputSplit, Iterator[(K, V)]) => Iterator[U],
																								preservesPartitioning: Boolean = false): RDD[U] = {
		new NewHadoopMapPartitionsWithSplitRDD(this, f, preservesPartitioning)
	}

	override def getPreferredLocations(hsplit: Partition): Seq[String] = {
		val split = hsplit.asInstanceOf[NewHadoopPartition].serializableHadoopSplit.value
		val locs = HadoopRDD.SPLIT_INFO_REFLECTIONS match {
			case Some(c) =>
				try {
					val infos = c.newGetLocationInfo.invoke(split).asInstanceOf[Array[AnyRef]]
					Some(HadoopRDD.convertSplitLocationInfo(infos))
				} catch {
					case e: Exception =>
						logDebug("Failed to use InputSplit#getLocationInfo.", e)
						None
				}
			case None => None
		}
		locs.getOrElse(split.getLocations.filter(_ != "localhost"))
	}

	override def persist(storageLevel: StorageLevel): this.type = {
		if (storageLevel.deserialized) {
			logWarning("Caching NewHadoopRDDs as deserialized objects usually leads to undesired" +
				" behavior because Hadoop's RecordReader reuses the same Writable object for all records." +
				" Use a map transformation to make copies of the records.")
		}
		super.persist(storageLevel)
	}
}

object HBaseUtil {
	protected implicit def stringTools2(v: String): StringExtend = new StringExtend(v)

	@throws[IOException]
	def ugiDoAs[A](func: () => A): A = {
		val conf = getHbaseConf
		val filename = "keytab.hbase".getPropStringVal.substring("keytab.hbase".getPropStringVal.lastIndexOf("/") + 1)
		val ugi = getUserGroupInfomation(conf, SparkFiles.get(filename))
		ugi.checkTGTAndReloginFromKeytab()
		ugi.doAs(new PrivilegedExceptionAction[A] {
			def run: A = {
				func()
			}
		})
	}
}
```

- spark 1.5版本使用会出现classnotfound的问题,需添加以下类

```
package org.apache.spark.rdd

import org.apache.spark.unsafe.types.UTF8String

object SqlNewHadoopRDDState2 {
	private[this] val inputFileName: ThreadLocal[UTF8String] = new ThreadLocal[UTF8String] {
		override protected def initialValue(): UTF8String = UTF8String.fromString("")
	}

	def getInputFileName(): UTF8String = inputFileName.get()

	private[spark] def setInputFileName(file: String) = inputFileName.set(UTF8String.fromString(file))

	private[spark] def unsetInputFileName(): Unit = inputFileName.remove()
}
```