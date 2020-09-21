

# does all you systems are supposed to be online 24/7. if yes we can replace 


# process list
ps auxww

# proxy poller health


# trapper health
watch -n1 'ps aux|grep "[t]rapper #"'
watch -n1 'ps -efww|grep -E -o "[t]rapper #.*"'


# count of history syncers
watch -n1 'ps aux|grep "[h]istory syncer #"'


# can improve installce 


# Disk performance:
sar -dp -w 1 10 >> /tmp/disk.activity.txt

# Usage of swap:
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done >> /tmp/swap.usage.txt

# CPU info:
cat /proc/cpuinfo >> /tmp/cpu.info.txt

# Memory:
cat /proc/meminfo >> /tmp/mem.info.txt

# Process list:
ps auxww >> /tmp/process.list.txt 


# Inside the server where service 'zabbix-server' is running please take a few snapshots of process list. It will take 2 minutes to complete:
for i in `seq 1 20`; do echo $(date) >> /tmp/master.processes.txt && ps auxww >> /tmp/master.processes.txt && echo "=======" >> /tmp/master.processes.txt && sleep 5; done 


for i in `seq 1 20`; do echo $(date) >> /tmp/proxy.processes.txt && ps auxww >> /tmp/proxy.processes.txt && echo "=======" >> /tmp/proxy.processes.txt && sleep 5; done 

for i in `seq 1 20`; do echo $(date) >> /tmp/master.processes.txt && ps auxww >> /tmp/master.processes.txt && echo "=======" >> /tmp/master.processes.txt && sleep 5; done 




for i in `seq 1 10`; do echo $(date) >> /tmp/proc.txt && ps auxww >> /tmp/proc.txt && echo "=======" >> /tmp/proc.txt && sleep 1; done


# which process in system is using swap
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done

# check if master processes are running
ps aux|grep conf$

# test memory leak '--suppressions=/root/minimal.supp'

for i in `seq 1 20`; do echo $(date) >> /tmp/java.poller.txt && ps auxww|grep [j]ava.poller.# >> /tmp/java.poller.txt && echo "=======" >> /tmp/java.poller.txt && sleep 5; done

cat /tmp/java.poller.txt



echo "ewogICA8bXlzcWw+CiAgIE1lbWNoZWNrOkxlYWsKICAgbWF0Y2gtbGVhay1raW5kczogcG9zc2libGUKICAgLi4uCiAgIG9iajovdXNyLypsaWIqL215c3FsLyoKfQp7CiAgIDxjcnlwdG8+CiAgIE1lbWNoZWNrOkxlYWsKICAgbWF0Y2gtbGVhay1raW5kczogcG9zc2libGUKICAgLi4uCiAgIG9iajovdXNyLypsaWIqLypsaWJjcnlwdG8qCn0K" | base64 --decode > /tmp/ignore.mysql.libcrypto.supp
valgrind --suppressions=/tmp/ignore.mysql.libcrypto.supp \
--leak-check=full \
--trace-children=yes \
--track-origins=yes \
--max-stackframe=5000000 \
--read-var-info=yes \
--leak-resolution=high \
--log-file=/tmp/valgrind.zabbix_proxy.log \
/usr/sbin/zabbix_proxy -c /etc/zabbix/zabbix_proxy.conf --foreground


valgrind --suppressions=/root/minimal.supp \
--leak-check=full \
--trace-children=yes \
--track-origins=yes \
--max-stackframe=5000000 \
--read-var-info=yes \
--leak-resolution=high \
--log-file=/tmp/valgrind.zabbix_server.log \
/usr/sbin/zabbix_server -c /etc/zabbix/zabbix_server.conf --foreground



for i in `seq 1 5`; do zabbix_close_all_events_by_triggerid.sh 179697 100 $(date +%s) close; done


n -b -k 8,8

top -b -n 10 -d 0.2 -p 1 | tail -1 | awk '{print $9}'
Where:

-b: Batch-mode;
-n 2: Number-of-iterations;
-d 0.2: Delay-time(in second, here is 200ms);
-p <PID>: Monitor-PIDs
tail -1: the last row
awk ' {print $9}
': the 9-th column(the cpu usage number



# debug for zabbix proxy data sender
grep "$(ps auxw | grep "^zabbix.*data sender" | awk '{print $2}'):" /var/log/zabbix/zabbix_proxy.log > /tmp/proxy.data.sender.log



sed -n '/PATTERN1/,/PATTERN2/p' file

awk '/PATTERN1/{f=1}/PATTERN2/{f=0;print}f' file

awk '/:20200728:21.*/,/:20200728:21.*/{next} 1' /var/log/zabbix/zabbix_proxy.log

awk '/:20200730:12.*/,/:20200730:12.*/{next} 1' /var/log/zabbix/zabbix_server.log > /tmp/log.log


awk '/:20200728:20.*/{f=1}/:20200728:21.*/{f=0;print}f' /var/log/zabbix/zabbix_proxy.log > /tmp/proxy.from.2000.till.2200.log



:20200728:21

ps auxw | grep "data sender" | awk '{print " -p " $2}'|xargs strace -s 256 -T -tt -f -o proxy.strace.out


# snapshot of process list
for i in `seq 1 6`; do echo $(date) >> /tmp/process.list.txt && ps -efwww >> /tmp/process.list.txt && echo "=======" >> /tmp/process.list.txt && sleep 1; done



cat /proc/cpuinfo
cat /proc/meminfo
ps aux


ps -efwww|grep -E -o '^zabbix.*\/zabbix_proxy: [a-z -]+'|sed 's|^.*: ||g'|sort|uniq



time for i in `seq 1 1000`; do zabbix_get -s 127.0.0.1 -k agent.ping ; done 

mtr --tcp --port 443 --interval 1 --report --report-cycles 3 www.zabbix.com > /tmp/file.log

watch -n1 -c 'innotop -h"ip.of.db.server" -u"usename" -p"password" --count 1 -d 1 -n --mode Q'

innotop -h'ip.of.db.server' -u'usename' -p'password' --count 1 -d 1 -n --mode Q > /tmp/zabbix.queries.txt


for i in U Q O S T K L; do innotop --count 1 -d 1 -n --mode $i >> /tmp/innotop.out; sleep 5; innotop --count 1 -d 1 -n --mode $i >> /tmp/innotop.out;  done


sudo du -a /var/lib/mysql/ | sort -n -r | head -n 20 > /tmp/var.log.mysql.biggest.files


# timing of config cache reload
ps -eo cmd|egrep -o "[s]ynced.configuration.*sec" 

egrep "(Server|ServerPort|Hostname)=" /etc/zabbix/zabbix_proxy.conf


for i in `seq 1 10`
do
echo $i >> output.txt &
done



# Provide information about shared memory segments and semaphore arrays:
ipcs -a > /tmp/memory.segments.txt
# Process list:
ps aux > /tmp/process.list.txt
# Netstat:
netstat -a > /tmp/netstat.txt


tail -10000 /var/log/messages | gzip --best > /tmp/var.log.messages.gz 


ps -eo pid,cmd,%cpu,%mem --sort=-%mem
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done

# show listening ports
ss -ntl
ss --numeric --tcp --listening


ps aux | grep ^zabbix.*synced | grep -E -o "synced configuration in [0-9\.]+ sec"

# see agent uptime
date
ps -eo pid,lstart,cmd | grep "[z]abbix_agentd.conf"

ps www -eo cmd

/* cpu and mem usage */
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head


# for solaris 10
kstat -p cpu_stat:::/^idle$\|^wait$\|^user$\|^kernel$/


while :; do echo "$(date),$(kstat -p cpu_stat:::/^idle$\|^wait$\|^user$\|^kernel$/ | \
sed "s|idle|idle,|;s|wait|wait,|;s|user|user,|;s|kernel|kernel,|;s|$|,|" | \
tr -cd "[:print:]" )" | tee -a ~/cpu_stat.csv; sleep 5; done



while :; do date >> ~/cpu_stat.log; kstat -p cpu_stat:::/^idle$\|^wait$\|^user$\|^kernel$/ >> ~/cpu_stat.log; sleep 5; done


while :; do zabbix_server -R housekeeper_execute; sleep 60; done


sudo -H -u zabbix bash -c 'printenv'
sudo -H -u zabbix bash -c 'ldconfig -p'


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


ps -efwww | grep "[z]abbix_server.*history syncer #.*syncing history"
syncing history



for i in `seq 1 180`; do echo $(date) >> /tmp/history.syncer.txt && ps -efwww | grep "[z]abbix_server.*history syncer #" >> /tmp/history.syncer.txt && echo "=======" >> /tmp/history.syncer.txt && sleep 1; done






for i in `seq 1 120`; do echo $(date) >> /tmp/proxy.sender.txt && ps -efwww | grep "[z]abbix_proxy.*data sender" >> /tmp/proxy.sender.txt && echo "=======" >> /tmp/proxy.sender.txt && sleep 1; done





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

# this should report empty string
SELECT * FROM information_schema.TABLES WHERE table_schema = 'zabbix' AND table_collation != 'utf8_bin';

# this should report content
SELECT * FROM information_schema.TABLES WHERE table_schema = 'zabbix' AND table_collation = 'utf8_bin';


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

sar -dp -w 1 10 >> /tmp/disk.activity.log

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

until mysql -e "show slave status\G;" | grep -i "Slave_SQL_Running: Yes";do
  mysql -e "stop slave; SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1; start slave;";
  sleep 1;
done



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



