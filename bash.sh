
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


watch -n1 'ps aux|grep [z]abbix_server >> zabbix_activity.log;echo "====================" >> zabbix_activity.log;sleep 1'


# check the disk performance with this command
sar -dp -w 1 10



# clear log
> /var/log/zabbix/zabbix_proxy.log

# increase logging for poller
zabbix_proxy -R log_level_increase="poller"

# start collection for five minutes
tcpdump -i any udp port 161 -w pcap.pcap
# brake the operation with CTRL+C

# decrease logging for poller
zabbix_proxy -R log_level_decrease="poller"

