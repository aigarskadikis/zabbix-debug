



--see if vacuum is in progress
SELECT * FROM pg_catalog.pg_stat_progress_analyze;
SELECT * FROM pg_catalog.pg_stat_progress_vacuum;

--show most recent sessions
SELECT TO_CHAR(DATE(TO_TIMESTAMP(sessions.lastaccess)),'YYYY-MM-DD HH:mm') AS "recent_acccess", users.alias
FROM sessions
JOIN users ON (users.userid=sessions.userid)
ORDER BY sessions.lastaccess;


TO_CHAR(DATE(TO_TIMESTAMP(sessions.lastaccess)),'YYYY-MM-DD HH:mm')


--replication status
SELECT
client_addr AS client, usename AS user, application_name AS name,
state, sync_state AS mode,
(pg_wal_lsn_diff(pg_current_wal_lsn(),sent_lsn) / 1024)::int as pending,
(pg_wal_lsn_diff(sent_lsn,write_lsn) / 1024)::int as write,
(pg_wal_lsn_diff(write_lsn,flush_lsn) / 1024)::int as flush,
(pg_wal_lsn_diff(flush_lsn,replay_lsn) / 1024)::int as replay,
(pg_wal_lsn_diff(pg_current_wal_lsn(),replay_lsn))::int / 1024 as total_lag
FROM pg_stat_replication;


# show stats per hypertables
\o /tmp/timescaledb.all.txt
SELECT * FROM timescaledb_information.chunks;
\o /tmp/timescaledb.txt
SELECT hypertable_name,chunk_name,is_compressed FROM timescaledb_information.chunks ORDER BY 1;
\o





--size of postgres
select relname, pg_size_pretty(pg_relation_size(C.oid)) AS DATA ,
pg_size_pretty(pg_total_relation_size(C.OID) - pg_relation_size(C.oid)) AS INDEXES ,
pg_size_pretty(pg_total_relation_size(C.OID)) AS Total from pg_class C
LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
WHERE c.relkind = 'r'::"char"
order by relpages desc limit 20 ;








--rename live table to '_old'
--create back empty table to continue storing data during migration
--download '_old' to CSV
--recreate a '_partitioned' table containing hypertables
--import from CSV to '_partitioned'
--rename live table to '_recent'
--rename '_partitioned' table to live
--copy from '_recent' to live
--all graphs must be completed in GUI. drop '_recent', drop '_old'



--size per tables hypertables
\o /tmp/tables.hypertables.txt
SELECT table_schema, table_name, table_bytes, pg_size_pretty(total_bytes) AS total 
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
      WHERE relkind = 'r' ) a) a
	  ORDER BY 1,2;
\o


--ts 2.6.1 show chunks

\o /tmp/relations.txt
SELECT show_chunks('history');
SELECT show_chunks('history_uint');
SELECT show_chunks('history_text');
SELECT show_chunks('history_str');
SELECT show_chunks('history_log');
SELECT show_chunks('trends');
SELECT show_chunks('trends_uint');
\o

SELECT * FROM chunk_compression_stats('history_uint');
SELECT * FROM chunk_compression_stats('history');
SELECT * FROM chunk_compression_stats('history_str');
SELECT * FROM chunk_compression_stats('history_log');
SELECT * FROM chunk_compression_stats('history_text');
SELECT * FROM chunk_compression_stats('trends');
SELECT * FROM chunk_compression_stats('trends_uint');



--ts 2.6.1. drop history older than 6 days
SELECT drop_chunks(relation=>'history', older_than=>extract(epoch from now()::DATE - 6)::integer);
SELECT drop_chunks(relation=>'history_uint', older_than=>extract(epoch from now()::DATE - 6)::integer);
SELECT drop_chunks(relation=>'history_str', older_than=>extract(epoch from now()::DATE - 6)::integer);
SELECT drop_chunks(relation=>'history_log', older_than=>extract(epoch from now()::DATE - 6)::integer);
SELECT drop_chunks(relation=>'history_text', older_than=>extract(epoch from now()::DATE - 6)::integer);


SELECT * FROM chunk_compression_stats('history_uint');



SELECT * FROM timescaledb_information.chunks WHERE hypertable_name = 'hyper_int';






select pid,usename,pg_blocking_pids(pid) as blocked_by,query as blocked_query from pg_stat_activity where cardinality(pg_blocking_pids(pid)) > 0;


select pid,usename,pg_blocking_pids(pid) as blocked_by,query as blocked_query from pg_stat_activity \gx








--should figure out which slow SQLs are originated first, i.e. which one likely causes locks and delays for other queries.
--Try to use these to show running queries (PG 9.2+):
SELECT pid, state, age(clock_timestamp(), query_start), usename, CHAR_LENGTH(query) AS q_len, LEFT(query, 200) AS query
FROM pg_stat_activity
WHERE state NOT LIKE '%idle%' AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start desc;

--the same but also includes information about transactions:
\o /tmp/postgres.processes.txt
SELECT a.pid, a.state, age(clock_timestamp(), a.query_start), a.usename, l.mode, a.backend_xmin, CHAR_LENGTH(a.query) AS q_len, LEFT(a.query, 200) AS query
FROM pg_stat_activity a
JOIN pg_locks l ON l.pid = a.pid
WHERE a.state NOT LIKE '%idle%' AND a.query NOT ILIKE '%pg_stat_activity%'
ORDER BY a.query_start desc;
\o

SELECT CONCAT( '/host_discovery.php?form=update&itemid=', itemid) AS "URL" FROM items where flags=1 and delay='1h';


--autovacuum for a specific table
alter table zabbix.public.item_discovery set (autovacuum_vacuum_cost_limit = 300);




# backup only data in the table partitions
pg_dump --host="localhost" --username="postgres" --dbname=zabbix --format=plain --blobs --verbose --data-only --table=partitions.'alerts*' --file=alerts.sql

# backup everything from the schema 'public', this will not contain partitions. It's a plain and readable backup
/usr/bin/pg_dump -U postgres -n public zabbix > /pgdata_archive/Backup_Zabbix_Database/dump_zabbix_public_schema

# almost the same command as before but be are backuping everything which comes from schema 'partitions'. in practice practically it's schema 'public'
/usr/local/bin/pg_dump --host="localhost" --username="postgres" --exclude-schema="partitions" 




# dump database but don't include any data which is inside partitions regarding history and trends
pg_dump \
--dbname=zabbix \
--username="postgres" \
--format=custom \
--blobs \
--verbose \
--exclude-table=partitions.'history*' \
--exclude-table=partitions.'trends*' \
--file=zabbixDB.without.history.trends.dump

# create new DB which belongs to user 'postgres'
createdb -O postgres zabbix20211203

# cd /path/to/dump/which was using using 'format=custom' (it's acompressed file)
pg_restore \
--dbname=zabbix20211203 \
--username="postgres" \
--format=custom \
--verbose \
zabbixDB.without.history.trends.dump

cd /tmp
wget https://cdn.zabbix.com/zabbix/sources/stable/5.0/zabbix-5.0.18.tar.gz
tar xvf zabbix-5.0.18.tar.gz
cd /tmp/zabbix-5.0.18/database/postgresql
grep "ALTER TABLE.*events" /tmp/zabbix-5.0.18/database/postgresql/schema.sql
grep "ALTER TABLE.*alerts" /tmp/zabbix-5.0.18/database/postgresql/schema.sql



SELECT * FROM ids WHERE table_name LIKE 'auditlog';



--biggest metrics
SELECT itemid,SUM(LENGTH(value)) FROM history_text WHERE clock > EXTRACT(epoch FROM NOW()-INTERVAL '5 MINUTE') GROUP BY itemid ORDER BY SUM(LENGTH(value)) DESC LIMIT 5;
SELECT itemid,SUM(LENGTH(value)) FROM history_str WHERE clock > EXTRACT(epoch FROM NOW()-INTERVAL '5 MINUTE') GROUP BY itemid ORDER BY SUM(LENGTH(value)) DESC LIMIT 5;
SELECT itemid,SUM(LENGTH(value)) FROM history_log WHERE clock > EXTRACT(epoch FROM NOW()-INTERVAL '5 MINUTE') GROUP BY itemid ORDER BY SUM(LENGTH(value)) DESC LIMIT 5;



SELECT * FROM pg_stat_activity LIMIT 1
\gx

--clock, from_unixtime
SELECT TO_CHAR(DATE(TO_TIMESTAMP(clock)),'YYYY-MM-DD HH:mm'),name FROM events
WHERE source=3 AND object=4 AND LENGTH(name)>0
ORDER BY clock ASC;


--see the new LLD comming in in the proxy
SELECT FROM_UNIXTIME(clock), hosts.host, items.key_, LENGTH(value), value FROM proxy_history JOIN items ON (items.itemid = proxy_history.itemid) JOIN hosts ON (hosts.hostid = items.hostid) WHERE items.flags=1;


--active query
\o /tmp/20.minutes.txt
SELECT
pid,
now() - pg_stat_activity.query_start AS duration,
query,
state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '20 minutes';
\o



echo "SELECT * FROM items JOIN hosts ON (hosts.hostid=items.hostid) WHERE hosts.host='hostTitleHere';" | psql -t -A -F"TabSep" nameOfZabbixDB | sed "s%TabSep%\t%g" > /tmp/23217.tsv


--copy host names, host groups, IPs to CSV. Zabbix 5.0. It works only as a one line:
\copy (SELECT hosts.host AS host,hstgrp.name AS host_group,interface.ip AS IP FROM hosts JOIN hosts_groups ON (hosts_groups.hostid=hosts.hostid) JOIN hstgrp ON (hstgrp.groupid=hosts_groups.groupid) JOIN interface ON (interface.hostid=hosts.hostid) WHERE hosts.status IN (0,1))  TO '/tmp/hosts.hg.ips.csv' WITH CSV





--delete from events in postgres
DELETE FROM events WHERE source > 0 AND clock IN (SELECT clock FROM events WHERE source > 0 LIMIT 1 OFFSET 0);

DELETE FROM events WHERE source IN (1,2,3) AND clock IN (SELECT clock FROM events WHERE source IN (1,2,3) LIMIT 1 OFFSET 0);


pg_dump \
--dbname=z50 \
--file=zabbix50.dump \
--format=custom \
--blobs \
--verbose \
--exclude-table-data '*.history*' \
--exclude-table-data '*.trends*'



pg_dump \
--dbname=z50 \
--format=plain \
--blobs \
--verbose \
--data-only \
--exclude-table '*.history*' \
--exclude-table '*.trends*' \
--file=z50.without.history.sql


pg_dump \
--dbname=zabbix \
--format=custom \
--blobs \
--verbose \
--exclude-table=partitions.'history*' \
--exclude-table=partitions.'trends*' \
--file=zabbixDB.without.history.trends.dump




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
--dbname=z50 \
--file=zabbix50.dump \
--format=custom \
--blobs \
--verbose \
--table=users \
--table=maintenances \
--table=hosts \
--table=hstgrp \
--table=group_prototype \
--table=group_discovery \
--table=screens \
--table=screens_items \
--table=screen_user \
--table=screen_usrgrp \
--table=slideshows \
--table=slideshow_user \
--table=slideshow_usrgrp \
--table=slides \
--table=drules \
--table=dchecks \
--table=applications \
--table=httptest \
--table=httpstep \
--table=interface \
--table=valuemaps \
--table=items \
--table=httpstepitem \
--table=httptestitem \
--table=media_type \
--table=media_type_param \
--table=media_type_message \
--table=usrgrp \
--table=users_groups \
--table=scripts \
--table=actions \
--table=operations \
--table=opmessage \
--table=opmessage_grp \
--table=opmessage_usr \
--table=opcommand \
--table=opcommand_hst \
--table=opcommand_grp \
--table=opgroup \
--table=optemplate \
--table=opconditions \
--table=conditions \
--table=config \
--table=triggers \
--table=trigger_depends \
--table=functions \
--table=graphs \
--table=graphs_items \
--table=graph_theme \
--table=globalmacro \
--table=hostmacro \
--table=hosts_groups \
--table=hosts_templates \
--table=items_applications \
--table=mappings \
--table=media \
--table=rights \
--table=services \
--table=services_links \
--table=services_times \
--table=icon_map \
--table=icon_mapping \
--table=sysmaps \
--table=sysmaps_elements \
--table=sysmaps_links \
--table=sysmaps_link_triggers \
--table=sysmap_element_url \
--table=sysmap_url \
--table=sysmap_user \
--table=sysmap_usrgrp \
--table=maintenances_hosts \
--table=maintenances_groups \
--table=timeperiods \
--table=maintenances_windows \
--table=regexps \
--table=expressions \
--table=ids \
--table=alerts \
--table=history \
--table=history_uint \
--table=history_str \
--table=history_log \
--table=history_text \
--table=proxy_history \
--table=proxy_dhistory \
--table=events \
--table=trends \
--table=trends_uint \
--table=acknowledges \
--table=auditlog \
--table=auditlog_details \
--table=service_alarms \
--table=autoreg_host \
--table=proxy_autoreg_host \
--table=dhosts \
--table=dservices \
--table=escalations \
--table=globalvars \
--table=graph_discovery \
--table=host_inventory \
--table=housekeeper \
--table=images \
--table=item_discovery \
--table=host_discovery \
--table=interface_discovery \
--table=profiles \
--table=sessions \
--table=trigger_discovery \
--table=application_template \
--table=item_condition \
--table=item_rtdata \
--table=application_prototype \
--table=item_application_prototype \
--table=application_discovery \
--table=opinventory \
--table=trigger_tag \
--table=event_tag \
--table=problem \
--table=problem_tag \
--table=tag_filter \
--table=event_recovery \
--table=correlation \
--table=corr_condition \
--table=corr_condition_tag \
--table=corr_condition_group \
--table=corr_condition_tagpair \
--table=corr_condition_tagvalue \
--table=corr_operation \
--table=task \
--table=task_close_problem \
--table=item_preproc \
--table=task_remote_command \
--table=task_remote_command_result \
--table=task_data \
--table=task_result \
--table=task_acknowledge \
--table=sysmap_shape \
--table=sysmap_element_trigger \
--table=httptest_field \
--table=httpstep_field \
--table=dashboard \
--table=dashboard_user \
--table=dashboard_usrgrp \
--table=widget \
--table=widget_field \
--table=task_check_now \
--table=event_suppress \
--table=maintenance_tag \
--table=lld_macro_path \
--table=host_tag \
--table=config_autoreg_tls \
--table=module \
--table=interface_snmp \
--table=lld_override \
--table=lld_override_condition \
--table=lld_override_operation \
--table=lld_override_opstatus \
--table=lld_override_opdiscover \
--table=lld_override_opperiod \
--table=lld_override_ophistory \
--table=lld_override_optrends \
--table=lld_override_opseverity \
--table=lld_override_optag \
--table=lld_override_optemplate \
--table=lld_override_opinventory \
--table=dbversion \
--exclude-table-data '*.history*' \
--exclude-table-data '*.trends*'



grep "^CREATE TABLE" schema.sql | sed "s| (| \\\|g" | sed "s|CREATE TABLE |--table=|"


pg_dump \
--dbname=z50 \
--file=zabbix50.dump \
--format=custom \
--blobs \
--verbose \
--include-table=users \
--include-table=maintenances \
--include-table=hosts \
--include-table=hstgrp \
--include-table=group_prototype \
--include-table=group_discovery \
--include-table=screens \
--include-table=screens_items \
--include-table=screen_user \
--include-table=screen_usrgrp \
--include-table=slideshows \
--include-table=slideshow_user \
--include-table=slideshow_usrgrp \
--include-table=slides \
--include-table=drules \
--include-table=dchecks \
--include-table=applications \
--include-table=httptest \
--include-table=httpstep \
--include-table=interface \
--include-table=valuemaps \
--include-table=items \
--include-table=httpstepitem \
--include-table=httptestitem \
--include-table=media_type \
--include-table=media_type_param \
--include-table=media_type_message \
--include-table=usrgrp \
--include-table=users_groups \
--include-table=scripts \
--include-table=actions \
--include-table=operations \
--include-table=opmessage \
--include-table=opmessage_grp \
--include-table=opmessage_usr \
--include-table=opcommand \
--include-table=opcommand_hst \
--include-table=opcommand_grp \
--include-table=opgroup \
--include-table=optemplate \
--include-table=opconditions \
--include-table=conditions \
--include-table=config \
--include-table=triggers \
--include-table=trigger_depends \
--include-table=functions \
--include-table=graphs \
--include-table=graphs_items \
--include-table=graph_theme \
--include-table=globalmacro \
--include-table=hostmacro \
--include-table=hosts_groups \
--include-table=hosts_templates \
--include-table=items_applications \
--include-table=mappings \
--include-table=media \
--include-table=rights \
--include-table=services \
--include-table=services_links \
--include-table=services_times \
--include-table=icon_map \
--include-table=icon_mapping \
--include-table=sysmaps \
--include-table=sysmaps_elements \
--include-table=sysmaps_links \
--include-table=sysmaps_link_triggers \
--include-table=sysmap_element_url \
--include-table=sysmap_url \
--include-table=sysmap_user \
--include-table=sysmap_usrgrp \
--include-table=maintenances_hosts \
--include-table=maintenances_groups \
--include-table=timeperiods \
--include-table=maintenances_windows \
--include-table=regexps \
--include-table=expressions \
--include-table=ids \
--include-table=alerts \
--include-table=history \
--include-table=history_uint \
--include-table=history_str \
--include-table=history_log \
--include-table=history_text \
--include-table=proxy_history \
--include-table=proxy_dhistory \
--include-table=events \
--include-table=trends \
--include-table=trends_uint \
--include-table=acknowledges \
--include-table=auditlog \
--include-table=auditlog_details \
--include-table=service_alarms \
--include-table=autoreg_host \
--include-table=proxy_autoreg_host \
--include-table=dhosts \
--include-table=dservices \
--include-table=escalations \
--include-table=globalvars \
--include-table=graph_discovery \
--include-table=host_inventory \
--include-table=housekeeper \
--include-table=images \
--include-table=item_discovery \
--include-table=host_discovery \
--include-table=interface_discovery \
--include-table=profiles \
--include-table=sessions \
--include-table=trigger_discovery \
--include-table=application_template \
--include-table=item_condition \
--include-table=item_rtdata \
--include-table=application_prototype \
--include-table=item_application_prototype \
--include-table=application_discovery \
--include-table=opinventory \
--include-table=trigger_tag \
--include-table=event_tag \
--include-table=problem \
--include-table=problem_tag \
--include-table=tag_filter \
--include-table=event_recovery \
--include-table=correlation \
--include-table=corr_condition \
--include-table=corr_condition_tag \
--include-table=corr_condition_group \
--include-table=corr_condition_tagpair \
--include-table=corr_condition_tagvalue \
--include-table=corr_operation \
--include-table=task \
--include-table=task_close_problem \
--include-table=item_preproc \
--include-table=task_remote_command \
--include-table=task_remote_command_result \
--include-table=task_data \
--include-table=task_result \
--include-table=task_acknowledge \
--include-table=sysmap_shape \
--include-table=sysmap_element_trigger \
--include-table=httptest_field \
--include-table=httpstep_field \
--include-table=dashboard \
--include-table=dashboard_user \
--include-table=dashboard_usrgrp \
--include-table=widget \
--include-table=widget_field \
--include-table=task_check_now \
--include-table=event_suppress \
--include-table=maintenance_tag \
--include-table=lld_macro_path \
--include-table=host_tag \
--include-table=config_autoreg_tls \
--include-table=module \
--include-table=interface_snmp \
--include-table=lld_override \
--include-table=lld_override_condition \
--include-table=lld_override_operation \
--include-table=lld_override_opstatus \
--include-table=lld_override_opdiscover \
--include-table=lld_override_opperiod \
--include-table=lld_override_ophistory \
--include-table=lld_override_optrends \
--include-table=lld_override_opseverity \
--include-table=lld_override_optag \
--include-table=lld_override_optemplate \
--include-table=lld_override_opinventory \
--include-table=dbversion 



pg_dump \
--dbname=z52 \
--file=zabbix52.dump \
--format=custom \
--blobs \
--verbose \
--table='public.events' \
--table='public.alerts'




INSERT INTO mycopy(colA, colB) SELECT col1, col2 FROM mytable;



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


 oid | table_schema | table_name | row_estimate | total_bytes | index_bytes | toast_bytes | table_bytes | total | index | toast | table

--size of biggest tables, hypertables, order by table name (useful if timescaleDB used)
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
      WHERE relkind = 'r' ) a) a
	  ORDER BY 3;
\o
\gx

--more primitive
\o /tmp/tables.hypertables.txt
SELECT table_schema, table_name, table_bytes, pg_size_pretty(total_bytes) AS total 
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
      WHERE relkind = 'r' ) a) a
	  ORDER BY 1,2;
\o

--oder by size
SELECT table_name, table_bytes, pg_size_pretty(total_bytes) AS total 
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
      WHERE relkind = 'r' ) a) a
	  ORDER BY 2 DESC;


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
      WHERE relkind = 'r' ) a) a
ORDER BY total_bytes DESC
LIMIT 8;







SELECT * FROM problem
WHERE clock >= EXTRACT(EPOCH FROM (TIMESTAMP '2020-03-03 00:00:00'))
AND clock < EXTRACT(EPOCH FROM (TIMESTAMP '2020-03-05 00:00:00'))
AND name LIKE ('Trigger name%'); 

DELETE FROM housekeeper WHERE housekeeperid IN (SELECT housekeeperid FROM housekeeper where tablename != 'events' LIMIT 1);



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




--autovacuum by dead tuples
\o /tmp/zabbix.autovacuum.n_dead_tup.txt
SELECT schemaname, relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_all_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;
\o

--autovacuum by table name
\o /tmp/zabbix.autovacuum.relname.txt
SELECT schemaname, relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_all_tables
WHERE n_dead_tup > 0
ORDER BY relname DESC;
\o




\o /tmp/zabbix.autovacuum.txt
SELECT schemaname, relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_all_tables
ORDER BY n_dead_tup DESC;
\o

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
--dbname=second \
--no-owner \
--format=c \
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
