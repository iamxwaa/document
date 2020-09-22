# MinIO

- [下载 MinIO Server 和 MinIO Client](https://min.io/download)

- 使用说明

  - 启动

    ```bash
    #设置认证信息
    export MINIO_ACCESS_KEY=admin
    export MINIO_SECRET_KEY=admin123

    #启动 minio.exe [FLAGS] COMMAND [ARGS...]
    minio server --anonymous /data
    ```

  - 配置上传结果保存elasticsearch

    ```bash
    mc admin config set local notify_elasticsearch:1 queue_limit="0"  url="http://192.168.120.135:9200" format="namespace" index="minio_events" queue_dir="" username="" password=""

    mc event add local/exe arn:minio:sqs::1:elasticsearch
    ```

- Java Api使用

  - 添加依赖

    ```xml
    <dependency>
        <groupId>io.minio</groupId>
        <artifactId>minio</artifactId>
        <version>7.1.0</version>
    </dependency>
    ```

  - 代码

    ```java
    package com.example.demo;

    import java.io.File;
    import java.io.IOException;
    import java.security.InvalidKeyException;
    import java.security.NoSuchAlgorithmException;

    import org.apache.commons.io.FileUtils;

    import io.minio.BucketExistsArgs;
    import io.minio.DownloadObjectArgs;
    import io.minio.MakeBucketArgs;
    import io.minio.MinioClient;
    import io.minio.ObjectWriteResponse;
    import io.minio.PutObjectArgs;
    import io.minio.errors.MinioException;

    public class MinioTest {

        static String url = "http://192.168.118.139:9000";
        static String accessKey = "admin";
        static String secretKey = "admin123";

        public static void main(String[] args) {
            String bucket = "exe";
            String path = "D:\\Tools\\44.0.2403.157_chrome_installer.exe";
            String contentType = "application/exe";

            // String bucket = "zip";
            // String path = "D:\\Tools\\apache-maven-3.1.1-bin.zip";
            // String contentType = "arachive/zip";

            try {
                ObjectWriteResponse objectWriteResponse = upload(bucket, path, contentType);
                download(objectWriteResponse.bucket(), objectWriteResponse.object(),
                        "F:\\miniotest\\save\\" + objectWriteResponse.object());
            } catch (InvalidKeyException | IllegalArgumentException | NoSuchAlgorithmException | IOException e) {
                e.printStackTrace();
            }
        }

        private static ObjectWriteResponse upload(String bucket, String path, String contentType)
                throws InvalidKeyException, IllegalArgumentException, NoSuchAlgorithmException, IOException {
            try {
                // 使用MinIO服务的URL，端口，Access key和Secret key创建一个MinioClient对象
                MinioClient minioClient = MinioClient.builder().endpoint(url).credentials(accessKey, secretKey).build();

                // 检查存储桶是否已经存在
                BucketExistsArgs bucketExistsArgs = BucketExistsArgs.builder().bucket(bucket).build();
                boolean isExist = minioClient.bucketExists(bucketExistsArgs);
                if (isExist) {
                    System.out.println("Bucket already exists.");
                } else {
                    // 创建一个名为asiatrip的存储桶，用于存储照片的zip文件。
                    MakeBucketArgs makeBucketArgs = MakeBucketArgs.builder().bucket(bucket).build();
                    minioClient.makeBucket(makeBucketArgs);
                }

                // 使用putObject上传一个文件到存储桶中。
                File file = new File(path);
                System.out.println(
                        String.format("%s is successfully uploaded as %s to `%s` bucket.", file, file.getName(), bucket));
                ObjectWriteResponse objectWriteResponse = minioClient
                        .putObject(PutObjectArgs.builder().bucket(bucket).object(file.getName())
                                .stream(FileUtils.openInputStream(file), -1, 10485760).contentType(contentType).build());

                System.out.println(objectWriteResponse);
                return objectWriteResponse;
            } catch (MinioException e) {
                System.out.println("Error occurred: " + e);
            }
            return null;
        }

        private static void download(String bucket, String name, String path) {
            try {
                // 使用MinIO服务的URL，端口，Access key和Secret key创建一个MinioClient对象
                MinioClient minioClient = MinioClient.builder().endpoint(url).credentials(accessKey, secretKey).build();

                // 下载文件
                DownloadObjectArgs downloadObjectArgs = DownloadObjectArgs.builder().bucket(bucket).object(name)
                        .filename(path).build();
                minioClient.downloadObject(downloadObjectArgs);
            } catch (MinioException | InvalidKeyException | IllegalArgumentException | NoSuchAlgorithmException
                    | IOException e) {
                System.out.println("Error occurred: " + e);
            }
        }
    }
    ```

- 问题

  > ErrorResponse(code = AccessDenied, message = Access denied ...
  > 可能服务器时间和本地相差太大
  