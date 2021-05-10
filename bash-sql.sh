#!/bin/bash

# zabbix 5.0, items changing the state:
mysql --batch -e "
SELECT FROM_UNIXTIME(events.clock), hosts.host, items.name, items.itemid,
CASE items.flags WHEN 0 THEN 'Normal item' WHEN 1 THEN 'Discovery rule' WHEN 4 THEN 'Auto From LLD' END AS flags,
CASE events.value WHEN 0 THEN 'ok' WHEN 1 THEN 'unsupported' END AS state,
events.name FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=3
AND events.object IN (4,5)
AND clock > UNIX_TIMESTAMP(NOW()-INTERVAL 5 DAY);
" zabbix > /tmp/items.flapping.state.ordered.by.clock.tsv

# zabbix 5.2
mysql --batch -e "
SELECT FROM_UNIXTIME(events.clock),
events.source,
events.object,
events.objectid,
events.value
FROM events
WHERE events.clock > UNIX_TIMESTAMP(NOW()-INTERVAL 100 HOUR)
AND events.object IN (4,5)
LIMIT 10
\G
" zabbix > /tmp/items.flapping.state.ordered.by.clock.tsv




# zabbix 5.0, items changing grouped by biggest damage:
mysql --batch -e "
SELECT COUNT(*), hosts.host, items.name, items.itemid, items.flags, events.value, events.name FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=3
AND events.object IN (4,5)
AND clock > UNIX_TIMESTAMP(NOW()-INTERVAL 5 DAY)
GROUP BY hosts.host, items.name, items.itemid, items.flags, events.value, events.name
ORDER BY COUNT(*) DESC
" zabbix > /tmp/items.flapping.state.count.tsv


# zabbix 5.0, items changing grouped by biggest damage. with host groups
mysql --batch -e "SET SESSION group_concat_max_len = 1000000;
SELECT COUNT(*), GROUP_CONCAT(hstgrp.name) AS hostGroups,
hosts.host, items.name, items.itemid,
CASE items.flags WHEN 0 THEN 'Normal item' WHEN 1 THEN 'Discovery rule' WHEN 4 THEN 'Auto From LLD' END AS flags,
events.name
FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hosts_groups ON (hosts_groups.hostid=hosts.hostid)
JOIN hstgrp ON (hosts_groups.groupid=hstgrp.groupid)
WHERE events.source=3
AND events.object IN (4,5)
AND events.value=1
AND clock > UNIX_TIMESTAMP(NOW()-INTERVAL 5 DAY)
GROUP BY hosts.host, items.name, items.itemid, items.flags, events.value, events.name
ORDER BY COUNT(*) DESC;
" zabbix > /tmp/items.flapping.by.count.tsv



