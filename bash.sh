
# show slow mysql updates
grep slow.*update /var/log/zabbix/zabbix_server.log
grep slow.*update /var/log/zabbix/zabbix_proxy.log

# show slow mysql inserts
grep slow.*insert /var/log/zabbix/zabbix_server.log
grep slow.*insert /var/log/zabbix/zabbix_proxy.log

# show slow queries
grep slow /var/log/zabbix/zabbix_server.log
grep slow /var/log/zabbix/zabbix_proxy.log



# debuging odbc connection which use DSN to Oracle database
sudo -uzabbix env

# set the right character set and collate to the instance
mysql --database=zabbix -B -N -e "SHOW TABLES" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}' | mysql --database=zabbix

# set the right character set and collate to the instance if DB host is remotely
mysql -h location.to.db.instance --database=zabbix -B -N -e "SHOW TABLES" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}' | mysql  -h location.to.db.instance --database=zabbix

# spliting the log file into pieces
cd
gzip -c /<path>/strace.log | split -b 14m - strace.gz
