

ps aux | grep ^zabbix.*synced | grep -E -o "synced configuration in [0-9\.]+ sec"

# see agent uptime
date
ps -eo pid,lstart,cmd | grep "[z]abbix_agentd.conf"

ps www -eo cmd

/* cpu and mem usage */
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head


iostat -c

nc -zv 192.168.1.15 22


# sessionid in database: 4a91e77a98f6e1d9699e218f01f9523e 
# sid in web server log:                 699e218f01f9523e


cd /var/log/zabbix
sed -n '/20200113:144959.744/,/20200113:145528.999/p' zabbix_server.log > /tmp/long-running-traps.log

sed "s|^[0-9:.\ ]\+||" /var/log/zabbix/zabbix_server.log | sort | uniq -c | sort -n
sed "s|^[0-9:.\ ]\+||" /var/log/zabbix/zabbix_proxy.log | sort | uniq -c | sort -n


# show slow mysql updates
grep slow.*update /var/log/zabbix/zabbix_server.log
grep slow.*update /var/log/zabbix/zabbix_proxy.log

# show slow mysql inserts
grep slow.*insert /var/log/zabbix/zabbix_server.log
grep slow.*insert /var/log/zabbix/zabbix_proxy.log

# show slow queries
grep slow /var/log/zabbix/zabbix_server.log
grep slow /var/log/zabbix/zabbix_proxy.log


cd /var/lib/mysql/zabbix && ls -Slhr | tail -30

# total size of mysql dir
du -sh /var/lib/mysql/
du -sh /var/lib/mysql/zabbix/


ls -alh /data/mysql/zabbix/history*
ls -alh /data/mysql/zabbix/trends*
ls -alh /var/lib/mysql/zabbix/*

# check for Non-breaking space character
sed 's|\xc2\xa0|ISSUEHERE|g' /etc/zabbix/web/zabbix.conf.php | grep ISSUEHERE


# see the struggle of delivering data from proxy perspective
grep "zbx_setproctitle.*title.*data sender" /var/log/zabbix/zabbix_proxy.log | grep "[0-9][0-9]\+\.[0-9]\+ sec"
# it will show the sender session which finally succeeded the data delivering in a time period bigger than 9 seconds
# we will require to see lines before the matched line

zcat /var/log/zabbix/zabbix_server.log-*gz | grep "Starting Zabbix Server\|Zabbix Server stopped\|syncing history data\|syncing trend data"

for i in `seq 1 60`; do ./json_item_tcp.sh >> /tmp/tcp.conn && sleep 1; done; netstat -a >> /tmp/tcp.conn


echo "$(ls -1 /proc/*/environ)" | while IFS= read -r line; do { sudo cat $line | tr '\0' '\n' | sed "s|$|;|" | tr -cd "[:print:]" | grep HOSTNAME; echo;} done
grep -E "PPid:\s+1$" /proc/*/status
sudo grep ^VmRSS /proc/*/status | grep -E "[0-9]{5} kB$"

sudo grep ^VmRSS /proc/*/status | grep -E "[0-9]{5} kB$" | sed "s|status.*$|environ|" | xargs sudo cat



for i in `seq 1 10`; do echo $(date) >> /tmp/zabbix.proc && ps aux | grep zabbix >> /tmp/zabbix.proc && echo "=======" && sleep 1; done


for i in `seq 1 10`; do echo $(date) >> /tmp/zabbix.proc && ps aux | grep zabbix >> /tmp/zabbix.proc && echo "=======" && sleep 1; done

for i in `seq 1 10`; do echo $(date) >> /tmp/zabbix.trapper && ps -ef | grep ^zabbix.*trapper.# >> /tmp/zabbix.trapper && echo "=======" >> /tmp/zabbix.trapper && sleep 1; done


for i in `seq 1 20`; do zabbix_agentd -c /etc/zabbix/zabbix_agentd.conf -t system.uptime >> /tmp/uptime.by.agent.log && sleep 1; done



for i in `seq 1 20`; do zabbix_agentd -c /etc/zabbix/zabbix_agentd.conf -t system.uptime >> /tmp/uptime.by.agent.log && sleep 1; done



for i in `seq 1 20`; do zabbix_agentd -R housekeeper_execute && sleep 1; done



for i in `seq 1 10`; do echo $(date) >> /tmp/httpd.stats && curl -sLk https://127.0.0.1/server-status?auto >> /tmp/httpd.stats && sleep 5; done

for i in `seq 1 10`; do echo $(date) >> /tmp/pollers.busy.log && ps aux| grep ": poller #" >> /tmp/pollers.busy.log && sleep 1; done


for i in `seq 1 10`; do echo $(date) >> /tmp/php-fpm.stats && curl -sLk http://127.0.0.1/status >> /tmp/php-fpm.stats && sleep 1; done

for seq in {1..254};do echo 192.168.99.$seq >> /tmp/engineid.out && snmpget -v 3 -l authPriv -u snmpuser -x AES -X testtest -a SHA -A testtest 192.168.99.$seq <OID> >> /tmp/engineid.out ;done

watch -n .2 'ps aux | grep [t]rapper'


# debuging odbc connection which use DSN to Oracle database
sudo -uzabbix env

# set the right character set and collate to the instance
mysql --database=zabbix -B -N -e "SHOW TABLES" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}' | mysql --database=zabbix

# set the right character set and collate to the instance if DB host is remotely
mysql -h location.to.db.instance --database=zabbix -B -N -e "SHOW TABLES" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}' | mysql  -h location.to.db.instance --database=zabbix

# The biggest tables are history, history_uint, trends, trends_uint. These tables are storing only numbers. There is no point to install collation since the numbers can not be lower case or upper case. We will exclude these tables in the conversion process.
mysql -h127.0.0.1 -uzabbix -pzabbix --database=zabbix -B -N -e "SHOW TABLES" | grep -v "^history$\|^history_uint$\|^trends$\|^trends_uint$" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}'

mysql -h127.0.0.1 -uzabbix -pzabbix --database=zabbix -B -N -e "SHOW TABLES" | grep -v "^history$\|^history_uint$\|^trends$\|^trends_uint$" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}' | wc -l
 | mysql  -h location.to.db.instance --database=zabbix

mysql --database=zabbix -B -N -e "SHOW TABLES" | awk '{print "SHOW CREATE TABLE",$1,"\\G"}' | mysql --database=zabbix >> ~/stock.3.4.schema.log
 


# spliting the log file into pieces
cd
gzip -c /<path>/strace.log | split -b 14m - strace.gz


watch -n1 'ps aux|grep [z]abbix_server >> zabbix_activity.log;echo "====================" >> zabbix_activity.log;sleep 1'


# check the disk performance with this command
sar -dp -w 1 10

# what is using swap. During issue please run
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r


# look which exact module has been used by zabbix_server binary
ldd /usr/sbin/zabbix_proxy | grep -i ipmi

# on RHEL
rpm -qf /lib64/libOpenIPMI.so.0

# on debian look the package name which owns the module
dpkg -S /full/path/to/libOpenIPMI.so.0
# based on contend in previous command ask version of package
dpkg -l libopenipmi0




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


