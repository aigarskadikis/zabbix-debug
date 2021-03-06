

--biggest metrics
SELECT itemid,SUM(LENGTH(value)) FROM history_text WHERE clock > EXTRACT(epoch FROM NOW()-INTERVAL '5 MINUTE') GROUP BY itemid ORDER BY SUM(LENGTH(value)) DESC LIMIT 5;
SELECT itemid,SUM(LENGTH(value)) FROM history_str WHERE clock > EXTRACT(epoch FROM NOW()-INTERVAL '5 MINUTE') GROUP BY itemid ORDER BY SUM(LENGTH(value)) DESC LIMIT 5;
SELECT itemid,SUM(LENGTH(value)) FROM history_log WHERE clock > EXTRACT(epoch FROM NOW()-INTERVAL '5 MINUTE') GROUP BY itemid ORDER BY SUM(LENGTH(value)) DESC LIMIT 5;



--copy host names, host groups, IPs to CSV. Zabbix 5.0. It works only as a one line:
\copy (SELECT hosts.host AS host,hstgrp.name AS host_group,interface.ip AS IP FROM hosts JOIN hosts_groups ON (hosts_groups.hostid=hosts.hostid) JOIN hstgrp ON (hstgrp.groupid=hosts_groups.groupid) JOIN interface ON (interface.hostid=hosts.hostid) WHERE hosts.status IN (0,1))  TO '/tmp/hosts.hg.ips.csv' WITH CSV




--delete from events in postgres
DELETE FROM events WHERE source > 0 AND clock IN (SELECT clock FROM events WHERE source > 0 LIMIT 1 OFFSET 0);

--configuration backup

pg_dump --host=pg \
--format=custom \
--blobs \
--clean \
--verbose \
--exclude-table-data=history* \
--exclude-table-data=trends* \
--exclude-table-data=events \
--exclude-table-data=acknowledges \
--exclude-table-data=alerts \
--exclude-table-data=auditlog \
--exclude-table-data=auditlog_details \
--exclude-table-data=profiles \
--exclude-table-data=service_alarms \
--exclude-table-data=sessions \
--exclude-table-data=problem \
--exclude-table-data=event_recovery \
z44 > z44.sql


--Backup postgres, ignore hyper tables, hypertables

pg_dump \
--dbname=z44 \
--file=zabbix44.dump \
--format=custom \
--blobs \
--verbose \
--exclude-schema=_timescaledb_internal \
--exclude-schema=_timescaledb_cache \
--exclude-schema=_timescaledb_catalog \
--exclude-schema=_timescaledb_config \
--exclude-table-data '*.history*' \
--exclude-table-data '*.trends*'







--backup one month.
time psql z50 -c "COPY (
SELECT * FROM trends_uint
WHERE clock >= EXTRACT(EPOCH FROM (TIMESTAMP '2021-01-01 00:00:00'))
AND clock < EXTRACT(EPOCH FROM (TIMESTAMP '2021-02-01 00:00:00'))
) TO STDOUT;" | gzip --best > trends_uint.202101.raw.gz

--install paralel gzip. this will use all CPU cores for compression
--yum install pigz
time psql z50 -c "COPY (
SELECT * FROM trends_uint
WHERE clock >= EXTRACT(EPOCH FROM (TIMESTAMP '2021-01-01 00:00:00'))
AND clock < EXTRACT(EPOCH FROM (TIMESTAMP '2021-02-01 00:00:00'))
) TO STDOUT;" | pigz --best > trends_uint.202101.raw.gz

--better compression. sacrifice time
time psql z50 -c "COPY (
SELECT * FROM trends_uint
WHERE clock >= EXTRACT(EPOCH FROM (TIMESTAMP '2021-01-01 00:00:00'))
AND clock < EXTRACT(EPOCH FROM (TIMESTAMP '2021-02-01 00:00:00'))
) TO STDOUT;" | xz > trends_uint.202101.raw.xz

--test inserting create test table
psql z50 -c "
CREATE TABLE trends_uint_test (LIKE trends_uint INCLUDING ALL);
"

time zcat trends_uint.202101.raw.gz | psql -c "COPY trends_uint_test FROM STDIN;" z50

--drop and recreate table
psql z50 -c "
DROP TABLE trends_uint_test; CREATE TABLE trends_uint_test (LIKE trends_uint INCLUDING ALL);
"

--copy back
time xzcat trends_uint.202101.raw.xz | psql -c "COPY trends_uint_test FROM STDIN;" z50

psql z50 -c "
DROP TABLE trends_uint_test;
"

--it's important to test with a backend online as we will insert data in background in a similar way.




pg_dump \
--dbname=z50 \
--format=plain \
--blobs \
--verbose \
--data-only \
--table=history_uint \
--file=z50.history_uint.sql

ls -lh z50.history_uint.sql



pg_dump \
--dbname=z50 \
--format=plain \
--blobs \
--verbose \
--data-only \
--table='_timescaledb_internal._hyper_9_783_chunk' \
--file=z50.history_uint.sql



SELECT ho.hostid, ho.name, COUNT(*) AS records, 
(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables 
WHERE TABLE_NAME = 'history_text' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS "Total size average (Mb)", 
sum(length(history_text.value))/1024/1024 + sum(length(history_text.clock))/1024/1024 + sum(length(history_text.ns))/1024/1024
+ sum(length(history_text.itemid))/1024/1024 AS "history_text Column Size (Mb)"
FROM history_text
LEFT OUTER JOIN items i on history_text.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1)
AND clock > EXTRACT(epoch FROM NOW()-INTERVAL '30 MINUTE')
AND clock < EXTRACT(epoch FROM NOW())
GROUP BY ho.hostid
ORDER BY 4 DESC
LIMIT 5;



--best query ever. most consuming text metrics
SELECT hosts.host,history_text.itemid,items.key_,
COUNT(history_text.itemid) AS "count", AVG(LENGTH(history_text.value))::NUMERIC(10,2) AS "avg size",
(COUNT(history_text.itemid) * AVG(LENGTH(history_text.value)))::NUMERIC(10,2) AS "Count x AVG"
FROM history_text 
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > EXTRACT(epoch FROM NOW()-INTERVAL '96 HOUR')
GROUP BY hosts.host,history_text.itemid,items.key_
ORDER BY 6 DESC
LIMIT 5
\gx


--best query ever. analyze history_log
SELECT hosts.host,history_log.itemid,items.key_,
COUNT(history_log.itemid) AS "count", AVG(LENGTH(history_log.value))::NUMERIC(10,2) AS "avg size",
(COUNT(history_log.itemid) * AVG(LENGTH(history_log.value)))::NUMERIC(10,2) AS "Count x AVG"
FROM history_log 
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > EXTRACT(epoch FROM NOW()-INTERVAL '30 MINUTE')
GROUP BY hosts.host,history_log.itemid,items.key_
ORDER BY 6 DESC
LIMIT 5
\gx


SELECT schemaname, relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_all_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC
LIMIT 10
\gx




--active query
SELECT
pid,
now() - pg_stat_activity.query_start AS duration,
query,
state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '20 minutes';


--biggest metrics on postgres
SELECT hosts.host, items.itemid, items.key_,
AVG(LENGTH(history_text.value))::NUMERIC(10,2),
COUNT(history_text.itemid) FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE history_text.clock >= extract(epoch from now() - interval '24 hour')
GROUP BY 1,2
HAVING COUNT(history_text.itemid) > 0
ORDER BY AVG(LENGTH(history_text.value))::NUMERIC(10,2) DESC
LIMIT 10
\gx



EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 DAY'))

--simulate latast data page per history_uint;
SELECT h2.itemid,h2.clock,h2.value FROM history_uint h2 
JOIN (
SELECT h.itemid,MAX(h.clock) AS clock
FROM history_uint h
JOIN items i ON i.itemid = h.itemid
WHERE i.hostid=16963
AND h.clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '48 HOUR'))
GROUP BY h.itemid
) result1
ON result1.itemid = h2.itemid
AND h2.clock = result1.clock
ORDER BY h2.itemid;


SELECT h2.itemid,h2.clock,h2.value FROM history_uint h2 
JOIN (
SELECT h.itemid,MAX(h.clock) AS clock
FROM history_uint h
JOIN items i ON i.itemid = h.itemid
WHERE i.hostid=16963
AND h.clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '10 MINUTE'))
GROUP BY h.itemid
) result1
ON result1.itemid = h2.itemid
AND h2.clock = result1.clock
ORDER BY h2.itemid;


http://z50.catonrug.net:150/hosts.php?form=update&hostid=16963


--report events which comes from discovered triggers only
SELECT COUNT(DISTINCT events.eventid) AS count,trigger_template.description, hosts.host AS template FROM events
  LEFT JOIN trigger_discovery on events.objectid=trigger_discovery.triggerid
  LEFT JOIN triggers on trigger_discovery.parent_triggerid=triggers.triggerid
  LEFT JOIN triggers trigger_template on (triggers.templateid=trigger_template.triggerid)
  LEFT JOIN functions ON (functions.triggerid=trigger_template.triggerid)
  LEFT JOIN items ON (items.itemid=functions.itemid)
  LEFT JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
AND events.object=0
AND events.value=1
GROUP BY trigger_template.description,hosts.host
ORDER BY COUNT(DISTINCT events.eventid) ASC
\G


SELECT events.eventid,trigger_template.description, hosts.host AS template FROM events
  LEFT JOIN trigger_discovery on events.objectid=trigger_discovery.triggerid
  LEFT JOIN triggers on trigger_discovery.parent_triggerid=triggers.triggerid
  LEFT JOIN triggers trigger_template on (triggers.templateid=trigger_template.triggerid)
  LEFT JOIN functions ON (functions.triggerid=trigger_template.triggerid)
  LEFT JOIN items ON (items.itemid=functions.itemid)
  LEFT JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
AND events.object=0
AND events.value=1
AND events.clock > UNIX_TIMESTAMP (NOW() - INTERVAL 4 HOUR)
\G




--report events which comes only from raw templated triggers
SELECT COUNT(DISTINCT events.eventid) AS count,trigger_template.description, hosts.host AS template FROM events
  JOIN triggers ON (triggers.triggerid=events.objectid)
  JOIN triggers trigger_template on (triggers.templateid=trigger_template.triggerid)
  JOIN functions ON (functions.triggerid=trigger_template.triggerid)
  JOIN items ON (items.itemid=functions.itemid)
  JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
AND events.object=0
GROUP BY trigger_template.description,hosts.host
ORDER BY COUNT(DISTINCT events.eventid) ASC
\G





--
SELECT COUNT(DISTINCT events.eventid),trigger_template.description, hosts.host FROM events

    JOIN triggers ON (triggers.triggerid=events.objectid)
    JOIN triggers trigger_template on (triggers.templateid=trigger_template.triggerid)
    JOIN functions ON (functions.triggerid=trigger_template.triggerid)
    JOIN items ON (items.itemid=functions.itemid)
    JOIN hosts ON (hosts.hostid=items.hostid)

WHERE events.source=0
AND events.object=0

GROUP BY trigger_template.description
ORDER BY COUNT(DISTINCT events.eventid) ASC;



--show one table size in postgres
SELECT pg_size_pretty( pg_total_relation_size('events') );

--postgre engine settings, default values
\o /tmp/postgres.settings.current.vs.stock.txt
SELECT name, setting, boot_val, reset_val, unit FROM pg_settings ORDER BY name;
\o

--search for big log entries
SELECT hosts.host,items.key_,LENGTH(history_log.value)
FROM history_log 
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 DAY'))
AND LENGTH(history_log.value)>500;

--search for big text entries
SELECT hosts.host,items.key_,LENGTH(history_text.value)
FROM history_text 
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 DAY'))
AND LENGTH(history_text.value)>6000;


SELECT hosts.name AS host, items.name AS item
FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(history_text.value) > 6000
AND history_text.clock > UNIX_TIMESTAMP (NOW() - INTERVAL 30 MINUTE)
\G



SELECT hosts.host,items.key_,LENGTH(history_str.value)
FROM history_str 
JOIN items ON (items.itemid=history_str.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 DAY'))
AND LENGTH(history_str.value)>5;



--with functions, host groups, hosts, items, interfaces
SELECT
hosts.host,
interface.dns,
CASE
WHEN interface.type=0 THEN 'Unknown'
WHEN interface.type=1 THEN 'Agent'
WHEN interface.type=2 THEN 'SNMP'
WHEN interface.type=3 THEN 'IPMI'
WHEN interface.type=4 THEN 'JMX'
END AS type,
CASE
WHEN hosts.available=0 THEN 'Unknown'
WHEN hosts.available=1 THEN 'Available'
WHEN hosts.available=2 THEN 'Not available'
END AS available,
ARRAY_TO_STRING(array_agg(DISTINCT hstgrp.name), ', ') AS "host groups",
host_inventory.os_full,host_inventory.os_short,host_inventory.contact,
hosts.error,
ARRAY_TO_STRING(array_agg(DISTINCT applications.name), ', ') AS "applications",
items.name,items.error,
functions.functionid,
triggers.expression
FROM items
LEFT JOIN hosts ON (hosts.hostid=items.hostid)
RIGHT JOIN interface ON (hosts.hostid=interface.hostid)
LEFT JOIN hosts_groups ON (hosts_groups.hostid=hosts.hostid)
LEFT JOIN items_applications ON (items.itemid=items_applications.itemid)
LEFT JOIN applications ON (items_applications.applicationid=applications.applicationid)
LEFT JOIN hstgrp ON (hstgrp.groupid=hosts_groups.groupid)
LEFT JOIN host_inventory ON (host_inventory.hostid=hosts.hostid)
LEFT JOIN functions ON (functions.itemid=items.itemid)
LEFT JOIN triggers ON (triggers.triggerid=functions.triggerid)
WHERE hosts.status IN (0,1)
AND items.flags IN (0,4)
AND hosts.hostid=10336
GROUP BY
hosts.host,hosts.available,hosts.error,
interface.dns,interface.type,
items.name,items.error,
host_inventory.os_full,host_inventory.os_short,host_inventory.contact,
functions.functionid,
triggers.expression
\gx


--expand functions.functionid
SELECT CONCAT ('{', hosts.host, ':', items.key_, '.', functions.name, '(', functions.parameter, ')')
FROM functions
LEFT JOIN items ON (items.itemid=functions.itemid)
LEFT JOIN hosts ON (hosts.hostid=items.hostid)
WHERE functions.functionid=22328;




CASE
WHEN items.flags=0 THEN 'normal'
WHEN items.flags=1 THEN 'LLD rule'
WHEN items.flags=2 THEN 'prototype'
WHEN items.flags=4 THEN 'from LLD'
END AS flags,






--host groups, hosts, items, interfaces
SELECT
items.itemid,
hosts.hostid
FROM items
LEFT JOIN hosts ON (hosts.hostid=items.hostid)
RIGHT JOIN interface ON (hosts.hostid=interface.hostid)
LEFT JOIN items_applications ON (items.itemid=items_applications.itemid)
WHERE hosts.status IN (0,1)
AND items.flags IN (0,4)
AND hosts.hostid=10336
;

\gx







/* simplest group_concat example PostgreSQL */
SELECT DISTINCT hostid,array_to_string(array_agg(itemid), ',') FROM items GROUP BY hostid;


--curent timestamp 
SELECT EXTRACT(EPOCH FROM (NOW() - INTERVAL '5 MINUTES'));

--seek for dublicate records
SELECT COUNT(*),userid
FROM users 
GROUP BY userid 
ORDER BY COUNT(*) ASC;

SELECT COUNT(*),userid
FROM users 
GROUP BY userid 
ORDER BY COUNT(*) DESC
LIMIT 10;


--show active connections
\o /tmp/active.connections.log
SELECT * FROM pg_stat_activity;
\o

--Show how many users are having active sessions at the recent moment,sesitive
SELECT COUNT(*),
       users.userid,
	   users.type,
	   users.refresh,
	   users.rows_per_page,
	   users.autologout
FROM users
JOIN sessions ON (users.userid = sessions.userid)
WHERE (sessions.status=0)
  AND (sessions.lastaccess > EXTRACT(EPOCH FROM (NOW() - INTERVAL '5 MINUTES')))
GROUP BY users.userid,users.type,users.refresh,users.rows_per_page,users.autologout
ORDER BY COUNT(*) ASC; 


\o /tmp/functions.log
\df+
\o

--show template name for item which has been generated from LLD which belongs to template
SELECT
hosts.host,
items.itemid as autogenerated_item_id,
items.key_ as item_key,
triggers.triggerid as triggerid,
triggers.description as trigger_title,
item_discovery.parent_itemid as item_prototype_id_in_host_level,
trigger_discovery.parent_triggerid as trigger_prototype_id_in_host_level,
prototype_triggers.description as prototype_triggers_name_at_host_level,
lld.name as discovery_name_in_host_level,
lld.itemid as discovery_id_in_host_level,
lld.templateid as discovery_id_in_template_level,
template_responsible.hostid as template_id,
template_responsible.host as template_name
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items parent_itemid_items ON (parent_itemid_items.itemid=item_discovery.parent_itemid)
JOIN item_discovery lld_id ON (lld_id.itemid=parent_itemid_items.itemid)
JOIN items lld ON (lld.itemid=lld_id.parent_itemid)
JOIN items template_id_responsible ON (template_id_responsible.itemid=lld.itemid)
JOIN hosts template_responsible ON (template_responsible.hostid=template_responsible.hostid)
JOIN functions ON (items.itemid=functions.itemid)
JOIN triggers ON (functions.triggerid=triggers.triggerid)
JOIN trigger_discovery ON (trigger_discovery.triggerid=triggers.triggerid)
JOIN triggers prototype_triggers ON (prototype_triggers.triggerid=trigger_discovery.parent_triggerid)
WHERE items.flags='4'
  AND hosts.host='AKADIKIS-840-G2'
  AND hosts.status IN (0,1)
LIMIT 2 
\gx
;


--size of biggest tables, hypertables, 
\o /tmp/biggest.tables.log
SELECT *, pg_size_pretty(total_bytes) AS total , pg_size_pretty(index_bytes) AS index ,
       pg_size_pretty(toast_bytes) AS toast , pg_size_pretty(table_bytes) AS table
FROM
  (SELECT *, total_bytes-index_bytes-coalesce(toast_bytes, 0) AS table_bytes
   FROM
     (SELECT c.oid,
             nspname AS table_schema,
             relname AS table_name ,
             c.reltuples AS row_estimate ,
             pg_total_relation_size(c.oid) AS total_bytes ,
             pg_indexes_size(c.oid) AS index_bytes ,
             pg_total_relation_size(reltoastrelid) AS toast_bytes
      FROM pg_class c
      LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE relkind = 'r' ) a) a;
\o
\gx








SELECT * FROM problem
WHERE clock >= EXTRACT(EPOCH FROM (TIMESTAMP '2020-03-03 00:00:00'))
AND clock < EXTRACT(EPOCH FROM (TIMESTAMP '2020-03-05 00:00:00'))
AND name LIKE ('Trigger name%'); 


--delete events. ordering by eventid (and not the clock) required because recovery event will always be after problem event
--it's not allways the case when a host is behind a proxy with nodata trigger, and proxy goes offline..
DELETE FROM events
WHERE eventid IN (
SELECT eventid FROM events
WHERE source=0
AND object=0
AND objectid=179697
AND clock <= EXTRACT(EPOCH FROM (TIMESTAMP '2020-08-10 00:00:00' - INTERVAL '1 MONTH ')) ORDER BY eventid ASC LIMIT 10000
);



DELETE FROM events WHERE source > 0 AND clock IN (SELECT clock FROM events WHERE source > 0 LIMIT 1 OFFSET 0);

DELETE FROM events WHERE source=0 and object=0 and clock <= EXTRACT(EPOCH FROM (timestamp '2020-07-24 00:00:00' - INTERVAL '1 MONTH ')) ORDER BY 'eventid' limit 100000;




-- posthres >= 9.2
SELECT pid, age(clock_timestamp(), query_start), usename, query 
FROM pg_stat_activity 
WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%' 
ORDER BY query_start desc;

-- before 9.2
SELECT procpid, age(clock_timestamp(), query_start), usename, current_query 
FROM pg_stat_activity 
WHERE current_query != '<IDLE>' AND current_query NOT ILIKE '%pg_stat_activity%' 
ORDER BY query_start desc;




SELECT to_char(date(to_timestamp(auditlog.clock)),'YYYY-MM-DD'),
auditlog.auditid,
users.alias,
CASE auditlog.action
           WHEN 0 THEN 'ADD'
           WHEN 1 THEN 'UPDATE'
           WHEN 2 THEN 'DELETE'
           WHEN 3 THEN 'LOGIN'
           WHEN 4 THEN 'LOGOUT'
           WHEN 5 THEN 'ENABLE'
           WHEN 6 THEN 'DISABLE'
       END AS action,
       CASE auditlog.resourcetype
           WHEN 0 THEN 'USER'
           WHEN 2 THEN 'ZABBIX_CONFIG'
           WHEN 3 THEN 'MEDIA_TYPE'
           WHEN 4 THEN 'HOST'
           WHEN 5 THEN 'ACTION'
           WHEN 6 THEN 'GRAPH'
           WHEN 7 THEN 'GRAPH_ELEMENT'
           WHEN 11 THEN 'USER_GROUP'
           WHEN 12 THEN 'APPLICATION'
           WHEN 13 THEN 'TRIGGER'
           WHEN 14 THEN 'HOST_GROUP'
           WHEN 15 THEN 'ITEM'
           WHEN 16 THEN 'IMAGE'
           WHEN 17 THEN 'VALUE_MAP'
           WHEN 18 THEN 'IT_SERVICE'
           WHEN 19 THEN 'MAP'
           WHEN 20 THEN 'SCREEN'
           WHEN 22 THEN 'SCENARIO'
           WHEN 23 THEN 'DISCOVERY_RULE'
           WHEN 24 THEN 'SLIDESHOW'
           WHEN 25 THEN 'SCRIPT'
           WHEN 26 THEN 'PROXY'
           WHEN 27 THEN 'MAINTENANCE'
           WHEN 28 THEN 'REGEXP'
           WHEN 29 THEN 'MACRO'
           WHEN 30 THEN 'TEMPLATE'
           WHEN 31 THEN 'TRIGGER_PROTOTYPE'
           WHEN 32 THEN 'ICON_MAP'
           WHEN 33 THEN 'DASHBOARD'
           WHEN 34 THEN 'CORRELATION'
           WHEN 35 THEN 'GRAPH_PROTOTYPE'
           WHEN 36 THEN 'ITEM_PROTOTYPE'
           WHEN 37 THEN 'HOST_PROTOTYPE'
           WHEN 38 THEN 'AUTOREGISTRATION'
       END AS resourcetype,
	   auditlog.resourceid
	   FROM auditlog 
JOIN users ON (users.userid=auditlog.userid)
;







SELECT MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_text WHERE clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 HOUR'));
SELECT MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_log WHERE clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 HOUR'));

SELECT MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_text WHERE clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 DAY'));
SELECT MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_log WHERE clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 DAY'));

SELECT MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_str WHERE clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 HOUR'));


SELECT hosts.name AS host, items.name AS item
FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(history_text.value) > 1
AND history_text.clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '2 DAY'))
;



SELECT COUNT(*), hosts.name AS host, items.name AS item
FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(history_text.value) > 1
AND history_text.clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '2 DAY'))
GROUP BY 2,3
ORDER BY 1 DESC
;


SELECT COUNT(*), hosts.name AS host, items.name AS item
FROM history_log
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(history_log.value) > 1000
AND history_log.clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '2 DAY'))
GROUP BY 2,3
ORDER BY 1 DESC
; 





SELECT hosts.name AS host, items.name AS item
FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(history_text.value) > 30000
AND history_text.clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 HOUR'))
;

SELECT hosts.name AS host, items.name AS item
FROM history_log
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(history_log.value) > 1000
AND history_log.clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 HOUR'))
;



SELECT hosts.name AS host, items.name AS item
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.itemid IN (
SELECT itemid FROM history_log 
WHERE LENGTH(value) > 1000
AND clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 HOUR'))
)
;



SELECT COUNT(*),CASE alerts.status
           WHEN 0 THEN 'NOT_SENT'
           WHEN 1 THEN 'SENT'
           WHEN 2 THEN 'FAILED'
           WHEN 3 THEN 'NEW'
       END AS status,
	   actions.name
FROM alerts
JOIN actions ON (alerts.actionid=actions.actionid)
WHERE alerts.clock > EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 HOUR'))
GROUP BY alerts.status,actions.name;



/* version */
SELECT version();



-- set an output to an external file
\o /tmp/output.txt

-- show hypertables of log table
SELECT * FROM chunk_relation_size_pretty('history_log');
-- nothing will be printend on screen. that is ok

-- show hypertables of trend integer table
SELECT * FROM chunk_relation_size_pretty('trends_uint');
-- nothing will be printend on screen. that is ok

-- show the biggest tables/hypertables
SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC;
-- nothing will be printend on screen

\q



-- autovacum settings
select name, setting, source, short_desc from pg_settings where name like '%autova%';




-- when the last time the table received a vacuum
\o /tmp/zabbix.autovacuum.txt
SELECT schemaname, relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_all_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;
\p

select itemid, count(*) from history_log where clock>=EXTRACT(EPOCH FROM (timestamp '2020-07-07 05:00:00' - INTERVAL '1 HOUR')) group by itemid order by count(*) DESC LIMIT 20;



SELECT hosts.name AS host, items.name AS item
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.itemid IN (
SELECT itemid FROM history_log 
WHERE LENGTH(value) > 3000 
AND clock > EXTRACT(EPOCH FROM (timestamp '2020-07-07 05:00:00')))
;



SELECT hosts.name AS host, items.name AS item
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.itemid IN (
SELECT itemid FROM history_log 
WHERE LENGTH(value) > 3000 
AND clock > EXTRACT(EPOCH FROM (timestamp '2020-07-07 05:00:00' - INTERVAL '1 HOUR')))
;


/* create new user role 'zabbixa' */
createuser --pwprompt zabbixa
createuser --pwprompt zabbixs

/* create database 'z40' and assign owner to be user 'zabbix' */
dropdb z30 && createdb -O zabbixs z30
dropdb zabbix && createdb -O zabbixs zabbix

/* restore schema. this is mandatory step. with '--clean' argument and fresh database it will produce a lot of errors */ 
pg_restore \
--dbname=z30 \
--no-owner \
--format=c \
--schema-only \
/tmp/zabbix30.pg.dump



pg_restore \
--dbname=z30 \
--no-owner \
--data-only \
--format=c \
/tmp/zabbix30.pg.dump

pg_restore \
--dbname=zabbix \
zabbix30.pg.dump



--no-owner

/* pg_restore: [custom archiver] could not read from input file: end of file */


SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;



/* backup zabbix 4.0 */

pg_dump \
--dbname=<database> \
--host=<host> \
--username=<user> \
--file=zabbix40.pg10.dump \
--format=custom \
--blobs \
--verbose \
--exclude-table-data '*.history*' \
--exclude-table-data '*.trends*'


pg_dump \
--dbname=z30 \
--file=zabbix30.pg10.dump \
--format=custom \
--blobs \
--verbose \
--exclude-table-data '*.history*' \
--exclude-table-data '*.trends*'


createuser --pwprompt zabbix

dropdb z40b && createdb -O zabbix z40b
dropdb z30b && createdb -O zabbix z30b


pg_restore \
--dbname=z30 \
--no-owner \
--format=c \
--schema-only \
zabbix30.pg.dump

pg_restore \
--dbname=z30 \
--no-owner \
--data-only \
--format=c \
zabbix30.pg.dump


/* pg_restore: [archiver (db)] connection to database "z30" failed: FATAL:  database "z30" does not exist */

createuser --pwprompt zabbixs
createuser --pwprompt zabbixa

dropdb zabbix && createdb -O zabbixs zabbix

cd /tmp
pg_restore \
--dbname=zabbix \
--format=c \
--verbose \
zabbix30.pg.dump

--no-owner \



pg_dump \
--dbname=z40 \
--file=zabbix40.pg10.dump \
--format=custom \
--blobs \
--verbose \
--exclude-table-data '*.history*' \
--exclude-table-data '*.trends*'




pg_dump \
--dbname=z44 \
--host=pg \
--port=5432 \
--file=zabbix40.pg10.dump \
--format=custom \
--blobs \
--verbose \
--exclude-table-data '*.history*' \
--exclude-table-data '*.trends*'

--show which items belong to which template. on 4.0
SELECT hosts.host,
       hosts.hostid,
       items.key_ AS item_key,
       template_items.itemid AS itemid_at_template_level,
       template_hosts.host AS template_name
FROM triggers
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN triggers template_triggers ON (triggers.templateid=template_triggers.triggerid)
JOIN functions template_functions ON (template_functions.triggerid=template_triggers.triggerid)
JOIN items template_items ON (template_items.itemid=template_functions.itemid)
JOIN hosts template_hosts ON (template_hosts.hostid=template_items.hostid)
WHERE triggers.flags IN (0)
  AND items.flags NOT IN (1)
  AND hosts.status IN (0,1)
  LIMIT 1
;

-- on 4.2
SELECT hosts.host,
       hosts.hostid,
       functions.itemid AS itemid_at_host_level,
       items.key_ AS item_key,
       triggers.triggerid AS triggerid_at_host_level,
       triggers.description AS trigger_title,
       functions.name AS trigger_function,
       template_items.itemid AS itemid_at_template_level,
       template_triggers.triggerid AS triggerid_at_template_level,
       template_triggers.expression AS trigger_expression,
	   template_functions.name AS template_function,
	   template_functions.parameter AS template_parameter,
       template_hosts.hostid AS templateid_aka_hostid,
       template_hosts.host AS template_name
FROM triggers
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN triggers template_triggers ON (triggers.templateid=template_triggers.triggerid)
JOIN functions template_functions ON (template_functions.triggerid=template_triggers.triggerid)
JOIN items template_items ON (template_items.itemid=template_functions.itemid)
JOIN hosts template_hosts ON (template_hosts.hostid=template_items.hostid)
WHERE triggers.flags IN (0)
  AND items.flags NOT IN (1)
  AND hosts.status IN (0,1)
  LIMIT 1
\gx

  AND hosts.host=''




-- on 3.0
SELECT hosts.host,
       hosts.hostid,
       functions.itemid AS itemid_at_host_level,
       items.key_ AS item_key,
       triggers.triggerid AS triggerid_at_host_level,
       triggers.description AS trigger_title,
       functions.function AS trigger_function,
       template_items.itemid AS itemid_at_template_level,
       template_triggers.triggerid AS triggerid_at_template_level,
       template_triggers.expression AS trigger_expression,
	   template_functions.function AS template_function,
	   template_functions.parameter AS template_parameter,
       template_hosts.hostid AS templateid_aka_hostid,
       template_hosts.host AS template_name
FROM triggers
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN triggers template_triggers ON (triggers.templateid=template_triggers.triggerid)
JOIN functions template_functions ON (template_functions.triggerid=template_triggers.triggerid)
JOIN items template_items ON (template_items.itemid=template_functions.itemid)
JOIN hosts template_hosts ON (template_hosts.hostid=template_items.hostid)
WHERE triggers.flags IN (0)
  AND items.flags NOT IN (1)
  AND hosts.status IN (0,1)
  AND hosts.host='agent box 2' 
  AND triggers.description like 'three%'
  LIMIT 1
  \gx

  
  \x\g\x


  ;
  
   
SELECT hosts.host,
functions.triggerid,
items.key_,
string_agg(DISTINCT functions.function, ',') AS functions,
string_agg(DISTINCT functions.parameter, ',') AS parameter
FROM functions 
JOIN triggers ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN triggers template_triggers ON (template_triggers.triggerid=triggers.templateid)
WHERE hosts.host='agent box 2'
GROUP BY 1,functions.triggerid,items.key_
;


  \x\g\x






WHERE functions.triggerid=13647 


Lack of available virtual memory on server {HOST.NAME}



pg_dump \
--dbname=DBNAME \
--host=HOSTNAME \
--port=PORT \
--username=NAME \
--file=zabbix30.schema.sql \
--schema-only \
--format=plain



pg_dump \
--dbname=z44 \
--host=pg \
--file=zabbix44.pg.schema.dump \
--schema-only \
--format=plain







pg_dump \
--dbname=DBNAME \
--host=HOSTNAME \
--port=PORT \
--username=NAME \
--file=zabbix30.pg.dump \
--format=custom \
--compress=9 \
--blobs \
--exclude-table-data=history* \
--exclude-table-data=trends* \
--exclude-table-data=events \
--exclude-table-data=acknowledges \
--exclude-table-data=alerts \
--exclude-table-data=auditlog \
--exclude-table-data=auditlog_details \
--exclude-table-data=profiles \
--exclude-table-data=service_alarms \
--exclude-table-data=sessions \
--exclude-table-data=problem \
--exclude-table-data=event_recovery


/* You can use pg_dump utility from PostgreSQL. Here is an example to perform a backup without history and trends tables: */
pg_dump \
--dbname=<database> \
--host=<host> \
--username=<user> \
--file=zabbix40.pg10.dump \
--format=custom \
--blobs \
--verbose \
--exclude-table-data '*.history*' \
--exclude-table-data '*.trends*'
/* Replace <user>, <host>, <database>. The 'custom' format is already compressed. You can influence the compress ratio with an external '--compress=9' argument for maximum compression. */
 
/* To restore: */
pg_restore \
--dbname=<database> \
--host=<host> \
zabbix40.pg10.dump
/* Replace <host>, <database> */



pg_dump \
--dbname=z30 \
--host=pg \
--file=zabbix30.pg.dump \
--format=custom \
--compress=9 \
--blobs \
--exclude-table-data=history* \
--exclude-table-data=trends* \
--exclude-table-data=events \
--exclude-table-data=acknowledges \
--exclude-table-data=alerts \
--exclude-table-data=auditlog \
--exclude-table-data=auditlog_details \
--exclude-table-data=profiles \
--exclude-table-data=service_alarms \
--exclude-table-data=sessions \
--exclude-table-data=problem \
--exclude-table-data=event_recovery




--host=pg \

\o /tmp/pgoutput.log

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
AND triggers.description like '%has just been restarted'
AND functions.function IN ('change')
;

\o

\q



\o /tmp/pgoutput.log


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
AND triggers.description like 'Zabbix agent on {HOST.NAME} is unreachable for 5 minutes'
;




/* report hosts where the trigger seems to be linked in template level but actually NOT */

\o /tmp/orphaned.triggers.log

SELECT hosts.host,
items.key_,
functions.function,
triggers.templateid,
triggers.expression,
functions.itemid,
triggers.triggerid,
triggers.description
FROM triggers
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE triggers.flags IN (0)
AND items.flags NOT IN (1)
AND hosts.status IN (0,1)
AND triggers.triggerid NOT IN ( 

SELECT triggers.triggerid
FROM triggers
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE triggers.flags IN (0)
AND items.flags NOT IN (1)

);

\o

\q



           host            | templateid | expression | itemid | triggerid
---------------------------+------------+------------+--------+-----------
 Template App Zabbix Agent |            | {12549}=1  |  22232 |     13025
 Template OS Linux         |      13025 | {12550}=1  |  10020 |     10047
 Template OS OpenBSD       |      13025 | {12715}=1  |  22833 |     13328
 Template OS FreeBSD       |      13025 | {12731}=1  |  22873 |     13344
 Template OS AIX           |      13025 | {12747}=1  |  22913 |     13360
 Template OS HP-UX         |      13025 | {12763}=1  |  22953 |     13376
 Template OS Solaris       |      13025 | {12779}=1  |  22993 |     13392
 Template OS Mac OS X      |      13025 | {12795}=1  |  23033 |     13408
 Template OS Windows       |      13025 | {12824}=1  |  23160 |     13437
 agent box 1               |      13025 | {13217}=1  |  24186 |     13605
 agent box 2               |      13025 | {13220}=1  |  24189 |     13608





/* live variables and database size */
\o postgresql-9-live-variables.txt

SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC;

SHOW ALL;

\o

\q




pg_dump -c -O -F plain -N partitions --username=DBUser DBName

pg_dump --host=pg --format plain --verbose --file "<abstract_file_path_dump>" --table <history_<(str|text|uint|log)>_new> --inserts <database_name> --data-only


pg_dump -d z40 -F c -b -v -f ~/new
        --exclude-table-data '*.history_log*' 
        --exclude-table-data '*.history_str*' 
        --exclude-table-data '*.history_uint*' 
        --exclude-table-data '*.history_text*' 
        --exclude-table-data '*.trends*' 
        --exclude-table-data '*.trends_uint*'


pg_dump --host=pg \
--format=custom \
--blobs \
--clean \
--verbose \
--exclude-table-data=history* \
--exclude-table-data=trends* \
--exclude-table-data=events \
--exclude-table-data=acknowledges \
--exclude-table-data=alerts \
--exclude-table-data=auditlog \
--exclude-table-data=auditlog_details \
--exclude-table-data=profiles \
--exclude-table-data=service_alarms \
--exclude-table-data=sessions \
--exclude-table-data=problem \
--exclude-table-data=event_recovery \
z42 > z42.sql



pg_dump
--dbname=z50 \
--format=plain \
--blobs \
--clean \
--verbose \
--data-only \
--include-table-data=history_uint \
--file=history_uint.sql


z42 > zabbix.pg.dump.compressed


--clean \
--blobs \



--verbose \

pg_dump --host=pg --data-only --exclude-table

--exclude-schema

pg_dump --schema-only --exclude-table=history* --exclude-table=trends* z50 > schema.sql 


pg_dump --host=pg --schema-only --exclude-table=history* --exclude-table=trends* --exclude-table=events z40 > out40.sql

/* configuration backup 4.4 */
pg_dump \
--host=pg \
--schema-only \
--exclude-table=acknowledges \
--exclude-table=alerts \
--exclude-table=auditlog \
--exclude-table=auditlog_details \
--exclude-table=events \
--exclude-table=history* \
--exclude-table=trends* \
--exclude-table=profiles \
--exclude-table=service_alarms \
--exclude-table=sessions \
--exclude-table=problem \
--exclude-table=event_recovery \
z40 > out40.sql

/* configuration backup 4.4 */
pg_dump \
--host=pg \
--data-only \
--exclude-table=acknowledges \
--exclude-table=alerts \
--exclude-table=auditlog \
--exclude-table=auditlog_details \
--exclude-table=events \
--exclude-table=history* \
--exclude-table=trends* \
--exclude-table=profiles \
--exclude-table=service_alarms \
--exclude-table=sessions \
--exclude-table=problem \
--exclude-table=event_recovery \
z40 > data44.sql




/* configuration backup 4.4 */
pg_dump \
--host=pg \
--exclude-table=acknowledges \
--exclude-table=alerts \
--exclude-table=auditlog \
--exclude-table=auditlog_details \
--exclude-table=events \
--exclude-table=history* \
--exclude-table=trends* \
--exclude-table=profiles \
--exclude-table=service_alarms \
--exclude-table=sessions \
--exclude-table=problem \
--exclude-table=event_recovery \
z40 > data40.sql



pg_dump \
--host=pg \
--data-only \
--exclude-table=history* \
--exclude-table=trends* \
z40 > data44.sql



/* authorize in pg database */ 
su - postgres -c 'psql zabbix'

/* show create table directly from bash */
su - postgres
pg_dump -st public.history zabbix
pg_dump -st public.history_uint zabbix
pg_dump -st public.history_str zabbix
pg_dump -st public.history_log zabbix
pg_dump -st public.history_text zabbix
pg_dump -st public.trends zabbix
pg_dump -st public.trends_uint zabbix


psql zabbix

/* observe if there is any partitions made */
\d+ public.history*;
\d+ public.trends*;

/* create partitioning for history_uint */
CREATE TABLE public.history_uint (
    itemid bigint NOT NULL,
    clock integer DEFAULT 0 NOT NULL,
    value numeric(20,0) DEFAULT '0'::numeric NOT NULL,
    ns integer DEFAULT 0 NOT NULL
) PARTITION BY RANGE (clock);


CREATE TABLE public.history_old PARTITION OF public.history
    FOR VALUES FROM (MINVALUE) TO (1554140222);
CREATE TABLE public.history_y2019m04 PARTITION OF public.history
    FOR VALUES FROM (1554140223) TO (1556732222);	
CREATE TABLE public.history_y2019m05 PARTITION OF public.history
    FOR VALUES FROM (1556732223) TO (1559324222);

CREATE INDEX ON public.history_old USING btree (itemid, clock);
CREATE INDEX ON public.history_y2019m04 USING btree (itemid, clock);
CREATE INDEX ON public.history_y2019m05 USING btree (itemid, clock);

alter table history owner to zabbix;





SELECT relname, last_vacuum, last_autovacuum FROM pg_stat_user_tables;

SELECT 
    schemaName
    ,relname
    ,n_live_tup
    ,n_dead_tup
    ,last_autovacuum
FROM pg_stat_all_tables
ORDER BY n_dead_tup
    /(n_live_tup
      * current_setting('autovacuum_vacuum_scale_factor')::float8
      + current_setting('autovacuum_vacuum_threshold')::float8)
     DESC
