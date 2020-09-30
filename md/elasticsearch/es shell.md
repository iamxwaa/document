# elasticsearch 快捷脚本

## 删除标记为red的索引

```shell
#!/bin/bash
address=192.168.119.215:9200
curl -s $address/_cat/indices | grep red | awk '{print $3}' | while read arr
do
    curl -X DELETE $address/$arr
done
```
