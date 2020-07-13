
\o /tmp/functions.log
\df+
\o


SELECT EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 HOUR'));



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


select itemid, count(*) from history_log where clock>=EXTRACT(EPOCH FROM (timestamp '2020-07-07 05:00:00' - INTERVAL '1 HOUR')) group by itemid order by count(*) DESC LIMIT 20;
SELECT schemaname, relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_all_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;

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



, , <database>


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
  AND hosts.host=''
  LIMIT 1
\gx







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
