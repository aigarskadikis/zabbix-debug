# Troubleshoot performance problems of Zabbix application layer

## DB performance, performance with "history syncer"

Check backlog

```
zabbix_server -R diaginfo=historycache
```

### See if disk is bottleneck

```
iostat -x -t 1
```

In output, ensure the last column is not having 100% utilization for the mount point which is attached to DB server.

Common mistakes: adding more than one block device into volume group will always cause some degradation (opposite of best practice, how not to do)

### Which process consumes disk writes/reads. Fancy method

```
dnf install iostat
iostat
```

In case of PostgreSQL, ensure no auto vaccuum sits too long

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


```
dnf install mtr
mtr ip.of.db.server
```

There should be no packet loss.

If latency is less than 5ms, that is good



### Test throughput from "zabbix-server" to DB (MySQL/PostgreSQL).

On DB server stop agent

```
systemctl stop zabbix-agent
```

Set on listening state

```
iperf3 -s -p 10050
```

From "zabbix-server", push data:

```
iperf3 -c ip.address.of.db -p 10050 -t 10
```


### TimescaleDB

## There should be not too many hypertables

Ideally one table should contain less than 99 references to hypertables. Bacause selecting data from table need to look on index every time. An index too wide will cost extra CPU time to locate and print data.

## Hypertable too big

If a hypertable gets bigger than 10GB, it will increase the risk for a vaacuum process to lock the table, therefore block the application layer.


