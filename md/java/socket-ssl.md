# Java Socket SSL双向认证

- 准备服务端和客户端的秘钥

```bash
#生成服务端秘钥
keytool -genkey -keystore server_ks.jks -storepass test_server -keyalg RSA -keypass test_server -keysize 2048 -validity 7000

#生成服务端证书
keytool -export -keystore server_ks.jks -storepass test_server -file server.cer

#生成客户端秘钥
keytool -genkey -keystore client_ks.jks -storepass test_client -keyalg RSA -keypass test_client -keysize 2048 -validity 7000

#生成客户端证书
keytool -export -keystore client_ks.jks -storepass test_client -file client.cer

#将服务端证书导入到服务端truststore中
keytool -import -keystore serverTrust_ks.jks -storepass test_server -file server.cer

#将客户端证书导入到服务端truststore中
keytool -import -keystore clientTrust_ks.jks -storepass test_client -file client.cer
```

- 服务端代码

```java
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLServerSocket;
import javax.net.ssl.TrustManagerFactory;
import java.io.*;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.security.KeyStore;

public class SslServer {

    public static File writeToFile1 = new File("D:\\test\\配置.txt");
    public static File writeToFile2 = new File("D:\\test\\配置2.txt");

    public static void main(String[] args) throws InterruptedException {
        new Thread(new ServerOne()).start();
        Thread.sleep(3600 * 1000);
    }

    public static class ServerOne implements Runnable {

        // SSL协议版本
        private static final String TLS = "TLSv1.2";
        // KeyStore的类型
        private static final String PROVIDER = "SunX509";
        // 秘钥类型,java默认是JKS,Android不支持JKS,只能用BKS
        private static final String STORE_TYPE = "JKS";
        // 秘钥的路径
        private static final String KEY_STORE_NAME = "D:\\test\\server_ks.jks";

        private static final String TRUST_STORE_NAME = "D:\\test\\clientTrust_ks.jks";
        // Server的端口
        private static final int DEFAULT_PORT = 8090; // 自定义端口
        // 秘钥的密码
        private static final String SERVER_KEY_STORE_PASSWORD = "test_server"; // 秘钥的密码
        private static final String SERVER_TRUST_KEY_STORE_PASSWORD = "test_client";// 密码

        @Override
        public void run() {

            SSLServerSocket sslServerSocket = null;
            try {
                // 获取SSLContext
                SSLContext sslContext = SSLContext.getInstance(TLS);

                // 生成秘钥的manager
                KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(PROVIDER);
                // 加载信任的证书
                TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(PROVIDER);
                // 加载秘钥
                KeyStore keyStoreOne = KeyStore.getInstance(STORE_TYPE);
                KeyStore keyStoreTwo = KeyStore.getInstance(STORE_TYPE);
                keyStoreOne.load(new FileInputStream(KEY_STORE_NAME), SERVER_KEY_STORE_PASSWORD.toCharArray());
                keyStoreTwo.load(new FileInputStream(TRUST_STORE_NAME), SERVER_TRUST_KEY_STORE_PASSWORD.toCharArray());
                // 秘钥初始化
                keyManagerFactory.init(keyStoreOne, SERVER_KEY_STORE_PASSWORD.toCharArray());
                trustManagerFactory.init(keyStoreTwo);
                // 初始化SSLContext
                sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);
                // 获取SSLContext的SocketFactory
                sslServerSocket = (SSLServerSocket) sslContext.getServerSocketFactory()
                        .createServerSocket(DEFAULT_PORT);
                // 是否开启双向验证
                sslServerSocket.setNeedClientAuth(true);
                System.out.println("服务器已开启,等待连接 .....");
                while (true) {
                    Socket accept = sslServerSocket.accept();
                    accept.setKeepAlive(true);
                    System.out.println("客户端 : " + accept.getInetAddress().getHostAddress());

                    try (InputStream inputStream = accept.getInputStream();
                            OutputStream outputStream = accept.getOutputStream();) {
                        byteMsgReader(inputStream, outputStream);
                        // socket.shutdownOutput(); // 长连接则不关闭输出流
                        // socket.shutdownInput(); // 长连接则不关闭输入流
                    } catch (Exception e) {
                        System.out.println(e.toString());
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();

                try {
                    if (sslServerSocket != null) {
                        sslServerSocket.close();
                        System.out.println("服务器关闭！");
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    /**
     * 字节流-解析客户端的消息
     */
    public static void byteMsgReader(InputStream inputStream, OutputStream outputStream) throws Exception {
        BufferedInputStream bufferedInputStream = new BufferedInputStream(inputStream);
        FileOutputStream bufferedOutputStream1 = new FileOutputStream(writeToFile1, false);
        FileOutputStream bufferedOutputStream2 = new FileOutputStream(writeToFile2, false);
        byte[] b = new byte[4096];
        int i = 0;
        while ((i = bufferedInputStream.read(b)) > 0) {
            bufferedOutputStream1.write(b, 0, i);
            bufferedOutputStream1.flush();
            if (i < b.length) { // 根据读取的长度是否满格判断当前文件是否已读取完毕
                bufferedOutputStream1.close();
                break;
            }
        }
        System.out.println("接收完成第一个文件");
        byteMsgWriter(outputStream);
        i = 0;
        byte[] b2 = new byte[4096];
        while ((i = bufferedInputStream.read(b2)) > 0) {
            bufferedOutputStream2.write(b2, 0, i);
            bufferedOutputStream2.flush();
            if (i < b2.length) { // 根据读取的长度是否满格判断当前文件是否已读取完毕
                bufferedOutputStream2.close();
                break;
            }
        }
        System.out.println("接收完成第二个文件");
        byteMsgWriter(outputStream);
    }

    /**
     * 字节流-发送给客户端回执消息
     */
    public static void byteMsgWriter(OutputStream outputStream) throws Exception {
        BufferedOutputStream bufferedOutputStreamBack = new BufferedOutputStream(outputStream);
        bufferedOutputStreamBack.write("服务端已成功接收文件.".getBytes(StandardCharsets.UTF_8));
        bufferedOutputStreamBack.write("\n".getBytes(StandardCharsets.UTF_8));
        bufferedOutputStreamBack.flush(); // 第一次发送消息，长连接实现方式
    }

}
```

- 客户端代码

```java
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.TrustManagerFactory;
import java.io.*;
import java.security.KeyStore;

public class SslClient {

    public static File readFile = new File("D:\\test\\pom.xml");

    public static void main(String[] args) throws InterruptedException {
        new Thread(new ClientOne()).start();
        Thread.sleep(3600 * 1000);
    }

    public static class ClientOne implements Runnable {

        private static final String TLS = "TLSv1.2";
        private static final String PROVIDER = "SunX509";
        private static final String STORE_TYPE = "JKS";
        private static final String TRUST_STORE_NAME = "D:\\test\\serverTrust_ks.jks";
        private static final String KEY_STORE_NAME = "D:\\test\\client_ks.jks";
        private static final String CLIENT_KEY_STORE_PASSWORD = "test_client"; // 密码
        private static final String CLIENT_TRUST_KEY_STORE_PASSWORD = "test_server";// 密码

        @Override
        public void run() {

            SSLSocket socket = null;
            try {
                SSLContext sslContext = SSLContext.getInstance(TLS);
                KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(PROVIDER);
                // 生成信任证书Manager,默认系统会信任CA机构颁发的证书,自定的证书需要手动的加载
                TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(PROVIDER);
                KeyStore keyStoreOne = KeyStore.getInstance(STORE_TYPE);
                KeyStore keyStoreTwo = KeyStore.getInstance(STORE_TYPE);
                // 加载client端密钥
                keyStoreOne.load(new FileInputStream(KEY_STORE_NAME), CLIENT_KEY_STORE_PASSWORD.toCharArray());
                // 信任证书
                keyStoreTwo.load(new FileInputStream(TRUST_STORE_NAME), CLIENT_TRUST_KEY_STORE_PASSWORD.toCharArray());
                keyManagerFactory.init(keyStoreOne, CLIENT_KEY_STORE_PASSWORD.toCharArray());
                trustManagerFactory.init(keyStoreTwo);

                // 初始化
                sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

                // 此种写法代表客户端信任所有证书
                /*
                 * TrustManager[] trustAllCerts = new TrustManager[]{new X509TrustManager() {
                 * public java.security.cert.X509Certificate[] getAcceptedIssuers() { return new
                 * java.security.cert.X509Certificate[]{}; } public void
                 * checkClientTrusted(X509Certificate[] chain, String authType) { } public void
                 * checkServerTrusted(X509Certificate[] chain, String authType) { } }}; //初始化
                 * sslContext.init(keyManagerFactory.getKeyManagers(), trustAllCerts, null);
                 */

                socket = (SSLSocket) sslContext.getSocketFactory().createSocket("192.168.122.139", 12345);
                socket.setKeepAlive(true);
                // socket.setSoTimeout(10000);
                try (InputStream inputStream = socket.getInputStream();
                        OutputStream outputStream = socket.getOutputStream();) {
                    byteMsgWriter(outputStream, inputStream);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            } catch (Exception e) {
                e.printStackTrace();

                try {
                    if (socket != null) {
                        socket.close();
                        System.out.println("客户端关闭");
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    /**
     * 字节流-发送给服务端
     */
    public static void byteMsgWriter(OutputStream outputStream, InputStream inputStream) throws Exception {
        BufferedInputStream bufferedInputStream = new BufferedInputStream(new FileInputStream(readFile));
        BufferedOutputStream bufferedOutputStream = new BufferedOutputStream(outputStream);
        // mark后读取超过readlimit字节数据，mark标记就会失效
        bufferedInputStream.mark(909600000);
        byte[] b = new byte[4096];
        int i;
        while ((i = bufferedInputStream.read(b)) > 0) {
            bufferedOutputStream.write(b, 0, i);
            bufferedOutputStream.flush(); // 第一次发送消息，长连接实现方式
        }

        bufferedInputStream.reset();
        Thread.sleep(1); // 必须加休眠，否则第二个文件流会发生错乱
        characterMsgReader(inputStream); // 从服务端接收消息
        while ((i = bufferedInputStream.read(b)) > 0) {
            bufferedOutputStream.write(b, 0, i);
            bufferedOutputStream.flush(); // 第二次发送消息，长连接实现方式
        }
        characterMsgReader(inputStream); // 从服务端接收消息
    }

    /**
     * 字符流-解析服务端的回执消息-不间断解析
     */
    public static void characterMsgReader(InputStream inputStream) throws Exception {
        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
        String line;
        while ((line = bufferedReader.readLine()) != null) {
            System.out.println("服务端消息： " + line);
        }
    }

}
```
