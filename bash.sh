


systemctl -a | awk '/php/ {print $1}' | xargs systemctl status | grep -i master


while (sleep 1) do timeout 18s tcpdump -i any host 127.0.0.1 -w /tmp/$(date +%Y%m%d%H%M%S).pcap ; done
while (sleep 1) do timeout 1800s tcpdump -i any host 127.0.0.1 -w /tmp/$(date +%Y%m%d%H%M%S).pcap ; done

$(date +%Y%m%d)


while (sleep 1) do echo -e "\n$(date)" >> /tmp/port.80.443.log; grep ":0050\|:01BB" /proc/net/tcp >> /tmp/port.80.443.log; done


zabbix_get -s host -k 'system.run[psql -dzabbix -Atf /tmp/query.sql]'

'system.run["ip addr show | awk -F'[/ ]+' 'BEGIN {ORG=\",\"} $2==\"inet\" && $3!~\"^127.0.0.\" {print $3}'"]'
'system.run[cat /proc/meminfo | grep MemTotal | cut -d: -f2 | tr -d ' '\k\B]'



# If next time happens the same try to prepare debugging for us using strace and gdb output for processes. It can be done using this commands(strace and gdb must be installed by that time):

mkdir -p /tmp/zbx; ps -o pid,%mem,pcpu,time,command ax | grep [z]abbix_server | tee /tmp/zbx/gdb.ps.log | awk '{ print "gdb -batch -ex bt -ex q -p "$1" > /tmp/zbx/gdb."$1".log 2>&1 &" }' | sh
mkdir -p /tmp/zbx; ps -o pid,%mem,pcpu,time,command ax | grep [z]abbix_server | tee /tmp/zbx/strace.ps.log | awk '{ print "timeout 60s strace -ttt -f -s500 -o /tmp/zbx/strace."$1".log -p "$1"&" }' | sh
# This log file can be archived and sent to us:
tar -cvJf debug.log.tar.xz /tmp/zbx


# gdb backtrace on all zabbix_server processes
mkdir -p /tmp/zbx; ps -o pid,%mem,pcpu,time,command ax | grep [z]abbix_server | tee /tmp/zbx/gdb.ps.log | awk '{ print "gdb -batch -ex bt -ex q -p "$1" > /tmp/zbx/gdb."$1".log 2>&1 &" }' | sh

# strace on all zabbix_Server processes for 60s
mkdir -p /tmp/zbx; ps -o pid,%mem,pcpu,time,command ax | grep [z]abbix_server | tee /tmp/zbx/strace.ps.log | awk '{ print "timeout 60s strace -ttt -f -s500 -o /tmp/zbx/strace."$1".log -p "$1"&" }' | sh




awk -v matchfile=/tmp/matchfile.log -v nomatchfile=/tmp/nomatchfile.log '/sending configuration/ {print > matchfile; next} {print > nomatchfile}' /var/log/zabbix/zabbix_server.log

awk -v matchfile=/tmp/matchfile.log -v nomatchfile=/tmp/nomatchfile.log '/sending configuration/ {print > matchfile; next} {print > nomatchfile}' /var/log/zabbix/zabbix_server.log


awk -v matchfile=yes.log -v nomatchfile=next.log "/cannot send list of active checks/ {print > matchfile; next} {print > nomatchfile}"


mkdir -p /tmp/zabbixServer && cd /var/log/zabbix && for pid in $(pidof zabbix_server); do grep "$pid:$(date +%Y%m%d):" zabbix_server.log > /tmp/zabbixServer/$pid.log; done
mkdir -p /tmp/zabbixProxy && cd /var/log/zabbix && for pid in $(pidof zabbix_proxy); do grep "$pid:$(date +%Y%m%d):" zabbix_proxy.log > /tmp/zabbixProxy/$pid.log; done
# explained
mkdir -p /tmp/zabbixServer
for pid in $(
pidof zabbix_server
)
do grep "$pid:$(date +%Y%m%d):" zabbix_server.log > /tmp/zabbixServer/$pid.log
done





mkdir /tmp/zabbix
for pid in $(
pidof zabbix_server
)
do grep "$pid:$(date +%Y%m%d):" /var/log/zabbix/zabbix_server.log > /tmp/zabbix/$pid.log
done



watch -n.1 'grep ":0050\|:01BB" /proc/net/tcp'


while (sleep 1) do echo -e "\n$(date)" >> /tmp/port.80.443.log; grep ":0050\|:01BB" /proc/net/tcp >> /tmp/port.80.443.log; done


mysql zabbix --defaults-file=/var/lib/zabbix/.my.cnf --batch -e "SHOW CREATE TABLE history_uint;" | grep -c "$(date --date="2 day" "+p%Y_%m_%d")"
mysql zabbix --defaults-file=/var/lib/zabbix/.my.cnf --batch -e "SHOW CREATE TABLE history;" | grep -c "$(date --date="2 day" "+p%Y_%m_%d")"
mysql zabbix --defaults-file=/var/lib/zabbix/.my.cnf --batch -e "SHOW CREATE TABLE history_str;" | grep -c "$(date --date="2 day" "+p%Y_%m_%d")"
mysql zabbix --defaults-file=/var/lib/zabbix/.my.cnf --batch -e "SHOW CREATE TABLE history_text;" | grep -c "$(date --date="2 day" "+p%Y_%m_%d")"
mysql zabbix --defaults-file=/var/lib/zabbix/.my.cnf --batch -e "SHOW CREATE TABLE history_log;" | grep -c "$(date --date="2 day" "+p%Y_%m_%d")"

mysql zabbix --defaults-file=/var/lib/zabbix/.my.cnf --batch -e "SHOW CREATE TABLE trends_uint;" | grep -c "$(date --date='TZ="UTC" 00:00 next Month' "+p%Y_%m")"
mysql zabbix --defaults-file=/var/lib/zabbix/.my.cnf --batch -e "SHOW CREATE TABLE trends;" | grep -c "$(date --date='TZ="UTC" 00:00 next Month' "+p%Y_%m")"



# A command to check SSL connection:
openssl s_client -connect host.hello.world.com -port 10051 -psk `cat /etc/zabbix/ssl/private/zabbix_agentd.psk` -psk_identity "PSK 001"


while (sleep 10) do mysql -h'127.0.0.1' -u'zabbix' -p'zabbix' zabbix -e "DELETE FROM event_recovery WHERE eventid NOT IN (SELECT eventid FROM events) LIMIT 100;"; done




# According to https://access.redhat.com/solutions/69271, we can install 'sysstat' package to utilize 'pidstat' utility to generate debugging information to understand which process holds the most context switches:
pidstat -w 3 10 > /tmp/pidstat.out
pidstat -wt 3 10 > /tmp/pidstat-t.out
strace -c -f -p <pid of process/thread>


mysql -sN --batch -e "
SELECT
FROM_UNIXTIME(repercussion.clock),
repercussion.name,
FROM_UNIXTIME(rootCause.clock),
rootCause.name
FROM events repercussion
JOIN event_recovery ON (event_recovery.eventid=repercussion.eventid)
JOIN events rootCause ON (rootCause.eventid=event_recovery.c_eventid)
WHERE event_recovery.c_eventid IS NOT NULL
ORDER BY repercussion.clock ASC;
" zabbix > /tmp/all.events.by.global.correlation.tsv


mysql -sN --batch -e "
SELECT
hosts.host,
items.name,
items.key_,
items.delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.status=0
ORDER BY 1,2,3,4;
" zabbix > /tmp/all.enabled.items.tsv



mysql -sN --batch zabbix -e "
SELECT items.name,
items.key_,
items.delay,
hosts.host,
p.host AS proxy_name
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
LEFT JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
WHERE hosts.status=0;
" > /tmp/items.tsv


Thank you for the screenshot. Since this is a test environment, for troubleshooting purposes it could really help to install:

StartAlerters=1
Restart the backend, increase the log level for "alert manager" and "alerter" by executing this block:

zabbix_server -R log_level_increase="alert manager"
zabbix_server -R log_level_increase="alerter"
zabbix_server -R log_level_increase="alert manager"
zabbix_server -R log_level_increase="alerter"
Check debug level:

grep "log level" /var/log/zabbix/zabbix_server.log  
 The last 2 lines should say "log level has been increased to 5"

Simulate a fresh event in GUI. Make sure the ServiceNow engagement has been initiated.

Decrease log level:

zabbix_server -R log_level_decrease="alert manager"
zabbix_server -R log_level_decrease="alerter"
zabbix_server -R log_level_decrease="alert manager"
zabbix_server -R log_level_decrease="alerter"
grep "log level" /var/log/zabbix/zabbix_server.log
Last 2 lines should say: "log level has been increased to 3"



grep "Starting Zabbix Server\|Zabbix Server stopped" /var/log/zabbix/zabbix_server.log
zcat /var/log/zabbix/zabbix_server.log-*gz | grep "Starting Zabbix Server\|Zabbix Server stopped" | sort | tail -20


grep "please increase" /var/log/zabbix/zabbix_server.log
zcat /var/log/zabbix/zabbix_server.log-*gz | grep "please increase" | sort | tail -20


for x in {1..5}; do ps aux | sort -nrk 3,3 | head -n 10; sleep 5; done >> /tmp/processes.txt

for x in {1..5}; do ps ax | grep zabbix; sleep 5; done >> /tmp/zabbix.txt




grep -B1 tm_try_task_close_problem.*FAIL /var/log/zabbix/zabbix_server.log | grep -oP 'tcp.taskid=\K\d+'
# We can print on screen SQL delete commands which can be used to improve the situation:
grep -B1 tm_try_task_close_problem.*FAIL /var/log/zabbix/zabbix_server.log | grep -oP 'tcp.taskid=\K\d+' | xargs -i echo "DELETE FROM task WHERE taskid IN ({});"


# vmware statistics
grep vmware /var/log/zabbix/zabbix_server.log | grep "Performance counter data" | cut -d '[' -f1 | cut -d ":" -f4 | sort | uniq -c




# server queue details
# obtain session tokken:
curl http://127.0.0.1:152/api_jsonrpc.php -s -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"user.login","params":{"user":"Admin","password":"zabbix"},"id":1,"auth":null}' | grep -E -o "([0-9a-f]{32,32})"
curl http://127.0.0.1/api_jsonrpc.php -s -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"user.login","params":{"user":"api","password":"zabbix"},"id":1,"auth":null}' | grep -E -o "([0-9a-f]{32,32})"

# Query if it works
zabbix_get -s 127.0.0.1 -p 15251 -k '{"request":"queue.get","sid":"3d54c84d71f9f214e2108c91a2b38ea5","type":"details","limit":"999999"}'
zabbix_get -s 127.0.0.1 -p 10051 -k '{"request":"queue.get","sid":"2fbf06f496529c68bce2c94f94a0531a","type":"details","limit":"999999"}'

# put ID's in file:
zabbix_get -s 127.0.0.1 -p 15251 -k '{"request":"queue.get","sid":"3d54c84d71f9f214e2108c91a2b38ea5","type":"details","limit":"999999"}' > /tmp/queue.json
zabbix_get -s 127.0.0.1 -p 10051 -k '{"request":"queue.get","sid":"2fbf06f496529c68bce2c94f94a0531a","type":"details","limit":"999999"}' > /tmp/queue.json


# count of items
grep -oP 'itemid\":\K\d+' /tmp/queue.json | xargs -i echo "
SELECT hosts.host
FROM hosts 
JOIN items ON (hosts.hostid = items.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE items.itemid='{}'
;" | psql --no-align --tuples-only z52 | sort | uniq -c

# golden query
grep -oP 'itemid\":\K\d+' /tmp/queue.json | tr '\n' ',' | sed 's|.$||' | xargs -i echo "
SELECT p.host AS proxy, hosts.host, items.key_
FROM hosts 
JOIN items ON (hosts.hostid = items.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
LEFT JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
WHERE items.itemid IN ({})
;" | mysql --table zabbix > /tmp/queue.txt



grep -oP 'itemid\":\K\d+' /tmp/queue.json | tr '\n' ',' | sed 's|.$||' | xargs -i echo "
SELECT p.host AS proxy, hosts.host, items.key_
FROM hosts 
JOIN items ON (hosts.hostid = items.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
LEFT JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
WHERE items.itemid IN ({})
;" | psql z52

# maximum 2MB of data can be passed to xargs
# echo | xargs --show-limits
Your environment variables take up 2351 bytes
POSIX upper limit on argument length (this system): 2092753
POSIX smallest allowable upper limit on argument length (all systems): 4096
Maximum length of command we could actually use: 2090402
Size of command buffer we are actually using: 131072




SELECT hosts.host FROM hosts
JOIN items ON (items.hostid=hosts.hostid)
WHERE items.itemid='zabbix[queue]'
AND hosts.status=0;

for i in `seq 1 20`; do echo $(date) >> /tmp/proxy.proc.log && ps auxww >> /tmp/proxy.proc.log && echo "=======" >> /tmp/proxy.proc.log && sleep 5; done 
for i in `seq 1 2`; do echo $(date) >> /tmp/proxy.proc.log && ps auxww >> /tmp/proxy.proc.log && echo "=======" >> /tmp/proxy.proc.log && sleep 5; done 


for i in `seq 1 20`; do echo $(date) >> /tmp/proxy.proc.log && ps auxww >> /tmp/ps.auxww.$(hostname).log && echo "=======" >> /tmp/proxy.proc.log && sleep 5; done 
for i in `seq 1 2`; do echo $(date) >> /tmp/proxy.proc.log && ps auxww >> /tmp/ps.auxww.$(hostname).log && echo "=======" >> /tmp/proxy.proc.log && sleep 5; done 

for i in `seq 1 20`; do echo $(date) >> /tmp/ps.auxww.$(hostname).log && ps auxww >> /tmp/ps.auxww.$(hostname).log && echo "=======" >> /tmp/ps.auxww.$(hostname).log && sleep 5; done 


watch -n.1 'ps auxww|grep "[h]istory syncer #"'

watch -n.1 'ps auxww|grep -oE "zabbix_server: [h]istory syncer #.*"'

watch -n.1 'ps auxww|grep -oE "[h]istory syncer #.*"'



#!/bin/bash

if [ -f /tmp/completed ]; then
    echo "the script has been executed already" 
else
    echo "executing someting now"
    [ $? -eq 0 ] && touch /tmp/completed
fi




grep "syncing history data in progress\|syncing trend data done" *

Zabbix Server stopped

grep "Zabbix Server stopped\|Starting Zabbix Server" *

grep "Zabbix Server stopped" *

grep "Starting Zabbix Server" *


# active files in current directory with recent timestamp
find . -cmin -60

cd /var/log/zabbix
find . -cmin -1440 | xargs ls -lh
find . -cmin -1440 | xargs grep Z3001

# statistics about database went down
zcat /var/log/zabbix/zabbix_server*gz | grep Z3001 | sort | tail -10



find /var/log/zabbix -type f -name '*.gz' -mtime -5 -exec zcat {} \ | grep housekeeper;



1440

find . -cmin -1440 | xargs

zcat /var/log/zabbix/zabbix_server*gz | grep housekeeper | sort | tail -20




grep -r innodb_buffer_pool_size /etc/*


tasklist | findstr "zabbix"
netstat -ano 0 | findstr "10050"
sc query "zabbix agent"

while (sleep 3) do lsof | grep ^java | wc -l; done
while (sleep 30) do lsof | grep ^java | wc -l; done



while (sleep 3) do echo 1; done

# list of open files:
lsof -p $(pidof mysqld) > /tmp/mysqld.list.open.files.txt
lsof > /tmp/list.open.files.txt

mkdir /tmp/lsof 

# cat /etc/cron.d/open_file_descriptors
*/15 * * * * root /usr/sbin/lsof > /tmp/lsof/$(date "+\%Y\%m\%d\%H\%M\%S").out


# check time difference
timedatectl


# Could you please also upload system log 
# /var/log/messages on RHEL/CentOS 
# or /var/log/syslog on Debian/Ubuntu?
dmesg > /tmp/dmesg.txt


for i in `seq 225 230`; do ping -c1 10.$(ip a | grep -oP "inet 10\.\K\d+\.\d+").$i; done;

for i in `seq 1 11`; do echo $(date) >> /tmp/history.syncer.txt && ps auxww|grep "[h]istory syncer #" >> /tmp/history.syncer.txt && echo "=======" >> /tmp/history.syncer.txt && sleep 5; done 

# generate random number 
echo $(grep -m1 -ao '[0-9][0-9]' /dev/urandom | sed s/0/10/ | head -n1)

for i in `seq 1 11`; do ; done 



zabbix_sender -z 127.0.0.1 -p 14051 -s stream -k stream -o "$(grep -m1 -ao '[0-9][0-9]' /dev/urandom | sed s/0/10/ | head -n1)"

for i in `seq 1 11`; do zabbix_sender -z 127.0.0.1 -p 14051 -s stream -k stream -o "$(grep -m1 -ao '[0-9][0-9]' /dev/urandom | sed s/0/10/ | head -n1)"; done 


for i in `seq 1 11`; do echo 1;sleep 1; done 



while :; do zabbix_sender -z 127.0.0.1 -p 14051 -s stream -k stream -o "$(grep -m1 -ao '[0-9][0-9]' /dev/urandom | sed s/0/10/ | head -n1)"; done


while :; do echo $(date) >> /tmp/history.syncer.txt && ps auxww|grep "[h]istory syncer #" >> /tmp/history.syncer.txt && echo "=======" >> /tmp/history.syncer.txt && sleep 5; done

watch -n1 'ps auxww|grep "[h]istory syncer #"'
strace -s 256 -o /tmp/some.domain.name.com.log zabbix_agentd -t net.dns[,some.domain.name.com,,,]


mysql -u'root' -p'password' -e 'SHOW GLOBAL VARIABLES;' > /tmp/mysql.global.variables.txt
mysql -u'root' -p'password' -e 'SHOW VARIABLES;' > /tmp/mysql.variables.txt


# ZBX_TCP_WRITE() failed: [32] Broken pipe
# network issue
# 250ms is a bad network latency in case of Zabbix version below 4.2. In 4.2 version LLD processing is performed using separate process. You need to increase update interval of the discovery rules used, or decrease network latency. Also you can try to upgrade to the 4.0 version with compression. Key idea here - less data - less time required to send data.
# Broken pipe it means that TCP connection was interrupted

grep housekeeper /var/log/zabbix/zabbix_server.log
# or search in compressed archives
zcat /var/log/zabbix/zabbix_server*gz | grep housekeeper | sort | tail -20

find /var/log/zabbix -type f -name '*' -mtime -2 -exec ls -lh {} \;

# houskeeper in last 5 days
find /var/log/zabbix -type f -name 'zabbix_server*.gz' -mtime -5 -exec sh -c "zcat {} | grep housekeeper" \; | sort



find /var/log/zabbix -type f -name '*.gz' -mtime -5 -exec zcat {} \ | grep housekeeper;


find /var/log/zabbix -type f -name '*.gz' -mtime -5 -exec rm {} \;


tail -99999

zabbix_proxy -R log_level_increase="data sender" 
zabbix_proxy -R log_level_decrease="data sender" 


# discover all history syncers
ps auxww | grep "[h]istory syncer #.*" | awk ' { print $2 } '

# beautifull representation if history syncer
watch -n1 'ps auxww|grep -o "[h]istory syncer #.*"'

cat /proc/16819/cmdline



# on zabbix master server
tail -999999 /var/log/zabbix/zabbix_server.log | gzip > /tmp/zabbix_server.log.$(date "+%Y%m%d%H%M").gz
# on zabbix proxy server
tail -999999 /var/log/zabbix/zabbix_proxy.log | gzip > /tmp/zabbix_proxy.log.$(date "+%Y%m%d%H%M").gz 

tail -999999 /var/log/zabbix/zabbix_agentd.log | gzip > /tmp/zabbix_agentd.log.$(date "+%Y%m%d%H%M").gz







# If the mibs are installed globally at '/usr/share/snmp/mibs' and you have enabled the translator at:
cat /etc/snmp/snmp.conf
# mibs :
# mibdirs /usr/share/snmp/mibs
# mibs +ALL
# We can perform an snmpwalk:
snmpwalk -v 2c -c public 192.168.88.1 . > /tmp/192.168.88.1.snmpwalk
# remember to include . (dot) right after IP address to have full list!



# Once you start up a server or a proxy, your poller caches the specific engineID and msgAuthoritativeEngineBoots value pair.
# Another poller then my cache the same engineID on a different device, but this device has a different msgAuthoritativeEngineBoots value.
# So once the 2nd poller polls the first device or the first poller polls the 2nd device, you're going to have connectivity issues and gaps in data, since the msgAuthoritativeEngineBoots differs from what was expected for this EngineID.

# on centos7



# poll config
grep ^[^#] /etc/zabbix/zabbix_server.conf


# CPU utilization
# Memory usage
# Zabbix cache usage, % free
# Zabbix data gathering process busy %
# Zabbix internal process busy %
# Zabbix server performance
# Configuration and log files:

# Zabbix server configuration file /etc/zabbix/zabbix_server.conf
# Zabbix server log file /etc/zabbix/zabbix_server.log

# Command outputs:
zabbix_server -V
ps aux | grep zabbix >> /tmp/ps.output
top -n1 -b >> /tmp/top.output
sar -d -wp 1 10 >> /tmp/sar.output
df -h >> /tmp/df.output

# Environment data:
OS information (cat /etc/*release).
CPU information (cat /proc/cpuinfo).
RAM information (free -h).
Storage information (Disk types - SSD, HDD, SAS) (RAID info).
Housekeeper or partitioning used for removing old data. 

free -h > /tmp/db.server.free.memory.log
cat /proc/cpuinfo > /tmp/db.server.cpu.info.log
sar -d -wp 1 10 >> /tmp/sar.output


e9eec97e9c670fbc37658710bfadd61e
zabbix_get -s 127.0.0.1 -p 10051 -k '{"request":"queue.get","sid":"e9eec97e9c670fbc37658710bfadd61e","type":"details","limit":"999999"}'


SELECT sessionid FROM sessions;
SELECT sessionid FROM sessions
WHERE 

;

;


echo 'SELECT sessionid FROM sessions​ WHERE userid IN (SELECT userid FROM users WHERE type=3) AND status=0 LIMIT 1'


zabbix_get -s 127.0.0.1 -p 10051 -k {"request":"queue.get","sid":"c56cae42778e90fe1a1c88a55c341f41","type":"details","limit":"99"}'
zabbix_get -s 127.0.0.1 -p 10051 -k {"request":"queue.get","sid":"c56cae42778e90fe1a1c88a55c341f41","type":"details","limit":"999"}'
zabbix_get -s 127.0.0.1 -p 10051 -k {"request":"queue.get","sid":"c56cae42778e90fe1a1c88a55c341f41","type":"details","limit":"9999"}'
zabbix_get -s 127.0.0.1 -p 10051 -k {"request":"queue.get","sid":"c56cae42778e90fe1a1c88a55c341f41","type":"details","limit":"99999"}'
zabbix_get -s 127.0.0.1 -p 10051 -k {"request":"queue.get","sid":"c56cae42778e90fe1a1c88a55c341f41","type":"details","limit":"999999"}'

grep -oP 'itemid\":\K\d+' /tmp/queue.json | xargs -i echo "
SELECT hosts.host, items.type
FROM hosts 
JOIN items ON (hosts.hostid = items.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE items.itemid='{}'
AND proxy.host='broceni';
" | mysql -N zabbix | sort | uniq


jq '.data[].itemid' /tmp/queue.json | xargs -i echo "
SELECT hosts.host, items.type
FROM hosts 
JOIN items ON (hosts.hostid = items.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE items.itemid='{}'
AND proxy.host='broceni';
" | mysql -N zabbix | sort | uniq


curl http://127.0.0.1:152/api_jsonrpc.php -s -X POST -H 'Content-Type: application/json' -d \
'{"jsonrpc":"2.0","method":"user.login","params":{"user":"Admin","password":"zabbix"},"id":1,"auth":null}' | \
grep -E -o "([0-9a-f]{32,32})"


zabbix_get -s 127.0.0.1 -p 15251 ​-k '{"request":"queue.get","sid":"0cf5f7e39de997d9a02593ab973acf85","type":"details","limit":"9999999"}' > /tmp/queue.json 



--zabbix_get -s 127.0.0.1 -p 10051 -k '{"request":"queue.get","sid":"c56cae42778e90fe1a1c88a55c341f41","type":"details","limit":"9999999"}'



# logging for snmptrapd
systemctl edit snmptrapd.service
ExecStart=/usr/sbin/snmptrapd -Ln -f -Lf /var/log/snmptrapd.log

a=$(grep ":$(date +%Y%m%d):" /var/log/zabbix/zabbix_server.log | grep -c Timeouto);b=$(grep ":$(date +%Y%m%d):" /var/log/zabbix/zabbix_server.log | grep -c Timeout);echo "$a,$b" | grep "^0" > 2&>1; if [ $? -eq 0 ]; then echo "$a,$b" | grep -Eo "[0-9]+$" ; else echo no; fi


a=$(grep ":$(date +%Y%m%d):" /var/log/zabbix/zabbix_server.log | grep -c Timeouto);b=$(grep ":$(date +%Y%m%d):" /var/log/zabbix/zabbix_server.log | grep -c Timeout);echo "$b,$a" | grep "^0" > 2&>1; if [ $? -eq 0 ]; then echo "$b,$a" | grep -Eo "[0-9]+$" ; else echo no; fi



# common info from DB server
top -n1 -b >> /tmp/top.output
sar -d -wp 1 10 >> /tmp/sar.output
df -h >> /tmp/df.output
cat /etc/*release
cat /proc/cpuinfo
free -h


# mysql console

# does all you systems are supposed to be online 24/7. if yes we can replace 

# On Centos/Red Hat
sudo rpm -qa | grep "zabbix\|php"
# On Ubuntu/Debian
sudo apt list --installed | grep "zabbix\|php"


/usr/sbin/mysqld --verbose --help | grep -A 1 "Default options"


# process list
ps auxww

# proxy poller health

# compress gzip 
sudo tar -zcvf /tmp/httpd/conf.d.tar.gz /etc/httpd/conf.d
# or better the whole etc
sudo tar -zcvf /tmp/etc.tar.gz /etc

sudo tar -zcvf /tmp/httpd.tar.gz /etc/httpd

sudo tar -zcvf /tmp/zabbix_proxy.log.tar.gz /var/log/zabbix/zabbix_proxy.log


sudo tar -zcvf /tmp/mysqld.conf.tar.gz ~/mysql.txt /var/log/mysqld.log 

sudo tar -zcvf /tmp/mysqld.conf.tar.gz /etc/my.cnf /etc/mysql/my.cnf /usr/etc/my.cnf /root/.my.cnf

sudo tar -zcvf /tmp/snmpsim.gz /usr/share/snmpsim


sudo tar -zcvf /tmp/log.httpd.tar.gz /var/log/httpd
sudo tar -zcvf /tmp/log.apache2.tar.gz /var/log/apache2 

sudo tar -zcvf /tmp/archive.jmxterm.tar.gz /tmp/jmx*


tar -zcvf /tmp/mysql.5.7.23.conf.tar.gz /etc/my.cnf /etc/mysql
tar -zcvf /tmp/etc.tar.gz /etc

tar -zcvf /tmp/log.httpd.tar.gz /var/log/httpd
tar -zcvf /tmp/log.apache2.tar.gz /var/log/apache2


# schedule 'innotop utility' to list queries
echo "* * * * * root date >> /tmp/innotop.txt && innotop -h'127.0.0.1' -P'3306' -u'zabbix' -p'zabbix' --count 1 -d 1 -n --mode Q >> /tmp/innotop.txt && echo ====== >> /tmp/innotop.txt" | sudo tee /etc/cron.d/transactions_onboard


echo "* * * * * root date >> /tmp/innotop.txt && innotop -h'ros' -P'3306' -u'zabbix' -p'zabbix' --count 1 -d 1 -n --mode Q >> /tmp/innotop.txt && echo ====== >> /tmp/innotop.txt && sleep 29 && date >> /tmp/innotop.txt && innotop -h'ros' -P'3306' -u'zabbix' -p'zabbix' --count 1 -d 1 -n --mode Q >> /tmp/innotop.txt && echo ====== >> /tmp/innotop.txt" | sudo tee /etc/cron.d/transactions_onboard 


watch -n.1 "innotop -h'ros' -P'3306' -u'root' -p'zabbix' --count 1 -d 1 -n --mode Q"


# trapper health
watch -n1 'ps aux|grep "[t]rapper #"'

watch -n1 'ps auxww | grep "[z]abbix_server: trapper #"'

watch -n1 'ps auxww | grep "[z]abbix_server: history syncer #"'


watch -n.1 'ps auxww | grep "^zabbix.*[z]abbix_server: trapper #"'

watch -n.1 'ps auxww | grep "^zabbix.*[z]abbix_server: trapper #.*waiting for connection"'



# trappers
watch -n1 'ps -efww|grep -E -o "[t]rapper #.*"'

# show proxy pollers
watch -n1 'ps -efww|grep -E -o "[p]roxy poller #.*"'


# count of history syncers
watch -n1 'ps auxww|grep "[h]istory syncer #"'


watch -n1 'ps auxww|grep "[t]rapper #"'


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

for i in `seq 1 20`; do echo $(date) >> /tmp/master.processes.txt && ps auxww >> /tmp/master.processes.txt && echo "=======" >> /tmp/master.processes.txt && sleep 3; done 


for i in `seq 1 5`; do echo $(date) >> /tmp/processes.$(hostname -s).txt && ps auxww >> /tmp/processes.$(hostname -s).txt && echo "=======" >> /tmp/processes.$(hostname -s).txt && sleep 1; done 


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

du -a /var/lib/mysql/zabbix | sort

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



while :; do nr=0; nr=((nr+1)); echo $nr; sleep 1; done


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

zcat /var/log/zabbix/zabbix_server.log-*gz | grep "Starting Zabbix Server\|Zabbix Server stopped" | sort | tail -20

zcat /var/log/zabbix/zabbix_server.log-*gz | grep "query failed"
zcat /var/log/zabbix/zabbix_server.log-*gz | grep "database"

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



