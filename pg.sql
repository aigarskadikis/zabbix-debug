


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
--exclude-table-data-data=acknowledges \
--exclude-table-data=alerts \
--exclude-table-data=auditlog \
--exclude-table-data=auditlog_details \
--exclude-table-data=profiles \
--exclude-table-data=service_alarms \
--exclude-table-data=sessions \
--exclude-table-data=problem \
--exclude-table-data=event_recovery \
z42 > z42.sql







z42 > zabbix.pg.dump.compressed


--clean \
--blobs \



--verbose \

pg_dump --host=pg --data-only --exclude-table

--exclude-schema



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
