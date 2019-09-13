
# show slow mysql updates
grep slow.*update /var/log/zabbix/zabbix_server.log
grep slow.*update /var/log/zabbix/zabbix_proxy.log

# show slow mysql inserts
grep slow.*insert /var/log/zabbix/zabbix_server.log
grep slow.*insert /var/log/zabbix/zabbix_proxy.log

# show slow queries
grep slow /var/log/zabbix/zabbix_server.log
grep slow /var/log/zabbix/zabbix_proxy.log


for i in `seq 1 10`; do echo $(date) >> /tmp/zabbix.proc && ps aux | grep zabbix >> /tmp/zabbix.proc && sleep 5; done


for i in `seq 1 10`; do echo $(date) >> /tmp/httpd.stats && curl -sLk https://127.0.0.1/server-status?auto >> /tmp/httpd.stats && sleep 5; done


watch -n .2 'ps aux | grep [t]rapper'


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

# what is using swap. During issue please run
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r


# clear log
> /var/log/zabbix/zabbix_proxy.log

# increase logging for poller
zabbix_proxy -R log_level_increase="poller"

# start collection for five minutes
tcpdump -i any udp port 161 -w pcap.pcap
# brake the operation with CTRL+C

# decrease logging for poller
zabbix_proxy -R log_level_decrease="poller"

# check that compression enabled for Server and Proxy
strings $(which zabbix_server)|grep -i zlib
strings $(which zabbix_proxy)|grep -i zlib

ps auxw | grep "data sender" | awk '{print " -p " $2}'|xargs strace -s 256 -T -tt -f -o proxy.strace.out


