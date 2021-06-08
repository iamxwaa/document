./sqoop eval --connect jdbc:mysql://192.168.119.208:3306/xw \
--username root \
--password root \
--query "select * from xw.base_area limit 10"

./sqoop import \
--connect jdbc:mysql://192.168.119.208:3306/xw \
--username root \
--password root \
--table base_area \
--fields-terminated-by '\t' \
--delete-target-dir \
--num-mappers 2 \
--hive-import \
--hive-database xw \
--hive-table base_area_from_mysql