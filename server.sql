/* show all LLD rulles by execution time and discovery key. show the count of rules */
select delay,key_,count(*) from items where flags = 1 group by delay, key_ order by delay,count(*);

/* show all items from specific host */
select * from items where hostid in (select hostid from hosts where hostid in (select hostid from interface) and host like 'Zabbix server');
select name,key_ from items where hostid in (select hostid from hosts where hostid in (select hostid from interface) and host like 'Zabbix server');


/* select all items from specific host group */
select * from items where hostid in (select hostid from hosts_groups where groupid in (select groupid from groups where name like 'Zabbix servers'));

/* Select all items from all hosts */
select * from items where hostid in (select hostid from hosts where hostid in (select hostid from interface) and host like '%');

/* list the biggest log items in the database */
select itemid, hostid, name, lastlogsize from items where type=7 and value_type=2 and lastlogsize>1000000;

/* Show how much items are created/active/disabled per type */
select case when type=0 then 'Zabbix Agent' when type=1 then 'SNMPv1 agent' when type=2 then 'Zabbix trapper' when type=3 then 'simple check' when type=4 then 'SNMPv2 agent' when type=5 then 'Zabbix internal' when type=6 then 'SNMPv3 agent' when type=7 then 'Zabbix agent (active)' when type=8 then 'Zabbix aggregate' when type=9 then 'web item' when type=10 then 'external check' when type=11 then 'database monitor' when type=12 then 'IPMI agent' when type=13 then 'SSH agent' when type=14 then 'TELNET agent' when type=15 then 'calculated' when type=16 then 'JMX agent' when type=17 then 'SNMP trap' when type=18 then 'Dependent item' end as type,case when status=0 then 'ON' else 'OFF' end as status,count(*) from items group by type,status order by type, status desc;

/* show unsupported items, transfer hostid into human readable name */
SELECT h.host AS 'Host name',i.name AS 'ITEM name',i.key_ AS 'KEY' FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1';

/* detect database character set and collate */
SELECT @@character_set_database, @@collation_database\G;
/* check collation. this should report empty string */
SELECT * FROM information_schema.TABLES WHERE table_schema = 'zabbix' AND table_collation != 'utf8_bin';
/* check collation. this should report content */
SELECT * FROM information_schema.TABLES WHERE table_schema = 'zabbix' AND table_collation = 'utf8_bin';

/* list all events based on Zabbix trigger ID */
select * from events where source = 0 and objectid = <triggerid> order by clock DESC LIMIT 10;

/* show mysql variables */
show variables where Variable_name like 'innodb_file_per_table';

/* Show session count opened per each user */
SELECT sessions.userid,users.alias,count(*) FROM sessions INNER JOIN users ON sessions.userid = users.userid GROUP BY sessions.userid;



