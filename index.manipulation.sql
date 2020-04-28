
# https://dev.mysql.com/doc/refman/5.7/en/partitioning-management-range-list.html


/* partitioning by itemid per float table. kickstart script */
mysql zabbix -sN -e 'create table history_new like history; DROP INDEX history_1 ON history_new;'
mysql zabbix -sN -e 'SELECT itemid,itemid FROM items JOIN hosts ON (hosts.hostid=items.hostid) WHERE items.value_type=0 AND hosts.status IN (0,1);' | \
sed 's|^|PARTITION itemid_|;s|\t| VALUES IN (|;s|$|),|' | \
tr -cd "[:print:]" | \
sed 's|^|ALTER TABLE history_new PARTITION BY LIST(itemid) (|;s|.$|);|' > history_new.sql
cat history_new.sql | mysql zabbix


/* partitioning by itemid per integer table. kickstart script */
mysql zabbix -sN -e 'create table history_uint_new like history_uint; DROP INDEX history_uint_1 ON history_uint_new;'
mysql zabbix -sN -e 'SELECT itemid,itemid FROM items JOIN hosts ON (hosts.hostid=items.hostid) WHERE items.value_type=1 AND hosts.status IN (0,1);' | \
sed 's|^|PARTITION itemid_|;s|\t| VALUES IN (|;s|$|),|' | \
tr -cd "[:print:]" | \
sed 's|^|ALTER TABLE history_uint_new PARTITION BY LIST(itemid) (|;s|.$|);|' > history_uint_new.sql
cat history_uint_new.sql | mysql zabbix
/* each blank partition will take 128kb */


insert ignore into aste select * from history where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 hour);


[mysqld]
group_concat_max_len = 1000000

SET SESSION group_concat_max_len = 1000000;


/* float values */
SELECT DISTINCT hosts.host,
                GROUP_CONCAT(items.itemid) AS 'float'
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.value_type=0
  AND hosts.status IN (0,1)
GROUP BY items.hostid
\G

/* integers */
SELECT DISTINCT hosts.host,
                GROUP_CONCAT(items.itemid) AS 'integers'
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.value_type=1
  AND hosts.status IN (0,1)
GROUP BY items.hostid
\G

/* character */
SELECT DISTINCT hosts.host,
                GROUP_CONCAT(items.itemid) AS 'character'
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.value_type=2
  AND hosts.status IN (0,1)
GROUP BY items.hostid
\G



SELECT DISTINCT hosts.hostid,
                GROUP_CONCAT(items.itemid) AS 'integers'
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.value_type=1
  AND hosts.status IN (0,1)
GROUP BY items.hostid
\G




SELECT DISTINCT hosts.hostid AS "PARTITION",GROUP_CONCAT(items.itemid) AS "VALUES IN (" FROM items JOIN hosts ON (hosts.hostid=items.hostid) WHERE items.value_type=1 AND hosts.status IN (0,1) GROUP BY items.hostid\G


mysql zabbix -sN -e 'SELECT DISTINCT hosts.hostid AS "PARTITION",GROUP_CONCAT(items.itemid) AS "VALUES IN (" FROM items JOIN hosts ON (hosts.hostid=items.hostid) WHERE items.value_type=1 AND hosts.status IN (0,1) GROUP BY items.hostid\G'

/* create new float table with partitioning by hostid */
mysql zabbix -sN -e 'create table history_new like history; DROP INDEX history_1 ON history_new;'

/* calculate partitions to be made at first launch */
mysql zabbix -sN -e 'SET SESSION group_concat_max_len = 1000000;
SELECT DISTINCT hosts.hostid,
GROUP_CONCAT(items.itemid)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.value_type=0
AND hosts.status IN (0,1)
GROUP BY items.hostid;' | \
sed 's|^|PARTITION hostid_|;s|\t| VALUES IN (|;s|$|),|' | \
tr -cd "[:print:]" | \
sed 's|^|ALTER TABLE history_new PARTITION BY LIST(itemid) (|;s|.$|);|' > history.new.sql
/* ERROR 3507 (HY000) at line 1: Failed to update table_partition_values dictionary object */
/* https://bugs.mysql.com/bug.php?id=93587 */






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


