# zabbix-debug

## DB performance, performance with "history syncer"

Check backlog

```
zabbix_server -R diaginfo=historycache
```

### Test throughput from "zabbix-server" to DB.

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
iperf -c ip.address.of.db -p 10050 -t 10
```


