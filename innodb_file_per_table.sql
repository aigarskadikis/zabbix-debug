
--do a snapshot, backup of vmware

--following steps can be execute on the fly. this is tested and works on MariaDB 5.5.68 (CentOS 7.8.2003).

--Perform these task via 'screen' utility. Start with smallest table.
--Measure all table sizes:
mysql zabbix
SELECT table_name,table_rows,data_length,index_length,round(((data_length + index_length) / 1024 / 1024 / 1024),2) "Size in GB" FROM information_schema.tables WHERE table_schema = "zabbix" ORDER BY round(((data_length + index_length) / 1024 / 1024 / 1024),2) DESC LIMIT 8;



--Rename 'history_uint' in database:
--{code}
RENAME TABLE history_uint TO history_uint_old; CREATE TABLE history_uint LIKE history_uint_old;
RENAME TABLE history_str TO history_str_old; CREATE TABLE history_str LIKE history_str_old;
RENAME TABLE history_text TO history_text_old; CREATE TABLE history_text LIKE history_text_old;
RENAME TABLE history_log TO history_log_old; CREATE TABLE history_log LIKE history_log_old;
RENAME TABLE history TO history_old; CREATE TABLE history LIKE history_old;
RENAME TABLE trends_uint TO trends_uint_old; CREATE TABLE trends_uint LIKE trends_uint_old;
RENAME TABLE trends TO trends_old; CREATE TABLE trends LIKE trends_old;
--{code}

exit

--Download schema:

cd
mysqldump --flush-logs --single-transaction --create-options --no-data zabbix history_uint_old > schema.history_uint_old.sql
mysqldump --flush-logs --single-transaction --create-options --no-data zabbix history_str_old > schema.history_str_old.sql
mysqldump --flush-logs --single-transaction --create-options --no-data zabbix history_text_old > schema.history_text_old.sql
mysqldump --flush-logs --single-transaction --create-options --no-data zabbix history_log_old > schema.history_log_old.sql
mysqldump --flush-logs --single-transaction --create-options --no-data zabbix history_old > schema.history_old.sql
mysqldump --flush-logs --single-transaction --create-options --no-data zabbix trends_uint_old > schema.trends_uint_old.sql
mysqldump --flush-logs --single-transaction --create-options --no-data zabbix trends_old > schema.trends_old.sql

--7 files
ls -lh *_old.sql
ls -lh *_old.sql | wc -l


--Download data:
cd
mysqldump --flush-logs --single-transaction --no-create-info zabbix history_uint_old | gzip --fast > data.history_uint_old.sql.gz
mysqldump --flush-logs --single-transaction --no-create-info zabbix history_str_old | gzip --fast > data.history_str_old.sql.gz
mysqldump --flush-logs --single-transaction --no-create-info zabbix history_text_old | gzip --fast > data.history_text_old.sql.gz
mysqldump --flush-logs --single-transaction --no-create-info zabbix history_log_old | gzip --fast > data.history_log_old.sql.gz
mysqldump --flush-logs --single-transaction --no-create-info zabbix history_old | gzip --fast > data.history_old.sql.gz
mysqldump --flush-logs --single-transaction --no-create-info zabbix trends_uint_old | gzip --fast > data.trends_uint_old.sql.gz
mysqldump --flush-logs --single-transaction --no-create-info zabbix trends_old | gzip --fast > data.trends_old.sql.gz

--observe sizes
ls -lh *.sql.gz

--measure if there is content inside dump
zcat data.history_uint_old.sql.gz | head -24
zcat data.history_str_old.sql.gz | head -24
zcat data.history_text_old.sql.gz | head -24
zcat data.history_log_old.sql.gz | head -24
zcat data.history_old.sql.gz | head -24
zcat data.trends_uint_old.sql.gz | head -24
zcat data.trends_old.sql.gz | head -24


--Drop 'old' tables
mysql zabbix
DROP TABLE history_uint_old;
DROP TABLE history_str_old;
DROP TABLE history_text_old;
DROP TABLE history_log_old;
DROP TABLE history_old;
DROP TABLE trends_uint_old;
DROP TABLE trends_old;

SHOW TABLES;
-- it should be only 166 tables

--list again size of biggest tables:
SELECT table_name,table_rows,data_length,index_length,round(((data_length + index_length) / 1024 / 1024 / 1024),2) "Size in GB" FROM information_schema.tables WHERE table_schema = "zabbix" ORDER BY round(((data_length + index_length) / 1024 / 1024 / 1024),2) DESC LIMIT 8;
--the size should be very small

exit

--turn down zabbix server and frontend
systemctl stop zabbix-server zabbix-agent rh-nginx116-nginx rh-php72-php-fpm 
--make sure no process is running
ps aux | grep "[z]abbix_server"

--stop database engine
systemctl stop mariadb

--remove data directory
rm -rf '/var/lib/mysql/*'

mysql_install_db


--install customization file:
cd /etc/my.cnf.d
cat << 'EOF' > zabbix.cnf
[mysqld]
innodb_flush_method = O_DIRECT
max_connections = 2000
innodb_file_per_table=1
EOF

--selinux is off
setenforce 0

--start mariadb server
systemctl start mariadb




create user zabbix@localhost identified by 'password';

grant all privileges on zabbix.* to zabbix@localhost;

exit 

cat schema.sql | mysql -uzabbix -ppassword zabbix

zcat data.sql.gz | mysql -uzabbix -ppassword zabbix

--start the instance back
systemctl start zabbix-server


--bring back old tables
cat *_old.sql | mysql -uzabbix -ppassword zabbix

show tables;
--it prints 173

--insert back data in background
zcat data.history_uint_old.sql.gz | mysql -uzabbix -ppassword zabbix
zcat data.history_str_old.sql.gz | mysql -uzabbix -ppassword zabbix
zcat data.history_text_old.sql.gz | mysql -uzabbix -ppassword zabbix
zcat data.history_log_old.sql.gz | mysql -uzabbix -ppassword zabbix
zcat data.history_old.sql.gz | mysql -uzabbix -ppassword zabbix
zcat data.trends_uint_old.sql.gz | mysql -uzabbix -ppassword zabbix
zcat data.trends_old.sql.gz | mysql -uzabbix -ppassword zabbix


--set old table as current and move back recent data
RENAME TABLE history_uint TO history_uint_tmp; RENAME TABLE history_uint_old TO history_uint; INSERT IGNORE INTO history_uint SELECT * FROM history_uint_tmp;
RENAME TABLE history_str TO history_str_tmp; RENAME TABLE history_str_old TO history_str; INSERT IGNORE INTO history_str SELECT * FROM history_str_tmp;
RENAME TABLE history_text TO history_text_tmp; RENAME TABLE history_text_old TO history_text; INSERT IGNORE INTO history_text SELECT * FROM history_text_tmp;
RENAME TABLE history_log TO history_log_tmp; RENAME TABLE history_log_old TO history_log; INSERT IGNORE INTO history_log SELECT * FROM history_log_tmp;
RENAME TABLE history TO history_tmp; RENAME TABLE history_old TO history; INSERT IGNORE INTO history SELECT * FROM history_tmp;
RENAME TABLE trends_uint TO trends_uint_tmp; RENAME TABLE trends_uint_old TO trends_uint; INSERT IGNORE INTO trends_uint SELECT * FROM trends_uint_tmp;
RENAME TABLE trends TO trends_tmp; RENAME TABLE trends_old TO trends; INSERT IGNORE INTO trends SELECT * FROM trends_tmp;

--check if there is old data and recent data in frontend. graphs should be now complete (except 5-10 minutes downtime)

--drop 'tmp' tables:
DROP TABLE history_uint_tmp;
DROP TABLE history_str_tmp;
DROP TABLE history_text_tmp;
DROP TABLE history_log_tmp;
DROP TABLE history_tmp;
DROP TABLE trends_uint_tmp;
DROP TABLE trends_tmp;

show tables;
--it should be only 166 tables

sudo du -a /var/lib/mysql/ | sort -n -r | head -n 20





