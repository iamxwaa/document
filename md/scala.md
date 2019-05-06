# scala

 Scala 是一种函数对象混合的语言，具有一些强大的优点：

- Scala 可编译为 Java 字节码，这意味着它在 JVM 上运行。除了允许继续利用丰富的 Java 开源生态系统之外，Scala 还可以集成到现有的 IT 环境中，无需进行迁移。

- Scala 基于 Haskell 和 ML 的函数原则，大量借鉴了 Java 程序员钟爱的面向对象概念。因此，它可以将两个领域的优势混合在一起，从而提供了显著的优点，而且不会失去我们一直依赖的熟悉的技术。

## 优势

- 兼容 Java
  这点很明显（其他 200 多种 JVM 上的语言也兼容 Java），但它是如此重要的一个功能，因此不可小视。它意味着 Scala 可以使用所有 Java 库和框架爱。这也是对那些投资该技术的人员和公司的表达敬意。

- 联合编译（Joint Compilation）
  这表示与 Groovy 类似，Scala 类被编译为 Java 类，因此可以在 Java 项目中使用（甚至在他们被定义的同一项目中的 java 类 使用）。即使你的团队觉得完全转向 Scala，对于通过 JSR 223 整合动态语言，这依然很有用。

- 类型推断（Type Inference）
  如果编译器能猜到类型（通常它可以做到），你就不必告诉它。这使得 Scala 代码具有动态语言的简洁性，而同时保持类型安全。

- 隐式转换（Implicit conversion）
  使 Scala 具有类型安全性，正如扩展方法（extension method）之于 C#，开放类（open class）之于 ruby。即：向你未曾定义的类型添加方法（如字符串、列表、整数）。这是使得 Scala 符合 DSL（特定领域语言）模型的特性之一。

- 对象不变性
  scala 甚至提供了内置的不变对象垃圾收集器。对于Scala有这样一种说法：“每当提到不变性时，有人就会开始担心性能的问题，对于某些情况，这种担忧并非毫无来由，但对于 Scala，最终结果却与这一担忧相反。不可变的数据结构相对于可变的数据结构，更有助于获得较高的效率。其原因之一在于强大的垃圾收集器（garbage collector），与 JVM 中的垃圾收集器类似。”

- 自动生成 Getter 和 Setter
  如果你不需要（比如你只需 Setter），你必须显示地将他们私有化（private）。这不是问题，因为通常情况都需要。

- 函数具有第一等级（first-order）
  通过 iterable trait 实现了枚举协议（enumeration protocol），这有助于让代码更加干净、更加简洁，并能够带来其他一些好处。

- Actor 编程模式
  让高度并行应用程序的开发更加简单。

- 不必显示抓取或抛出(try-catch)异常
  可以认为使用已检查异常（checked exception）的害处多于好处。

## 劣势

- 语法复杂, 学习曲线非常高
- 国内 Scala 程序员很难找 (目前 Scala 的影响力也在缓慢扩大, 比如 Scala 社区中的明星 Spark 的流行也在慢慢拉动 Scala 的流行, 如同 rails 之于 ruby)
- 社区, 生态还比较小, Scala 风格的库还非常少(但可以和 Java 很容易的斜街很多时候弥补了这一点)

## scala语言与java的区别

- scala支持关联映射，如可以用`(key -> value)`表示一个键值对

- scala中的所有类型都是对象，包括基本数据类型

- scala中的case语句用来判断接收的消息，比java中的`switch...case...`更专注`receive{    case msg => action()    }`

- scala行动类实现了线程之上的并发抽象，通过发送消息相互通信，每个行动类都自动维护一个消息队列，并且实现发送消息和接收消息的基本操作。`receriver ! msg`

- scala是静态类型的，也即在编译之前就需要确定参数的类型，与C++的参数化类型相似

- scala包含两种类型的变量，val变量相当于java中的`const`，`var`则是常规变量

- scala中的基本数据类型，来源于Java中对相应数据类型的类封装，String类型则相同

- scala具有类型推断功能，在可由上下文推断的情况下，可以省略类型说明，如：`val x = 4`

- scala通过def关键字定义函数，在缺省显式return语句的情况下，返回函数最后计算得到的值

- scala采用`println`直接输出到标准输出，而不用`System.out.println`

- scala中的数组索引是`args(0)`，而非java中的`args[0]`

- scala数组Array包含方法`foreach(action)`，其中action是一个传入的函数，例如：`x => println(x)`

- scala提供指令式：`for(arg <- args)    println(arg)`

- scala中的所有操作符都是方法的调用，例如：`1+2`，等效于`(1).+(2)`
`0 to 5`，等效于`(0).to(5)`，`x(1)="scala"`，等效于`(x).update(1,"scala")`，`x(1)`等效于`(x).apply(1)`
scala通过定义伴生对象，分离静态成员，类似于java中的static关键字

- scala Array数组中所有对象都具有相同类型，实例化后数组长度不能再改变，但是数组元素值可以改变List数组中的元素值则不可改变，List有"::"实现叠加功能，操作符会创建一个新的List，List不支持append操作

- scala包含新的容器对象Tuple，元组可以包含多个不同类型的对象，例如：`val tp = (1,2,"scala")`，中tp就是一个Tuple[Int,Int,String]对象，tp._1表示取第一个元素

- scala中Set和Map类型有可变和不可变两种实现方式，分别保存在不同的包中

- scala没有"++"操作符

- scala提供trait关键字，描述对象的特质，类似于java中的接口interface

- scala提倡函数式编程风格，减少var变量的使用，这样可以得到简洁可读性更强的代码

- scala从文件中读取数据，`Source.fromFile("filename").getLines()`返回一个Iterator[String]对象

- scala中的"=="操作符比较的是值的相等性，提供函数eq、ne比较引用的相等性

- 每个类都继承自Any，scala中“\==”和equals相同，可以通过重写equals方法改变“==”的意义。类Any有两个子类，AnyVal和AnyRef。AnyVal是scala中内建值类的父类，Byte、Short、Char、Int、Long、Float、Double、Boolean、Unit，前面8个和java中的基本类型相对应。Unit大约相当于Java的Void类型，只有一个实例，写成()。在java平台上，AnyRef实际上就是java.lang.Object的别名。

- scala类和java类的不同还在于其继承了一个名为ScalaObject的记号特质，目前为止ScalaObject只包含一个方法名为$tag，在内部使用以加速模式匹配。

- Null类是null引用对象的类型，它是每个引用类的子类，Null不兼容值类型，不能把null赋给整数变量。Nothing类型在scala类层级的最底端，它是任何其他类型的子类型，然而根本没有这个类型的任何值，Nothing的一个用处是标明程序的不正常终止。

## 适用范围

- scala可用于web开发：web框架如lift、play

- scala可用于大数据：spark

## 技术应用

### 安装部署

- 下载地址 [http://www.scala-lang.org/download/](http://www.scala-lang.org/download/)

- 配置

  ```shell
  cd ~
  vi .bash_profile
  export SCALA_HOME=/home/xw/scala-2.11.8
  export PATH=$SCALA_HOME/bin:$PATH
  :wq
  ```

- 启用配置. .bash_profile

- 测试:输入 scala 有控制台

### 应用实例

#### Hello World

```scala
object Hw {
  def main(args: Array[String]): Unit = {
    println("hello world")
    Console.print("hello world")
  }
}
```

#### 隐式转换

```scala
object Impli2 {

  class Terminal(path: String, f: String => Unit) {

    def this(path: String) = this(path, x => println(x))

    def more = Source.fromFile(path, "UTF-8").getLines().foreach { x => println(x) }
    def more(f: String => Unit) = Source.fromFile(path, "UTF-8").getLines().foreach(f)
  }

  implicit def cov(path: String) = new Terminal(path)
  implicit def cov(path: Unit) = new Terminal2

  class Terminal2{
    def lineToArray = (x: String) => {
      val arr = x.split(" ")
          printf("%s:%s:%s:%s\n",arr(0),arr(1),arr(2),arr(3))
    }
  }
  
  def main(args: Array[String]): Unit = {
    "f:\\city.txt" more

    //"f:\\city.txt" more lineToArray
  }
}
```

#### actor模式

````scala
object Akka3 {

  def main(args: Array[String]): Unit = {
    val total = 1000000000
    val nrOfWorkers = 4

    startOneThread(total)
    startActor(total, nrOfWorkers)
  }

  def startOneThread(total: Int) = {
    var count = 0
    val start = System.currentTimeMillis
    for (i <- 0 until total) {
      count += 1
    }
    println("one thread cost time " + (System.currentTimeMillis - start) +"\none thread count "+count)
  }

  def startActor(total: Int, nrOfWorkers: Int) = {
    val nrOfMessages = total / nrOfWorkers
    val system = ActorSystem("messageSystem")
    val listener = system.actorOf(Props[Listener], "listener")
    val master = system.actorOf(Props(new Master(nrOfWorkers, nrOfMessages, listener)), "master")

    master ! Start
  }

  sealed trait Message
  case object Start extends Message
  case class Make(count: Int) extends Message
  case class Receive(count: Int) extends Message
  case class Finish(time: Long)

  class Master(nrOfWorkers: Int, nrOfMessages: Int, listener: ActorRef) extends Actor {
    val workerRouter = context.actorOf(Props[Maker].withRouter(RoundRobinRouter(nrOfWorkers)), "workerRouter")
    var msgCount = 0
    val total = nrOfMessages * nrOfWorkers
    val start = System.currentTimeMillis
    def receive = {
      case Start =>
        for (i <- 0 until nrOfWorkers)
          workerRouter ! Make(nrOfMessages)
      case Receive(count) =>
        msgCount += count
        if (msgCount == total) {
          println("akka count " + msgCount)
          listener ! Finish(System.currentTimeMillis - start)
          context.stop(self)
        }
    }
  }

  class Maker extends Actor {
    def receive = {
      case Make(count) =>
        var tmp = 0
        for (i <- 0 until count) {
          tmp += 1
        }
        sender ! Receive(tmp)
    }

    def msg: String = self.hashCode.toString
  }

  class Listener extends Actor {
    def receive = {
      case Finish(time) =>
        println("akka cost time " + time)
        context.system.shutdown()
    }
  }

}
````

### 参考资料

1. <http://developer.51cto.com/art/200906/127830.htm>
2. <http://www.ibm.com/developerworks/cn/java/j-scala/>
3. <http://www.scala-lang.org/api/current/>
