# Improve performance of Zabbix

## DB performance, performance with "history syncer"

Check backlog

```yaml
zabbix_server -R diaginfo=historycache
```

Watch

```yaml
watch -n1 'zabbix_server -R diaginfo=historycache | grep -A1 "history cache diagnostic information"'
```

The "values" reported indicate how many values are stored in RAM and not yet synhronized with database


### Disk performance

https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance-linux

```yaml
iostat -x -t 1
```

In output, ensure the last column is not having 100% utilization for the mount point which is attached to DB server.

Popular mistakes: adding more than one block device into volume group will always cause some degradation (opposite of best practice). Not a big problem if DB server has more than 99GB of memory.

### Which process consumes disk writes/reads. Fancy method

```yaml
dnf install iostat
iostat
```

In case of PostgreSQL, ensure no auto vacuum sits too long

### Connection to DB via IP/DNS

Check if IP or DNS used to reach database:

```
grep ^DB /etc/zabbix/zabbix_server.conf
```

See if more than one DNS server is used

```
cat /etc/resolv.conf
```

### Latency of DB server

```yaml
dnf install mtr
mtr ip.of.db.server
```

There should be no packet loss.

If latency is less than 5ms, that is good


### Test throughput from "zabbix-server" to DB (MySQL/PostgreSQL).

On DB server stop agent

```yaml
systemctl stop zabbix-agent
```

Set on listening state

```yaml
iperf3 -s -p 10050
```

From "zabbix-server", push data:

```yaml
iperf3 -c ip.address.of.db -p 10050 -t 10
```

### Any DB server

## Size of sessions table:

```sql
SELECT COUNT(*) FROM sessions;
```

Idealy the number should be less than 9999, because Zabbix GUI on every navigation click needs to iterate through ALL sessions just to validate if your session is active.

## Housekeeper

To see what kind of records the application layer deletes

```yaml
cd /var/log/zabbix && grep housekeeper zabbix_server.log
```

```sql
SELECT COUNT(*) FROM housekeeper;
```

The table holds the tasks the housekeeper needs to do. Ideally the output should be less than 99999.

Truncating a table is a workaround. If it's done, the relation database will now have orphaned data.


### PostgreSQL

## Size of tables (will count hypertables as a whole)

```sql
SELECT table_name, pg_size_pretty(pg_total_relation_size(quote_ident(table_name))), pg_total_relation_size(quote_ident(table_name))
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY 3 DESC;
```

This will print in human readable form

## rows per table

```sql
SELECT relname, n_live_tup, n_dead_tup,last_autovacuum FROM pg_stat_all_tables WHERE schemaname='public' ORDER BY 1;
```

### TimescaleDB

## Rows per hypertables, empty rows

```sql
SELECT schemaname,relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_all_tables
WHERE schemaname IN ('public','_timescaledb_internal') ORDER BY 1,2;
```

## Rows per tables/hypertables. Empty rows (dead tuples) per tables. Status of auto vacuum

```sql
SELECT schemaname, relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_all_tables WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;
```

## There should be not too many hypertables

Ideally one table should contain less than 99 references to hypertables. Bacause selecting data from table need to look on index every time. An index too wide will cost extra CPU time to locate and print data.

Count of hypertables

```sql
SELECT hypertable_name,
to_timestamp(range_start_integer) AS range_start,
to_timestamp(range_end_integer) AS range_end,
chunk_name,
(range_end_integer-range_start_integer) AS size
FROM timescaledb_information.chunks
WHERE hypertable_name IN ('history_log')
ORDER BY 2;
```

## Hypertable too big

If a hypertable gets bigger than 10GB, it will increase the risk for a vaacuum process to lock the table, therefore block the application layer.

Most recent hypertables

```sql
SELECT hypertable_name,
to_timestamp(range_start_integer) AS range_start,
to_timestamp(range_end_integer) AS range_end,
chunk_name,
(range_end_integer-range_start_integer) AS size
FROM timescaledb_information.chunks
WHERE hypertable_name IN ('history','history_uint','history_str','history_log','history_text','history_bin','trends_uint','trends')
AND range_start_integer > EXTRACT(EPOCH FROM NOW() - INTERVAL '24 hours')
ORDER BY 1,2;
```

To change size to 2h hypertables in the future:

```sql
SELECT set_chunk_time_interval('history', 28800);
SELECT set_chunk_time_interval('history_uint', 28800);
SELECT set_chunk_time_interval('history_str', 28800);
SELECT set_chunk_time_interval('history_log', 28800);
SELECT set_chunk_time_interval('history_text', 28800);
```

To calculate how many seconds are in 8 hours can use command from bash

```sh
echo $((3600*8))
```


## The index of hypertables must fit into memory

See the size of tables

### Appendix

## Kill backend

If history cache is full, history syncers and slow and restoring real time monitoring is more important than complete graphs, then

```sh
kill -9 $(pidof zabbix_server)
pidof zabbix_server
```

## Manually drop hypertables (TimescaleDB 2.80)

Drop hypertables (raw data) older than 90 days

```sql
SELECT drop_chunks(relation=>'history_log', older_than=>extract(epoch from now()::DATE - 90)::integer);
SELECT drop_chunks(relation=>'history_str', older_than=>extract(epoch from now()::DATE - 90)::integer); 
SELECT drop_chunks(relation=>'history_text', older_than=>extract(epoch from now()::DATE - 90)::integer); 
SELECT drop_chunks(relation=>'history_uint', older_than=>extract(epoch from now()::DATE - 90)::integer); 
SELECT drop_chunks(relation=>'history_bin', older_than=>extract(epoch from now()::DATE - 90)::integer); 
SELECT drop_chunks(relation=>'history', older_than=>extract(epoch from now()::DATE - 90)::integer);
```

Drop trends older than 1 year

```sql
SELECT drop_chunks(relation=>'trends_uint', older_than=>extract(epoch from now()::DATE - 365)::integer);
SELECT drop_chunks(relation=>'trends', older_than=>extract(epoch from now()::DATE - 365)::integer);
```
