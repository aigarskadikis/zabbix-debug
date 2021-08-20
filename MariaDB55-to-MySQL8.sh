#!/bin/bash

# On the MariaDB 5.5 server

# Do everything via 'screen' utility
yum -y install screen

# enter 'screen' mode
screen -L -S mysqldump

# Do schema backup
mysqldump --flush-logs --single-transaction --create-options --no-data zabbix | gzip --fast > schema.sql.gz

# Do data backup without historical data
mysqldump --flush-logs --single-transaction --no-create-info --ignore-table=zabbix.history --ignore-table=zabbix.history_log --ignore-table=zabbix.history_str --ignore-table=zabbix.history_text --ignore-table=zabbix.history_uint --ignore-table=zabbix.trends --ignore-table=zabbix.trends_uint zabbix | gzip --fast > data.sql.gz

# Backup data tables individually
mysqldump --flush-logs --single-transaction --no-create-db --no-create-info zabbix history_uint | gzip --fast > history_uint.sql.gz
mysqldump --flush-logs --single-transaction --no-create-db --no-create-info zabbix history_log | gzip --fast > history_log.sql.gz
mysqldump --flush-logs --single-transaction --no-create-db --no-create-info zabbix history_str | gzip --fast > history_str.sql.gz
mysqldump --flush-logs --single-transaction --no-create-db --no-create-info zabbix history_text | gzip --fast > history_text.sql.gz
mysqldump --flush-logs --single-transaction --no-create-db --no-create-info zabbix history | gzip --fast > history.sql.gz
mysqldump --flush-logs --single-transaction --no-create-db --no-create-info zabbix trends | gzip --fast > trends.sql.gz
mysqldump --flush-logs --single-transaction --no-create-db --no-create-info zabbix trends_uint | gzip --fast > trends_uint.sql.gz


# On the MySQL 8 server

rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum -y install mysql-community-server
setenforce 0
grep "temporary password" /var/log/mysqld.log | sed "s|^.*localhost:.||" | xargs -i echo "/usr/bin/mysqladmin -u root password 'z4bbi#SIA' -p'{}'" | sudo bash
cat << 'EOF' > ~/.my.cnf
[client]
user=root
password='z4bbi#SIA'
EOF
systemctl start mysqld

# create a fresh database
mysql -e "
CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER 'zabbix'@'%' IDENTIFIED BY 'z4bbi#SIA';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%';
FLUSH PRIVILEGES;
"

# Insert schema
zcat schema.sql.gz | mysql zabbix
# This will create all partitions as in old server

# Restore the main data
zcat data.sql.gz | mysql zabbix

# Install all dependencies required by partitioning script:
yum -y install python3 python3-pip
pip3.6 install mysql-connector-python
pip3.6 install pyyaml

# Upload 'zabbix_partitioning.conf' to '/etc/zabbix'. This file defines when to drop partitions

# Upload partitioning script to '/usr/bin/zabbix_partitioning.py' and set it executable
chmod +x /usr/bin/zabbix_partitioning.py

# Check help
zabbix_partitioning.py --help
# It should print exactly:
# usage: zabbix_partitioning.py [-h] [-c /etc/zabbix/zabbix_partitioning.conf]
#                               [-i] [-d] [-r]
# 
# This application is used to manage Zabbix database partitions on MySQL database
# 
# optional arguments:
#   -h, --help            show this help message and exit
#   -c /etc/zabbix/zabbix_partitioning.conf, --config /etc/zabbix/zabbix_partitioning.conf
#                         MySQL Partitioning script configuration file
#   -i, --init            Init partitions on selected tables
#   -d, --delete          Delete partitioning on selected tables
#   -r, --dry-run         Print SQL queries, do not perform any changes in database
  

# Try dry run to create future partitions
zabbix_partitioning.py --dry-run
# output should contain some SQL statements but nothing like 'error'

# Have a look how we have missing partitions in future:
mysql zabbix -e "
SHOW CREATE TABLE history\G
"

# create a cronjob to see how it executes in the very next minut
echo '* * * * * root zabbix_partitioning.py' | sudo tee /etc/cron.d/zabbix_partitioning

# make sure new partitions got made in future:
mysql zabbix -e "
SHOW CREATE TABLE history\G
"

# overwrite the cronjob to only execute at 3:03 AM and 8:03 AM
echo '3 3,8 * * * root zabbix_partitioning.py' | sudo tee /etc/cron.d/zabbix_partitioning

# Restore data back. This will take days. Can make a batch to execute all commands in a row.
# Make sure to done this through 'screen' utility
zcat history_uint.sql.gz | mysql zabbix
zcat history_log.sql.gz | mysql zabbix
zcat history_str.sql.gz | mysql zabbix
zcat history_text.sql.gz | mysql zabbix
zcat history.sql.gz | mysql zabbix
zcat trends.sql.gz | mysql zabbix
zcat trends_uint.sql.gz | mysql zabbix

