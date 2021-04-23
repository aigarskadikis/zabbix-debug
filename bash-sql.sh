#!/bin/bash

# zabbix 5.0, items changing the state:
mysql -s --batch -e "
SELECT events.clock, hosts.host, items.name, items.itemid, items.flags, events.value, events.name FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=3
AND events.object IN (4,5)
AND events.value=1
AND clock > UNIX_TIMESTAMP(NOW()-INTERVAL 2 DAY)
" zabbix > /tmp/items.flapping.state.tsv