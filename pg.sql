


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
