##es6 模板说明
```
{
	"order": 0,//优先级,数字越小级别越高
	"template": "ik-test*",//索引名称匹配
	"settings": {
		"index": {
			"number_of_shards": "2",//分片个数
			"number_of_replicas": "0"//副本个数
		}
	},
	"mappings": {
		"logs": {//匹配的type类型
			"properties": {
				"word1": {//字段名称
					"type": "text",//字段类型对应es2的string类型中index配置为analyzed的配置
					"analyzer": "ik_smart",//ik分词
					"fielddata": "true"//text类型字段如果需要使用聚合,该值需要为true
				},
				"word2": {
					"type": "keyword",//字段类型对应es2的string类型中index配置为not_analyzed的配置
					"fields": {//字段别名
						"raw1": {//别名,搜索时使用word2.raw1进行搜索
							"type": "text",
							"analyzer": "ik_max_word"//ik分词,最大粒度的拆分
						}
					}
				},
				"word3": {
					"type": "text",
					"index": "false"//该值为false时该字段不可查询和聚合
				},
				"ip": {
					"type": "ip"//ip类型
				},
				"time1": {
					"type": "date",//时间类型
					"format": "strict_date_optional_time||epoch_millis"//时间格式
				},
				"time2": {
					"type": "date",
					"format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
				}
			}
		}
	}
}
```