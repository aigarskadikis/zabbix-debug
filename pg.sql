


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
