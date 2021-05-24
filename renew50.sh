mysqldump \
--set-gtid-purged=OFF \
--flush-logs \
--single-transaction \
--no-create-info \
--ignore-table=zabbix.history \
--ignore-table=zabbix.history_log \
--ignore-table=zabbix.history_str \
--ignore-table=zabbix.history_text \
--ignore-table=zabbix.history_uint \
--ignore-table=zabbix.trends \
--ignore-table=zabbix.trends_uint \
zabbix > ~/data.sql


CREATE DATABASE future CHARACTER SET utf8 COLLATE utf8_bin;



cd /tmp
wget https://cdn.zabbix.com/zabbix/sources/stable/5.0/zabbix-5.0.12.tar.gz
tar xvf zabbix-5.0.12.tar.gz



cd /tmp/zabbix-5.0.12/database/mysql
cat schema.sql ~/data.sql | mysql future


cd

mysqldump \
--set-gtid-purged=OFF \
--flush-logs \
--single-transaction \
--ignore-table=future.history \
--ignore-table=future.history_log \
--ignore-table=future.history_str \
--ignore-table=future.history_text \
--ignore-table=future.history_uint \
--ignore-table=future.trends \
--ignore-table=future.trends_uint \
future > ~/schema.data.sql

cat 
