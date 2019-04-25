##elasticsearch 快捷脚本

###删除标记为red的索引

	#!/bin/bash
	curl -s 192.168.119.215:9200/_cat/indices | grep red | awk '{print $3}' | while read arr
	do
	  curl -X DELETE 192.168.119.215:9200/$arr
	done