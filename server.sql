

/* StartDBSyncers=4 by default can feed 4k NVPS. Don't increase it */

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

/* discoveries les than 10 minutes */
select key_,delay from items where flags=1 and delay not in (600,3600,0,'10m') and delay not like '%h' and delay not like '%d' order by delay;

/* show most frequently used functions */
select name,parameter,count(*) from functions group by 1,2 order by 3 desc limit 50;


/* show hosts having a dns name installed */



SELECT h.host,h.name,ii.type,ii.useip,ii.ip,ii.dns from hosts h join interface ii on h.hostid=ii.hostid WHERE LENGTH(ii.dns)>0 AND ii.useip=1;



/* top messages which were initiated to notify someone */
select count(*),t.description from alerts a inner join events e on a.p_eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by count(*) desc limit 10;
select count(*),t.description from alerts a inner join events e on a.p_eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by count(*) desc\G




select h.host from interface ii,hosts h WHERE h.hostid=ii.hostid AND ii.useip=1 AND LENGTH(ii.dns)>0;

UPDATE interface ii,hosts h SET ii.useip=0 WHERE h.hostid=ii.hostid AND ii.useip=1 AND LENGTH(ii.dns)>0 and h.host='bcm2711';




/* Cannot insert new item in the host configuration */
delete from ids where table_name='items';
delete from ids;

show processlist;
/* if query is all in caps this means it comes from frontend */

SELECT @@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G

SELECT @@innodb_file_per_table,@@datadir,@@innodb_buffer_pool_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G


SELECT @@hostname,@@version,@@datadir,@@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G;

/* if xtrabackup is used https://mariadb.com/kb/en/library/percona-xtrabackup-overview/ */ 
SELECT @@hostname,@@version,@@datadir,@@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_page_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G;

select @@version;

/* see the last failed messages */
select clock,error from alerts where status=2 order by clock desc limit 10;


/* command resets the trigger status. */
/* You can update trigger status using following query, replace "(list of trigger ids)" with actual trigger ids values with "," delimiter: */
update triggers set value = 0, lastchange = UNIX_TIMESTAMP(NOW()) WHERE triggerid in (list of trigger ids);


/* show the variation between SNMP community names being used in environment */
select snmp_community, snmpv3_securityname, snmpv3_securitylevel, snmpv3_authpassphrase, snmpv3_privpassphrase, snmpv3_authprotocol , snmpv3_privprotocol , snmpv3_contextname, count(*) from items i join hosts h on i.hostid = h.hostid where i.type in (1,4,6) group by snmp_community, snmpv3_securityname, snmpv3_securitylevel, snmpv3_authpassphrase, snmpv3_privpassphrase, snmpv3_authprotocol , snmpv3_privprotocol , snmpv3_contextname\G;

/* estimate how many miliseconds takes the each part in SQL query */
SET profiling = 1;
select * from sessions;
show profiles;
SHOW PROFILE FOR QUERY 1;
explain select * from sessions;
SET profiling = 0;

select clock,objectid,name,count(objectid) c from events where source=3 group by objectid having mod (c,2)=1;

select i.itemid, i.key_ ,i.delay,h.name from items i,hosts h where i.hostid=h.hostid and i.flags=1 and i.delay in ('10m','10s','1m','30s','5m','2m') and h.status=3;

SELECT ... FROM ... WHERE ... 
INTO OUTFILE 'textfile.csv'
FIELDS TERMINATED BY '|'
find / -name textfile.csv

/* Let's check the amount of events your top 20 triggers have associated with them */
select count(*),source,object,objectid from problem group by source,object,objectid order by count(*) desc limit 20;

/* version 3.4. delete all source 3 events from events and problem table. It safe to do with queries, but please make sure that you have a backup.: */
delete from events where source>0;
delete from problem where source>0;




/* show all LLD rulles by execution time and discovery key. show the count of rules */
select delay,key_,count(*) from items where flags = 1 group by delay, key_ order by delay,count(*);
select delay,key_,count(*) from items where flags = 1 group by delay, key_ order by count(*) desc;


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

/* Show how much items are created/active/disabled per type */
select case when type=0 then 'Zabbix Agent' when type=1 then 'SNMPv1 agent' when type=2 then 'Zabbix trapper' when type=3 then 'simple check' when type=4 then 'SNMPv2 agent' when type=5 then 'Zabbix internal' when type=6 then 'SNMPv3 agent' when type=7 then 'Zabbix agent (active)' when type=8 then 'Zabbix aggregate' when type=9 then 'web item' when type=10 then 'external check' when type=11 then 'database monitor' when type=12 then 'IPMI agent' when type=13 then 'SSH agent' when type=14 then 'TELNET agent' when type=15 then 'calculated' when type=16 then 'JMX agent' when type=17 then 'SNMP trap' when type=18 then 'Dependent item' end as type,case when status=0 then 'ON' else 'OFF' end as status,count(*) from items group by type,status order by type, status desc;

/* show unsupported items, transfer hostid into human readable name */
SELECT h.host AS 'Host name',i.name AS 'ITEM name',i.key_ AS 'KEY' FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1';


select * from items limit 1\G;


/* detect database character set and collate */
SELECT @@character_set_database, @@collation_database\G;
/* check collation. this should report empty string */
SELECT * FROM information_schema.TABLES WHERE table_schema = 'zabbix' AND table_collation != 'utf8_bin';
/* check collation. this should report content */
SELECT * FROM information_schema.TABLES WHERE table_schema = 'zabbix' AND table_collation = 'utf8_bin';

/* list all events based on Zabbix trigger ID */
select * from events where source = 0 and objectid = <triggerid> order by clock DESC LIMIT 10;

/* show mysql variables */
show variables where Variable_name like 'innodb_file_per_table';

/* Show session count opened per each user */
SELECT sessions.userid,users.alias,count(*) FROM sessions INNER JOIN users ON sessions.userid = users.userid GROUP BY sessions.userid;

/* identify whether there are some entities that are spamming these events */
select object,objectid,count(*) from events where source = 3 and object = 0 group by objectid order by count(*) desc limit 10;
select object,objectid,count(*) from events where source = 3 and object = 4 group by objectid order by count(*) desc limit 10;
select object,objectid,count(*) from events where source = 3 and object = 5 group by objectid order by count(*) desc limit 10;

/* show the event count per source */
select count(*), source from events group by source;

select count(*), source, object from events group by source;

/* show the the problem which are spamming the problem table the most */
select count(*),source,object,objectid from problem group by source,object,objectid order by count(*) desc limit 20;


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


select count(*),source from events where eventid in (1,2,3) group by source;

select status, count(*) from escalations group by status;

select status, count(*) from alerts where status in ('0','1','3') group by status;


delete from events where source=3 limit 10000;
SELECT FROM events WHERE source=0 and object=0 and clock <= UNIX_TIMESTAMP(NOW() - INTERVAL 2 DAY) ORDER BY 'eventid' limit 1000;
DELETE FROM events WHERE source=0 and object=0 and clock <= UNIX_TIMESTAMP(NOW() - INTERVAL 2 DAY) ORDER BY 'eventid' limit 1000;


optimize table triggers;
optimize table functions;
optimize table items;
optimize table hosts_groups;
optimize table rights;


select count(*), userid from sessions group by userid order by count;

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
select count(*) from functions f
    right join triggers t
    on f.triggerid=t.triggerid
where f.triggerid is NULL;


select i.interfaceid,i.hostid,i.ip,i.bulk,h.name from interface i join hosts h on i.hostid=h.hostid

select h.name,i.bulk from interface i join hosts h on i.hostid=h.hostid where i.type=2 and i.bulk=0;


/* select active events */
SELECT * FROM events JOIN triggers ON events.objectid = triggers.triggerid JOIN functions ON functions.triggerid = triggers.triggerid JOIN items ON items.itemid = functions.itemid JOIN hosts ON items.hostid = hosts.hostid WHERE events.source = 0  AND  LOWER(hosts.host) like 'Zabbix server';

/* show all triggers generated from trigger prototype by pointing out trigger prototype ID */
select t.value,from_unixtime(t.lastchange),t.description from trigger_discovery t1 join triggers t using (triggerid) where t1.parent_triggerid = 150390;

/* show the frequency of discovery rules, detailed */
select key_,delay from items where flags=1 group by key_;

/* most frequent integers */
select itemid,count(*) from history_uint group by itemid order by count(*) DESC LIMIT 10;


/* most frequent float numbers */
select itemid,count(*) from history group by itemid order by count(*) DESC LIMIT 10;

/* see the event titles */
select name from events where source=3 order by clock asc limit 20;


select count(*), source from events group by source;

select name from events where source=3 and name like 'No Such Instance%' order by clock asc limit 1200;
select count(*),name from events where source=3 and name like 'No Such Instance%';
select count(*),name from events where source=3 and name like 'Cannot evaluate expression%';




/* look for last events in events table */
 select * from events order by clock desc limit 10 ;
 
/* which zabbix agent have unhealthy state */
select name,error from hosts where available=2;

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
select itemid, count(*) from history_log where clock>=unix_timestamp(NOW() - INTERVAL 2 HOUR) group by itemid order by count(*) DESC LIMIT 10;
select itemid, count(*) from history_text where clock>=unix_timestamp(NOW() - INTERVAL 2 HOUR) group by itemid order by count(*) DESC LIMIT 10;
select itemid, count(*) from history_str where clock>=unix_timestamp(NOW() - INTERVAL 2 HOUR) group by itemid order by count(*) DESC LIMIT 10;


select distinct key_ from items where type = 5;

/* list all functions */
select count(*),functionid,parameter from functions group by functionid,parameter order by count(*) DESC;

/* show frequent functions */
select count(*),name,parameter from functions group by parameter order by count(*) DESC;


select @@optimizer_switch\G
# see if 'index_condition_pushdown=off'. if not the set to my.cnf
# optimizer_switch = 'index_condition_pushdown=off'

/* show all items per one host (including item prototypes) */
select key_ from items where hostid ='10564';
/* without prototype items */
select flags,key_ from items where hostid ='10564' and flags<>'2';

/* determine the count of functions (maybe the heaviest hosts) used in trigger expressions */
select count(*),i.hostid from triggers t inner join functions f on f.triggerid = t.triggerid inner join items i on f.itemid = i.itemid where i.hostid in (10543,'10536','10537','10540','10554','10555','10558','10559','10563','10564','10565','10569','10571','10573','10832') group by i.hostid;


/* see the biggest records */
SELECT itemid,LENGTH(value) FROM proxy_history ORDER BY LENGTH(value) DESC limit 10;
SELECT itemid,LENGTH(value) FROM history_uint ORDER BY LENGTH(value) DESC limit 10;


/* "[Z3005] query failed: [1062] Duplicate entry" */
delete from ids;

 
 