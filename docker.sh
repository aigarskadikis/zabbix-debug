docker run --name zabbix-proxy-sqlite3 -d zabbix/zabbix-proxy-sqlite3:alpine-5.0-latest


--link some-zabbix-server:zabbix-server


docker stop zabbix-proxy-sqlite3 && docker rm zabbix-proxy-sqlite3

docker run --name zabbix-proxy-sqlite3 -e ZBX_HOSTNAME=mysql8mon -e ZBX_SERVER_HOST=10.133.253.43 -e ZBX_STARTPOLLERS=1 -e ZBX_STARTPREPROCESSORS=1 -e ZBX_STARTTRAPPERS=1 -e ZBX_STARTDBSYNCERS=1 -e ZBX_STARTDISCOVERERS=0 -e ZBX_CACHEUPDATEFREQUENCY=3600 -e ZBX_STARTPINGERS=0 -e ZBX_STARTHTTPPOLLERS=0 -d zabbix/zabbix-proxy-sqlite3:centos-5.0-latest

-u="root" \

docker run --name zabbix-proxy-sqlite3 \
-e ZBX_HOSTNAME=proxy1 \
--volume ./jopa:/usr/lib/zabbix/externalscripts \
-d zabbix/zabbix-proxy-sqlite3:centos-5.0.1

docker run --name zabbix-proxy-sqlite3 \
-e ZBX_HOSTNAME=proxy1 \
-d zabbix/zabbix-proxy-sqlite3:alpine-5.0.1



docker run --name zabbix-proxy-sqlite3 \
-u="root" \
-e ZBX_HOSTNAME=proxy1 \
-e ZBX_SERVER_HOST=10.133.253.43 \
-e ZBX_STARTPOLLERS=1 \
-e ZBX_STARTPREPROCESSORS=1 \
-e ZBX_STARTTRAPPERS=1 \
-e ZBX_STARTDBSYNCERS=1 \
-e ZBX_STARTDISCOVERERS=0 \
-e ZBX_CACHEUPDATEFREQUENCY=3600 \
-e ZBX_STARTPINGERS=0 \
-e ZBX_STARTHTTPPOLLERS=0 \
-d zabbix/zabbix-proxy-sqlite3:centos-5.0-latest

docker exec -it zabbix-proxy-sqlite3 bash

cd /usr/lib/zabbix/externalscripts/
touch something
touch: cannot touch 'something': Permission denied

docker run --name zabbix-proxy-sqlite3 --volume /usr/lib/zabbix/externalscripts:/usr/lib/zabbix/externalscripts -e ZBX_HOSTNAME=mysql8mon -e ZBX_SERVER_HOST=10.133.253.43 -e ZBX_STARTPOLLERS=1 -e ZBX_STARTPREPROCESSORS=1 -e ZBX_STARTTRAPPERS=1 -e ZBX_STARTDBSYNCERS=1 -e ZBX_STARTDISCOVERERS=0 -e ZBX_CACHEUPDATEFREQUENCY=3600 -e ZBX_STARTPINGERS=0 -e ZBX_STARTHTTPPOLLERS=0 -d zabbix/zabbix-proxy-sqlite3:centos-5.0-latest
docker run --name zabbix-proxy-sqlite3 -u="root" --volume /usr/lib/zabbix/externalscripts:/usr/lib/zabbix/externalscripts -e ZBX_HOSTNAME=mysql8mon -e ZBX_SERVER_HOST=10.133.253.43 -e ZBX_STARTPOLLERS=1 -e ZBX_STARTPREPROCESSORS=1 -e ZBX_STARTTRAPPERS=1 -e ZBX_STARTDBSYNCERS=1 -e ZBX_STARTDISCOVERERS=0 -e ZBX_CACHEUPDATEFREQUENCY=3600 -e ZBX_STARTPINGERS=0 -e ZBX_STARTHTTPPOLLERS=0 -d zabbix/zabbix-proxy-sqlite3:centos-5.0-latest

docker exec -it zabbix-proxy-sqlite3 bash