
# https://dev.mysql.com/doc/refman/5.7/en/partitioning-management-range-list.html

create table aste like history;


CREATE TABLE `history` (
  `itemid` bigint unsigned NOT NULL,
  `clock` int NOT NULL DEFAULT '0',
  `value` double(16,4) NOT NULL DEFAULT '0.0000',
  `ns` int NOT NULL DEFAULT '0',
  KEY `history_1` (`itemid`,`clock`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin



insert ignore into aste select * from history where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 hour);


DROP INDEX history_1 ON aste;


CREATE TABLE `aste` (
  `itemid` bigint unsigned NOT NULL,
  `clock` int NOT NULL DEFAULT '0',
  `value` double(16,4) NOT NULL DEFAULT '0.0000',
  `ns` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin


CREATE INDEX aste_1 ON aste (itemid);


ALTER TABLE `aste` PARTITION BY LIST(itemid) (PARTITION i150448 VALUES IN (150448));

ALTER TABLE `aste` PARTITION BY LIST(itemid) (PARTITION i150447 VALUES IN (150447));

ALTER TABLE aste ADD PARTITION (PARTITION i150448 VALUES IN (150448));
ALTER TABLE aste ADD PARTITION (PARTITION i150446 VALUES IN (150446));

/* list all float items which are not template items */
SELECT itemid FROM items JOIN hosts ON (hosts.hostid=items.hostid) WHERE items.value_type=0 AND hosts.status IN (0,1);

/* integers */
SELECT itemid FROM items JOIN hosts ON (hosts.hostid=items.hostid) WHERE items.value_type=1 AND hosts.status IN (0,1);


mysql zabbix -sN -e 'SELECT itemid FROM items JOIN hosts ON (hosts.hostid=items.hostid) WHERE items.value_type=0 AND hosts.status IN (0,1);' \
| awk '{print "ALTER TABLE aste ADD PARTITION (PARTITION",$1,"VALUES IN (",$1,"));"}' \
| sed 's|(PARTITION |(PARTITION i|' \
| mysql --database=zabbix


show create table aste;


