
cat << EOF > zabbix_agentd.conf
PidFile=$(pwd)/zabbix_agentd.pid
LogFile=$(pwd)/zabbix_agentd.log
Server=127.0.0.1

DebugLevel=4

LogFileSize=0

ServerActive=10.133.253.43:13452,10.133.253.43:13453
RefreshActiveChecks=120

StartAgents=0
ListenPort=10050

BufferSize=8000
EOF
> zabbix_agentd.log

./zabbix_agentd -c zabbix_agentd.conf --foreground


docker stop prx34nr1 && docker rm  prx34nr1 && docker run --name prx34nr1 \
-e ZBX_HOSTNAME="prx34nr1" \
-e ZBX_SERVER_HOST="10.133.253.43" \
-e ZBX_SERVER_PORT="13451" \
-e ZBX_DEBUGLEVEL="4" \
-p 13452:10051 \
-d zabbix/zabbix-proxy-sqlite3:alpine-3.4.8


docker stop prx34nr2 && docker rm prx34nr2 && docker run --name prx34nr2 \
-e ZBX_HOSTNAME="prx34nr2" \
-e ZBX_SERVER_HOST="10.133.253.43" \
-e ZBX_SERVER_PORT="13451" \
-e ZBX_DEBUGLEVEL="4" \
-p 13453:10051 \
-d zabbix/zabbix-proxy-sqlite3:alpine-3.4.8




for i in `seq 1 999`; do echo $i >> /tmp/sample.log; done;

echo 1000 >> /tmp/sample.log

docker stop prx34nr2 && docker start prx34nr1
# host will move to other


docker stop prx34nr1 && docker start prx34nr2


docker stop prx34nr2
# move manually host to prx34nr1
docker exec -it z34srv zabbix_server -R config_cache_reload
docker start prx34nr1

docker stop prx34nr1
# move manually host to prx34nr1
docker exec -it z34srv zabbix_server -R config_cache_reload
docker start prx34nr2

prx34nr1
d3bcd3fa7a8f786eb29324dd22485615c488f7fed7ad87ec5a49db2333200658

prx34nr2
607bddcab8f7ab3fc724c4eeee1ff16aaa9c31a0c57dc4b9407422b56d5c41e8

docker exec -it prx34nr1 zabbix_proxy -R config_cache_reload
docker exec -it prx34nr2 zabbix_proxy -R config_cache_reload

# need to wait 120 seconds so agent knows what to do. It will pick up position where it left

Write some additional records:
for i in `seq 1001 1010`; do echo $i >> /tmp/sample.log; done;
cat /tmp/sample.log

for i in `seq 1011 1020`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1021 1029`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1031 1039`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1041 1049`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1051 1059`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1060 1069`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1070 1079`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1080 1089`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1090 1099`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1100 1109`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1110 1119`; do echo $i >> /tmp/sample.log; done; 
for i in `seq 1120 1129`; do echo $i >> /tmp/sample.log; done; 




echo 3 >> /tmp/sample.log


cat /tmp/sample.log


docker logs prx34nr1
docker logs prx34nr2


select lastlogsize from items where itemid=28353;

touch /var/lib/zabbix/zabbix_proxy_db.prx34nr2