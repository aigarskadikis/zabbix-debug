


/* enable loging to table */
Please do the following sequence:

# sign in database client as root. take a look on current settings
select @@log_output, @@general_log, @@general_log_file\G

# set the global logging to table
SET global log_output = 'table';

# see now the situation has been changed comparing to original
select @@log_output, @@general_log, @@general_log_file\G

# take a note that log table currently is empty
select count(*) from mysql.general_log;
 
# enable the logging
SET global general_log = 1;
# THIS WILL START TO WRITE MASSIVE CONTENT!

# see how the number is increasing. execute few times:
select count(*) from mysql.general_log;
# I hope its less than 10000 records per second!

# wait 10 minutes

# stop logging
SET global general_log = 0;

# make sure number remains static
select count(*) from mysql.general_log;

# set back the log settings to file
SET global log_output = 'file';

# this must be the same as in the beginning
select @@log_output, @@general_log, @@general_log_file\G

# ======not required to execute - to observe records=======
describe mysql.general_log;
show create table mysql.general_log\G

# observe records
select * from mysql.general_log limit 10\G


/* summarize a specific discovery rule - unsuppoerted/supported ratio */
SELECT i.state,h.host AS 'Host name',i.name AS 'ITEM name',i.key_ AS 'KEY' FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.key_='vfs.fs.discovery[{HOST.NAME}]' and h.status=0 and i.state=0 limit 10;

/* on 3.4 */
select description from triggers WHERE triggerid IN (select objectid from events where eventid=15);
      

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

/* most unsupported items per host */
SELECT DISTINCT h.host AS 'Host name',count(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' GROUP BY h.host ORDER BY 2;

 SELECT DISTINCT h.host AS 'Host name',count(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' GROUP BY h.host ORDER BY 2 desc limit 15;

/* only enabled hosts */
SELECT DISTINCT h.host AS 'Host name',count(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' and h.status=0 GROUP BY h.host ORDER BY 2 desc limit 15; 
SELECT DISTINCT h.host AS 'Host name',count(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' and h.status=0 GROUP BY h.host ORDER BY 2 desc limit 15; 
 

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




/* StartDBSyncers=4 by default can feed 4k NVPS. Don't increase it. If history syncer is busy there may be to much nodata or time based triggers functions */


select e.eventid from events e INNER JOIN triggers t ON ( t.triggerid = e.objectid ) where t.triggerid = NULL;


/* most frequent metrics */
select itemid,count(*) from history_uint where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by count(*) desc limit 10;
select itemid,count(*) from history where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by count(*) desc limit 10;
select itemid,count(*) from history_str where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by count(*) desc limit 10;
select itemid,count(*) from history_log where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by count(*) desc limit 10;
select itemid,count(*) from history_text where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by count(*) desc limit 10;


/* otimize sessions table in case of lazy bastard - cannot fine tune the API script */
select count(*) from sessions;
delete from sessions where (lastaccess < UNIX_TIMESTAMP(NOW()) - 3600); optimize table sessions;
SELECT count(u.alias),
       u.alias
FROM users u
INNER JOIN sessions s ON (u.userid = s.userid)
WHERE (s.status=0)
  AND (s.lastaccess > UNIX_TIMESTAMP(NOW()) - 300)
GROUP BY u.alias;


/* which users belongs to groupid */
select u.alias from users_groups ug join users u where ug.userid=u.userid and ug.usrgrpid=7;


/* filter active triggers by severity on 3.4 with events table (a database killer) */ 
SELECT count(t.priority) AS COUNT,
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
ORDER BY count(t.priority);

/* filter active triggers by severity on 3.4 with events table (NOT a database killer) */ 
select count(t.priority),CASE
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
ORDER BY count(t.priority);


/* problems by severity */
select count(*) from zabbix.triggers where priority=5 and value=1;
select count(*) from zabbix.triggers where priority=4 and value=1;
select count(*) from zabbix.triggers where priority=3 and value=1;
select count(*) from zabbix.triggers where priority=2 and value=1;
select count(*) from zabbix.triggers where priority=1 and value=1;
select count(*) from zabbix.triggers where priority=0 and value=1;


/* max and average value lenght */
select max(LENGTH (value)), avg(LENGTH (value)) from history_text where clock> UNIX_TIMESTAMP (now() - INTERVAL 30 MINUTE);




/* show which user is active  */
SELECT u.alias
FROM users u
INNER JOIN users_groups g ON ( u.userid = g.userid )
INNER JOIN sessions s ON ( u.userid = s.userid )
WHERE (s.status = 0);

/* search for metrics in history_text table where curently those are not stored as text */
SELECT COUNT(itemid) FROM history_text WHERE itemid IN (SELECT itemid FROM items where value_type<>4);

SELECT u.alias
FROM users u
INNER JOIN users_groups g ON ( u.userid = g.userid )
INNER JOIN sessions s ON ( u.userid = s.userid )
WHERE (s.status = 0)
and (s.lastaccess > NOW() - 3600);

/* active users users */
SELECT count(u.alias),
       u.alias
FROM users u
INNER JOIN sessions s ON (u.userid = s.userid)
WHERE (s.status=0)
GROUP BY u.alias;

/* active users not including guests */
SELECT count(u.alias),u.alias FROM users u INNER JOIN sessions s ON (u.userid = s.userid) WHERE (s.status=0)   AND (u.alias<>'guest') GROUP BY u.alias;


/* users online in last 5 minutes */
SELECT count(u.alias),
       u.alias
FROM users u
INNER JOIN sessions s ON (u.userid = s.userid)
WHERE (s.status=0)
  AND (s.lastaccess > UNIX_TIMESTAMP(NOW()) - 300)
GROUP BY u.alias;

/* ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 's INNER JOIN users u ON (u.userid = s.userid) where (u.alias='guest')' at line 1 */





DELETE s FROM sessions s INNER JOIN users u ON (u.userid = s.userid) where u.alias='guest'; OPTIMIZE table sessions;



/* show which user is onlyne by groupid */
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
select DISTINCT h.name, i.key_, t.error from events e  inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 limit 80\G


select DISTINCT h.name, i.key_, t.error from events e  inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like 'Cannot obtain file information: [2] No such file or directory';


select DISTINCT h.name, i.key_, t.error from events e  inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like '%Agent is unavailable.%' and e.clock>UNIX_TIMESTAMP(NOW())-3600;


/* timeout */
select count(t.error), key_,t.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like 'Timeout while executing a shell script.' group by key_ order by count(t.error) desc;


select count(t.error),h.name, key_,t.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like 'Timeout while executing a shell script.' and e.clock>UNIX_TIMESTAMP(NOW())-3600 group by key_ order by count(t.error) desc;


/* trigger error statisticks */
select count(t.error), t.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 group by t.error;


/* latest monitoring problems */
select count(t.error), t.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and e.clock>UNIX_TIMESTAMP(NOW())-3600 group by t.error;


/* discoveries les than 10 minutes */
select key_,delay from items where flags=1 and delay not in (600,3600,0,'10m') and delay not like '%h' and delay not like '%d' order by delay;

/* show most frequently used functions */
select name,parameter,count(*) from functions group by 1,2 order by 3 desc limit 50;
/* on 2.4 */
select function,parameter,count(*) from functions group by 1,2 order by 3 desc limit 50;




/* show hosts having a dns name installed */
SELECT h.host,h.name,ii.type,ii.useip,ii.ip,ii.dns from hosts h join interface ii on h.hostid=ii.hostid WHERE LENGTH(ii.dns)>0 AND ii.useip=1;



/* top messages which were initiated to notify someone (not works on 3.0) */
select count(*),t.description from alerts a inner join events e on a.p_eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by count(*) desc limit 10;
select count(*),t.description from alerts a inner join events e on a.p_eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by count(*) desc\G

/* on 3.0 */
select count(*),t.description from alerts a inner join events e on a.eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by count(*) desc limit 10;



/* identify possibly old records which belongs to nonexisting trigger */
select objectid,name from events where source=0 and objectid not in (select triggerid from triggers)\G

select count(*) from events where source=0 and objectid not in (select triggerid from triggers);
select objectid,name from events where source=0 and objectid not in (select triggerid from triggers) order by clock\G


/* items having probles receiving data */
select count(*),objectid as itemid,name from events where source = 3 AND object = 4 and LENGTH(name)>0 group by name order by count(*) desc limit 10\G


select h.host from interface ii,hosts h WHERE h.hostid=ii.hostid AND ii.useip=1 AND LENGTH(ii.dns)>0;

UPDATE interface ii,hosts h SET ii.useip=0 WHERE h.hostid=ii.hostid AND ii.useip=1 AND LENGTH(ii.dns)>0 and h.host='bcm2711';

/* see unsent alerts */
select count(*), status from alerts group by status;


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
select snmp_community, snmpv3_securityname, snmpv3_securitylevel, snmpv3_authpassphrase, snmpv3_privpassphrase, snmpv3_authprotocol , snmpv3_privprotocol , snmpv3_contextname, count(*) from items i join hosts h on i.hostid = h.hostid where i.type in (1,4,6) group by snmp_community, snmpv3_securityname, snmpv3_securitylevel, snmpv3_authpassphrase, snmpv3_privpassphrase, snmpv3_authprotocol , snmpv3_privprotocol , snmpv3_contextname\G;
/* filter by host */
select snmp_community, snmpv3_securityname, snmpv3_securitylevel, snmpv3_authpassphrase, snmpv3_privpassphrase, snmpv3_authprotocol , snmpv3_privprotocol , snmpv3_contextname, count(*) from items i join hosts h on i.hostid = h.hostid where i.type in (1,4,6) and h.hostid=10814 group by snmp_community, snmpv3_securityname, snmpv3_securitylevel, snmpv3_authpassphrase, snmpv3_privpassphrase, snmpv3_authprotocol , snmpv3_privprotocol , snmpv3_contextname\G;

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
select delay,key_,count(*) from items where flags = 1 group by delay, key_ order by count(*) desc;
select delay,key_,count(*) from items where flags = 1 group by delay, key_ order by delay,count(*);
select itemid,delay,key_,count(*) from items where flags = 1 group by delay, key_ order by count(*) asc;
select itemid,delay,count(*) from items where flags = 1 group by delay, key_ order by count(*) asc;
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
       count(*)
FROM items
GROUP BY TYPE,
         status
ORDER BY TYPE,
         status DESC;
		 

select distinct key_ from items where type = 0;
select distinct key_ from items where type = 3;
select distinct key_ from items where type = 4;

		 
select count(*),type from items  group by type;


		 
SELECT TYPE,
       CASE
           WHEN status=0 THEN 'ON'
           ELSE 'OFF'
       END AS status,
       count(*)
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

delete from events where source in (1,2,3) limit 1000000; 


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

/* check how many hosts behind the proxy has unknown status */
select name,error,proxy_hostid from hosts where available=0 and proxy_hostid in (select hostid from hosts where host='rpi4riga');


select count(*),available from hosts where proxy_hostid in (select hostid from hosts where host='RPiProxY8b923a') group by available order by 1;
select count(*),available from hosts where proxy_hostid in (select hostid from hosts where host='rpi4riga') group by 2 order by 1;
/* Explanation of availability:
0, HOST_AVAILABLE_UNKNOWN - Unknown availability (grayed out icon)
1, HOST_AVAILABLE_TRUE - The host is available (green icon)
2, HOST_AVAILABLE_FALSE - The host is not available (red icon) */



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

/* if problem related to 'insert into items' */
select key_ from items where hostid=11818 and key_ like "%the-key-in-the-message%";



/* DROP PROCEDURE partition_create; DROP PROCEDURE partition_drop;
DROP PROCEDURE partition_maintenance;DROP PROCEDURE partition_maintenance_all;
DROP PROCEDURE partition_verify; SHOW PROCEDURE STATUS; */


 