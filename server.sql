


/* show hosts behind proxies, show ip addresses */
SELECT p.host AS proxy_name,
hosts.host AS host_name,
CASE
WHEN interface.type=0 THEN 'UNKNOWN'
WHEN interface.type=1 THEN 'AGENT'
WHEN interface.type=2 THEN 'SNMP'
WHEN interface.type=3 THEN 'IPMI'
WHEN interface.type=4 THEN 'JMX'
END AS type,
interface.ip
FROM hosts
JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
JOIN interface ON (interface.hostid=hosts.hostid)
WHERE hosts.available = 0
ORDER BY p.host
INTO OUTFILE '/tmp/hosts.IP.address.behind.proxy.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

;

SELECT json_object('Proxy', p.host,
'Host', hosts.host,
'Type', interface.type,
'IP', interface.ip)
FROM hosts
JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
JOIN interface ON (interface.hostid=hosts.hostid)
WHERE hosts.available = 0
ORDER BY p.host
;

select hostid from [hosts] FOR JSON AUTO;


echo "[
$(mysql zabbix -sN -e '
SET SESSION group_concat_max_len = 1000000;
SELECT GROUP_CONCAT(
JSON_OBJECT(
"Proxy", p.host,
"Host", hosts.host,
"Type", interface.type,
"IP", interface.ip
)
SEPARATOR ", ")
FROM hosts 
JOIN hosts p ON (hosts.proxy_hostid=p.hostid) 
JOIN interface ON (interface.hostid=hosts.hostid) 
WHERE hosts.available = 0 ORDER BY p.host')
]" | jq .

mysql zabbix -sN -e 'SET SESSION group_concat_max_len = 1000000; SELECT GROUP_CONCAT(JSON_OBJECT("Proxy", p.host,"Host", hosts.host,"Type", interface.type,"IP", interface.ip) SEPARATOR ", ") FROM hosts JOIN hosts p ON (hosts.proxy_hostid=p.hostid) JOIN interface ON (interface.hostid=hosts.hostid) WHERE hosts.available = 0 ORDER BY p.host'

mysql zabbix -sN -e 'SELECT GROUP_CONCAT(JSON_OBJECT("Proxy", p.host,"Host", hosts.host,"Type", interface.type,"IP", interface.ip) SEPARATOR ", ") FROM hosts JOIN hosts p ON (hosts.proxy_hostid=p.hostid) JOIN interface ON (interface.hostid=hosts.hostid) WHERE hosts.available = 0 ORDER BY p.host;'


SELECT HOST,
       CASE
           WHEN available=0 THEN 'unknown'
           WHEN available=1 THEN 'available'
           WHEN available=2 THEN 'not available'
       END AS available
FROM hosts
WHERE status=0 
INTO OUTFILE '/tmp/hosts.availability.unknown.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


cat << 'EOF' > secure_file_priv.cnf
[mysqld]
secure-file-priv=/tmp
EOF


select CASE
           WHEN state=0 THEN 'NORMAL'
           WHEN state=1 THEN 'UNKNOWN'
       END as state,
	   error
FROM triggers
where flags IN (0,4)
AND state=1;

UPDATE items SET state=0 WHERE state=1;

SELECT itemid,state FROM items where state=1;

UPDATE triggers SET state=0 WHERE flags IN (0,4) AND state=1;

SELECT state FROM triggers WHERE flags IN (0,4) AND state=1;



/* show hostid's behind a proxy */
SELECT h.hostid FROM hosts h JOIN hosts p ON h.proxy_hostid=p.hostid WHERE p.host='riga';


SELECT DISTINCT itemid, value from history_uint WHERE itemid IN (SELECT itemid FROM items WHERE key_='system.uptime')
AND clock>INTERVAL(NOW()-2 HOURS);

	


SELECT items.delay,
items.params
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE key_ LIKE '%odbc%'
AND items.status=0
AND items.value_type=4
AND hosts.status IN (0,1);


	
	

SELECT proxy.host,
hosts.host,
items.
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE 




/* unsupported items per host. works from 3.4 - 4.2 */
SELECT hosts.host,
       events.objectid AS itemid,
       items.key_,
       events.name AS error,
       count(events.objectid) AS occurrence
FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source = 3
  AND events.object = 4
  AND LENGTH(events.name)>0
GROUP BY hosts.host,
         events.objectid,
		 items.key_,
         events.name
ORDER BY count(*)\x\g\x








SELECT items.type,
       items.key_,
       items.delay,
       items.status,
       items.value_type,
       items.flags
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.host='Zabbix server';





/* deleted items */
/* most frequent records in auditlog. works 4.4 */
SELECT resourceid, resourcename
FROM auditlog
WHERE action=2
AND resourcetype=15
\G


/* zabibx 3.0 trigger linkage. it will list all hosts and templates which are using 'system.uptime' item key together with trigger function 'change' */
SELECT hosts.host,
triggers.templateid,
triggers.expression,
functions.itemid,
triggers.triggerid
FROM triggers
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE triggers.flags IN (0)
AND items.flags NOT IN (1)
AND items.key_='system.uptime'
AND functions.function IN ('change')
;



/* most frequent records in auditlog. works 4.4 */
SELECT COUNT(resourcetype),
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=3 THEN 'LOGIN'
           WHEN action=4 THEN 'LOGOUT'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END as action,
	   CASE
WHEN resourcetype=0 THEN 'USER'
WHEN resourcetype=2 THEN 'ZABBIX_CONFIG'
WHEN resourcetype=3 THEN 'MEDIA_TYPE'
WHEN resourcetype=4 THEN 'HOST'
WHEN resourcetype=5 THEN 'ACTION'
WHEN resourcetype=6 THEN 'GRAPH'
WHEN resourcetype=7 THEN 'GRAPH_ELEMENT'
WHEN resourcetype=11 THEN 'USER_GROUP'
WHEN resourcetype=12 THEN 'APPLICATION'
WHEN resourcetype=13 THEN 'TRIGGER'
WHEN resourcetype=14 THEN 'HOST_GROUP'
WHEN resourcetype=15 THEN 'ITEM'
WHEN resourcetype=16 THEN 'IMAGE'
WHEN resourcetype=17 THEN 'VALUE_MAP'
WHEN resourcetype=18 THEN 'IT_SERVICE'
WHEN resourcetype=19 THEN 'MAP'
WHEN resourcetype=20 THEN 'SCREEN'
WHEN resourcetype=22 THEN 'SCENARIO'
WHEN resourcetype=23 THEN 'DISCOVERY_RULE'
WHEN resourcetype=24 THEN 'SLIDESHOW'
WHEN resourcetype=25 THEN 'SCRIPT'
WHEN resourcetype=26 THEN 'PROXY'
WHEN resourcetype=27 THEN 'MAINTENANCE'
WHEN resourcetype=28 THEN 'REGEXP'
WHEN resourcetype=29 THEN 'MACRO'
WHEN resourcetype=30 THEN 'TEMPLATE'
WHEN resourcetype=31 THEN 'TRIGGER_PROTOTYPE'
WHEN resourcetype=32 THEN 'ICON_MAP'
WHEN resourcetype=33 THEN 'DASHBOARD'
WHEN resourcetype=34 THEN 'CORRELATION'
WHEN resourcetype=35 THEN 'GRAPH_PROTOTYPE'
WHEN resourcetype=36 THEN 'ITEM_PROTOTYPE'
WHEN resourcetype=37 THEN 'HOST_PROTOTYPE'
WHEN resourcetype=38 THEN 'AUTOREGISTRATION'	   
	   END as resourcetype
FROM auditlog
GROUP BY 2,3
ORDER BY COUNT(*)
\G



SELECT from_unixtime(clock),value_avg from trends
JOIN items ON (items.itemid=trends.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.name='Metric title of CPU'
AND hosts.host='Host name, but NOT host Visible name'
AND trends.clock > UNIX_TIMESTAMP('2020-04-01 00:00:00')
AND trends.clock < UNIX_TIMESTAMP('2020-05-01 00:00:00');


SELECT from_unixtime(clock),value_avg from trends_uint
JOIN items ON (items.itemid=trends_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.name='Metric title of CPU'
AND hosts.host='Host name, but NOT host Visible name'
AND trends_uint.clock > UNIX_TIMESTAMP('2020-04-01 00:00:00')
AND trends_uint.clock < UNIX_TIMESTAMP('2020-05-01 00:00:00');


SELECT from_unixtime(clock),value_avg/1024/1024 "MB" from trends_uint
JOIN items ON (items.itemid=trends_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.name='Memory used for virtualbox'
AND hosts.host='ubuntu18.catonrug.lan'
AND trends_uint.clock > UNIX_TIMESTAMP('2020-04-01 00:00:00')
AND trends_uint.clock < UNIX_TIMESTAMP('2020-05-01 00:00:00');

Free disk space on /
ubuntu18.catonrug.lan

/* hosts table has been changed */
SELECT FROM_UNIXTIME(auditlog.clock) AS clock,
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END AS action,
       users.alias,
       hosts.host
FROM auditlog
JOIN users ON (users.userid=auditlog.userid)
JOIN hosts ON (hosts.hostid=auditlog.resourceid)
WHERE auditlog.clock > UNIX_TIMESTAMP(NOW() - INTERVAL 7 DAY)
  AND hosts.status NOT IN (3)
ORDER BY clock
\G



       auditlog_details.oldvalue,
       auditlog_details.newvalue,
	   auditlog.resourcename,
	   auditlog.resourceid,
	   auditlog.details



/* new or delete */
SELECT users.alias,hosts.host,
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=3 THEN 'LOGIN'
           WHEN action=4 THEN 'LOGOUT'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END AS action,
       CASE
           WHEN resourcetype=0 THEN 'USER'
           WHEN resourcetype=2 THEN 'ZABBIX_CONFIG'
           WHEN resourcetype=3 THEN 'MEDIA_TYPE'
           WHEN resourcetype=4 THEN 'HOST'
           WHEN resourcetype=5 THEN 'ACTION'
           WHEN resourcetype=6 THEN 'GRAPH'
           WHEN resourcetype=7 THEN 'GRAPH_ELEMENT'
           WHEN resourcetype=11 THEN 'USER_GROUP'
           WHEN resourcetype=12 THEN 'APPLICATION'
           WHEN resourcetype=13 THEN 'TRIGGER'
           WHEN resourcetype=14 THEN 'HOST_GROUP'
           WHEN resourcetype=15 THEN 'ITEM'
           WHEN resourcetype=16 THEN 'IMAGE'
           WHEN resourcetype=17 THEN 'VALUE_MAP'
           WHEN resourcetype=18 THEN 'IT_SERVICE'
           WHEN resourcetype=19 THEN 'MAP'
           WHEN resourcetype=20 THEN 'SCREEN'
           WHEN resourcetype=22 THEN 'SCENARIO'
           WHEN resourcetype=23 THEN 'DISCOVERY_RULE'
           WHEN resourcetype=24 THEN 'SLIDESHOW'
           WHEN resourcetype=25 THEN 'SCRIPT'
           WHEN resourcetype=26 THEN 'PROXY'
           WHEN resourcetype=27 THEN 'MAINTENANCE'
           WHEN resourcetype=28 THEN 'REGEXP'
           WHEN resourcetype=29 THEN 'MACRO'
           WHEN resourcetype=30 THEN 'TEMPLATE'
           WHEN resourcetype=31 THEN 'TRIGGER_PROTOTYPE'
           WHEN resourcetype=32 THEN 'ICON_MAP'
           WHEN resourcetype=33 THEN 'DASHBOARD'
           WHEN resourcetype=34 THEN 'CORRELATION'
           WHEN resourcetype=35 THEN 'GRAPH_PROTOTYPE'
           WHEN resourcetype=36 THEN 'ITEM_PROTOTYPE'
           WHEN resourcetype=37 THEN 'HOST_PROTOTYPE'
           WHEN resourcetype=38 THEN 'AUTOREGISTRATION'
       END AS resourcetype,
	   auditlog.resourcename,
	   auditlog.resourceid,
	   auditlog.details
FROM auditlog
JOIN users ON (users.userid=auditlog.userid)
JOIN hosts ON (hosts.hostid=auditlog.resourceid)
WHERE resourcetype IN (4,26,30,37)
\G



SELECT FROM_UNIXTIME(auditlog.clock) as clock,
       users.alias,
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=3 THEN 'LOGIN'
           WHEN action=4 THEN 'LOGOUT'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END AS action,
       CASE
           WHEN resourcetype=0 THEN 'USER'
           WHEN resourcetype=2 THEN 'ZABBIX_CONFIG'
           WHEN resourcetype=3 THEN 'MEDIA_TYPE'
           WHEN resourcetype=4 THEN 'HOST'
           WHEN resourcetype=5 THEN 'ACTION'
           WHEN resourcetype=6 THEN 'GRAPH'
           WHEN resourcetype=7 THEN 'GRAPH_ELEMENT'
           WHEN resourcetype=11 THEN 'USER_GROUP'
           WHEN resourcetype=12 THEN 'APPLICATION'
           WHEN resourcetype=13 THEN 'TRIGGER'
           WHEN resourcetype=14 THEN 'HOST_GROUP'
           WHEN resourcetype=15 THEN 'ITEM'
           WHEN resourcetype=16 THEN 'IMAGE'
           WHEN resourcetype=17 THEN 'VALUE_MAP'
           WHEN resourcetype=18 THEN 'IT_SERVICE'
           WHEN resourcetype=19 THEN 'MAP'
           WHEN resourcetype=20 THEN 'SCREEN'
           WHEN resourcetype=22 THEN 'SCENARIO'
           WHEN resourcetype=23 THEN 'DISCOVERY_RULE'
           WHEN resourcetype=24 THEN 'SLIDESHOW'
           WHEN resourcetype=25 THEN 'SCRIPT'
           WHEN resourcetype=26 THEN 'PROXY'
           WHEN resourcetype=27 THEN 'MAINTENANCE'
           WHEN resourcetype=28 THEN 'REGEXP'
           WHEN resourcetype=29 THEN 'MACRO'
           WHEN resourcetype=30 THEN 'TEMPLATE'
           WHEN resourcetype=31 THEN 'TRIGGER_PROTOTYPE'
           WHEN resourcetype=32 THEN 'ICON_MAP'
           WHEN resourcetype=33 THEN 'DASHBOARD'
           WHEN resourcetype=34 THEN 'CORRELATION'
           WHEN resourcetype=35 THEN 'GRAPH_PROTOTYPE'
           WHEN resourcetype=36 THEN 'ITEM_PROTOTYPE'
           WHEN resourcetype=37 THEN 'HOST_PROTOTYPE'
           WHEN resourcetype=38 THEN 'AUTOREGISTRATION'
       END AS resourcetype,
	   resourceid
FROM auditlog
JOIN users ON (users.userid=auditlog.userid)
WHERE action NOT IN (3,4)
  AND clock > UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY)
ORDER BY clock
;



/* list everything, but not login logout */
SELECT FROM_UNIXTIME(auditlog.clock),
       auditlog.userid,
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=3 THEN 'LOGIN'
           WHEN action=4 THEN 'LOGOUT'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END AS action,
       CASE
           WHEN resourcetype=0 THEN 'USER'
           WHEN resourcetype=2 THEN 'ZABBIX_CONFIG'
           WHEN resourcetype=3 THEN 'MEDIA_TYPE'
           WHEN resourcetype=4 THEN 'HOST'
           WHEN resourcetype=5 THEN 'ACTION'
           WHEN resourcetype=6 THEN 'GRAPH'
           WHEN resourcetype=7 THEN 'GRAPH_ELEMENT'
           WHEN resourcetype=11 THEN 'USER_GROUP'
           WHEN resourcetype=12 THEN 'APPLICATION'
           WHEN resourcetype=13 THEN 'TRIGGER'
           WHEN resourcetype=14 THEN 'HOST_GROUP'
           WHEN resourcetype=15 THEN 'ITEM'
           WHEN resourcetype=16 THEN 'IMAGE'
           WHEN resourcetype=17 THEN 'VALUE_MAP'
           WHEN resourcetype=18 THEN 'IT_SERVICE'
           WHEN resourcetype=19 THEN 'MAP'
           WHEN resourcetype=20 THEN 'SCREEN'
           WHEN resourcetype=22 THEN 'SCENARIO'
           WHEN resourcetype=23 THEN 'DISCOVERY_RULE'
           WHEN resourcetype=24 THEN 'SLIDESHOW'
           WHEN resourcetype=25 THEN 'SCRIPT'
           WHEN resourcetype=26 THEN 'PROXY'
           WHEN resourcetype=27 THEN 'MAINTENANCE'
           WHEN resourcetype=28 THEN 'REGEXP'
           WHEN resourcetype=29 THEN 'MACRO'
           WHEN resourcetype=30 THEN 'TEMPLATE'
           WHEN resourcetype=31 THEN 'TRIGGER_PROTOTYPE'
           WHEN resourcetype=32 THEN 'ICON_MAP'
           WHEN resourcetype=33 THEN 'DASHBOARD'
           WHEN resourcetype=34 THEN 'CORRELATION'
           WHEN resourcetype=35 THEN 'GRAPH_PROTOTYPE'
           WHEN resourcetype=36 THEN 'ITEM_PROTOTYPE'
           WHEN resourcetype=37 THEN 'HOST_PROTOTYPE'
           WHEN resourcetype=38 THEN 'AUTOREGISTRATION'
       END AS resourcetype,
       auditlog.resourcename
FROM auditlog
WHERE action NOT IN (3,4)
ORDER BY clock
\G







/* simple auditlog, list everything related to creating/deleting host or template */
SELECT FROM_UNIXTIME(clock),hosts.host,
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=3 THEN 'LOGIN'
           WHEN action=4 THEN 'LOGOUT'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END as action,
	   CASE
WHEN resourcetype=0 THEN 'USER'
WHEN resourcetype=2 THEN 'ZABBIX_CONFIG'
WHEN resourcetype=3 THEN 'MEDIA_TYPE'
WHEN resourcetype=4 THEN 'HOST'
WHEN resourcetype=5 THEN 'ACTION'
WHEN resourcetype=6 THEN 'GRAPH'
WHEN resourcetype=7 THEN 'GRAPH_ELEMENT'
WHEN resourcetype=11 THEN 'USER_GROUP'
WHEN resourcetype=12 THEN 'APPLICATION'
WHEN resourcetype=13 THEN 'TRIGGER'
WHEN resourcetype=14 THEN 'HOST_GROUP'
WHEN resourcetype=15 THEN 'ITEM'
WHEN resourcetype=16 THEN 'IMAGE'
WHEN resourcetype=17 THEN 'VALUE_MAP'
WHEN resourcetype=18 THEN 'IT_SERVICE'
WHEN resourcetype=19 THEN 'MAP'
WHEN resourcetype=20 THEN 'SCREEN'
WHEN resourcetype=22 THEN 'SCENARIO'
WHEN resourcetype=23 THEN 'DISCOVERY_RULE'
WHEN resourcetype=24 THEN 'SLIDESHOW'
WHEN resourcetype=25 THEN 'SCRIPT'
WHEN resourcetype=26 THEN 'PROXY'
WHEN resourcetype=27 THEN 'MAINTENANCE'
WHEN resourcetype=28 THEN 'REGEXP'
WHEN resourcetype=29 THEN 'MACRO'
WHEN resourcetype=30 THEN 'TEMPLATE'
WHEN resourcetype=31 THEN 'TRIGGER_PROTOTYPE'
WHEN resourcetype=32 THEN 'ICON_MAP'
WHEN resourcetype=33 THEN 'DASHBOARD'
WHEN resourcetype=34 THEN 'CORRELATION'
WHEN resourcetype=35 THEN 'GRAPH_PROTOTYPE'
WHEN resourcetype=36 THEN 'ITEM_PROTOTYPE'
WHEN resourcetype=37 THEN 'HOST_PROTOTYPE'
WHEN resourcetype=38 THEN 'AUTOREGISTRATION'	   
	   END as resourcetype,
	   auditlog.resourcename
FROM auditlog
JOIN hosts ON (hosts.hostid=auditlog.resourceid)
ORDER BY clock
\G




SELECT clock,eventid,sendto,subject,status FROM alerts 
ORDER BY clock;




/* LLD behind proxies only. for very huge instance remove the line having '%d' */
SELECT proxy.host as 'proxy',
       hosts.host,
	   COUNT(discovery.key_) as 'items2maintain',
       discovery.key_ as 'discovery key',
       discovery.delay as 'frequency'
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items discovery ON (discovery.itemid=item_discovery.parent_itemid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE items.status=0
  AND items.flags=4
  AND discovery.delay NOT LIKE '%d'
  AND discovery.delay NOT LIKE '%h'
  AND discovery.delay NOT IN ('3600')
GROUP BY discovery.key_,
         discovery.delay,
		 proxy.host,
         hosts.host
ORDER BY COUNT(discovery.key_)
\G


/* SNMPconfiguration on host level. replace hostid */
SELECT items.snmpv3_securityname AS USER,
       CASE items.snmpv3_securitylevel
           WHEN 0 THEN 'noAuthNoPriv'
           WHEN 1 THEN 'authNoPriv'
           WHEN 2 THEN 'authPriv'
       END AS secLev,
       CASE items.snmpv3_authprotocol
           WHEN 0 THEN 'MD5'
           WHEN 1 THEN 'SHA'
       END AS authProto,
       items.snmpv3_authpassphrase AS authPhrase,
       CASE items.snmpv3_privprotocol
           WHEN 0 THEN 'DES'
           WHEN 1 THEN 'AES'
       END AS privProto,
       items.snmpv3_privpassphrase AS privPhrase,
       CASE items.flags
           WHEN 0 THEN 'normal'
           WHEN 1 THEN 'rule'
           WHEN 2 THEN 'prototype'
           WHEN 4 THEN 'discovered'
       END AS flags,
       count(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE TYPE=6
  AND hosts.name='hostName'
   OR TYPE=6
  AND hosts.host='hostName'
GROUP BY 1,2,3,4,5,6,7;


/* on PostgreSQL */
SELECT proxy.host,
       hosts.host,
	   COUNT(discovery.key_),
       discovery.key_,
       discovery.delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items discovery ON (discovery.itemid=item_discovery.parent_itemid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE items.status=0
  AND items.flags=4
  AND discovery.delay NOT LIKE '%d'
  AND discovery.delay NOT LIKE '%h'
  AND discovery.delay NOT IN ('3600')
GROUP BY discovery.key_,
         discovery.delay,
		 proxy.host,
         hosts.host
ORDER BY COUNT(discovery.key_);



/* unsupported items. show problems related to items. works from 3.4 to 4.2 */
SELECT COUNT(items.key_),items.key_,items.error
FROM events
JOIN items ON (items.itemid=events.objectid)
WHERE source=3
  AND object=4
  AND items.status=0
  AND items.flags IN (0,1,4)
  AND LENGTH(items.error)>0
GROUP BY items.key_,
         items.error
ORDER BY COUNT(items.key_);


/* unsupported items. show problems related to items. works on 4.4 */
SELECT COUNT(items.key_),
       hosts.host,
       items.key_,
       item_rtdata.error
FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_rtdata ON (item_rtdata.itemid=items.itemid)
WHERE source=3
  AND object=4
  AND items.status=0
  AND items.flags IN (0,1,4)
  AND LENGTH(item_rtdata.error)>0
GROUP BY hosts.host,items.key_,
         item_rtdata.error
ORDER BY COUNT(items.key_)\G







/* only on mariadb only. does not work on mysql8 */
mysql -sN -e 'SELECT * FROM information_schema.GLOBAL_STATUS ORDER BY VARIABLE_NAME;' > /tmp/mariadb.global.status.log
mysql -sN -e 'SELECT * FROM information_schema.GLOBAL_VARIABLES ORDER BY VARIABLE_NAME;' > /tmp/mariadb.global.variables.log









/* filter out events/problems when they change state from Problem to OK or vice versa */
SELECT hosts.host,
       FROM_UNIXTIME(events.clock) as 'time',
       CASE
           WHEN events.value=0 THEN 'OK'
           WHEN events.value=1 THEN 'PROBLEM'
       END AS 'trigger',
       events.name
FROM events
JOIN triggers ON (events.objectid=triggers.triggerid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
  AND events.object=0
  AND events.name like '%Zabbix discoverer processes more%'
  AND events.clock > UNIX_TIMESTAMP('2020-03-27 18:00:00')
  AND events.clock < UNIX_TIMESTAMP('2020-03-27 18:00:00' + INTERVAL 12 HOUR)
;


/* how many hosts are having an agent interface with IP: 127.0.0.1 */
SELECT hosts.host,
       interface.useip,
       interface.ip,
       interface.dns,
       interface.port
FROM interface
JOIN hosts ON (hosts.hostid=interface.hostid)
WHERE interface.type=1
  AND interface.ip='127.0.0.1';



/* Most heaviest LLD discoveries. Heaviest in terms of how many items must be maintained */
/* master piece */
SELECT COUNT(discovery.key_),
       hosts.host,
       discovery.key_,
       discovery.delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items discovery ON (discovery.itemid=item_discovery.parent_itemid)
WHERE items.status=0
  AND items.flags=4
GROUP BY discovery.key_,
         discovery.delay,
         hosts.host
ORDER BY COUNT(discovery.key_)
\G







/* without days */
SELECT COUNT(discovery.key_),
       hosts.host,
       discovery.key_,
       discovery.delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items discovery ON (discovery.itemid=item_discovery.parent_itemid)
WHERE items.status=0
  AND items.flags=4
  AND discovery.delay not like '%d'
GROUP BY discovery.key_,
         discovery.delay,
         hosts.host
ORDER BY COUNT(discovery.key_)
\G



SELECT task.clock,
       task.taskid,
       CASE
           WHEN task.status=1 THEN 'new'
           WHEN task.status=2 THEN 'in pogress'
           WHEN task.status=3 THEN 'done'
           WHEN task.status=4 THEN 'expired'
       END AS status,
       pr.host AS proxy,
       hosts.host,
       CASE
           WHEN task_remote_command.execute_on=0 THEN 'agent'
           WHEN task_remote_command.execute_on=1 THEN 'server'
           WHEN task_remote_command.execute_on=2 THEN 'proxy'
       END AS execute_on,
       CASE
           WHEN task_remote_command.command_type=0 THEN 'custom script'
           WHEN task_remote_command.command_type=1 THEN 'IPMI'
           WHEN task_remote_command.command_type=2 THEN 'SSH'
           WHEN task_remote_command.command_type=3 THEN 'telnet'
           WHEN task_remote_command.command_type=4 THEN 'global script'
       END AS command_type,
       task_remote_command.command
FROM task
JOIN task_remote_command ON (task.taskid=task_remote_command.taskid)
JOIN hosts ON (hosts.hostid=task_remote_command.hostid)
JOIN hosts pr ON (pr.hostid=task.proxy_hostid)
WHERE task.type=2
AND clock>(UNIX_TIMESTAMP("2020-02-01 00:00:00"))
AND clock<(UNIX_TIMESTAMP("2020-03-01 00:00:00"))
;


/* items generating the most internal events. works on 4.4 */
SELECT COUNT(objectid),objectid,name FROM events WHERE SOURCE = 3   AND OBJECT = 4   AND objectid NOT IN     (SELECT itemid      FROM items) AND LENGTH(name)>0 GROUP BY objectid,name ORDER BY COUNT(objectid),objectid,name\G


/* check for possible deadlocks on the DB */
SHOW ENGINE INNODB STATUS;



/* apparently these items do not exist anymore */
SELECT COUNT(events.objectid),events.objectid,events.name
FROM events
WHERE events.source = 3
  AND events.object = 4
  AND events.objectid NOT IN (SELECT itemid FROM items)
AND LENGTH(events.name)>0
GROUP BY events.objectid,events.name
ORDER BY COUNT(events.objectid),events.objectid,events.name
\G


/* remove event for unexisting items */
DELETE FROM events
WHERE events.source = 3
  AND events.object = 4
  AND events.objectid NOT IN (SELECT itemid FROM items);

  
/* list items that are active(not disabled) and comes from discovery rule */
SELECT COUNT(*),item_discovery.parent_itemid from items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items parent ON (parent.itemid=item_discovery.itemid)
WHERE hosts.host='centos7.catonrug.lan'
AND items.status=0
AND items.flags=4
GROUP BY item_discovery.parent_itemid
ORDER BY COUNT(*)
\G

/* how many item prototypes configured per discovery */
SELECT COUNT(*),prototype.key_,prototype.delay from items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items prototype ON (prototype.itemid=item_discovery.parent_itemid)
WHERE hosts.host='centos7.catonrug.lan'
AND items.status=0
AND items.flags=2
GROUP BY prototype.key_,prototype.delay
ORDER BY COUNT(*)
\G


/* which action is disablad, active */
SELECT actionid,
       name,
       CASE
           WHEN status=0 THEN 'active'
           WHEN status=1 THEN 'disable'
       END AS status
FROM actions
WHERE eventsource=0;

/* which action is causing the most trouble (NOT_SENT) */
SELECT COUNT(*),CASE alerts.status
           WHEN 0 THEN 'NOT_SENT'
           WHEN 1 THEN 'SENT'
           WHEN 2 THEN 'FAILED'
           WHEN 3 THEN 'NEW'
       END AS status,alerts.actionid
FROM alerts
WHERE alerts.status=0
GROUP BY alerts.status,alerts.actionid; 
 
/* disable alerts */
UPDATE alerts set status = 2, message ="manual diable" where status = 0;

/* system.cpu.num[] - this key will report integer (not float). timestamp will be store in history_uint */
/* linux and windows host must have one comon item key. Item key must be in configured as "Zabbix agent (active)" */
/* Freqeuncy shoud be 30s or less. better to not link any trigger */
/* one specific case when agent time is to old */

SELECT DISTINCT hosts.host,FROM_UNIXTIME(MAX(history_uint.clock))
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.key_='agent.ping'
GROUP BY hosts.host
LIMIT 2;


SELECT DISTINCT hosts.host,FROM_UNIXTIME(MAX(history_uint.clock))
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.key_='proc.num[]'
GROUP BY hosts.host
ORDER BY FROM_UNIXTIME(MAX(history_uint.clock));



SELECT DISTINCT hosts.host,FROM_UNIXTIME(MAX(history_uint.clock))
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.key_='agent.ping'
GROUP BY hosts.host
LIMIT 2;


/* postgres */
SELECT DISTINCT hosts.host,MAX(history_uint.clock)
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.key_='system.cpu.num[]'
GROUP BY hosts.host
LIMIT 2;




/* these items exist and generate bad events in last 1 day */
SELECT COUNT(items.key_) as count,items.key_,events.name
FROM events
JOIN items ON (items.itemid=events.objectid)
WHERE events.source = 3
  AND events.object = 4
  AND events.objectid IN (SELECT itemid FROM items)
  AND clock > UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY)
AND LENGTH(events.name)>0
GROUP BY items.key_,events.name
ORDER BY COUNT(items.key_),items.key_,events.name
\G



select num from trends_uint 
WHERE clock > UNIX_TIMESTAMP('2020-01-03 00:00:00')
  AND clock < UNIX_TIMESTAMP('2020-01-04 00:00:00')
  AND itemid=49766;
  
  
/* show the minimal clock value for items. without partition name this is performance killer. */
SELECT hosts.host,items.key_,FROM_UNIXTIME(MIN(clock))
FROM history PARTITION (p202003211600)
JOIN items ON (items.itemid=history.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
GROUP BY hosts.host,items.key_;






/* which item takes the most space by frequency */
SELECT count(items.key_),
       hosts.host,
       items.key_
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 1 DAY)
GROUP BY hosts.host,
         items.key_
ORDER BY count(items.key_),
         hosts.host,
         items.key_ ASC
\G




/* by partition which item takes the most space by frequency */
SELECT count(items.key_),hosts.host,items.key_
FROM history PARTITION (p202003211600)
JOIN items ON (items.itemid=history.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
GROUP BY hosts.host,items.key_
ORDER BY count(items.key_),hosts.host,items.key_ ASC
\G





SELECT max(LENGTH (value)),avg(LENGTH (value))
FROM history_text
WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 1 DAY);


SELECT hosts.host,items.key_ 
FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(value)>657
LIMIT 10\G




/* representing the Host groups with */
SELECT h.host AS 'Host name',
       h.name AS 'Visible name',
       GROUP_CONCAT(C.name SEPARATOR ', ') AS 'Host groups',
       h.error AS 'Error'
FROM hosts h
JOIN hosts_groups AS B ON (h.hostid=B.hostid)
JOIN hstgrp AS C ON (B.groupid=C.groupid)
WHERE h.available = 2
GROUP BY h.host,h.name,h.error;

/* Listing template names */
SELECT h.host AS 'Host name',
       h.name AS 'Visible name',
       GROUP_CONCAT(b.host SEPARATOR ', ') AS 'Templates',
       h.error AS 'Error'
FROM hosts_templates,
     hosts h,
     hosts b,
     interface
WHERE hosts_templates.hostid = h.hostid
  AND hosts_templates.templateid = b.hostid
  AND interface.hostid = h.hostid
  AND h.available = 2
GROUP BY h.host,h.name,h.error;
  

SELECT DISTINCT 
    (SELECT min(ti.Country_id) 
     FROM tbl_countries ti 
     WHERE t.country_title = ti.country_title) As Country_id
    , country_title
FROM 
    tbl_countries t
  


/* SNMPv3 hosts */
SELECT hosts.host,
COUNT(items.type) as 'Count of items'
FROM hosts
JOIN items ON (items.hostid=hosts.hostid)
WHERE items.type in (6)
AND hosts.status=0
GROUP BY hosts.host,items.type
ORDER BY hosts.host;


/* SNMPv2 hosts */
SELECT hosts.host,
COUNT(items.type) as 'Count of items'
FROM hosts
JOIN items ON (items.hostid=hosts.hostid)
WHERE items.type in (4)
AND hosts.status=0
GROUP BY hosts.host,items.type
ORDER BY hosts.host;


/* show SNMPv1, SNMPv2, SNMPv3 items */
SELECT hosts.host,
CASE items.type
           WHEN 1 THEN 'SNMPv1'
           WHEN 4 THEN 'SNMPv2'
           WHEN 6 THEN 'SNMPv3'
END AS type,
COUNT(items.type)
FROM hosts
JOIN items ON (items.hostid=hosts.hostid)
WHERE items.type in (1,4,6)
AND hosts.status=0
GROUP BY hosts.host,items.type
ORDER BY hosts.host;


SELECT hosts.hostid,CONCAT(COUNT(items.type),' ',items.type)
FROM hosts
JOIN items ON items.hostid=hosts.hostid
WHERE items.type in (1,4,6)
GROUP BY hosts.hostid,items.type
ORDER BY hosts.hostid;

  
/* This table contains list of active problems, in other words it will contain list of opened PROBLEM events. 
PROBLEM events are trigger events with value TRIGGER_VALUE_PROBLEM and internal events with value ITEM_STATE_NOTSUPPORTED/TRIGGER_STATE_UNKNOWN  */
select COUNT(*),source from problem group by source;


/* show item prototypes, discoveries and items configured with SNMPv3 */
SELECT snmpv3_securityname AS USER,
       CASE snmpv3_securitylevel
           WHEN 0 THEN 'noAuthNoPriv'
           WHEN 1 THEN 'authNoPriv'
           WHEN 2 THEN 'authPriv'
       END AS secLev,
       CASE snmpv3_authprotocol
           WHEN 0 THEN 'MD5'
           WHEN 1 THEN 'SHA'
       END AS authProto,
       snmpv3_authpassphrase AS authPhrase,
       CASE snmpv3_privprotocol
           WHEN 0 THEN 'DES'
           WHEN 1 THEN 'AES'
       END AS privProto,
       snmpv3_privpassphrase AS privPhrase,
       CASE flags
           WHEN 0 THEN 'normal'
           WHEN 1 THEN 'rule'
           WHEN 2 THEN 'prototype'
           WHEN 4 THEN 'discovered'
       END AS flags,
       COUNT(*)
FROM items
WHERE TYPE=6
GROUP BY 1,2,3,4,5,6,7\G




/* see different type of items */
select COUNT(type), type from items where hostid=10814 group by type;


/* show template count on 3.0 */
select COUNT(*) from hosts where status=3;
/* host is disabled */
select COUNT(*) from hosts where status=1;
/* count of monitored hosts */
select COUNT(*) from hosts where status=0 and flags<>2;


/* items running */
SELECT COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags IN (0,4)
  AND items.state=0
  AND items.status=0
  AND hosts.status=0
  AND hosts.flags<>2;

/* items disabled */
SELECT COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags IN (0,4)
  AND items.state=0
  AND items.status=1
  AND hosts.flags<>2;

/* items not supported */
SELECT COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags IN (0,4)
  AND items.state=1
  AND items.status=0
  AND hosts.status=0
  AND hosts.flags<>2;

/* details about triggers */
SELECT COUNT(DISTINCT triggers.triggerid) AS cnt,
       triggers.status,
       triggers.value
FROM TRIGGERS
WHERE NOT EXISTS
    (SELECT functions.functionid
     FROM functions
     JOIN items ON functions.itemid=items.itemid
     JOIN hosts ON items.hostid=hosts.hostid
     WHERE functions.triggerid=triggers.triggerid
       AND (items.status<>0
            OR hosts.status<>0))
  AND triggers.flags IN (0,4)
GROUP BY triggers.status,
         triggers.value;

/* In the result there will be all 4 things */
SELECT task.taskid,hosts.host FROM task
JOIN task_remote_command on (task.taskid=task_remote_command.taskid)
JOIN task_remote_command_result on (task.taskid=task_remote_command_result.taskid)
JOIN hosts on (task_remote_command.hostid=hosts.hostid)



/* enable loging to table */
# Please do the following sequence:

# sign in database client as root. take a look on current settings
select @@log_output, @@general_log, @@general_log_file\G

# set the global logging to table
SET global log_output = 'table';

# see now the situation has been changed comparing to original
select @@log_output, @@general_log, @@general_log_file\G

# take a note that log table currently is empty
select COUNT(*) from mysql.general_log;
 
# enable the logging
SET global general_log = 1;
# THIS WILL START TO WRITE MASSIVE CONTENT!

# see how the number is increasing. execute few times:
select COUNT(*) from mysql.general_log;
# I hope its less than 10000 records per second!

# wait 10 minutes

# stop logging
SET global general_log = 0;

# make sure number remains static
select COUNT(*) from mysql.general_log;

# set back the log settings to file
SET global log_output = 'file';

# this must be the same as in the beginning
select @@log_output, @@general_log, @@general_log_file\G

# ======not required to execute - to observe records=======
describe mysql.general_log;
show create table mysql.general_log\G

# observe records
select * from mysql.general_log limit 10\G


/* summarize a specific discovery rule - unsuppoerted/supported ratio. Does not work on 4.4 */
SELECT i.state,h.host AS 'Host name',i.name AS 'ITEM name',i.key_ AS 'KEY' FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.key_='vfs.fs.discovery[{HOST.NAME}]' and h.status=0 and i.state=0 limit 10;

/* on 3.4 */
select description from triggers WHERE triggerid IN (select objectid from events where eventid=15);
      
/* Something impossible has just happened */
select COUNT(*) from item_preproc where itemid not in (select itemid from items);
delete from item_preproc where itemid not in (select itemid from items);

select @@foreign_key_checks\G

/* Problems are stuck in the Closing status 
Click on the timestamp of each stuck problem to get the Event ID from URL and then use it to remove the record. Replace the <eventid> with relevant value. */
DELETE FROM events WHERE source = 0 AND object = 0 AND eventid = <eventid>;

/*
0, ITEM_VALUE_TYPE_FLOAT - Float
1, ITEM_VALUE_TYPE_STR - Character
2, ITEM_VALUE_TYPE_LOG - Log
3, ITEM_VALUE_TYPE_UINT64 - Unsigned integer
4, ITEM_VALUE_TYPE_TEXT - Text
*/

SELECT COUNT(*) FROM history where itemid in (select itemid from items where value_type<>0);
SELECT COUNT(*) FROM history_str where itemid in (select itemid from items where value_type<>1);
SELECT COUNT(*) FROM history_log where itemid in (select itemid from items where value_type<>2);
SELECT COUNT(*) FROM history_uint where itemid in (select itemid from items where value_type<>3);
SELECT COUNT(*) FROM history_text where itemid in (select itemid from items where value_type<>4);


SELECT DISTINCT items.key_,hosts.host FROM history_text 
JOIN items ON (history_text.itemid=items.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
where history_text.itemid in (select itemid from items where value_type<>4);


DELETE FROM history where itemid in (select itemid from items where value_type<>0);
DELETE FROM history_str where itemid in (select itemid from items where value_type<>1);
DELETE FROM history_log where itemid in (select itemid from items where value_type<>2);
DELETE FROM history_uint where itemid in (select itemid from items where value_type<>3);
DELETE FROM history_text where itemid in (select itemid from items where value_type<>4);


/* compare the oldest record in events table with the data configured in GUI */
select min(clock) from events where source=0;
select min(clock) from events where source=3;
select min(clock) from events where source=2; 

/* postgreSQL manual housekeeper */
delete FROM alerts where age(to_timestamp(alerts.clock)) > interval '40 days';
delete FROM acknowledges where age(to_timestamp(acknowledges.clock)) > interval '40 days';
delete FROM events where age(to_timestamp(events.clock)) > interval '40 days';
delete FROM history where age(to_timestamp(history.clock)) > interval '40 days';
delete FROM history_uint where age(to_timestamp(history_uint.clock)) > interval '40 days' ;
delete FROM history_str  where age(to_timestamp(history_str.clock)) > interval '40 days' ;
delete FROM history_text where age(to_timestamp(history_text.clock)) > interval '40 days' ;
delete FROM history_log where age(to_timestamp(history_log.clock)) > interval '40 days' ;
delete FROM trends where age(to_timestamp(trends.clock)) > interval '90 days';
delete FROM trends_uint where age(to_timestamp(trends_uint.clock)) > interval '90 days' ;
delete from history where itemid not in (select itemid from items where status='0');
delete from history_uint where itemid not in (select itemid from items where status='0');
delete from history_str where itemid not in (select itemid from items where status='0');
delete from history_text where itemid not in (select itemid from items where status='0');
delete from history_log where itemid not in (select itemid from items where status='0');
delete from trends where itemid not in (select itemid from items where status='0');
delete from trends_uint where itemid not in (select itemid from items where status='0');	  
	  
/* */	  
SHOW FULL COLUMNS FROM items;
	  
/*	  
0, ITEM_TYPE_ZABBIX - Zabbix agent
1, ITEM_TYPE_SNMPV1 - SNMPv1 agent
2, ITEM_TYPE_TRAPPER - Zabbix trapper
3, ITEM_TYPE_SIMPLE - Simple check
4, ITEM_TYPE_SNMPV2C - SNMPv2 agent
5, ITEM_TYPE_INTERNAL - Zabbix internal
6, ITEM_TYPE_SNMPV3 - SNMPv3 agent
7, ITEM_TYPE_ZABBIX_ACTIVE - Zabbix agent (active) check
8, ITEM_TYPE_AGGREGATE - Aggregate
9, ITEM_TYPE_HTTPTEST - HTTP test (web monitoring scenario step)
10, ITEM_TYPE_EXTERNAL - External check
11, ITEM_TYPE_DB_MONITOR - Database monitor
12, ITEM_TYPE_IPMI - IPMI agent
13, ITEM_TYPE_SSH - SSH agent
14, ITEM_TYPE_TELNET - TELNET agent
15, ITEM_TYPE_CALCULATED - Calculated
16, ITEM_TYPE_JMX - JMX agent
17, ITEM_TYPE_SNMPTRAP - SNMP trap
18, ITEM_TYPE_DEPENDENT - Dependent item
*/	  

/* most unsupported items per host. Does not work on 4.4 */
SELECT DISTINCT h.host AS 'Host name',COUNT(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' GROUP BY h.host ORDER BY 2;

 SELECT DISTINCT h.host AS 'Host name',COUNT(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' GROUP BY h.host ORDER BY 2 desc limit 15;

/* only enabled hosts */
SELECT DISTINCT h.host AS 'Host name',COUNT(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' and h.status=0 GROUP BY h.host ORDER BY 2 desc limit 15; 
SELECT DISTINCT h.host AS 'Host name',COUNT(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' and h.status=0 GROUP BY h.host ORDER BY 2 desc limit 15; 
 

/* show SSH agent in unsupported state */
select i.state,i.itemid,i.hostid,i.key_,i.templateid,h.name from items i INNER JOIN hosts h where (h.hostid=i.hostid) and type=13 and i.flags=0 and h.status not in (3) and state=1;
	  
/* show Simple check in unsupported state */
select i.state,i.itemid,i.hostid,i.key_,i.templateid,h.name from items i INNER JOIN hosts h where (h.hostid=i.hostid) and type=3 and i.flags=0 and h.status not in (3) and state=1;

/* show Zabbix trapper in unsupported state */
select i.state,i.itemid,i.hostid,i.key_,i.templateid,h.name from items i INNER JOIN hosts h where (h.hostid=i.hostid) and type=2 and i.flags=0 and h.status not in (3) and state=1;

/* show Database monitor in unsupported state */
select i.state,i.itemid,i.hostid,i.key_,i.templateid,h.name from items i INNER JOIN hosts h where (h.hostid=i.hostid) and type=11 and i.flags=0 and h.status not in (3) and state=1;


/* summarize database permissions */
select host,db,user from mysql.db;
SELECT Host,User FROM mysql.user where User="zabbix";


/* StartDBSyncers=4 by default can feed 4k NVPS. Don't increase it. If history syncer is busy there may be to much nodata or time based triggers functions. History syncer is responsible about calculating triggers.
If StartDBSyncers there will be more locks on ids table and performance will decrease.
 */


select e.eventid from events e INNER JOIN triggers t ON ( t.triggerid = e.objectid ) where t.triggerid = NULL;


/* most frequent metrics */
select itemid,COUNT(*) from history_uint where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by COUNT(*) desc limit 10;
select itemid,COUNT(*) from history where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by COUNT(*) desc limit 10;
select itemid,COUNT(*) from history_str where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by COUNT(*) desc limit 10;
select itemid,COUNT(*) from history_log where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by COUNT(*) desc limit 10;
select itemid,COUNT(*) from history_text where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by COUNT(*) desc limit 10;


/* optimize sessions table in case of lazy bastard - cannot fine tune the API script */
select COUNT(*) from sessions;
delete from sessions where (lastaccess < UNIX_TIMESTAMP(NOW()) - 3600); optimize table sessions;
SELECT COUNT(u.alias),
       u.alias
FROM users u
INNER JOIN sessions s ON (u.userid = s.userid)
WHERE (s.status=0)
  AND (s.lastaccess > UNIX_TIMESTAMP(NOW()) - 300)
GROUP BY u.alias;


/* which users belongs to groupid, user group */
SELECT users.alias
FROM users_groups
JOIN users ON (users_groups.userid=users.userid)
WHERE users_groups.usrgrpid in (7);


/* filter active triggers by severity on 3.4 with events table (a database killer) */ 
SELECT COUNT(t.priority) AS COUNT,
       CASE
           WHEN t.priority=0 THEN 'Not classified'
           WHEN t.priority=1 THEN 'Information'
           WHEN t.priority=2 THEN 'Warning'
           WHEN t.priority=3 THEN 'Average'
           WHEN t.priority=4 THEN 'High'
           WHEN t.priority=5 THEN 'Disaster'
       END AS priority
FROM EVENTS e
INNER JOIN TRIGGERS t ON (e.objectid = t.triggerid)
WHERE e.source=0
  AND e.object=0
  AND t.value=1
GROUP BY t.priority
ORDER BY COUNT(t.priority);

/* filter active triggers by severity on 3.4 with events table (NOT a database killer) */ 
select COUNT(t.priority),CASE
           WHEN t.priority=0 THEN 'Not classified'
           WHEN t.priority=1 THEN 'Information'
           WHEN t.priority=2 THEN 'Warning'
           WHEN t.priority=3 THEN 'Average'
           WHEN t.priority=4 THEN 'High'
           WHEN t.priority=5 THEN 'Disaster'
       END AS priority
from triggers t
where t.value=1
and t.flags in (0,4)
GROUP BY t.priority
ORDER BY COUNT(t.priority);

/* auditlog */
SELECT COUNT(*),
       CASE
           WHEN action=0 THEN 'AUDIT_ACTION_ADD'
           WHEN action=1 THEN 'AUDIT_ACTION_UPDATE'
           WHEN action=2 THEN 'AUDIT_ACTION_DELETE'
           WHEN action=3 THEN 'AUDIT_ACTION_LOGIN'
           WHEN action=4 THEN 'AUDIT_ACTION_LOGOUT'
           WHEN action=5 THEN 'AUDIT_ACTION_ENABLE'
           WHEN action=6 THEN 'AUDIT_ACTION_DISABLE'
       END AS action
FROM auditlog
GROUP BY action;



SELECT COUNT(*),
       CASE
           WHEN action=0 THEN 'AUDIT_ACTION_ADD'
           WHEN action=1 THEN 'AUDIT_ACTION_UPDATE'
           WHEN action=2 THEN 'AUDIT_ACTION_DELETE'
           WHEN action=3 THEN 'AUDIT_ACTION_LOGIN'
           WHEN action=4 THEN 'AUDIT_ACTION_LOGOUT'
           WHEN action=5 THEN 'AUDIT_ACTION_ENABLE'
           WHEN action=6 THEN 'AUDIT_ACTION_DISABLE'
       END AS action
FROM auditlog
WHERE clock>(UNIX_TIMESTAMP("2020-01-01 00:00:00"))
  AND clock<(UNIX_TIMESTAMP("2020-02-01 00:00:00"))
GROUP BY action;



/* problems by severity */
select COUNT(*) from zabbix.triggers where priority=5 and value=1;
select COUNT(*) from zabbix.triggers where priority=4 and value=1;
select COUNT(*) from zabbix.triggers where priority=3 and value=1;
select COUNT(*) from zabbix.triggers where priority=2 and value=1;
select COUNT(*) from zabbix.triggers where priority=1 and value=1;
select COUNT(*) from zabbix.triggers where priority=0 and value=1;


/* max and average value lenght */
select max(LENGTH (value)), avg(LENGTH (value)) from history_text where clock> UNIX_TIMESTAMP (now() - INTERVAL 30 MINUTE);




/* show which user is active users  */
SELECT users.alias,sessions.sessionid,sessions.lastaccess
FROM users
JOIN users_groups ON ( users.userid = users_groups.userid )
JOIN sessions ON ( users.userid = sessions.userid )
WHERE (sessions.status = 0)
AND sessions.lastaccess>1583830440;


/* user group with specific rights causing trouble */
SELECT users.alias,sessions.sessionid,sessions.lastaccess,rights.rightid
FROM users
JOIN users_groups ON ( users.userid = users_groups.userid )
JOIN sessions ON ( users.userid = sessions.userid )
JOIN usrgrp ON ( usrgrp.usrgrpid = users_groups.usrgrpid )
JOIN rights ON ( rights.groupid = usrgrp.usrgrpid )
WHERE (sessions.status = 0)
AND sessions.lastaccess>1583830440;

/* tail -f zabbix_access.log | grep -E -o "sid=[0-9a-f]+" */

SELECT users.alias,
       sessions.sessionid,
       sessions.lastaccess,
       rights.rightid
FROM users
JOIN users_groups ON (users.userid = users_groups.userid)
JOIN sessions ON (users.userid = sessions.userid)
JOIN usrgrp ON (usrgrp.usrgrpid = users_groups.usrgrpid)
JOIN rights ON (rights.groupid = usrgrp.usrgrpid)
WHERE (sessions.status = 0)
  AND rights.rightid IN (7)
  AND sessions.lastaccess>NOW() - 3600;


/* search for metrics in history_text table where currently those are not stored as text */
SELECT COUNT(itemid) FROM history_text WHERE itemid IN (SELECT itemid FROM items where value_type<>4);

SELECT u.alias
FROM users u
INNER JOIN users_groups g ON ( u.userid = g.userid )
INNER JOIN sessions s ON ( u.userid = s.userid )
WHERE (s.status = 0)
and (s.lastaccess > NOW() - 3600);

/* active users users */
SELECT COUNT(u.alias),
       u.alias
FROM users u
INNER JOIN sessions s ON (u.userid = s.userid)
WHERE (s.status=0)
GROUP BY u.alias;

/* active users not including guests */
SELECT COUNT(u.alias),u.alias FROM users u INNER JOIN sessions s ON (u.userid = s.userid) WHERE (s.status=0)   AND (u.alias<>'guest') GROUP BY u.alias;


/* users online in last 5 minutes */
SELECT COUNT(u.alias),
       u.alias
FROM users u
INNER JOIN sessions s ON (u.userid = s.userid)
WHERE (s.status=0)
  AND (s.lastaccess > UNIX_TIMESTAMP(NOW()) - 300)
GROUP BY u.alias;

/* */
SELECT u.alias,
       s.sessionid
FROM users u
INNER JOIN sessions s ON (u.userid = s.userid)
WHERE (s.status=0)
  AND (s.lastaccess > UNIX_TIMESTAMP(NOW()) - 300);

/* ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 's INNER JOIN users u ON (u.userid = s.userid) where (u.alias='guest')' at line 1 */



DELETE FROM sessions
JOIN users ON (users.userid=sessions.userid)
WHERE users.alias='Admin'; 
OPTIMIZE TABLE sessions;



/* show which user is online by groupid */
SELECT u.alias
FROM users u
INNER JOIN users_groups g ON ( u.userid = g.userid )
INNER JOIN sessions s ON ( u.userid = s.userid )
WHERE (g.usrgrpid=7)
AND (s.status = 1);


/* select triggers from one host */
SELECT DISTINCT host, t.description, f.triggerid, t.value
FROM triggers t
INNER JOIN functions f ON ( f.triggerid = t.triggerid )
INNER JOIN items i ON ( i.itemid = f.itemid )
INNER JOIN hosts ON ( i.hostid = hosts.hostid )
WHERE (1=1)
AND host = 'Zabbix server' 
GROUP BY f.triggerid
ORDER BY t.lastchange DESC;

/* see hosts/templates having snmp trap items */
select h.name,i.hostid from items i join hosts h where i.hostid = h.hostid and i.type=17;


select DISTINCT h.name, i.key_, t.error from events e 
inner join triggers t on (e.objectid=t.triggerid)
INNER JOIN functions f ON ( f.triggerid = t.triggerid )
INNER JOIN items i ON ( i.itemid = f.itemid )
INNER JOIN hosts h ON ( i.hostid = h.hostid )
where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 limit 20;

/* problems receiving information */

/* show trigger evaluation problems - internal events. best query ever! */
SELECT DISTINCT hosts.name,
                COUNT(hosts.name),
                items.key_,
                triggers.error
FROM events
JOIN triggers ON (events.objectid=triggers.triggerid)
JOIN functions ON (functions.triggerid = triggers.triggerid)
JOIN items ON (items.itemid = functions.itemid)
JOIN hosts ON (items.hostid = hosts.hostid)
WHERE events.source=3
  AND events.object=0
  AND triggers.flags IN (0,4)
  AND triggers.state=1
GROUP BY hosts.name,items.key_,triggers.error
ORDER BY COUNT(hosts.name),
         hosts.name,
         items.key_,
         triggers.error\G
		 
		 



select DISTINCT h.name, i.key_, t.error from events e  inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like 'Cannot obtain file information: [2] No such file or directory';


select DISTINCT h.name, i.key_, t.error from events e  inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like '%Agent is unavailable.%' and e.clock>UNIX_TIMESTAMP(NOW())-3600;


/* timeout */
select COUNT(t.error), key_,t.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like 'Timeout while executing a shell script.' group by key_ order by COUNT(t.error) desc;


select COUNT(t.error),h.name, key_,t.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like 'Timeout while executing a shell script.' and e.clock>UNIX_TIMESTAMP(NOW())-3600 group by key_ order by COUNT(t.error) desc;


/* trigger error statisticks */
select COUNT(t.error), t.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 group by t.error;


/* latest monitoring problems */
select COUNT(t.error), t.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and e.clock>UNIX_TIMESTAMP(NOW())-3600 group by t.error;


/* discoveries les than 10 minutes */
select key_,delay from items where flags=1 and delay not in (600,3600,0,'10m') and delay not like '%h' and delay not like '%d' order by delay;

/* show most frequently used functions */
select name,parameter,COUNT(*) from functions group by 1,2 order by 3 desc limit 50;
/* on 2.4 */
select function,parameter,COUNT(*) from functions group by 1,2 order by 3 desc limit 50;






/* show hosts having a dns name installed */
SELECT h.host,h.name,ii.type,ii.useip,ii.ip,ii.dns from hosts h join interface ii on h.hostid=ii.hostid WHERE LENGTH(ii.dns)>0 AND ii.useip=1;



/* top messages which were initiated to notify someone (not works on 3.0) */
select COUNT(*),t.description from alerts a inner join events e on a.p_eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by COUNT(*) desc limit 10;
select COUNT(*),t.description from alerts a inner join events e on a.p_eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by COUNT(*) desc\G

/* on 3.0 */
select COUNT(*),t.description from alerts a inner join events e on a.eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by COUNT(*) desc limit 10;



/* identify possibly old records which belongs to nonexisting trigger */
select objectid,name from events where source=0 and objectid not in (select triggerid from triggers)\G

select COUNT(*) from events where source=0 and objectid not in (select triggerid from triggers);
select objectid,name from events where source=0 and objectid not in (select triggerid from triggers) order by clock\G


/* items having problems receiving data. Super useful select to summarize and fix issues for data gathering. works on 4.0, 4.4 */
SELECT hosts.host,
       events.objectid AS itemid,
       items.key_,
       events.name AS error,
       COUNT(events.objectid) AS occurrence
FROM EVENTS
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source = 3
  AND events.object = 4
  AND LENGTH(events.name)>0
GROUP BY hosts.host,
         events.objectid,
		 items.key_,
         events.name
ORDER BY COUNT(*)\x\g\x




select h.host from interface ii,hosts h WHERE h.hostid=ii.hostid AND ii.useip=1 AND LENGTH(ii.dns)>0;

UPDATE interface ii,hosts h SET ii.useip=0 WHERE h.hostid=ii.hostid AND ii.useip=1 AND LENGTH(ii.dns)>0 and h.host='bcm2711';

/* see unsent alerts */
select COUNT(*),CASE alerts.status
           WHEN 0 THEN 'NOT_SENT'
           WHEN 1 THEN 'SENT'
           WHEN 2 THEN 'FAILED'
           WHEN 3 THEN 'NEW'
       END AS status
from alerts
group by alerts.status;


select COUNT(*),CASE alerts.status
           WHEN 0 THEN 'NOT_SENT'
           WHEN 1 THEN 'SENT'
           WHEN 2 THEN 'FAILED'
           WHEN 3 THEN 'NEW'
       END AS status
from alerts
JOIN media_type ON (media_type.mediatypeid=alerts.mediatypeid)
where media_type.type=4
group by alerts.status;


/* Cannot insert new item in the host configuration */
delete from ids where table_name='items';
delete from ids;

show processlist;
/* if query is all in caps this means it comes from frontend */

FLUSH PRIVILEGES;

/* for 5.5.64-MariaDB Comming from Base CentOS 7 repo */
/* https://www.digitalocean.com/community/tutorials/how-to-change-a-mysql-data-directory-to-a-new-location-on-centos-7 */

SELECT @@version,@@datadir\G

SELECT @@version,@@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@open_files_limit,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G


SELECT @@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G

SELECT @@innodb_file_per_table,@@datadir,@@innodb_buffer_pool_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G


SELECT @@hostname,@@version,@@datadir,@@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G

/* if xtrabackup is used https://mariadb.com/kb/en/library/percona-xtrabackup-overview/ */ 
SELECT @@hostname,@@version,@@datadir,@@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_page_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G;

select @@hostname, @@version, @@datadir, @@innodb_file_per_table, @@skip_name_resolve, @@key_buffer_size, @@max_allowed_packet, @@max_connections, @@join_buffer_size, @@sort_buffer_size, @@read_buffer_size, @@thread_cache_size, @@query_cache_type, @@wait_timeout, @@innodb_buffer_pool_size, @@innodb_log_file_size, @@innodb_log_buffer_size, @@innodb_flush_method, @@innodb_buffer_pool_instances, @@innodb_flush_log_at_trx_commit, @@optimizer_switch\G

select @@version;

/* see the last failed messages */
select clock,error from alerts where status=2 order by clock desc limit 10;


/* command resets the trigger status. */
/* You can update trigger status using following query, replace "(list of trigger ids)" with actual trigger ids values with "," delimiter: */
update triggers set value = 0, lastchange = UNIX_TIMESTAMP(NOW()) WHERE triggerid in (list of trigger ids);

UPDATE items SET lastlogsize=0 where itemid=123456;


/* what item prototype has been assigned for discovery rule */
SELECT id.itemid,
       id.key_,
       id.lastcheck,
       id.ts_delete,
       i.name,
       i.key_,
       i.type,
       i.value_type,
       i.delay,
       i.history,
       i.trends,
       i.trapper_hosts,
       i.units,
       i.formula,
       i.logtimefmt,
       i.valuemapid,
       i.params,
       i.ipmi_sensor,
       i.snmp_community,
       i.snmp_oid,
       i.port,
       i.snmpv3_securityname,
       i.snmpv3_securitylevel,
       i.snmpv3_authprotocol,
       i.snmpv3_authpassphrase,
       i.snmpv3_privprotocol,
       i.snmpv3_privpassphrase,
       i.authtype,
       i.username,
       i.password,
       i.publickey,
       i.privatekey,
       i.description,
       i.interfaceid,
       i.snmpv3_contextname,
       i.jmx_endpoint,
       i.master_itemid,
       i.timeout,
       i.url,
       i.query_fields,
       i.posts,
       i.status_codes,
       i.follow_redirects,
       i.post_type,
       i.http_proxy,
       i.headers,
       i.retrieve_mode,
       i.request_method,
       i.output_format,
       i.ssl_cert_file,
       i.ssl_key_file,
       i.ssl_key_password,
       i.verify_peer,
       i.verify_host,
       id.parent_itemid,
       i.allow_traps
FROM item_discovery id
JOIN items i ON id.itemid=i.itemid
WHERE id.parent_itemid IN (103331);



/* show the variation between SNMP community names being used in environment */
SELECT snmp_community,
       snmpv3_securityname,
       snmpv3_securitylevel,
       snmpv3_authpassphrase,
       snmpv3_privpassphrase,
       snmpv3_authprotocol,
       snmpv3_privprotocol,
       snmpv3_contextname,
       COUNT(*)
FROM items i
JOIN hosts h ON i.hostid = h.hostid
WHERE i.type IN (1,4,6)
GROUP BY snmp_community,
         snmpv3_securityname,
         snmpv3_securitylevel,
         snmpv3_authpassphrase,
         snmpv3_privpassphrase,
         snmpv3_authprotocol,
         snmpv3_privprotocol,
         snmpv3_contextname\G;
		 

/* filter by host */
SELECT snmp_community,
       snmpv3_securityname,
       snmpv3_securitylevel,
       snmpv3_authpassphrase,
       snmpv3_privpassphrase,
       snmpv3_authprotocol,
       snmpv3_privprotocol,
       snmpv3_contextname,
       COUNT(*)
FROM items i
JOIN hosts h ON i.hostid = h.hostid
WHERE i.type IN (1,4,6)
  AND h.hostid=10814
GROUP BY snmp_community,
         snmpv3_securityname,
         snmpv3_securitylevel,
         snmpv3_authpassphrase,
         snmpv3_privpassphrase,
         snmpv3_authprotocol,
         snmpv3_privprotocol,
         snmpv3_contextname\G;

/* estimate how many miliseconds takes the each part in SQL query */
SET profiling = 1;
select * from sessions;
show profiles;
SHOW PROFILE FOR QUERY 1;
explain select * from sessions;
SET profiling = 0;

select clock,objectid,name,COUNT(objectid) c from events where source=3 group by objectid having mod (c,2)=1;

select i.itemid, i.key_ ,i.delay,h.name from items i,hosts h where i.hostid=h.hostid and i.flags=1 and i.delay in ('10m','10s','1m','30s','5m','2m') and h.status=3;

SELECT ... FROM ... WHERE ... 
INTO OUTFILE 'textfile.csv'
FIELDS TERMINATED BY '|'
find / -name textfile.csv

/* Let's check the amount of events your top 20 triggers have associated with them */
select COUNT(*),source,object,objectid from problem group by source,object,objectid order by COUNT(*) desc limit 20;

/* version 3.4. delete all source 3 events from events and problem table. It safe to do with queries, but please make sure that you have a backup.: */
delete from events where source>0;
delete from problem where source>0;





SELECT snmpv3_securityname AS USER,
       CASE snmpv3_securitylevel
           WHEN 0 THEN 'noAuthNoPriv'
           WHEN 1 THEN 'authNoPriv'
           WHEN 2 THEN 'authPriv'
       END AS secLev,
       CASE snmpv3_authprotocol
           WHEN 0 THEN 'MD5'
           WHEN 1 THEN 'SHA'
       END AS authProto,
       snmpv3_authpassphrase AS authPhrase,
       CASE snmpv3_privprotocol
           WHEN 0 THEN 'DES'
           WHEN 1 THEN 'AES'
       END AS privProto,
       snmpv3_privpassphrase AS privPhrase,
       CASE flags
           WHEN 0 THEN 'normal'
           WHEN 1 THEN 'rule'
           WHEN 2 THEN 'prototype'
           WHEN 4 THEN 'discovered'
       END AS flags,
       COUNT(*)
FROM items
WHERE TYPE=6
  AND hostid=10280
GROUP BY 1,
         2,
         3,
         4,
         5,
         6,
         7;



/* show all LLD rulles by execution time and discovery key. show the count of rules */
select delay,key_,COUNT(*) from items where flags = 1 group by delay, key_ order by COUNT(*) desc;
select delay,key_,COUNT(*) from items where flags = 1 group by delay, key_ order by delay,COUNT(*);
select itemid,delay,key_,COUNT(*) from items where flags = 1 group by delay, key_ order by COUNT(*) asc;
select itemid,delay,COUNT(*) from items where flags = 1 group by delay, key_ order by COUNT(*) asc;
select i.itemid, i.key_ ,i.delay,h.name from zabbix.items i,zabbix.hosts h where i.hostid=h.hostid and i.flags=1 and h.status=3 and itemid=<itemid>;










select i.itemid, i.key_ ,i.delay,h.name from zabbix.items i,zabbix.hosts h where i.hostid=h.hostid and i.flags=1 and h.status=3;


/* show all items from specific host */
select * from items where hostid in (select hostid from hosts where hostid in (select hostid from interface) and host like 'Zabbix server');
select name,key_ from items where hostid in (select hostid from hosts where hostid in (select hostid from interface) and host like 'Zabbix server');


/* select all items from specific host group */
select * from items where hostid in (select hostid from hosts_groups where groupid in (select groupid from groups where name like 'Zabbix servers'));

/* Select all items from all hosts */
select * from items where hostid in (select hostid from hosts where hostid in (select hostid from interface) and host like '%');

/* list the biggest log items in the database */
select itemid, hostid, name, lastlogsize from items where type=7 and value_type=2 and lastlogsize>1000000;

/* show possibly bigger log items on 4.4 */
SELECT hosts.host,
       hosts.name,
	   items.itemid,
       items.key_,
       item_rtdata.lastlogsize
FROM items
JOIN item_rtdata ON (item_rtdata.itemid=items.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.type=7
  AND items.value_type=2
ORDER BY item_rtdata.lastlogsize\G




select itemid, hostid, name, lastlogsize from items where type=7 and value_type=2 and lastlogsize>1000000;

select items.itemid, item_rtdata.lastlogsize from items join item_rtdata on (item_rtdata.itemid=items.itemid) where items.type=7 and items.value_type=2;

item_rtdata

/* Show how much items are created/active/disabled per type */
SELECT CASE
           WHEN TYPE=0 THEN 'Zabbix Agent'
           WHEN TYPE=1 THEN 'SNMPv1 agent'
           WHEN TYPE=2 THEN 'Zabbix trapper'
           WHEN TYPE=3 THEN 'simple check'
           WHEN TYPE=4 THEN 'SNMPv2 agent'
           WHEN TYPE=5 THEN 'Zabbix internal'
           WHEN TYPE=6 THEN 'SNMPv3 agent'
           WHEN TYPE=7 THEN 'Zabbix agent (active)'
           WHEN TYPE=8 THEN 'Zabbix aggregate'
           WHEN TYPE=9 THEN 'web item'
           WHEN TYPE=10 THEN 'external check'
           WHEN TYPE=11 THEN 'database monitor'
           WHEN TYPE=12 THEN 'IPMI agent'
           WHEN TYPE=13 THEN 'SSH agent'
           WHEN TYPE=14 THEN 'TELNET agent'
           WHEN TYPE=15 THEN 'calculated'
           WHEN TYPE=16 THEN 'JMX agent'
           WHEN TYPE=17 THEN 'SNMP trap'
           WHEN TYPE=18 THEN 'Dependent item'
           WHEN TYPE=19 THEN 'HTTP agent'
       END AS TYPE,
       CASE
           WHEN status=0 THEN 'ON'
           ELSE 'OFF'
       END AS status,
       COUNT(*)
FROM items
GROUP BY TYPE,
         status
ORDER BY TYPE,
         status DESC;
		 	 
		 
		 

SELECT hosts.host,
       hosts.name,
       history_str.itemid,
       items.key_,
       COUNT(*)
FROM history_str
JOIN items ON (items.itemid=history_str.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock>=1578924000
  AND clock<=1578952800
GROUP BY history_str.itemid
ORDER BY COUNT(*)\G



select hosts.host,items.key_,ts_delete from item_discovery
JOIN items ON (item_discovery.itemid=items.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
where ts_delete<>0;



SELECT hosts.host,
       hosts.name,
       history_text.itemid,
       items.key_,
       COUNT(*)
FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock>=1578924000
  AND clock<=1578952800
GROUP BY history_text.itemid
ORDER BY COUNT(*)\G
		 

SELECT hosts.host,
       hosts.name,
       history_log.itemid,
       items.key_,
       COUNT(*)
FROM history_log
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock>=1578924000
  AND clock<=1578952800
GROUP BY history_log.itemid
ORDER BY COUNT(*)\G
		 
		 
		 

select distinct key_ from items where type = 0;
select distinct key_ from items where type = 3;
select distinct key_ from items where type = 4;

		 
select COUNT(*),type from items  group by type;


		 
SELECT TYPE,
       CASE
           WHEN status=0 THEN 'ON'
           ELSE 'OFF'
       END AS status,
       COUNT(*)
FROM items
GROUP BY TYPE,
         status
ORDER BY TYPE,
         status DESC;


/* show unsupported items, transfer hostid into human readable name */
SELECT h.host AS 'Host name',i.name AS 'ITEM name',i.key_ AS 'KEY' FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1';


select * from items limit 1\G;


/* detect database character set and collate */
SELECT @@character_set_database, @@collation_database\G;
/* check collation. this should report empty string */
SELECT * FROM information_schema.TABLES WHERE table_schema = 'zabbix' AND table_collation != 'utf8_bin';
/* check collation. this should report content */
SELECT * FROM information_schema.TABLES WHERE table_schema = 'zabbix' AND table_collation = 'utf8_bin';



mysql -h 127.0.0.1 -u'zabbix' -p'zabbix' --database=zabbix -B -N -e "SHOW TABLES" | awk '{print "SHOW CREATE TABLE", $1,"\\G" }' | mysql -h 127.0.0.1 -u'zabbix' -p'zabbix' --database=zabbix

/* covert database */
mysql -h 127.0.0.1 -u zabbix -p'zabbix' --database=zabbix -B -N -e "SHOW TABLES" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}' | mysql -h 127.0.0.1 -u zabbix -p'zabbix' --database=zabbix 


mysql -h 127.0.0.1 -u zabbix -p'zabbix' --database=zabbix -B -N -e "SHOW TABLES" | grep -v "history*\|trends*" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}' | mysql -h 127.0.0.1 -u zabbix -p'zabbix' --database=zabbix 



/* list all events based on Zabbix trigger ID */
select * from events where source = 0 and objectid = <triggerid> order by clock DESC LIMIT 10;

/* show mysql variables */
show variables where Variable_name like 'innodb_file_per_table';

/* Show session count opened per each user */
SELECT sessions.userid,
       users.alias,
       COUNT(*)
FROM sessions
INNER JOIN users ON sessions.userid = users.userid
GROUP BY sessions.userid,
         users.alias;



SELECT u.alias,
       r.rightid,
       hgr.name,
       CASE
           WHEN r.permission=0 THEN 'DENY'
           WHEN r.permission=2 THEN 'READ_ONLY'
           WHEN r.permission=3 THEN 'READ_WRITE'
       END AS permission
FROM users u
JOIN users_groups ug ON (u.userid = ug.userid)
JOIN usrgrp ugrp ON (ugrp.usrgrpid = ug.usrgrpid)
JOIN rights r ON (ugrp.usrgrpid = r.groupid)
JOIN hstgrp hgr ON (r.id=hgr.groupid)
WHERE u.alias='first';



/* show unsupported itmes in 4.4. this query does not work on 4.0, 4.2 */
select hosts.name, item_rtdata.state, items.key_
from item_rtdata
JOIN items ON (items.itemid=item_rtdata.itemid)
JOIN hosts ON (items.hostid=hosts.hostid)
JOIN interface ON (interface.hostid=hosts.hostid)
where item_rtdata.state=1\G






/* identify whether there are some entities that are spamming these events */
select object,objectid,COUNT(*) from events where source = 3 and object = 0 group by objectid order by COUNT(*) desc limit 10;
select object,objectid,COUNT(*) from events where source = 3 and object = 4 group by objectid order by COUNT(*) desc limit 10;
select object,objectid,COUNT(*) from events where source = 3 and object = 5 group by objectid order by COUNT(*) desc limit 10;

/* show the event count per source */
select COUNT(*), source from events group by source;
select COUNT(*), source from events group by source;


SELECT COUNT(*),
       source
FROM events
WHERE clock>=1578924000
  AND clock<=1578927600
GROUP BY source;







SELECT COUNT(*),
       source
FROM events
WHERE clock>=1578924000
  AND clock<=1578957600
GROUP BY source;

select COUNT(*), source, object from events group by source;

/* show the the problem which are spamming the problem table the most */
select COUNT(*),source,object,objectid from problem group by source,object,objectid order by COUNT(*) desc limit 20;


/*
0, EVENT_SOURCE_TRIGGERS - Event was generated by a trigger status change
1, EVENT_SOURCE_DISCOVERY - Event was generated by discovery module
2, EVENT_SOURCE_AUTO_REGISTRATION - Event was generated by auto registration module
3, EVENT_SOURCE_INTERNAL - An internal event generated by items, LLD rules or triggers state change
*/

/* check out what actually is content of these records */
select * from events where source=3 limit 1;
 
/* remove events */
delete from events where source=3 limit 10;
delete from events where source=3 limit 100;
delete from events where source=3 limit 1000;

/* long queries */
SELECT HOST, COMMAND, TIME, ID, ROWS_EXAMINED, INFO FROM INFORMATION_SCHEMA.PROCESSLIST WHERE TIME > 60 AND COMMAND!='Sleep' AND HOST!='localhost' ORDER BY TIME DESC;


select COUNT(*),source from events where eventid in (1,2,3) group by source;

select status, COUNT(*) from escalations group by status;

select status, COUNT(*) from alerts where status in ('0','1','3') group by status;


delete from events where source=3 limit 10000;

delete from events where source in (1,2,3) limit 1000000; 


SELECT FROM events WHERE source=0 and object=0 and clock <= UNIX_TIMESTAMP(NOW() - INTERVAL 2 DAY) ORDER BY 'eventid' limit 1000;
DELETE FROM events WHERE source=0 and object=0 and clock <= UNIX_TIMESTAMP(NOW() - INTERVAL 2 DAY) ORDER BY 'eventid' limit 1000;


optimize table triggers;
optimize table functions;
optimize table items;
optimize table hosts_groups;
optimize table rights;


select COUNT(*), userid from sessions group by userid order by count;

/* show all triggers per hostid */

SELECT h.host, 
       t.description, 
       f.triggerid, 
       t.state 
FROM   zabbix.triggers t 
       JOIN zabbix.functions f 
         ON ( f.triggerid = t.triggerid ) 
       JOIN zabbix.items i 
         ON ( i.itemid = f.itemid ) 
       JOIN zabbix.hosts h 
         ON ( i.hostid = h.hostid ) 
WHERE  h.hostid = 10084;


/* LLDs behind proxy. must be execute on proxy database */
select clock,ns,items.delay,items.key_ from proxy_history join items on (proxy_history.itemid=items.itemid) where items.flags=1 order by clock asc limit 10;


/* size of postgres tables */
SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;


/* */
select COUNT(*) from functions f
    right join triggers t
    on f.triggerid=t.triggerid
where f.triggerid is NULL;


/* usage of passive checks, does not work on 4.4 */
SELECT DISTINCT CASE
                    WHEN TYPE=0 THEN 'Zabbix Agent'
                    WHEN TYPE=1 THEN 'SNMPv1 agent'
                    WHEN TYPE=2 THEN 'Zabbix trapper'
                    WHEN TYPE=3 THEN 'simple check'
                    WHEN TYPE=4 THEN 'SNMPv2 agent'
                    WHEN TYPE=5 THEN 'Zabbix internal'
                    WHEN TYPE=6 THEN 'SNMPv3 agent'
                    WHEN TYPE=7 THEN 'Zabbix agent (active)'
                    WHEN TYPE=8 THEN 'Zabbix aggregate'
                    WHEN TYPE=9 THEN 'web item'
                    WHEN TYPE=10 THEN 'external check'
                    WHEN TYPE=11 THEN 'database monitor'
                    WHEN TYPE=12 THEN 'IPMI agent'
                    WHEN TYPE=13 THEN 'SSH agent'
                    WHEN TYPE=14 THEN 'TELNET agent'
                    WHEN TYPE=15 THEN 'calculated'
                    WHEN TYPE=16 THEN 'JMX agent'
                    WHEN TYPE=17 THEN 'SNMP trap'
                    WHEN TYPE=18 THEN 'Dependent item'
                    WHEN TYPE=19 THEN 'HTTP agent'
                END AS TYPE,
                items.delay,
                COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE TYPE NOT IN (2,3,5,7,8,15,17)
  AND items.status=0
  AND items.flags IN (1,4)
  AND items.state=0
  AND hosts.status=0
GROUP BY 1,2;



/* performance killer. select which items takes the most space in history table */
SELECT DISTINCT items.key_,hosts.host, COUNT(*) FROM history 
JOIN items ON (items.itemid=history.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
GROUP BY history.itemid
ORDER BY COUNT(*) DESC;

SELECT DISTINCT items.key_,hosts.host, COUNT(*) FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
GROUP BY history_text.itemid
ORDER BY COUNT(*) DESC
LIMIT 5\G




SELECT 



select i.interfaceid,i.hostid,i.ip,i.bulk,h.name from interface i join hosts h on i.hostid=h.hostid

select h.name,i.bulk from interface i join hosts h on i.hostid=h.hostid where i.type=2 and i.bulk=0;


/* select active events */
SELECT * FROM events JOIN triggers ON events.objectid = triggers.triggerid JOIN functions ON functions.triggerid = triggers.triggerid JOIN items ON items.itemid = functions.itemid JOIN hosts ON items.hostid = hosts.hostid WHERE events.source = 0  AND  LOWER(hosts.host) like 'Zabbix server';

/* show all triggers generated from trigger prototype by pointing out trigger prototype ID */
select t.value,from_unixtime(t.lastchange),t.description from trigger_discovery t1 join triggers t using (triggerid) where t1.parent_triggerid = 150390;

/* show the frequency of discovery rules, detailed */
select key_,delay from items where flags=1 group by key_;

/* most frequent integers */
select itemid,COUNT(*) from history_uint group by itemid order by COUNT(*) DESC LIMIT 10;


/* most frequent float numbers */
select itemid,COUNT(*) from history group by itemid order by COUNT(*) DESC LIMIT 10;

/* see the event titles */
select name from events where source=3 order by clock asc limit 20;


select COUNT(*), source from events group by source;

select name from events where source=3 and name like 'No Such Instance%' order by clock asc limit 1200;
select COUNT(*),name from events where source=3 and name like 'No Such Instance%';
select COUNT(*),name from events where source=3 and name like 'Cannot evaluate expression%';

/* check how many hosts behind the proxy has unknown status */
SELECT name,error,proxy_hostid
FROM hosts
WHERE available=0
  AND proxy_hostid IN (SELECT hostid FROM hosts WHERE HOST='riga');

/* show hosts behind proxies */
SELECT p.host AS proxy_name,
       hosts.host AS host_name
FROM hosts
JOIN hosts p ON hosts.proxy_hostid=p.hostid
WHERE hosts.available = 0
ORDER BY p.host;







/* hosts with errors */
SELECT h.host AS host_name,
       h.error AS host_error,
       h.proxy_hostid AS proxy_id,
       p.host AS proxy_name
FROM hosts h
JOIN hosts p ON h.proxy_hostid=p.hostid
WHERE h.available = 0
AND LENGTH(h.error)>0;


SELECT h.host AS host_name,
       h.error AS host_error,
       h.proxy_hostid AS proxy_id,
       p.host AS proxy_name
FROM hosts h
JOIN hosts p ON h.proxy_hostid=p.hostid
WHERE LENGTH(h.error)>0;



/* show proxies */
SELECT hosts.name
FROM hosts
WHERE hosts.proxy_hostid IN (SELECT hostid FROM hosts);




SELECT hosts.name,hosts.error,hosts.proxy_hostid
FROM hosts
WHERE hosts.available=0
  AND hosts.proxy_hostid IN (SELECT hostid FROM hosts);
  
/* host is monitored by proxy */
SELECT hosts.host FROM hosts WHERE hosts.status IN (5, 6);
  
  


select COUNT(*),available from hosts where proxy_hostid in (select hostid from hosts where host='RPiProxY8b923a') group by available order by 1;
select COUNT(*),available from hosts where proxy_hostid in (select hostid from hosts where host='rpi4riga') group by 2 order by 1;
/* Explanation of availability:
0, HOST_AVAILABLE_UNKNOWN - Unknown availability (grayed out icon)
1, HOST_AVAILABLE_TRUE - The host is available (green icon)
2, HOST_AVAILABLE_FALSE - The host is not available (red icon) */



/* look for last events in events table */
 select * from events order by clock desc limit 10 ;
 
/* which hosts are monitored but have unhealthy state, unavailable */
select name,error from hosts WHERE available=2 AND status IN (0,1);





/* which zabbix agents are unavailable, showing red */
SELECT name,error
FROM hosts
JOIN interface ON (interface.hostid=hosts.hostid)
WHERE hosts.available=2
  AND hosts.status IN (0,1)
  AND interface.type=1;


  
/* hosts which has an agent interface attached */
SELECT COUNT(*)
FROM hosts
JOIN interface ON (interface.hostid=hosts.hostid)
WHERE hosts.available IN (0,1)
  AND hosts.status IN (0)
  AND interface.type=1;
  
  

  
  

/* link togeterhe hosts with hostgroups */
SELECT h.host, t.description, f.triggerid, t.value, t.lastchange, t.state FROM zabbix.triggers t
JOIN zabbix.functions f ON ( f.triggerid = t.triggerid )
JOIN zabbix.items i ON ( i.itemid = f.itemid )
JOIN zabbix.hosts h ON ( i.hostid = h.hostid )
JOIN zabbix.hosts_groups as B ON (h.hostid=B.hostid)
JOIN zabbix.hstgrp as C on (B.groupid=C.groupid)
WHERE h.available=2 ORDER BY t.lastchange DESC;


/* by name */
SELECT h.host, C.name FROM zabbix.hosts h
JOIN zabbix.hosts_groups as B ON (h.hostid=B.hostid)
JOIN zabbix.hstgrp as C on (B.groupid=C.groupid)
WHERE h.host in ('Zabbix server','proxy512');


/* show host groups for zabbix agents having the issue */
SELECT h.host AS 'Host name',
       h.name AS 'Visible name',
       GROUP_CONCAT(C.name SEPARATOR ', ') AS 'Host groups',
       h.error AS 'Error'
FROM zabbix.hosts h
JOIN zabbix.hosts_groups AS B ON (h.hostid=B.hostid)
JOIN zabbix.hstgrp AS C ON (B.groupid=C.groupid)
WHERE h.available = 2
GROUP BY h.host,h.name,h.error;

/* show template names for zabbix agent having the issue */
SELECT h.host AS 'Host name',
       h.name AS 'Visible name',
       GROUP_CONCAT(b.host SEPARATOR ', ') AS 'Templates',
       h.error AS 'Error'
FROM hosts_templates,
     hosts h,
     hosts b,
     interface
WHERE hosts_templates.hostid = h.hostid
  AND hosts_templates.templateid = b.hostid
  AND interface.hostid = h.hostid
  AND h.available = 2
GROUP BY h.host,h.name,h.error;

/* quite a output */
SELECT distinct 
  a.hostid as "Host ID",
  a.host as "Host name",
  a.name as "Visible name",
  GROUP_CONCAT(distinct hosts_templates.templateid) as "Template IDs",
  GROUP_CONCAT(distinct hosts_templates.templateid, " ", b.host) as "Template IDs and names",
  GROUP_CONCAT(distinct interface.ip) as "IP Addresses",
  GROUP_CONCAT(distinct interface.dns) as "DNS Names",
  GROUP_CONCAT(distinct interface.port) as "Ports"
FROM hosts_templates, hosts a, hosts b, interface
where hosts_templates.hostid = a.hostid
and hosts_templates.templateid = b.hostid
and interface.hostid = a.hostid
and a.status = 0
group by a.hostid


/* describe a events table */
SHOW TABLE STATUS FROM `zabbix` LIKE 'events'\G;


show global variables like '%buffer_pool%';
select itemid, COUNT(*) from history_log where clock>=unix_timestamp(NOW() - INTERVAL 2 HOUR) group by itemid order by COUNT(*) DESC LIMIT 10;
select itemid, COUNT(*) from history_text where clock>=unix_timestamp(NOW() - INTERVAL 2 HOUR) group by itemid order by COUNT(*) DESC LIMIT 10;
select itemid, COUNT(*) from history_str where clock>=unix_timestamp(NOW() - INTERVAL 2 HOUR) group by itemid order by COUNT(*) DESC LIMIT 10;



/* list all functions */
select COUNT(*),functionid,parameter from functions group by functionid,parameter order by COUNT(*) DESC;

/* show frequent functions */
select COUNT(*),name,parameter from functions group by parameter order by COUNT(*) DESC;

select name,COUNT(*) from functions group by name order by name;


select @@optimizer_switch\G
# see if 'index_condition_pushdown=off'. if not the set to my.cnf
# optimizer_switch = 'index_condition_pushdown=off'

/* show all items per one host (including item prototypes) */
select key_ from items where hostid ='10564';
/* without prototype items */
select flags,key_ from items where hostid ='10564' and flags<>'2';

/* determine the count of functions (maybe the heaviest hosts) used in trigger expressions */
SELECT COUNT(*),
       i.hostid
FROM triggers t
INNER JOIN functions f ON f.triggerid = t.triggerid
INNER JOIN items i ON f.itemid = i.itemid
GROUP BY i.hostid;


/* nodata function inside templates */
SELECT hosts.host,
       items.key_
FROM triggers
INNER JOIN functions ON functions.triggerid = triggers.triggerid
INNER JOIN items ON functions.itemid = items.itemid
INNER JOIN hosts ON hosts.hostid = items.hostid
WHERE functions.name = 'nodata'
AND hosts.status = 3



SELECT DISTINCT items.key_,
                COUNT(*)
FROM triggers
INNER JOIN functions ON functions.triggerid = triggers.triggerid
INNER JOIN items ON functions.itemid = items.itemid
INNER JOIN hosts ON hosts.hostid = items.hostid
WHERE functions.name = 'nodata'
GROUP BY items.key_;



/* see the biggest records */
SELECT itemid,LENGTH(value) FROM proxy_history ORDER BY LENGTH(value) DESC limit 10;
SELECT itemid,LENGTH(value) FROM history_uint ORDER BY LENGTH(value) DESC limit 10;


/* "[Z3005] query failed: [1062] Duplicate entry" */
delete from ids;

/* if problem related to 'insert into items' */
select key_ from items where hostid=11818 and key_ like "%the-key-in-the-message%";



/* DROP PROCEDURE partition_create; DROP PROCEDURE partition_drop;
DROP PROCEDURE partition_maintenance;DROP PROCEDURE partition_maintenance_all;
DROP PROCEDURE partition_verify; SHOW PROCEDURE STATUS; */


 
