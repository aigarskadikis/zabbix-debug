
--MySQL engine 5.6 and even 5.7 are not so good as MySQL 8.0/Percona 8.0 THEN 'also InnoDB cluster from MySQL CE 8.0 has good performance and reliability (InnoDB cluster with MySQL router).
--Kernel for the CentOS 7 is quite old and storage subsystem (multi queue/nvme THEN 'etc) THEN 'file system code and other critical internal design is much better in 4.X or 5.X kernels provided by fresh operation systems.
--Galera can be used in parallel with GTID based replication THEN 'so after creation of the second cluster THEN 'you can keep data in sync before final migration using GTID async replication between clusters. This will force you to use the same software version on the initial THEN 'but allow you seamless migration.



--When Zabbix ignores actual value of a trigger and do not add new OK event (with value = 0). That means that Zabbix server actually knows that trigger was processed and has OK status. But if DB contains different information, such behaviour can be because of a few reasons:
--1. DB SQL insert errors (related to events, problem) tables;
--2. Internal Zabbix error when Zabbix switched trigger to OK status, but did not add new event. For example because of internal exceptions;
--3. DB issue when you have DB High-Availability and inconsistent data in DB after switch failover.



SHOW GLOBAL VARIABLES LIKE '%packet%';
SHOW GLOBAL VARIABLES LIKE '%max%';


--Zabbix 3.0. Hosts that are not assigned to Linux servers or Windows servers group
SELECT DISTINCT hosts.host
FROM hosts_groups
JOIN hosts ON (hosts.hostid=hosts_groups.hostid)
WHERE hosts.status=0
AND hosts.hostid NOT IN (
SELECT hostid FROM hosts_groups WHERE groupid IN (2,8)
);


--prints clean hosts which is either in one group or in another
SELECT hosts_groups.hostid,COUNT(*)
FROM hosts_groups
JOIN hosts ON (hosts.hostid=hosts_groups.hostid)
WHERE hosts_groups.groupid IN (2,8)
GROUP BY hosts_groups.hostid
HAVING COUNT(*) = 1;

--show all clean hosts
SELECT hosts.host FROM hosts_groups
JOIN hosts ON (hosts.hostid=hosts_groups.hostid)
WHERE hosts.hostid IN (
SELECT hosts_groups.hostid
FROM hosts_groups
JOIN hosts ON (hosts.hostid=hosts_groups.hostid)
WHERE hosts.status=0
GROUP BY hosts_groups.hostid
HAVING COUNT(*) = 1
)
AND hosts_groups.groupid IN (2,8);



--show all item types on the host objects which is montitored
SELECT items.type,COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
GROUP BY items.type
ORDER BY items.type ASC;



--items overloading the system
SELECT COUNT(*),itemid FROM history_text WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 1 HOUR) GROUP BY itemid ORDER BY COUNT(*) DESC LIMIT 10;

SELECT COUNT(*),itemid FROM history_str WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 1 HOUR) GROUP BY itemid ORDER BY COUNT(*) DESC LIMIT 10;

SELECT COUNT(*),itemid FROM history_log WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 1 HOUR) GROUP BY itemid ORDER BY COUNT(*) DESC LIMIT 10;

SELECT COUNT(*),itemid FROM history_uint WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 1 HOUR) GROUP BY itemid ORDER BY COUNT(*) DESC LIMIT 10;

SELECT COUNT(*),itemid FROM history WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 1 HOUR) GROUP BY itemid ORDER BY COUNT(*) DESC LIMIT 10;



SELECT itemid,COUNT(*),MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_log WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 1 HOUR) GROUP BY itemid ORDER BY AVG(LENGTH(value)) DESC LIMIT 10;

SELECT itemid,COUNT(*),MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_text WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 1 HOUR) GROUP BY itemid ORDER BY AVG(LENGTH(value)) DESC LIMIT 10;


--what are those items
SELECT items.name,
items.key_,
items.type,
hosts.host,
hosts.hostid
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.itemid IN (350099,334718);





0, GROUP_GUI_ACCESS_SYSTEM - Use default authorization method set for Zabbix GUI
1, GROUP_GUI_ACCESS_INTERNAL - User of this group will be authorised against Zabbix database regardless of system settings
2, GROUP_GUI_ACCESS_LDAP - Users of this group will be authorized against LDAP
3, GROUP_GUI_ACCESS_DISABLED - Users of this group do not have access to Zabbix GUI


--determine if user is using LDAP, Internal auth
SELECT users.userid,users.alias,usrgrp.usrgrpid,usrgrp.gui_access
FROM users
JOIN users_groups ON (users_groups.userid=users.userid)
JOIN usrgrp ON (usrgrp.usrgrpid=users_groups.usrgrpid);
--0, GROUP_GUI_ACCESS_SYSTEM - Use default authorization method set for Zabbix GUI
--1, GROUP_GUI_ACCESS_INTERNAL - User of this group will be authorised against Zabbix database regardless of system settings
--2, GROUP_GUI_ACCESS_LDAP - Users of this group will be authorized against LDAP
--3, GROUP_GUI_ACCESS_DISABLED - Users of this group do not have access to Zabbix GUI


WHERE LOWER(users.alias)=LOWER('admin')
;



SELECT FROM_UNIXTIME(trends_uint.clock) AS clock, hosts.host, items.name, trends_uint.num,trends_uint.value_min, trends_uint.value_avg, trends_uint.value_max
FROM trends_uint
JOIN items ON (items.itemid=trends_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE trends_uint.clock > UNIX_TIMESTAMP(NOW() - INTERVAL 110 MINUTE)
ORDER BY trends_uint.clock DESC
LIMIT 20\G



--Oracle
SELECT DISTINCT h.host FROM hosts h INNER JOIN items i ON h.hostid = i.hostid INNER JOIN functions f ON i.itemid = f.itemid INNER JOIN triggers t ON f.triggerid = t.triggerid WHERE h.status = 3 and t.description like '%Master%';




SELECT DISTINCT(itemid),value FROM history_uint
WHERE itemid IN (
SELECT i.itemid FROM items i, hosts h
WHERE i.hostid=h.hostid
AND i.name like '%Operational%'
AND h.status=0
AND i.status=0
)
AND clock > UNIX_TIMESTAMP(NOW() - INTERVAL 1 MINUTE);




SELECT FROM_UNIXTIME(clock),value FROM history_uint
WHERE itemid=549479 AND clock IN (
SELECT max(clock) FROM history_uint WHERE itemid=549479
);



SELECT FROM_UNIXTIME(clock),value FROM history_uint
WHERE itemid IN (
SELECT i.itemid FROM items i, hosts h
WHERE i.hostid=h.hostid
AND i.name like '%Operational%'
AND h.status=0
AND i.status=0
)
AND clock IN (
SELECT max(clock) FROM history_uint WHERE itemid=549479
);



SELECT i.itemid FROM items i, hosts h
WHERE i.hostid=h.hostid
AND i.name like '%Operational%'
AND h.status=0
AND i.status=0;



SELECT
events.clock,
events.name,
events.value
FROM events 
JOIN triggers ON (triggers.triggerid=events.objectid)
WHERE source IN (0,3) AND object = 0 AND triggers.flags IN (0, 4);



select * from triggers where triggerid=748820\G

--identify trigger overrides between nested VS parent templates. Between host and template
select distinct(triggers.triggerid) as nested,asparent.triggerid as parent,hosts.host as nestedname,hosts2.host as parentname,triggers.description, asparent.priority as parentpriority, triggers.priority as nestedpriority
from triggers
join triggers asparent on (asparent.triggerid=triggers.templateid)
join functions on (triggers.triggerid=functions.triggerid)
join items on (functions.itemid=items.itemid)
join hosts on (items.hostid=hosts.hostid)
join functions functions2 on (asparent.triggerid=functions2.triggerid)
join items items2 on (functions2.itemid=items2.itemid)
join hosts hosts2 on (items2.hostid=hosts2.hostid)
where triggers.templateid is not null
and asparent.priority<>triggers.priority;

SELECT triggers.description,triggers.triggerid AS nested,asParent.triggerid AS parent,hosts.host AS nestedName,hosts2.host AS parentName
FROM triggers
JOIN triggers asParent ON (asParent.triggerid=triggers.templateid)
JOIN functions ON (triggers.triggerid=functions.triggerid)
JOIN items ON (functions.itemid=items.itemid)
JOIN hosts ON (items.hostid=hosts.hostid)
JOIN functions functions2 ON (asParent.triggerid=functions2.triggerid)
JOIN items items2 ON (functions2.itemid=items2.itemid)
JOIN hosts hosts2 ON (items2.hostid=hosts2.hostid)
WHERE triggers.templateid IS NOT NULL
AND asParent.priority<triggers.priority;


SELECT triggers.description,triggers.triggerid AS nested,asParent.triggerid AS parent,hosts.host AS nestedName,hosts2.host AS parentName
FROM triggers
JOIN triggers asParent ON (asParent.triggerid=triggers.templateid)
JOIN functions ON (triggers.triggerid=functions.triggerid)
JOIN items ON (functions.itemid=items.itemid)
JOIN hosts ON (items.hostid=hosts.hostid)
JOIN functions functions2 ON (asParent.triggerid=functions2.triggerid)
JOIN items items2 ON (functions2.itemid=items2.itemid)
JOIN hosts hosts2 ON (items2.hostid=hosts2.hostid)
WHERE triggers.templateid IS NOT NULL
AND asParent.priority>triggers.priority;


triggers.triggerid=748820


--unsupported items. 5.0
SELECT hosts.host,items.key_,item_rtdata.error
FROM item_rtdata
JOIN items ON (items.itemid=item_rtdata.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(item_rtdata.error)>0
;


--unsupported java items. 5.0
SELECT hosts.host,items.key_,item_rtdata.error
FROM item_rtdata
JOIN items ON (items.itemid=item_rtdata.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(item_rtdata.error)>0
AND items.type=16
;


SELECT COUNT(*),hosts.host
FROM item_rtdata
JOIN items ON (items.itemid=item_rtdata.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(item_rtdata.error)>0
AND items.type=16
GROUP BY hosts.host
ORDER BY COUNT(*) DESC
LIMIT 20;



SELECT * FROM items WHERE itemid=346879\G

-- item.flags
-- 0x00, ZBX_FLAG_DISCOVERY_NORMAL - Normal item
-- 0x01, ZBX_FLAG_DISCOVERY - Discovery rule
-- 0x02, ZBX_FLAG_DISCOVERY_PROTOTYPE - Item prototype
-- 0x04, ZBX_FLAG_DISCOVERY_CREATED - Auto-created item

-- if multiple hosts with a same ip address is behind proxy
SELECT proxy.host AS Proxy,hosts.host,hosts.name
FROM interface
JOIN hosts ON (interface.hostid=hosts.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE interface.ip='192.168.88.1';



SELECT hosts.hostid,items.itemid,items.master_itemid,items.flags,l2.key_
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN items l2 ON (items.master_itemid=l2.itemid)
WHERE hosts.hostid=12795
AND items.flags=4
AND items.master_itemid IS NOT NULL;

--which item gives a liffting on preprocessor
SELECT COUNT(*),hosts.hostid,items.master_itemid,items.flags,l2.key_,l2.delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN items l2 ON (items.master_itemid=l2.itemid)
WHERE items.flags=4
AND items.master_itemid IS NOT NULL
GROUP BY 2,3,4,5
HAVING COUNT(*) > 1
ORDER BY COUNT(*) ASC;



SELECT COUNT(*),hosts.hostid,items.master_itemid,items.flags,l2.key_,l2.delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN items l2 ON (items.master_itemid=l2.itemid)
WHERE items.flags=4
AND items.master_itemid IS NOT NULL
GROUP BY 2,3,4,5
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 20\G



SELECT COUNT(*),hosts.host,items.master_itemid,items.name
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.type=18
AND items.master_itemid > 0
AND hosts.status IN (0,1)
GROUP BY 2,3,4
HAVING COUNT(*) > 1
\G



--list the problems that should have been closed
select p.eventid,p.objectid,p.name,h.host from problem p 
left join triggers t on p.objectid=t.triggerid
left join functions f on t.triggerid=f.triggerid
left join items i on f.itemid=i.itemid
left join hosts h on i.hostid=h.hostid
where p.r_eventid is null and 
p.source=0 and
t.value=0;



--

SELECT COUNT(*),functions.itemid
FROM functions
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (items.hostid=hosts.hostid)
WHERE hosts.status=0 AND items.status=0
GROUP BY functions.itemid
ORDER BY COUNT(*) DESC
LIMIT 30
;


SELECT COUNT(*),functions.itemid
FROM functions
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (items.hostid=hosts.hostid)
WHERE hosts.status=0 AND items.status=0
AND functions.name='nodata'
GROUP BY functions.itemid
ORDER BY COUNT(*) DESC
LIMIT 30
;




SELECT macro,value FROM hostmacro WHERE macro like '%PERIOD%';



--check data time settings on particular machine. query failed: [1526] Table has no partition for value
SELECT proxy.host AS Proxy,hosts.host,hosts.name
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE items.itemid=315907;


--how many active problems:
SELECT COUNT(*),source,object,severity FROM problem GROUP BY 2,3,4 ORDER BY severity;


SELECT proxy.host AS Proxy,CASE items.type WHEN 0 THEN 'Passive' WHEN 7 THEN 'Active' END AS type, COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE items.type IN (0,7)
GROUP BY 1,2;



--4.0


UPDATE usrgrp SET users_status=0 WHERE usrgrpid IN (SELECT usrgrpid FROM users_groups WHERE userid=6);





users_status


--check SNMPv2 credential missconfiguration. Zabbix 4.4 and before.

-- host-wise the metrics
SELECT COUNT(*), hosts.host
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (items.hostid=hosts.hostid)
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 1 MINUTE)
GROUP BY hosts.host ORDER BY 1 ASC;


--enabled trigger functions
SELECT COUNT(*),functions.name,functions.parameter FROM functions
JOIN triggers ON (triggers.triggerid=functions.triggerid) JOIN items ON (items.itemid=functions.itemid) JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.status=0 AND triggers.status=0 AND hosts.status=0 GROUP BY 2,3 ORDER BY functions.name;


--trigger internal messages
SELECT COUNT(*),objectid,name FROM events
WHERE source=3 AND object=0 AND LENGTH(name)>0
GROUP BY objectid,name
ORDER BY COUNT(*) ASC
\G

--item internal messages
SELECT COUNT(*),objectid,name FROM events
WHERE source=3 AND object=4 AND LENGTH(name)>0
GROUP BY objectid,name
ORDER BY COUNT(*) ASC
\G


to_char(date(to_timestamp(clock)),'YYYY-MM-DD'),


SELECT TO_CHAR(DATE(TO_TIMESTAMP(clock)),'YYYY-MM-DD HH:mm'),name FROM events WHERE source=3 AND object=4 AND LENGTH(name)>0 AND objectid=156451 ORDER BY clock ASC;


SELECT FROM_UNIXTIME(clock),name FROM events
WHERE source=3 AND object=0 AND LENGTH(name)>0
AND objectid=12345
ORDER BY clock DESC
LIMIT 20\G



--item messages
SELECT FROM_UNIXTIME(clock),name FROM events
WHERE source=3 AND object=4 AND LENGTH(name)>0
GROUP BY
ORDER BY clock DESC
LIMIT 20\G


--calculated items
SELECT COUNT(*),items.params
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.type=15
AND hosts.status=0
AND items.status=0
GROUP BY items.params;



--data collection. Show information about enabled hosts, enabled items. Zabbix 5.0
SELECT
CASE items.type
WHEN 0 THEN 'Zabbix agent'
WHEN 2 THEN 'Zabbix trapper'
WHEN 3 THEN 'Simple check'
WHEN 5 THEN 'Zabbix internal'
WHEN 7 THEN 'Zabbix agent (active) check'
WHEN 8 THEN 'Aggregate'
WHEN 9 THEN 'HTTP test (web monitoring scenario step)'
WHEN 10 THEN 'External check'
WHEN 11 THEN 'Database monitor'
WHEN 12 THEN 'IPMI agent'
WHEN 13 THEN 'SSH agent'
WHEN 14 THEN 'TELNET agent'
WHEN 15 THEN 'Calculated'
WHEN 16 THEN 'JMX agent'
WHEN 17 THEN 'SNMP trap'
WHEN 18 THEN 'Dependent item'
WHEN 19 THEN 'HTTP agent'
WHEN 20 THEN 'SNMP agent'
END as type,COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.status=0
GROUP BY type
ORDER BY COUNT(*) DESC;


--Zabbix 5.0. List all maintenance windows
select m.name,case when m.maintenance_type=1 then 'With data collection' else 'No data collection' end Type,FROM_UNIXTIME(m.active_since) Active_since,FROM_UNIXTIME(m.active_till) Active_till,case when m.active_till > m.active_since then 'Active' else 'Expired' end State, m.description, GROUP_CONCAT(DISTINCT hg.name) Hostgroups, count(distinct hg.name) Hostgroups_count, GROUP_CONCAT(DISTINCT h.name) Hosts, count(distinct h.name) Hosts_count
FROM maintenances m
LEFT JOIN maintenances_groups mg on m.maintenanceid=mg.maintenanceid
LEFT JOIN maintenances_hosts mh on m.maintenanceid=mh.maintenanceid
LEFT JOIN hstgrp hg on mg.groupid=hg.groupid
LEFT JOIN hosts h on mh.hostid=h.hostid
GROUP BY 1,2,3,4,5,6;



SELECT maintenances.name,
CASE
WHEN maintenances.maintenance_type=1 THEN 'With data collection'
ELSE 'No data collection'
END TYPE,
FROM_UNIXTIME(maintenances.active_since) Active_since,
FROM_UNIXTIME(maintenances.active_till) Active_till,
CASE
WHEN maintenances.active_till > maintenances.active_since THEN 'Active'
ELSE 'Expired'
END State,
maintenances.description,
GROUP_CONCAT(DISTINCT hstgrp.name) Hostgroups,
GROUP_CONCAT(DISTINCT hosts.name) Hosts
FROM maintenances
JOIN maintenances_groups ON (maintenances_groups.maintenanceid=maintenances.maintenanceid)
JOIN hstgrp ON (hstgrp.groupid=maintenances_groups.groupid)
JOIN maintenances_hosts ON (maintenances_hosts.maintenanceid=maintenances.maintenanceid)
JOIN hosts ON (hosts.hostid=maintenances_hosts.hostid)
GROUP BY 1,2,3,4,5,6;



--postgres, mysql, Zabbix 5.0, detect incorrect trigger arguments
SELECT COUNT(*),
functions.name,
functions.parameter
FROM functions
JOIN triggers ON (triggers.triggerid=functions.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.status=0
AND triggers.status=0
AND hosts.status=0
GROUP BY 2,3
ORDER BY functions.name;

SELECT hosts.host,
items.name,
functions.name,
functions.parameter
FROM functions
JOIN triggers ON (triggers.triggerid=functions.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.status=0
AND triggers.status=0
AND hosts.status=0





--trigger top 100
SELECT e.objectid, t.description, COUNT(DISTINCT e.eventid) AS cnt_event FROM triggers t,events e
WHERE t.triggerid=e.objectid AND e.source=0 AND e.object=0 AND t.flags IN (0,4)
GROUP BY e.objectid ORDER BY cnt_event DESC LIMIT 100;

--trigger top 100 with host groups. Zabbix 5.0
SELECT hstgrp.name, events.objectid, triggers.description, COUNT(DISTINCT events.eventid) AS cnt_event FROM triggers
JOIN events ON (triggers.triggerid=events.objectid)
LEFT JOIN functions on triggers.triggerid=functions.triggerid
LEFT JOIN items on functions.itemid=items.itemid
LEFT JOIN hosts on items.hostid=hosts.hostid
LEFT JOIN hosts_groups on hosts.hostid=hosts_groups.hostid
LEFT JOIN hstgrp on hosts_groups.groupid=hstgrp.groupid
WHERE events.source=0 AND events.object=0 AND triggers.flags IN (0,4)
GROUP BY 1,2,3
ORDER BY cnt_event DESC
LIMIT 100;


SELECT events.objectid, triggers.description, COUNT(DISTINCT events.eventid) AS cnt_event FROM triggers
JOIN events ON (triggers.triggerid=events.objectid)
WHERE events.source=0 AND events.object=0 AND triggers.flags IN (0,4)
GROUP BY 1,2
ORDER BY cnt_event DESC
LIMIT 100;


--users online, mysql
SELECT COUNT(*),users.userid FROM users JOIN sessions ON (users.userid = sessions.userid) WHERE sessions.status=0 AND sessions.lastaccess > UNIX_TIMESTAMP(NOW()-INTERVAL 1 HOUR) GROUP BY users.userid;
SELECT COUNT(*),users.alias FROM users JOIN sessions ON (users.userid = sessions.userid) WHERE sessions.status=0 AND sessions.lastaccess > UNIX_TIMESTAMP(NOW()-INTERVAL 1 HOUR) GROUP BY users.alias;
--postgres
SELECT COUNT(*),users.userid FROM users JOIN sessions ON (users.userid = sessions.userid) WHERE sessions.status=0 AND sessions.lastaccess > EXTRACT(epoch FROM NOW()-INTERVAL '1 HOUR') GROUP BY users.userid;
SELECT COUNT(*),users.alias FROM users JOIN sessions ON (users.userid = sessions.userid) WHERE sessions.status=0 AND sessions.lastaccess > EXTRACT(epoch FROM NOW()-INTERVAL '1 HOUR') GROUP BY users.alias;



--list maintenance periods, mainenance name and ID. Zabbix 5.0
SELECT
maintenances.name,
maintenances.maintenanceid,
timeperiods.timeperiodid,
timeperiods.timeperiod_type,
timeperiods.every,
timeperiods.month,
timeperiods.dayofweek,
timeperiods.day,
timeperiods.start_time,
timeperiods.period,
timeperiods.start_date
FROM timeperiods
JOIN maintenances_windows ON (maintenances_windows.timeperiodid=timeperiods.timeperiodid)
JOIN maintenances ON (maintenances.maintenanceid=maintenances_windows.maintenanceid)
\G


SELECT * FROM maintenance_tag WHERE maintenanceid='';
SELECT * FROM maintenances_groups WHERE maintenanceid='';
SELECT * FROM maintenances_hosts WHERE maintenanceid='';
SELECT * maintenances_windows WHERE maintenanceid='';


--internal events, discovery events, auto-registration events, trigger events:
SELECT COUNT(*),object,source,objectid FROM events
WHERE clock >= UNIX_TIMESTAMP("2021-08-11 17:00:00")
AND clock < UNIX_TIMESTAMP("2021-08-11 18:00:00")
GROUP BY object,source,objectid
ORDER BY COUNT(*) DESC
LIMIT 10;

--only trigger events:
SELECT COUNT(*),hosts.host,triggers.description,events.objectid FROM events
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.clock >= UNIX_TIMESTAMP("2021-08-11 17:00:00")
AND events.clock < UNIX_TIMESTAMP("2021-08-11 18:00:00")
AND events.source=0 AND events.object=0
GROUP BY hosts.host,triggers.description,events.objectid
ORDER BY COUNT(*) DESC
LIMIT 10;



UPDATE usrgrp SET gui_access=1 WHERE usrgrpid IN (
SELECT usrgrpid FROM users_groups WHERE userid IN (
SELECT userid FROM users WHERE alias='Admin'
)
)


--convert all LDAP groups to use internal
UPDATE usrgrp SET gui_access=1 WHERE gui_access=2;

--force default authorization to be internal
UPDATE config SET authentication_type=0;

--unlock all acounts
UPDATE users SET attempt_clock=0 WHERE attempt_clock>0;


--list of alerts in progress and sent. Zabbix 5.0
SELECT COUNT(*),
alerts.actionid,
CASE alerts.status
WHEN 0 THEN 'NOT_SENT'
WHEN 1 THEN 'SENT'
WHEN 2 THEN 'FAILED'
WHEN 3 THEN 'NEW'
END AS status
FROM alerts
JOIN events ON (events.eventid=alerts.eventid)
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source IN (0,3) AND events.object = 0
GROUP BY alerts.actionid,alerts.status
ORDER BY alerts.status,COUNT(*);




SELECT hosts.host,
triggers.triggerid,
alerts.actionid,
CASE alerts.status
WHEN 0 THEN 'NOT_SENT'
WHEN 1 THEN 'SENT'
WHEN 2 THEN 'FAILED'
WHEN 3 THEN 'NEW'
END AS status
FROM alerts
JOIN events ON (events.eventid=alerts.eventid)
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source IN (0,3) AND events.object = 0
;




--analyze live proxy data
SELECT hosts.host,
items.key_,
items.flags,
SUM(LENGTH(value))
FROM proxy_history
JOIN items ON (items.itemid = proxy_history.itemid)
JOIN hosts ON (hosts.hostid = items.hostid)
GROUP BY 1,2,3
ORDER BY 4 DESC LIMIT 20; 


--select active and passive proxies
SELECT host,hostid FROM hosts WHERE status IN (5,6);


SET SESSION SQL_LOG_BIN=0; DELETE FROM events WHERE source IN (1,2,3) AND clock < UNIX_TIMESTAMP(NOW() - INTERVAL 7 DAY) LIMIT 10;

SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 00:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 01:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 01:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 02:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 02:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 03:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 03:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 04:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 04:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 05:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 05:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 06:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 06:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 07:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 07:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 08:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 08:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 09:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 09:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 10:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 10:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 11:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 11:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 12:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 12:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 13:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 13:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 14:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 14:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 15:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 15:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 16:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 16:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 17:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 17:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 18:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 18:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 19:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 19:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 20:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 20:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 21:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 21:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 22:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 22:00:00") AND clock < UNIX_TIMESTAMP("2021-08-11 23:00:00");
SELECT COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2021-08-11 23:00:00") AND clock < UNIX_TIMESTAMP("2021-08-12 00:00:00");







SELECT COUNT(*) FROM alerts WHERE clock >= UNIX_TIMESTAMP("2021-06-28 00:00:00") AND clock < UNIX_TIMESTAMP("2021-06-29 00:00:00");
SELECT COUNT(*) FROM alerts WHERE clock >= UNIX_TIMESTAMP("2021-06-29 00:00:00") AND clock < UNIX_TIMESTAMP("2021-06-30 00:00:00");
SELECT COUNT(*) FROM alerts WHERE clock >= UNIX_TIMESTAMP("2021-06-30 00:00:00") AND clock < UNIX_TIMESTAMP("2021-06-31 00:00:00");
SELECT COUNT(*) FROM alerts WHERE clock >= UNIX_TIMESTAMP("2021-06-31 00:00:00") AND clock < UNIX_TIMESTAMP("2021-07-01 00:00:00");
SELECT COUNT(*) FROM alerts WHERE clock >= UNIX_TIMESTAMP("2021-07-01 00:00:00") AND clock < UNIX_TIMESTAMP("2021-07-02 00:00:00");



--clean up old events from correlation rules
SELECT
FROM_UNIXTIME(repercussion.clock) AS "time of repercussion",
repercussion.name AS "repercussion",
FROM_UNIXTIME(rootCause.clock) "time of rootCause",
rootCause.name AS "rootCause"
FROM events repercussion
JOIN event_recovery ON (event_recovery.eventid=repercussion.eventid)
JOIN events rootCause ON (rootCause.eventid=event_recovery.c_eventid)
WHERE event_recovery.c_eventid IS NOT NULL
ORDER BY repercussion.clock ASC
\G


SELECT events.name FROM events JOIN event_recovery ON (event_recovery.eventid=events.eventid) WHERE event_recovery.c_eventid IS NOT NULL;

SELECT events.eventid FROM events JOIN event_recovery ON (event_recovery.eventid=events.eventid) WHERE event_recovery.c_eventid IS NOT NULL;

--delete the previous output
DELETE e FROM events e
LEFT JOIN event_recovery ON (event_recovery.eventid=e.eventid)
WHERE event_recovery.c_eventid IS NOT NULL
AND e.clock < UNIX_TIMESTAMP(NOW() - INTERVAL 30 DAY)
LIMIT 10;


SELECT
items.key_,
items.type,
delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0 AND items.status=0
AND hosts.host='pg.gnt.ros.do.lan';




--discovery feed
SELECT 
FROM_UNIXTIME(events.clock) AS "reported",
dservices.ip,
dservices.dns,
dservices.lastup AS "service last up",
dservices.lastdown AS "service last down",
CASE dservices.status WHEN 0 THEN 'Service UP' WHEN 1 THEN 'Service DOWN' END AS "service status",
dservices.value,
CASE dhosts.status WHEN 0 THEN 'Host is UP' WHEN 1 THEN 'Host is DOWN' END AS "host status",
dhosts.lastup AS "host last up",
dhosts.lastdown AS "host last down"
FROM events 
JOIN dhosts ON (dhosts.dhostid=events.objectid)
JOIN dservices ON (dservices.dserviceid=events.objectid)
WHERE events.source=1 AND events.object IN (1,2)
ORDER BY events.clock DESC LIMIT 3\G


SELECT 
events.clock AS "reported",
dservices.ip,
dservices.dns,
dservices.lastup AS "service last up",
dservices.lastdown AS "service last down",
CASE dservices.status WHEN 0 THEN 'Service UP' WHEN 1 THEN 'Service DOWN' END AS "service status",
dservices.value,
CASE dhosts.status WHEN 0 THEN 'Host is UP' WHEN 1 THEN 'Host is DOWN' END AS "host status",
dhosts.lastup AS "host last up",
dhosts.lastdown AS "host last down"
FROM events 
JOIN dhosts ON (dhosts.dhostid=events.objectid)
JOIN dservices ON (dservices.dserviceid=events.objectid)
WHERE events.source=1 AND events.object IN (1,2)
ORDER BY events.clock DESC LIMIT 3;

--Zabbix 5.4. user sessions
SELECT sessions.lastaccess,
sessions.status,
users.userid,
users.autologin,
users.autologout,
users.refresh,
users.attempt_failed,
users.attempt_clock,
usrgrp.gui_access
FROM sessions
JOIN users ON (users.userid=sessions.userid)
JOIN users_groups ON (users_groups.userid=users.userid)
JOIN usrgrp ON (usrgrp.usrgrpid=users_groups.usrgrpid);





0, DOBJECT_STATUS_UP - Service UP
1, DOBJECT_STATUS_DOWN - Service DOWN




SELECT triggerid,actionid FROM escalations;
DELETE FROM escalations WHERE triggerid=12345;
DELETE FROM escalations WHERE actionid=12345; 
DELETE FROM escalations;


--frequently used count functions 4.0,4.2,4.4,5.0
SELECT `functions`.`name`,
parameter,
COUNT(*)
FROM functions
JOIN items ON (items.itemid=`functions`.`itemid`)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.status=0
GROUP BY 1,2 
ORDER BY 2;




SELECT clock,itemid,COUNT(*) FROM proxy_history GROUP BY 1,2 HAVING COUNT(*)>1 ;

SELECT clock,itemid,COUNT(*) FROM proxy_history GROUP BY 1,2 HAVING COUNT(*)>1 ORDER BY clock DESC;

SELECT hosts.host,proxy_history.clock,items.type,items.key_,COUNT(*)
FROM proxy_history 
JOIN items ON (items.itemid=proxy_history.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
GROUP BY 1,2,3,4 HAVING COUNT(*)=1 ORDER BY clock DESC;




--This will list all aggregated items and calculated items and parameters used for aggregation:
SELECT CASE items.type WHEN 8 THEN 'Aggregate' WHEN 15 THEN 'Calculated' END AS "type",
items.params,
items.key_,
COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.status=0
AND items.type IN (8,15)
GROUP BY 1,2,3\G

--This will list all trigger functions and what kind of arguments has been used
SELECT `functions`.`name`,
parameter,
COUNT(*)
FROM functions
JOIN items ON (items.itemid=`functions`.`itemid`)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.status=0
GROUP BY 1,2 
ORDER BY 2;



CASE items.type WHEN 8 THEN 'Aggregate' WHEN 15 THEN 'Calculated' END AS "type",




--Zabbix 4.4 THEN 'close event manually
UPDATE triggers SET value=0 WHERE value=1 AND triggerid=16865;

--triggerid THEN 'problem THEN 'triggers
SELECT eventid,objectid,clock,ns,r_eventid,r_clock,r_ns,correlationid,userid  FROM problem WHERE objectid=16865;

SELECT status,value,lastchange,type,state,flags FROM triggers WHERE triggerid=16865 ORDER BY lastchange ASC;
SELECT status,value,lastchange,type,state,flags FROM triggers ORDER BY lastchange ASC;
SELECT status,value,lastchange,type,state,flags FROM triggers WHERE lastchange>0 ORDER BY lastchange ASC;

SET SESSION SQL_LOG_BIN=0; 
DELETE FROM events WHERE source=0 AND object=0 AND objectid=100709
AND clock > UNIX_TIMESTAMP(NOW()-INTERVAL 7 DAY);


select actionid, count(*) from escalations group by 1;
DELETE FROM escalations;


SELECT actionid, triggerid, status, COUNT(*) FROM escalations WHERE status<3 GROUP BY 1,2,3 ORDER BY status;


--zabbix 4.4
SELECT COUNT(*),
CASE task.type
WHEN 0 THEN 'UNDEFINED'
WHEN 1 THEN 'CLOSE_PROBLEM'
WHEN 2 THEN 'REMOTE_COMMAND'
WHEN 3 THEN 'REMOTE_COMMAND_RESULT'
WHEN 4 THEN 'ACKNOWLEDGE'
WHEN 5 THEN 'UPDATE_EVENTNAMES'
WHEN 6 THEN 'CHECK_NOW'
END AS "type",
CASE task.status
WHEN 1 THEN 'NEW'
WHEN 2 THEN 'INPROGRESS'
WHEN 3 THEN 'DONE'
WHEN 4 THEN 'EXPIRED'
END AS "status"
FROM task
GROUP BY 2,3
ORDER BY COUNT(*) DESC;






--Zabbix 4.4. some tasks are in a hanged state. Let's examine what are those:
SELECT FROM_UNIXTIME(task.clock),events.objectid,events.name
FROM task
JOIN task_close_problem ON (task_close_problem.taskid=task.taskid)
JOIN acknowledges ON (acknowledges.acknowledgeid=task_close_problem.acknowledgeid)
JOIN events ON (events.eventid=acknowledges.eventid)
WHERE task.type=1 AND task.status=1
AND events.source=0 AND events.object=0
ORDER BY task.clock DESC;


--Zabbix 4.4. Note down what tasks will be removed, then we can remove all 'CLOSE_PROBLEM' tasks that are in status 'NEW':
DELETE FROM task WHERE type=1 AND status=1;






SELECT count(a.eventid) FROM task_close_problem tcp LEFT JOIN acknowledges a ON tcp.acknowledgeid=a.acknowledgeid LEFT JOIN events e ON a.eventid=e.eventid WHERE e.eventid IN (SELECT eventid FROM events WHERE object = 0 AND source=0 AND clock>0 AND objectid NOT IN (SELECT triggerid FROM triggers));



DELETE FROM task
JOIN task_close_problem ON (task_close_problem.taskid=task.taskid)
JOIN acknowledges ON (acknowledges.acknowledgeid=task_close_problem.acknowledgeid)
WHERE task.type=1
AND task.status=1;


DELETE FROM task WHERE type=1 AND status=1 AND clock BETWEEN 1562567891 AND 1562568473;


DELETE FROM task WHERE type=1 AND status=1;



SELECT FROM_UNIXTIME(task.clock),events.objectid,events.name
FROM task
JOIN task_close_problem ON (task_close_problem.taskid=task.taskid)
JOIN acknowledges ON (acknowledges.acknowledgeid=task_close_problem.acknowledgeid)
JOIN events ON (events.eventid=acknowledges.eventid)
WHERE task.type=1 AND task.status=1
AND events.source=0 AND events.object=0
ORDER BY task.clock DESC;



delete from task where taskid in (
select t.taskid FROM task t
JOIN task_close_problem ON task_close_problem.taskid = t.taskid
JOIN acknowledges an ON acknowledges.acknowledgeid = task_close_problem.acknowledgeid
JOIN problem p ON problem.eventid = acknowledges.eventid
WHERE task.type = 1 AND task.status = 1 AND problem.source=0 AND problem.object=0 AND problem.objectid not in (
select triggerid from triggers where status=0
)
);






SELECT p.host AS proxy_name,
hosts.host,
interface.ip,
interface.dns,
interface.useip,
CASE interface.type
WHEN 1 THEN 'ZBX'
WHEN 2 THEN 'SNMP'
WHEN 3 THEN 'IPMI'
WHEN 4 THEN 'JMX'
END AS "type",
hosts.error
FROM hosts
JOIN interface ON interface.hostid=hosts.hostid
LEFT JOIN hosts p ON hosts.proxy_hostid=p.hostid


--item list THEN 'host of hosts which are enabled:
SELECT items.name,
items.key_,
items.delay,
hosts.host,
p.host AS proxy_name
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
LEFT JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
WHERE hosts.status=0;



--active users
SELECT COUNT(*),users.alias
FROM users
JOIN sessions ON (users.userid = sessions.userid)
GROUP BY users.alias
ORDER BY COUNT(*) DESC;



SELECT COUNT(*),users.username
FROM users
JOIN sessions ON (users.userid = sessions.userid)
GROUP BY users.username
ORDER BY COUNT(*) DESC;




-- lld worker. grep "End of substitute_key_macros_impl"
SELECT hosts.host
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.key_='vfs.fs.minimal.value[/,{$VFS.FS.MIN.VALUE.TIME}]'


--cronjob is pushing information. for hosts which are enabled
SELECT COUNT(*),
CASE items.type
WHEN 2 THEN 'Zabbix trapper'
WHEN 18 THEN 'Dependent item'
END AS type
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags=1
AND items.delay=0
AND hosts.status=0
GROUP BY items.type;


--cronjob is pusshing information. more detailed
SELECT 
items.key_,
CASE items.type
WHEN 2 THEN 'Zabbix trapper'
WHEN 18 THEN 'Dependent item'
END AS type
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags=1
AND items.delay='0'
AND hosts.status=0
GROUP BY 1,2;


SELECT hosts.host THEN 'items.key_ THEN 'CASE items.type WHEN 2 THEN 'Zabbix trapper' WHEN 18 THEN 'Dependent item' END AS type FROM items JOIN hosts ON (hosts.hostid=items.hostid) WHERE  items.flags=1 AND items.delay='0' AND hosts.status=0;






--biggest text metrics in database THEN 'enter directly the latest data page
SELECT SUM(LENGTH(value)) AS 'chars',
CONCAT('history.php?itemids%5B0%5D=' THEN 'itemid ,'&action=showlatest' ) AS 'URL'
FROM history_text
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 5 MINUTE)
GROUP BY itemid
ORDER BY SUM(LENGTH(value)) DESC
LIMIT 5;

SELECT SUM(LENGTH(value)) AS 'chars',
CONCAT('history.php?itemids%5B0%5D=' THEN 'itemid ,'&action=showlatest' ) AS 'URL'
FROM history_log
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 5 MINUTE)
GROUP BY itemid
ORDER BY SUM(LENGTH(value)) DESC
LIMIT 5;

SELECT SUM(LENGTH(value)) AS 'chars',
CONCAT('history.php?itemids%5B0%5D=' THEN 'itemid ,'&action=showlatest' ) AS 'URL'
FROM history_str
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 5 MINUTE)
GROUP BY itemid
ORDER BY SUM(LENGTH(value)) DESC
LIMIT 5;


--Force all Zabbix agent hosts to use IP:
UPDATE interface SET useip=1 WHERE type=1 AND main=1; 

--Set all Zabbix agent hosts to use DNS:
UPDATE interface SET useip=0 WHERE type=1 AND main=1 AND LENGTH(dns)>0;



--recent txt metrics in 10 minutes
SELECT history_text.itemid,
SUM(LENGTH(history_text.value)) AS 'chars',
CONCAT('history.php?itemids%5B0%5D=' THEN 'history_text.itemid ,'&action=showlatest' ) AS 'URL'
FROM history_text
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 10 MINUTE)
GROUP BY history_text.itemid
ORDER BY SUM(LENGTH(history_text.value)) DESC
LIMIT 10\G


--recent log metrics in 10 minutes
SELECT history_log.itemid,
SUM(LENGTH(history_log.value)) AS 'chars',
CONCAT('history.php?itemids%5B0%5D=' THEN 'history_log.itemid ,'&action=showlatest' ) AS 'URL'
FROM history_log
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 10 MINUTE)
GROUP BY history_log.itemid
ORDER BY SUM(LENGTH(history_log.value)) DESC
LIMIT 10\G


--how many items each host is having
SELECT COUNT(*),hosts.host
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
GROUP BY hosts.host
ORDER BY COUNT(*) ASC;


--list "Zabbix trapper" keys (items.type=2) only for monitored hosts (hosts.status=0) and enabled items (items.status=0)
SELECT COUNT(*),
key_
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.status=0
AND items.type=2
GROUP BY key_;



--web scenarios
SELECT DISTINCT hosts.host,
p.host AS proxy_name
FROM hosts
JOIN items ON (items.hostid=hosts.hostid)
LEFT JOIN hosts p ON hosts.proxy_hostid=p.hostid
WHERE hosts.status=0
AND items.type=9
ORDER BY proxy_name;

SELECT COUNT(*),objectid,object,source FROM events WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY) GROUP BY objectid,object,source ORDER BY COUNT(*) ASC;

SELECT COUNT(*),source FROM events GROUP BY source;









--The item is not discovered anymore and will be deleted in
SELECT hosts.host,
items.key_,
FROM_UNIXTIME(item_discovery.ts_delete) AS 'willBeDeleted',
CONCAT('items.php?form=update&hostid=' THEN 'hosts.hostid THEN ''&itemid=' THEN 'items.itemid ) AS 'URL'
from items 
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE item_discovery.ts_delete > 0
\G


SELECT COUNT(*),objectid,object,source FROM events WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY) GROUP BY objectid,object,source ORDER BY COUNT(*) ASC;



SELECT history_text.itemid,
SUM(LENGTH(history_text.value)) AS 'chars',
CONCAT('history.php?itemids%5B0%5D=' THEN 'history_text.itemid ,'&action=showlatest' ) AS 'URL'
FROM history_text
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 3 DAY)
GROUP BY history_text.itemid
ORDER BY SUM(LENGTH(history_text.value)) DESC
LIMIT 10;



334514&action=showlatest


--biggest text metrics in database
SELECT SUM(LENGTH(value)) AS 'chars',
CONCAT('history.php?itemids%5B0%5D=' THEN 'itemid ,'&action=showlatest' ) AS 'URL'
FROM history_text
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 5 MINUTE)
GROUP BY itemid
ORDER BY SUM(LENGTH(value)) DESC
LIMIT 5;

--biggest log entries
SELECT hosts.host,hosts.hostid,history_log.itemid,COUNT(*),SUM(LENGTH(history_log.value))
FROM history_log
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 5 MINUTE)
GROUP BY history_log.itemid
ORDER BY SUM(LENGTH(history_log.value)) DESC
LIMIT 10;

--string entries
SELECT hosts.host,hosts.hostid,history_str.itemid,COUNT(*),SUM(LENGTH(history_str.value))
FROM history_str
JOIN items ON (items.itemid=history_str.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 5 MINUTE)
GROUP BY history_str.itemid
ORDER BY SUM(LENGTH(history_str.value)) DESC
LIMIT 10;


--detect exceptions in update. valuable query
SELECT h1.host AS exceptionInstalled,
i1.name,
i1.key_,
i1.delay,
h2.host AS differesFromTemplate,
i2.name,
i2.key_,
i2.delay
FROM items i1
JOIN items i2 ON (i2.itemid=i1.templateid)
JOIN hosts h1 ON (h1.hostid=i1.hostid)
JOIN hosts h2 ON (h2.hostid=i2.hostid)
WHERE i1.delay<>i2.delay\G




--username
SELECT h1.host AS exceptionInstalled, i1.name, i1.key_, i1.username, h2.host AS differesFromTemplate, i2.username FROM items i1 JOIN items i2 ON (i2.itemid=i1.templateid) JOIN hosts h1 ON (h1.hostid=i1.hostid) JOIN hosts h2 ON (h2.hostid=i2.hostid) WHERE i1.username<>i2.username\G
--password
SELECT h1.host AS exceptionInstalled, i1.name, i1.key_, i1.password, h2.host AS differesFromTemplate, i2.password FROM items i1 JOIN items i2 ON (i2.itemid=i1.templateid) JOIN hosts h1 ON (h1.hostid=i1.hostid) JOIN hosts h2 ON (h2.hostid=i2.hostid) WHERE i1.password<>i2.password\G



--different username
SELECT level1.key_,items.key_ FROM items
JOIN items level1 ON (level1.itemid=items.templateid) 
WHERE level1.username<>items.username;

--different password
SELECT level1.key_,items.key_ FROM items
JOIN items level1 ON (level1.itemid=items.templateid)
WHERE level1.password<>items.password;

--highlight exceptions
SELECT items.delay,items.key_,items.templateid
FROM items
JOIN hosts ON hosts.hostid=items.hostid
WHERE items.itemid=333307;

SELECT items.delay,items.key_,items.templateid
FROM items
JOIN hosts ON hosts.hostid=items.hostid
WHERE hosts.hostid=109293;


SELECT h.hostid THEN 'h.host THEN 'htempl.host AS template FROM hosts h
    LEFT JOIN hosts_templates ht ON h.hostid=ht.hostid
    LEFT JOIN hosts htempl ON ht.templateid=htempl.hostid
WHERE h.status=0 and h.hostid=11850 and h.flags in (0,4);


--show pure items
--i.flags IN (0,1,2) show discovery rules and item prototypes
SELECT i.itemid AS itemAtHostLevel THEN 'h.hostid THEN '
htempl.hostid AS templateID
FROM items i
LEFT JOIN hosts h ON h.hostid=i.hostid
LEFT JOIN hosts_templates ht ON h.hostid=ht.hostid
LEFT JOIN hosts htempl ON ht.templateid=htempl.hostid
WHERE h.status=0
AND i.flags IN (0)
AND h.hostid=11850;


select * from items where itemid=320197\G
hostid=12856



--remove looping tasks
# https://support.zabbix.com/browse/ZBX-18802
SELECT count(a.eventid) FROM task_close_problem tcp LEFT JOIN acknowledges a ON tcp.acknowledgeid=a.acknowledgeid LEFT JOIN events e ON a.eventid=e.eventid WHERE e.eventid IN (SELECT eventid FROM events WHERE object = 0 AND source=0 AND clock>0 AND objectid NOT IN (SELECT triggerid FROM triggers));
SELECT count(eventid) FROM events WHERE object = 0 AND source=0 AND clock>0 AND objectid NOT IN (SELECT triggerid FROM triggers);








--list the enabled hosts in Zabbix and which templates are attached to them
SELECT h.hostid THEN 'h.host THEN 'htempl.host AS template FROM hosts h
    LEFT JOIN hosts_templates ht ON h.hostid=ht.hostid
    LEFT JOIN hosts htempl ON ht.templateid=htempl.hostid
WHERE h.status=0 and h.flags in (0,4);



--delete all events comming from specific trigger id. only execute if trigger is not in problem state



--live unsupported items
SELECT hosts.host,COUNT(*),
CONCAT('items.php?filter_hostids%5B%5D=' THEN 'hosts.hostid THEN ''&filter_application=&filter_name=&filter_key=&filter_type=-1&filter_delay=&filter_snmp_oid=&filter_value_type=-1&filter_history=&filter_trends=&filter_state=-1&filter_status=-1&filter_with_triggers=-1&filter_templated_items=-1&filter_discovery=-1&subfilter_set=1&subfilter_state%5B1%5D=1' ) AS "check data"
 FROM hosts
JOIN items ON (items.hostid=hosts.hostid)
JOIN item_rtdata ON (item_rtdata.itemid=items.itemid)
WHERE hosts.status=0
AND items.flags IN (0,4)
AND item_rtdata.state=1
GROUP BY hosts.host,3
ORDER BY COUNT(*) DESC
LIMIT 1
\G







--catter host inventory
SELECT host_inventory.macaddress_a,GROUP_CONCAT(hosts.host) FROM host_inventory
JOIN hosts ON (hosts.hostid=host_inventory.hostid)
WHERE hosts.status=0 AND host_inventory.macaddress_a LIKE '%enterprises%'
GROUP BY host_inventory.macaddress_a
\G

--query all device title which has installed objectID at the 'macaddress_a' field
SET SESSION group_concat_max_len = 1000000; SELECT GROUP_CONCAT(hosts.host) FROM host_inventory
JOIN hosts ON (hosts.hostid=host_inventory.hostid)
WHERE hosts.status=0 AND host_inventory.macaddress_a LIKE '%enterprises%'
\G


--query all device title which has installed objectID at the 'macaddress_a' field. ip address THEN 'ip addreses
SET SESSION group_concat_max_len = 1000000; SELECT GROUP_CONCAT(interface.ip) FROM interface
JOIN hosts ON (hosts.hostid=interface.hostid)
WHERE hosts.status=0 AND interface.main=1 AND interface.type=2
\G

JOIN host_inventory ON (host_inventory.hostid=interface.hostid)


--big data in mysql history_text
SELECT itemid,COUNT(*),SUM(LENGTH(value)) FROM history_text
WHERE clock >= UNIX_TIMESTAMP('2021-03-19 00:00:00')
AND clock < UNIX_TIMESTAMP('2021-03-20 00:00:00')
GROUP BY itemid
ORDER BY SUM(LENGTH(value)) DESC LIMIT 20;
--big data in mysql history_log
SELECT itemid,COUNT(*),SUM(LENGTH(value)) FROM history_log
WHERE clock >= UNIX_TIMESTAMP('2021-03-19 00:00:00')
AND clock < UNIX_TIMESTAMP('2021-03-20 00:00:00')
GROUP BY itemid
ORDER BY SUM(LENGTH(value)) DESC LIMIT 20;



--postgres
SELECT itemid,COUNT(*),SUM(LENGTH(value)) FROM history_text
WHERE clock >= EXTRACT(EPOCH FROM (TIMESTAMP '2021-02-20 00:00:00'))
AND clock < EXTRACT(EPOCH FROM (TIMESTAMP '2021-03-21 00:00:00'))
GROUP BY itemid
ORDER BY SUM(LENGTH(value)) DESC;
--posthres integers
SELECT itemid,COUNT(*),SUM(value) FROM history_uint
WHERE clock >= EXTRACT(EPOCH FROM (TIMESTAMP '2021-02-20 00:00:00'))
AND clock < EXTRACT(EPOCH FROM (TIMESTAMP '2021-03-21 00:00:00'))
GROUP BY itemid
ORDER BY SUM(value) DESC;



--fetch recent floating numbers
SELECT DISTINCT(history.itemid),hosts.host,items.key_,
FROM_UNIXTIME(MAX(history.clock)) AS "clock",
history.value
FROM history
JOIN items ON (items.itemid=history.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE history.clock > UNIX_TIMESTAMP(NOW() - INTERVAL 10 MINUTE)
GROUP BY history.itemid,items.key_,hosts.host,history.value
LIMIT 2
\G



--fetch recent integers
SELECT DISTINCT(history_uint.itemid),hosts.host,items.key_,
FROM_UNIXTIME(MAX(history_uint.clock)) AS "clock",
history_uint.value
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE history_uint.clock > UNIX_TIMESTAMP(NOW() - INTERVAL 2 MINUTE)
GROUP BY history_uint.itemid,items.key_,hosts.host,history_uint.value; 




/* which escalation is causing the most trouble */
SELECT COUNT(*),actions.name,escalations.status
from escalations
JOIN actions ON (actions.actionid=escalations.actionid)
GROUP BY actions.name,escalations.status
ORDER BY COUNT(*) DESC
LIMIT 10;




SELECT COUNT(*),
actions.name,
actions.actionid 
FROM events
JOIN alerts ON (alerts.eventid=events.eventid)
JOIN actions ON (actions.actionid=alerts.actionid)
WHERE events.source=0
AND events.object=0
GROUP BY actions.name,actions.actionid
ORDER BY COUNT(*) ASC
LIMIT 10\G






/* hosts not reachable behind proxy and master server */
SELECT p.host AS proxy_name,
hosts.host,
interface.ip,
interface.dns,
interface.useip,
CASE interface.type
WHEN 1 THEN 'ZBX'
WHEN 2 THEN 'SNMP'
WHEN 3 THEN 'IPMI'
WHEN 4 THEN 'JMX'
END AS "type",
hosts.error
FROM hosts
JOIN interface ON interface.hostid=hosts.hostid
LEFT JOIN hosts p ON hosts.proxy_hostid=p.hostid
WHERE hosts.status=0
AND interface.main=1
AND hosts.available=2;


SELECT hosts.host,
interface.ip,
interface.dns,
interface.useip,
CASE interface.type
WHEN 1 THEN 'ZBX'
WHEN 2 THEN 'SNMP'
WHEN 3 THEN 'IPMI'
WHEN 4 THEN 'JMX'
END AS "type",
hosts.error
FROM hosts
JOIN interface ON interface.hostid=hosts.hostid
WHERE hosts.status=0
AND interface.main=1
AND hosts.available=2;





/* unsupported LLDs discoveries items 5.0 */
SELECT
hosts.host,
items.name,
CONCAT( 'host_discovery.php?form=update&itemid=' THEN 'items.itemid ) AS "open item",
item_rtdata.error
FROM item_rtdata
JOIN items ON (items.itemid=item_rtdata.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags IN (1)
AND items.status=0
AND LENGTH(item_rtdata.error)>0
\G



--leading host with most unsupported items. works on 4.4
SELECT hosts.host,
COUNT(*),
CONCAT( '/items.php?filter_hostids%5B%5D=' THEN 'hosts.hostid ,'&filter_application=&filter_name=&filter_key=&filter_type=-1&filter_delay=&filter_snmp_oid=&filter_value_type=-1&filter_history=&filter_trends=&filter_state=1&filter_with_triggers=-1&filter_templated_items=-1&filter_discovery=-1&filter_set=1') AS "show unsupported items"
FROM items
JOIN hosts ON (items.hostid=hosts.hostid)
JOIN item_rtdata ON (item_rtdata.itemid=items.itemid)
WHERE hosts.status=0
AND LENGTH(item_rtdata.error) > 0
GROUP BY 1,3
ORDER BY COUNT(*) DESC
LIMIT 1
\G


SELECT hosts.host,
items.key_,
CONCAT( "https://zbx.catonrug.net/" THEN ''history.php?itemids%5B0%5D=' THEN 'items.itemid THEN ''&action=showlatest' ) AS "check data",
CONCAT( "https://zbx.catonrug.net/" THEN ''items.php?form=update&hostid=' THEN 'hosts.hostid THEN ''&itemid=' THEN 'items.itemid ) AS "open item"
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.templateid IS NULL
AND items.flags NOT IN (4,1)
AND items.status=0
\G




items.php?form=update&hostid=12814&itemid=309738


https://zbx.catonrug.net/history.php?itemids%5B0%5D=109064&action=showlatest


--5.0 show which items are linked to hosts but not belong to any template
SELECT hosts.host,
hosts.hostid,
items.key_,
items.itemid,
items.templateid
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.templateid IS NULL
AND items.flags NOT IN (4)
AND items.status=0
\G




--list all items per one host
SELECT key_ THEN 'delay THEN 'type THEN 'flags THEN 'value_type
FROM items
WHERE status=0
AND hostid=12795;


SELECT hosts.host,items.itemid,items.key_,
COUNT(history_log.itemid)  AS 'count' THEN 'AVG(LENGTH(history_log.value)) AS 'avg size',
(COUNT(history_log.itemid) * AVG(LENGTH(history_log.value))) AS 'Count x AVG'
FROM history_log 
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 6 MINUTE)
GROUP BY hosts.host,history_log.itemid
ORDER BY 6 DESC
LIMIT 5\G


SELECT hosts.host,items.itemid,items.key_,
COUNT(history_log.itemid)  AS 'count' THEN 'AVG(LENGTH(history_log.value)) AS 'avg size',
(COUNT(history_log.itemid) * AVG(LENGTH(history_log.value))) AS 'Count x AVG'
FROM history_log 
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > UNIX_TIMESTAMP("2021-02-02 15:00:00")
AND clock < UNIX_TIMESTAMP("2021-02-02 15:30:00")
GROUP BY hosts.host,history_log.itemid
ORDER BY 6 DESC
LIMIT 5\G



yum -y install iperf
iperf -s -p 10051


--show all items and state on one host. 4.4 THEN '5.0 THEN '5.2
SELECT items.itemid,
items.type,
items.key_,
items.flags,
item_rtdata.state,
item_rtdata.error
FROM items
JOIN item_rtdata ON (item_rtdata.itemid=items.itemid)
WHERE items.status=0
AND items.hostid=12345\G


SELECT items.key_,events.object,events.name
FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.object IN (4,5)
AND events.source=3
AND events.clock > UNIX_TIMESTAMP(NOW()-INTERVAL 30 DAY)
AND hosts.hostid=11268\G


SELECT items.key_,events.object,COUNT(*)
FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.object IN (4,5)
AND events.source=3
AND events.clock > UNIX_TIMESTAMP(NOW()-INTERVAL 30 DAY)
AND hosts.hostid=11268
GROUP BY events.object
\G









--SNMPv3 hosts behind proxy
SELECT p.host,hosts.hostid,items.itemid
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hosts p ON (hosts.proxy_hostid=p.hostid)

WHERE hosts.available=0;



--best query ever. log entries consuming the most space. history_log
SELECT hosts.host,items.itemid,items.key_,
COUNT(history_log.itemid)  AS 'count' THEN 'AVG(LENGTH(history_log.value)) AS 'avg size',
(COUNT(history_log.itemid) * AVG(LENGTH(history_log.value))) AS 'Count x AVG'
FROM history_log 
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 30 MINUTE)
GROUP BY hosts.host,history_log.itemid
ORDER BY 6 DESC
LIMIT 3\G


--best query ever. history_text entries consuming the most space
SELECT hosts.host,items.itemid,items.key_,
COUNT(history_text.itemid) AS 'count' THEN 'AVG(LENGTH(history_text.value)) AS 'avg size',
(COUNT(history_text.itemid) * AVG(LENGTH(history_text.value))) AS 'Count x AVG'
FROM history_text 
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 30 MINUTE)
GROUP BY hosts.host,history_text.itemid
ORDER BY 6 DESC
LIMIT 3\G



--biggest text values
SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '
(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables 
WHERE TABLE_NAME = 'history_text' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN '
sum(length(history_text.value))/1024/1024 + sum(length(history_text.clock))/1024/1024 + sum(length(history_text.ns))/1024/1024 + sum(length(history_text.itemid))/1024/1024 AS 'history_text Column Size (Mb)'
FROM history_text
LEFT OUTER JOIN items i on history_text.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1)
AND clock > UNIX_TIMESTAMP(now() - INTERVAL 1 DAY - INTERVAL 600 MINUTE)
AND clock < UNIX_TIMESTAMP(now() - INTERVAL 1 DAY)
GROUP BY ho.hostid
ORDER BY 4 DESC
LIMIT 5\G



/* Measure the size of text blocks getting inserted in text tables recently */
SELECT MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_text WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 30 MINUTE);
SELECT MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_log WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 30 MINUTE);
SELECT MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_str WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 30 MINUTE);





--biggest metrics in database mysql THEN 'table history_text
SELECT hosts.host,items.key_,AVG(LENGTH(history_text.value))
FROM history_text 
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock> UNIX_TIMESTAMP (now() - INTERVAL 60 MINUTE)
AND LENGTH(history_text.value)>60
GROUP BY 1,2,3
ORDER BY LENGTH(history_text.value) DESC
LIMIT 3\G



--biggest metrics in database mysql THEN 'table history_log
SELECT hosts.host,items.itemid,items.key_,
COUNT(history_log.itemid) AS 'occurance',
AVG(LENGTH(history_log.value)) AS 'average length'
FROM history_log 
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 30 MINUTE)
GROUP BY hosts.host,history_log.itemid
LIMIT 5\G


--biggest metrics in database mysql THEN 'table history_text
SELECT hosts.host,items.itemid,items.key_,
COUNT(history_text.itemid) AS 'occurance',
AVG(LENGTH(history_text.value)) AS 'average length'
FROM history_text 
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 30 MINUTE)
GROUP BY hosts.host,history_text.itemid
LIMIT 5\G





--biggest metrics in database mysql THEN 'table history_log
SELECT hosts.host,items.key_,LENGTH(history_log.value) AS 'length'
FROM history_log 
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock> UNIX_TIMESTAMP (now() - INTERVAL 60 MINUTE)
AND LENGTH(history_log.value)>60
ORDER BY LENGTH(history_log.value) DESC
LIMIT 3\G



SELECT problem.objectid,problem.object,problem.source,problem.correlationid,COUNT(*) FROM problem GROUP BY 1,2,3,4 ORDER BY COUNT(*) DESC LIMIT 15;


SELECT min(clock) from events;

DELETE FROM events WHERE clock < UNIX_TIMESTAMP(NOW() - INTERVAL 6 MONTH) LIMIT 1000;

DELETE FROM events WHERE clock < UNIX_TIMESTAMP(NOW() - INTERVAL 14 DAY) LIMIT 1000;


select COUNT(*) THEN 'source THEN 'object from events WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY) group by source,object;

select COUNT(*) THEN 'source THEN 'object from events WHERE clock > UNIX_TIMESTAMP(NOW() - INTERVAL 7 DAY) group by source,object;

select COUNT(*) THEN 'source THEN 'object from events WHERE clock > UNIX_TIMESTAMP('2020-06-01 00:00:00') AND clock < UNIX_TIMESTAMP('2020-07-01 00:00:00') group by source,object;

select COUNT(*) THEN 'source THEN 'object from events WHERE clock > UNIX_TIMESTAMP('2020-07-01 00:00:00') AND clock < UNIX_TIMESTAMP('2020-08-01 00:00:00') group by source,object;

select COUNT(*) THEN 'source THEN 'object from events WHERE clock > UNIX_TIMESTAMP('2020-08-01 00:00:00') AND clock < UNIX_TIMESTAMP('2020-09-01 00:00:00') group by source,object;

select COUNT(*) THEN 'source THEN 'object from events WHERE clock > UNIX_TIMESTAMP('2020-09-01 00:00:00') AND clock < UNIX_TIMESTAMP('2020-10-01 00:00:00') group by source,object;

select COUNT(*) THEN 'source THEN 'object from events WHERE clock > UNIX_TIMESTAMP('2020-10-01 00:00:00') AND clock < UNIX_TIMESTAMP('2020-11-01 00:00:00') group by source,object;

select COUNT(*) THEN 'source THEN 'object from events WHERE clock > UNIX_TIMESTAMP('2020-11-01 00:00:00') AND clock < UNIX_TIMESTAMP('2020-12-01 00:00:00') group by source,object;

select COUNT(*) THEN 'source THEN 'object from events WHERE clock > UNIX_TIMESTAMP('2020-12-01 00:00:00') AND clock < UNIX_TIMESTAMP('2021-01-01 00:00:00') group by 








SELECT hosts.host,items.key_,LENGTH(history_log.value)
FROM history_log 
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock> UNIX_TIMESTAMP (now() - INTERVAL 30 MINUTE)
AND LENGTH(history_log.value)>500;


--postgrese
select itemid,count(*) from history_log
where clock >= extract(epoch from now() - interval '10 hour')
group by itemid order by count DESC LIMIT 10;

select itemid,count(*) from history_str
where clock >= extract(epoch from now() - interval '10 hour')
group by itemid order by count DESC LIMIT 10;



SELECT hosts.host THEN 'items.key_,
AVG(LENGTH(history_text.value))::NUMERIC(10,2),
COUNT(history_text.itemid) FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE history_text.clock >= extract(epoch from now() - interval '1 hour')
GROUP BY 1,2
HAVING COUNT(history_text.itemid) > 0
ORDER BY AVG(LENGTH(history_text.value))::NUMERIC(10,2) DESC
LIMIT 10;


SELECT hosts.host THEN 'items.key_,
AVG(LENGTH(history_log.value))::NUMERIC(10,2),
COUNT(history_log.itemid) FROM history_log
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE history_log.clock >= extract(epoch from now() - interval '1 hour')
GROUP BY 1,2
HAVING COUNT(history_log.itemid) > 0
ORDER BY AVG(LENGTH(history_log.value))::NUMERIC(10,2) DESC
LIMIT 10;



--show unreachable hosts. hosts not reachable:
SELECT
hosts.host,
interface.ip,
interface.dns,
interface.useip,
CASE interface.type
WHEN 1 THEN 'ZBX'
WHEN 2 THEN 'SNMP'
WHEN 3 THEN 'IPMI'
WHEN 4 THEN 'JMX'
END AS "type",
hosts.error
FROM hosts
JOIN interface ON interface.hostid=hosts.hostid
WHERE hosts.available=2
AND interface.main=1
AND hosts.status=0;



SELECT
hosts.host,
interface.ip,
interface.dns,
interface.useip,
interface.type,
hosts.error
FROM hosts
WHERE interface.hostid=hosts.hostid
AND hosts.available=2
AND interface.main=1
AND hosts.status=0;



--frequent big metrics
SELECT itemid,COUNT(*),AVG(LENGTH(value))
FROM history_text
WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 115 MINUTE)
GROUP BY itemid
ORDER BY COUNT(*) DESC
LIMIT 15;


--frequent big metrics
SELECT itemid,AVG(LENGTH(value)),COUNT(*)
FROM history_text
WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 15 MINUTE)
GROUP BY itemid
ORDER BY AVG(LENGTH(value)) DESC
LIMIT 30;

SELECT itemid,AVG(LENGTH(value)),COUNT(*)
FROM history_log
WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 15 MINUTE)
GROUP BY itemid
ORDER BY AVG(LENGTH(value)) DESC
LIMIT 30;

ZBX_STARTJAVAPOLLERS=5



--frequent big metrics used in value cache
SELECT itemid,COUNT(*),AVG(LENGTH(value))
FROM history_text
WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 15 MINUTE)
AND itemid IN (
SELECT itemid FROM functions WHERE name='count' AND parameter LIKE '%like%'
)
GROUP BY itemid
ORDER BY COUNT(*) DESC;

--log table
SELECT itemid,COUNT(*),AVG(LENGTH(value))
FROM history_log
WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 15 MINUTE)
AND itemid IN (
SELECT itemid FROM functions WHERE name='count' AND parameter LIKE '%like%'
)
GROUP BY itemid
ORDER BY COUNT(*) DESC;

--str table
SELECT itemid,COUNT(*),AVG(LENGTH(value))
FROM history_str
WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 15 MINUTE)
AND itemid IN (
SELECT itemid FROM functions WHERE name='count' AND parameter LIKE '%like%'
)
GROUP BY itemid
ORDER BY COUNT(*) DESC;

--frequently used count functions 4.0,4.2,4.4,5.0
SELECT `functions`.`name`,
parameter,
COUNT(*)
FROM functions
JOIN items ON (items.itemid=`functions`.`itemid`)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND functions.name='count'
AND functions.parameter LIKE '%like%'
GROUP BY 1,2 
ORDER BY 2;

--filter out functions which contains an installed macro
SELECT `functions`.`name`,
hostmacro.value,
COUNT(*)
FROM functions
JOIN items ON (items.itemid=`functions`.`itemid`)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hostmacro ON (hostmacro.macro=functions.parameter)
WHERE hosts.status=0
AND functions.parameter LIKE '{%'
GROUP BY 1,2
ORDER BY 2;

--host level mapping
SELECT `functions`.`name`,
hostmacro.value,
COUNT(*)
FROM functions
JOIN items ON (items.itemid=`functions`.`itemid`)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hostmacro ON (hostmacro.macro=functions.parameter)
WHERE hosts.status=0
AND functions.parameter LIKE '{%'
GROUP BY 1,2
ORDER BY 2;




--host level mapping+templates
SELECT `functions`.`name`,
hostmacro.value,
COUNT(*)
FROM functions
JOIN items ON (items.itemid=`functions`.`itemid`)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hostmacro ON (hostmacro.macro=functions.parameter)
WHERE functions.parameter LIKE '{%'
GROUP BY 1,2
ORDER BY 2;




--global level mapping
SELECT `functions`.`name`,
globalmacro.value,
COUNT(*)
FROM functions
JOIN items ON (items.itemid=`functions`.`itemid`)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN globalmacro ON (globalmacro.macro=functions.parameter)
WHERE functions.parameter LIKE '{%'
GROUP BY 1,2
ORDER BY 2;

WHERE hosts.status=0






--list item IDs on a host level which is having unsupported state
--copy content to notepad for later reference
SET SESSION group_concat_max_len = 1000000;
SELECT GROUP_CONCAT(items.itemid) FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.flags IN (0,4)
AND items.state=0;


--mysql: list all unsupported items coming from hosts which are currently enabled
SET SESSION group_concat_max_len = 1000000;
SELECT GROUP_CONCAT(itemid)
FROM items
WHERE flags IN (0,4)
AND state=1
AND hostid IN (SELECT hostid FROM hosts WHERE status=0);

--postgres: list all unsupported items comming from hosts which are currently enabled
SELECT array_to_string(array_agg(itemid) THEN '',')
FROM items
WHERE flags IN (0,4)
AND state=1
AND hostid IN (SELECT hostid FROM hosts WHERE status=0);

--set unsupported items to be disabled for the hosts which are currently enabled
UPDATE items
SET status=1
WHERE flags IN (0,4)
AND state=1
AND hostid IN (SELECT hostid FROM hosts WHERE status=0);





--postgres
SELECT array_to_string(array_agg(items.itemid) THEN '',') FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.flags IN (0,4)
AND items.state=0;


-- Condition object>0 filters out all events except triggers.
delete from events where source=3 and object>0 limit 10000;
-- 0 THEN 'EVENT_OBJECT_TRIGGER - Trigger
-- 1 THEN 'EVENT_OBJECT_DHOST - Discovered/lost host
-- 2 THEN 'EVENT_OBJECT_DSERVICE - Discovered/lost service
-- 3 THEN 'EVENT_OBJECT_AUTOREGHOST - Discovered Active agent
-- 4 THEN 'EVENT_OBJECT_ITEM - Item
-- 5 THEN 'EVENT_OBJECT_LLDRULE - Low level discovery rule

--frequently used functions 3.2 THEN '3.4,
SELECT `functions`.`parameter`,
`items`.`delay`,
`functions`.`function`,
COUNT(*)
FROM functions
JOIN items ON (items.itemid=`functions`.`itemid`)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=3
AND REGEXP_LIKE(`functions`.`parameter` THEN ''[0-9]+')
AND `functions`.`function` NOT IN ('last','change','diff','nodata')
GROUP BY 1,2,3
ORDER BY `functions`.`parameter`,`items`.`delay`;

--look if build in template set has some references per this OID
SELECT key_ FROM items WHERE snmp_oid like '%1.3.6.1.2.1.2.2.1.8%';
SELECT key_ FROM items WHERE snmp_oid like '%1.3.6.1.4.1.11.2.3.7.8.3%';



SELECT hosts.host,items.key_ FROM items 
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.snmp_oid like '%1.3.6.1.4.1.11.2.3%'
\G



--frequently used functions 4.0,4.2,4.4,5.0
SELECT `functions`.`name`,
parameter,
COUNT(*)
FROM functions
JOIN items ON (items.itemid=`functions`.`itemid`)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
GROUP BY 1,2 
ORDER BY 2;


--itemid's behind proxy
SELECT p.host,hosts.hostid,items.itemid
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
WHERE hosts.available=0;

--itemid's linked to master
SELECT hosts.host,items.itemid
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.available=0;



SET SESSION group_concat_max_len = 1000000;

SELECT GROUP_CONCAT(FROM_UNIXTIME(alerts.clock),',' THEN 'alerts.subject,',' THEN '`groups`.name SEPARATOR '\n')

--see missconfiguration
SELECT 
functions.name,
functions.parameter,
GROUP_CONCAT(hosts.host) AS 'templates'
FROM triggers
INNER JOIN functions ON functions.triggerid = triggers.triggerid
INNER JOIN items ON functions.itemid = items.itemid
INNER JOIN hosts ON hosts.hostid = items.hostid
WHERE hosts.status = 3
AND functions.name IN ('nodata','avg','min','max','sum')
AND functions.parameter NOT LIKE '#%'
AND functions.parameter NOT LIKE '%m'
AND functions.parameter NOT LIKE '%h'
AND functions.parameter NOT LIKE '%d'
AND functions.parameter NOT LIKE ''
AND functions.parameter > 0
AND functions.parameter < 60
GROUP BY 1,2
LIMIT 100;
\G

--value cache is increasing forever
SELECT 
functions.name,
functions.parameter,
GROUP_CONCAT(hosts.host) AS 'templates'
FROM triggers
INNER JOIN functions ON functions.triggerid = triggers.triggerid
INNER JOIN items ON functions.itemid = items.itemid
INNER JOIN hosts ON hosts.hostid = items.hostid
WHERE hosts.status = 3
AND functions.name IN ('nodata','avg','min','max','sum')
AND functions.parameter NOT LIKE '#%'
AND functions.parameter NOT LIKE '%m'
AND functions.parameter NOT LIKE '%h'
AND functions.parameter NOT LIKE '%d'
AND functions.parameter NOT LIKE ''
AND functions.parameter > 0
AND functions.parameter < 60
GROUP BY 1,2
LIMIT 100;
\G



--postgres
SELECT 
functions.name,
functions.parameter,
hosts.host AS "template"
FROM triggers
INNER JOIN functions ON functions.triggerid = triggers.triggerid
INNER JOIN items ON functions.itemid = items.itemid
INNER JOIN hosts ON hosts.hostid = items.hostid
WHERE hosts.status = 3
AND functions.name IN ('nodata','avg','min','max')
AND functions.parameter NOT LIKE '#%'
AND functions.parameter NOT LIKE '%m'
AND functions.parameter NOT LIKE '%h'
AND functions.parameter NOT LIKE '%d'
AND functions.parameter NOT LIKE ''
AND functions.parameter NOT LIKE '{%'
AND functions.parameter NOT LIKE '%}'
GROUP BY 1,2,3
LIMIT 100;




--missconfiguration in template
SELECT
functions.name,
functions.parameter,
GROUP_CONCAT(hosts.host) AS 'templates'
FROM triggers
INNER JOIN functions ON functions.triggerid = triggers.triggerid
INNER JOIN items ON functions.itemid = items.itemid
INNER JOIN hosts ON hosts.hostid = items.hostid
WHERE hosts.status = 3
AND functions.name IN ('nodata','avg','min','max')
AND functions.parameter NOT LIKE '#%'
AND functions.parameter NOT LIKE '%m'
AND functions.parameter NOT LIKE '%h'
AND functions.parameter NOT LIKE '%d'
AND functions.parameter NOT LIKE ''
AND functions.parameter > 0
AND functions.parameter < 60
GROUP BY 1,2
LIMIT 100
\G

--missconfiguration in hosts
SELECT
functions.name,
functions.parameter,
GROUP_CONCAT(hosts.host) AS 'templates'
FROM triggers
INNER JOIN functions ON functions.triggerid = triggers.triggerid
INNER JOIN items ON functions.itemid = items.itemid
INNER JOIN hosts ON hosts.hostid = items.hostid
WHERE hosts.status = 0
AND functions.name IN ('nodata','avg','min','max')
AND functions.parameter NOT LIKE '#%'
AND functions.parameter NOT LIKE '%m'
AND functions.parameter NOT LIKE '%h'
AND functions.parameter NOT LIKE '%d'
AND functions.parameter NOT LIKE ''
AND functions.parameter > 0
AND functions.parameter < 60
GROUP BY 1,2
LIMIT 100
\G



--see misconfiguration
SELECT hosts.host AS 'template',
functions.name,
functions.parameter
FROM triggers
INNER JOIN functions ON functions.triggerid = triggers.triggerid
INNER JOIN items ON functions.itemid = items.itemid
INNER JOIN hosts ON hosts.hostid = items.hostid
WHERE hosts.status = 3
AND functions.name IN ('nodata','avg','min','max')
AND functions.parameter NOT LIKE '#%'
AND functions.parameter NOT LIKE '%m'
AND functions.parameter NOT LIKE '%h'
AND functions.parameter NOT LIKE '%d'
AND functions.parameter NOT LIKE ''
GROUP BY 1,2,3
LIMIT 100
\G





--have to wait till the recovery event arrives 
--(the one which should close all events per objectid) and then execute housekeeper.
--tested and it did decrease records in the table 'problem' :)
SELECT COUNT(*) FROM problem;

--show all internal events together:
SELECT objectid,object,name,COUNT(*)
FROM problem 
WHERE source=3 AND object>0
GROUP BY objectid,object,name
ORDER BY COUNT(*) DESC
LIMIT 15
\G


--internal active problems per items
SELECT 
hosts.host,
items.key_,
problem.objectid,
problem.name,
COUNT(*)
FROM problem
JOIN items ON (items.itemid=problem.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE problem.source=3 AND problem.object=4
GROUP BY problem.objectid,problem.name
ORDER BY COUNT(*) DESC
LIMIT 15
\G



--internal active problems per lld rule
SELECT hosts.host,
items.key_,
problem.objectid,
problem.name,
COUNT(*)
FROM problem
JOIN items ON (items.itemid=problem.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE problem.source=3 AND problem.object=5
GROUP BY problem.objectid,problem.name
ORDER BY COUNT(*) DESC
LIMIT 15
\G




--Let's start with removing problems for source 3 which is related to internal events.
DELETE FROM problem WHERE source=3 AND object>0 LIMIT 100000; 



--detect if event correlation is used
SELECT * FROM event_recovery WHERE correlationid IS NOT NULL;

SELECT * FROM problem WHERE correlationid IS NOT NULL;

--event closed by global correlation rule
SELECT correlation.name,COUNT(*) FROM event_recovery
JOIN correlation ON (correlation.correlationid=event_recovery.correlationid)
WHERE event_recovery.correlationid IS NOT NULL
GROUP BY correlation.name
ORDER BY COUNT(*) DESC
LIMIT 15;

--event closed by a user
SELECT users.alias,COUNT(*)
FROM event_recovery 
JOIN users ON (users.userid=event_recovery.userid)
WHERE event_recovery.userid IS NOT NULL
GROUP BY users.alias
ORDER BY COUNT(*) DESC
LIMIT 15;








--Hosts having most problems THEN 'slow frontend THEN 'triggers in problem state
SELECT COUNT(*),
hosts.host,
triggers.description
FROM problem
JOIN 
s ON (triggers.triggerid=problem.objectid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE problem.source=3
AND problem.object=0
GROUP BY functions.functionid,hosts.host,triggers.description
ORDER BY COUNT(*)
DESC LIMIT 15;





--You can stop all active escalation (it does not touch the configuration) THEN 'stop zabbix server and run SQL commands:
--mark all "not sent" emails as "failed" to have a precise info if the user did recieve a notification
update alerts set status=2,error='' where status=0 and alerttype=0;
--stop all active escalations
delete from escalations;






--current trends trends 
SELECT COUNT(*) FROM trends WHERE clock = UNIX_TIMESTAMP("2020-11-30 15:00:00");
SELECT COUNT(*) FROM trends_uint WHERE clock = UNIX_TIMESTAMP("2020-11-30 15:00:00");

SELECT COUNT(*) FROM trends WHERE clock = UNIX_TIMESTAMP("2020-11-30 16:00:00");
SELECT COUNT(*) FROM trends_uint WHERE clock = UNIX_TIMESTAMP("2020-11-30 16:00:00");

--previous hour
SELECT COUNT(*) FROM trends WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 115 MINUTE) AND clock < UNIX_TIMESTAMP(NOW()-INTERVAL 55 MINUTE);
SELECT COUNT(*) FROM trends_uint WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 115 MINUTE) AND clock < UNIX_TIMESTAMP(NOW()-INTERVAL 55 MINUTE);

--now
SELECT COUNT(*) FROM trends WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 55 MINUTE);
SELECT COUNT(*) FROM trends_uint WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 55 MINUTE);

--current trends trends


0 THEN 'ITEM_VALUE_TYPE_FLOAT - Float
1 THEN 'ITEM_VALUE_TYPE_STR - Character
2 THEN 'ITEM_VALUE_TYPE_LOG - Log
3 THEN 'ITEM_VALUE_TYPE_UINT64 - Unsigned integer
4 THEN 'ITEM_VALUE_TYPE_TEXT - Text



--mysql simulate latast data page per history_uint;
SELECT h2.itemid,FROM_UNIXTIME(h2.clock),h2.value FROM history_uint h2
JOIN (
SELECT h.itemid,MAX(h.clock) AS clock
FROM history_uint h
JOIN items i ON i.itemid = h.itemid
WHERE i.hostid=11850
AND h.clock > UNIX_TIMESTAMP(NOW()-INTERVAL 1 HOUR) 
GROUP BY h.itemid
) AS result1
WHERE result1.itemid = h2.itemid
AND h2.clock = result1.clock
ORDER BY h2.itemid;

--postgres simulate latast data page per history_uint
SELECT h2.itemid,h2.clock,h2.value FROM history_uint h2 
JOIN (
SELECT h.itemid,MAX(h.clock) AS clock
FROM history_uint h
JOIN items i ON i.itemid = h.itemid
WHERE i.hostid=17954
AND h.clock > EXTRACT(EPOCH FROM(NOW()-INTERVAL '24 HOUR'))
GROUP BY h.itemid
) result1
ON result1.itemid = h2.itemid
AND h2.clock = result1.clock
ORDER BY h2.itemid;



--events on hourly basis
SELECT COUNT(*) FROM events WHERE source=0 AND clock > UNIX_TIMESTAMP(NOW()-INTERVAL 1 HOUR);


--seek if there are no dublicate records:
SELECT auditid,COUNT(auditid) FROM auditlog GROUP BY auditid HAVING COUNT(auditid) > 0;

SELECT auditid,COUNT(auditid) FROM auditlog GROUP BY auditid HAVING COUNT(auditid) > 1;


--list "Expired" maintenance periods
SELECT 
FROM_UNIXTIME(active_till),
maintenanceid THEN 'name
FROM maintenances
WHERE active_till < UNIX_TIMESTAMP(NOW());

--remove "Expired" maintenance periods
DELETE FROM maintenances
WHERE active_till < UNIX_TIMESTAMP(NOW());




SELECT hosts.host,items.key_ FROM triggers
JOIN functions ON functions.triggerid=triggers.triggerid
JOIN items ON items.itemid=functions.itemid
JOIN hosts ON hosts.hostid=items.hostid
WHERE triggers.triggerid=51962\G

--works on 3.4
SET SESSION group_concat_max_len = 1000000;

SELECT GROUP_CONCAT(FROM_UNIXTIME(alerts.clock),',' THEN 'alerts.subject,',' THEN '`groups`.name SEPARATOR '\n')
FROM alerts
JOIN events ON events.eventid=alerts.eventid
JOIN functions ON functions.triggerid=events.objectid
JOIN items ON items.itemid=functions.itemid
JOIN hosts_groups ON hosts_groups.hostid=items.hostid
JOIN `groups` ON `groups`.groupid=hosts_groups.groupid
WHERE events.source IN (0,3)
AND events.object = 0 
;



SELECT alerts.clock THEN 'alerts.sendto
FROM alerts
JOIN events ON events.eventid=alerts.eventid
JOIN functions ON functions.triggerid=events.objectid
JOIN items ON items.itemid=functions.itemid
JOIN hosts_groups ON hosts_groups.hostid=items.hostid
JOIN groups ON groups.groupid=hosts_groups.groupid
WHERE events.source IN (0,3)
AND events.object = 0;

AND hosts_groups.groupid>0



--works on 5.0
SET SESSION group_concat_max_len = 1000000;
SELECT alerts.clock,
alerts.sendto,
alerts.subject,
hosts_groups.hostgroupid,
hosts_groups.groupid,
hstgrp.name
FROM alerts
JOIN events ON events.eventid=alerts.eventid
JOIN functions ON functions.triggerid=events.objectid
JOIN items ON items.itemid=functions.itemid
JOIN hosts_groups ON hosts_groups.hostid=items.hostid
JOIN `hstgrp` ON `hstgrp`.groupid=hosts_groups.groupid
WHERE events.source IN (0,3)
AND events.object = 0 
;


JOIN hstgrp ON (hstgrp.groupid=hg.hostgroupid)


JOIN functions ON (functions.triggerid=events.objectid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hosts_groups ON (hosts_groups.hostid=hosts.hostid)


WHERE alerts.clock > UNIX_TIMESTAMP("2020-08-21 00:00:00")
AND alerts.clock < UNIX_TIMESTAMP("2020-11-22 00:00:00")



JOIN groups g ON (g.groupid=hosts_groups.hostid)

JOIN hosts_groups ON (host_groups.hostid=hosts.hostid)
JOIN groups ON (groups.groupid=hosts_groups.groupid)





--summarize what alerts has been scheduled in database to be delivered 
SELECT FROM_UNIXTIME(clock) THEN 'sendto THEN 'subject
FROM alerts
WHERE clock > UNIX_TIMESTAMP("2020-08-21 00:00:00")
AND clock < UNIX_TIMESTAMP("2020-11-22 00:00:00")
;

SET SESSION group_concat_max_len = 1000000;
SELECT GROUP_CONCAT(FROM_UNIXTIME(clock),',' THEN 'sendto,',' THEN 'subject SEPARATOR '\n')
FROM alerts
WHERE clock > UNIX_TIMESTAMP("2020-08-21 00:00:00")
AND clock < UNIX_TIMESTAMP("2020-11-22 00:00:00")
\G

GROUP_CONCAT(C.name SEPARATOR ' THEN '')



--historical events
SELECT FROM_UNIXTIME(clock) AS 'time',
       CASE severity
           WHEN 0 THEN 'NOT_CLASSIFIED'
           WHEN 1 THEN 'INFORMATION'
           WHEN 2 THEN 'WARNING'
           WHEN 3 THEN 'AVERAGE'
           WHEN 4 THEN 'HIGH'
           WHEN 5 THEN 'DISASTER'
       END AS severity,
	   CASE acknowledged
           WHEN 0 THEN 'NO'
           WHEN 1 THEN 'YES'
       END AS acknowledged,
	   CASE value
           WHEN 0 THEN 'OK'
           WHEN 1 THEN 'PROBLEM '
       END AS trigger_status,
       name
FROM events
WHERE source=0
  AND object=0
  ORDER BY clock DESC
  LIMIT 10\G

--historical events + host name
SELECT hosts.host,FROM_UNIXTIME(events.clock) AS 'time',
       CASE events.severity
           WHEN 0 THEN 'NOT_CLASSIFIED'
           WHEN 1 THEN 'INFORMATION'
           WHEN 2 THEN 'WARNING'
           WHEN 3 THEN 'AVERAGE'
           WHEN 4 THEN 'HIGH'
           WHEN 5 THEN 'DISASTER'
       END AS severity,
	   CASE events.acknowledged
           WHEN 0 THEN 'NO'
           WHEN 1 THEN 'YES'
       END AS events,
	   CASE events.value
           WHEN 0 THEN 'OK'
           WHEN 1 THEN 'PROBLEM '
       END AS trigger_status,
       events.name
FROM events
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
AND events.object=0
ORDER BY events.clock DESC
LIMIT 10\G
  
--historical event + action name. 5.0
SELECT FROM_UNIXTIME(events.clock) AS 'time',
       CASE events.severity
           WHEN 0 THEN 'NOT_CLASSIFIED'
           WHEN 1 THEN 'INFORMATION'
           WHEN 2 THEN 'WARNING'
           WHEN 3 THEN 'AVERAGE'
           WHEN 4 THEN 'HIGH'
           WHEN 5 THEN 'DISASTER'
       END AS severity,
	   CASE events.acknowledged
           WHEN 0 THEN 'NO'
           WHEN 1 THEN 'YES'
       END AS acknowledged,
	   CASE events.value
           WHEN 0 THEN 'OK'
           WHEN 1 THEN 'PROBLEM '
       END AS trigger_status,
       events.name AS 'event',
	   actions.name AS 'action'
FROM events
JOIN alerts ON (alerts.eventid=events.eventid)
JOIN actions ON (actions.actionid=alerts.actionid)
WHERE events.source=0
AND events.object=0
ORDER BY events.clock ASC
LIMIT 10\G






  
--historical event + action name. 3.0
SELECT FROM_UNIXTIME(events.clock),
       triggers.description,
	   actions.name
FROM events
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN alerts ON (alerts.eventid=events.eventid)
JOIN actions ON (actions.actionid=alerts.actionid)
WHERE events.source=0
AND events.object=0
ORDER BY events.clock ASC
LIMIT 10;



--critical attributes per overloaded database
SELECT @@hostname, @@version, @@datadir, @@innodb_file_per_table;


--list action names which reference the 'email' delivery only. solution is based in existing records in database. zabbix 5.0
SELECT DISTINCT actions.name
FROM actions
JOIN alerts ON (alerts.actionid=actions.actionid)
JOIN media_type ON (media_type.mediatypeid=alerts.mediatypeid)
WHERE media_type.name='Email Google';

--3.0
SELECT DISTINCT actions.name
FROM actions
JOIN alerts ON (alerts.actionid=actions.actionid)
JOIN media_type ON (media_type.mediatypeid=alerts.mediatypeid)
WHERE media_type.description='Email';


--Show all actions per each media type. Zabbix 5.0
SELECT DISTINCT actions.name AS 'action name',
media_type.name AS 'media type'
FROM actions
JOIN alerts ON (alerts.actionid=actions.actionid)
JOIN media_type ON (media_type.mediatypeid=alerts.mediatypeid)
GROUP BY media_type.name,actions.name
ORDER BY 1,2
\G

--3.0
SELECT DISTINCT actions.name AS 'action name',
media_type.description AS 'media type'
FROM actions
JOIN alerts ON (alerts.actionid=actions.actionid)
JOIN media_type ON (media_type.mediatypeid=alerts.mediatypeid)
GROUP BY media_type.description,actions.name
ORDER BY 1,2
\G


--zabbix 5.0 identify dashboard based on itemid in classic graph
SELECT name FROM dashboard WHERE dashboardid IN (
SELECT dashboardid FROM widget WHERE widgetid IN (
SELECT widgetid FROM widget_field WHERE value_graphid IN (
SELECT graphid FROM graphs_items WHERE itemid=137127
)
)
);


--widget refresh rate configured inside widget
SELECT
dashboard.dashboardid,
widget.type,
users.alias,
widget_field.value_int
FROM widget_field
JOIN widget ON (widget.widgetid=widget_field.widgetid)
JOIN dashboard ON (dashboard.dashboardid=widget.dashboardid)
JOIN users ON (users.userid=dashboard.userid)
WHERE widget_field.type=0
AND widget_field.name='rf_rate'
;

--reset dashboard global settings to 15m

SELECT * FROM widget_field WHERE name='rf_rate';

UPDATE widget_field SET value_int=900 WHERE name='rf_rate';
--dashboard never reloads
UPDATE widget_field SET value_int=0 WHERE name='rf_rate';

--dashboard widget refresh
select * from profiles where idx='web.dashbrd.widget.rf_rate';
--dashboard widget refresh set to 15m
update profiles set value_int=900 where idx='web.dashbrd.widget.rf_rate';
--disable automatic refresh
update profiles set value_int=0 where idx='web.dashbrd.widget.rf_rate';




--update LDAP configuration via SQL
UPDATE config
SET ldap_host='ldaps://ldaps',
    ldap_port='636',
    ldap_base_dn='OU=UsersForZabbix,OU=TopSecret,DC=custom,DC=lan',
    ldap_bind_dn='CN=zbxldap,OU=UsersForZabbix,OU=TopSecret,DC=custom,DC=lan',
    ldap_bind_password='Abc12345',
    ldap_search_attribute='sAMAccountName',
    ldap_configured='1',
    ldap_case_sensitive='0';

--get SLA from database regarding IT services
SELECT 
FROM_UNIXTIME(service_alarms.clock) AS 'clock',
services.name,
CASE
WHEN service_alarms.value=0 THEN 'OK'
WHEN service_alarms.value=2 THEN 'Warning'
WHEN service_alarms.value=3 THEN 'Average'
WHEN service_alarms.value=4 THEN 'High'
WHEN service_alarms.value=5 THEN 'Disaster'
END AS 'severity'
FROM service_alarms
JOIN services ON (services.serviceid=service_alarms.serviceid)
ORDER BY service_alarms.clock ASC;




--which inventory field in host level will override inventory field
SELECT hosts.host,
items.key_,
CASE
WHEN items.inventory_link=1 THEN 'type'
WHEN items.inventory_link=2 THEN 'type_full'
WHEN items.inventory_link=3 THEN 'name'
WHEN items.inventory_link=4 THEN 'alias'
WHEN items.inventory_link=5 THEN 'os'
WHEN items.inventory_link=6 THEN 'os_full'
WHEN items.inventory_link=7 THEN 'os_short'
WHEN items.inventory_link=8 THEN 'serialno_a'
WHEN items.inventory_link=9 THEN 'serialno_b'
WHEN items.inventory_link=10 THEN 'tag'
WHEN items.inventory_link=11 THEN 'asset_tag'
WHEN items.inventory_link=12 THEN 'macaddress_a'
WHEN items.inventory_link=13 THEN 'macaddress_b'
WHEN items.inventory_link=14 THEN 'hardware'
WHEN items.inventory_link=15 THEN 'hardware_full'
WHEN items.inventory_link=16 THEN 'software'
WHEN items.inventory_link=17 THEN 'software_full'
WHEN items.inventory_link=18 THEN 'software_app_a'
WHEN items.inventory_link=19 THEN 'software_app_b'
WHEN items.inventory_link=20 THEN 'software_app_c'
WHEN items.inventory_link=21 THEN 'software_app_d'
WHEN items.inventory_link=22 THEN 'software_app_e'
WHEN items.inventory_link=23 THEN 'contact'
WHEN items.inventory_link=24 THEN 'location'
WHEN items.inventory_link=25 THEN 'location_lat'
WHEN items.inventory_link=26 THEN 'location_lon'
WHEN items.inventory_link=27 THEN 'notes'
WHEN items.inventory_link=28 THEN 'chassis'
WHEN items.inventory_link=29 THEN 'model'
WHEN items.inventory_link=30 THEN 'hw_arch'
WHEN items.inventory_link=31 THEN 'vendor'
WHEN items.inventory_link=32 THEN 'contract_number'
WHEN items.inventory_link=33 THEN 'installer_name'
WHEN items.inventory_link=34 THEN 'deployment_status'
WHEN items.inventory_link=35 THEN 'url_a'
WHEN items.inventory_link=36 THEN 'url_b'
WHEN items.inventory_link=37 THEN 'url_c'
WHEN items.inventory_link=38 THEN 'host_networks'
WHEN items.inventory_link=39 THEN 'host_netmask'
WHEN items.inventory_link=40 THEN 'host_router'
WHEN items.inventory_link=41 THEN 'oob_ip'
WHEN items.inventory_link=42 THEN 'oob_netmask'
WHEN items.inventory_link=43 THEN 'oob_router'
WHEN items.inventory_link=44 THEN 'date_hw_purchase'
WHEN items.inventory_link=45 THEN 'date_hw_install'
WHEN items.inventory_link=46 THEN 'date_hw_expiry'
WHEN items.inventory_link=47 THEN 'date_hw_decomm'
WHEN items.inventory_link=48 THEN 'site_address_a'
WHEN items.inventory_link=49 THEN 'site_address_b'
WHEN items.inventory_link=50 THEN 'site_address_c'
WHEN items.inventory_link=51 THEN 'site_city'
WHEN items.inventory_link=52 THEN 'site_state'
WHEN items.inventory_link=53 THEN 'site_country'
WHEN items.inventory_link=54 THEN 'site_zip'
WHEN items.inventory_link=55 THEN 'site_rack'
WHEN items.inventory_link=56 THEN 'site_notes'
WHEN items.inventory_link=57 THEN 'poc_1_name'
WHEN items.inventory_link=58 THEN 'poc_1_email'
WHEN items.inventory_link=59 THEN 'poc_1_phone_a'
WHEN items.inventory_link=60 THEN 'poc_1_phone_b'
WHEN items.inventory_link=61 THEN 'poc_1_cell'
WHEN items.inventory_link=62 THEN 'poc_1_screen'
WHEN items.inventory_link=63 THEN 'poc_1_notes'
WHEN items.inventory_link=64 THEN 'poc_2_name'
WHEN items.inventory_link=65 THEN 'poc_2_email'
WHEN items.inventory_link=66 THEN 'poc_2_phone_a'
WHEN items.inventory_link=67 THEN 'poc_2_phone_b'
WHEN items.inventory_link=68 THEN 'poc_2_cell'
WHEN items.inventory_link=69 THEN 'poc_2_screen'
WHEN items.inventory_link=70 THEN 'poc_2_notes'
END AS 'will overwrite'
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.inventory_link > 0
ORDER BY hosts.host
\G



--recent activity
select max(FROM_UNIXTIME(clock)) FROM alerts WHERE actionid=48 AND clock < UNIX_TIMESTAMP(NOW()-INTERVAL 24 HOUR);


--why and when alert failed
SELECT
FROM_UNIXTIME(alerts.clock) AS 'time',
actions.name,
users.alias,
alerts.error
FROM alerts
JOIN actions ON (actions.actionid=alerts.actionid)
LEFT JOIN users ON (users.userid=alerts.userid)
WHERE alerts.status=2
AND alerts.clock > UNIX_TIMESTAMP(NOW()-INTERVAL 1 DAY)
ORDER BY alerts.clock ASC
LIMIT 10\G
--At least 3 steps are involved in the notification:
----Escalator. This process cooks the message a validates if a destination (telephone number THEN 'email) is configured in user card;
----Alert manager. It's a single process which passes the task to the individual worker;
----Alerter. A process which actually executes the delivery. Can be multiple concurrent processes. Can be a bottleneck if the command cannot be executed successfully (timeout THEN 'permission THEN 'DNS THEN 'credential issue).


SELECT 
  FROM_UNIXTIME(alerts.clock) AS 'time',
  actions.name,
  users.alias,
  alerts.error
FROM alerts
  JOIN actions ON (actions.actionid=alerts.actionid)
  LEFT JOIN users ON (users.userid=alerts.userid)
WHERE alerts.status=2
AND alerts.clock > UNIX_TIMESTAMP(NOW()-INTERVAL 1 DAY) 
ORDER BY alerts.clock ASC
LIMIT 10\G 


--predict when the next check will happen
SELECT FROM_UNIXTIME(MAX(clock)+3600) FROM history_uint WHERE itemid=248757;

--info about template triggers
SELECT COUNT(DISTINCT events.eventid),trigger_template.description THEN 'hosts.host FROM events
    JOIN triggers ON (triggers.triggerid=events.objectid)
    JOIN triggers trigger_template on (triggers.templateid=trigger_template.triggerid)
    JOIN functions ON (functions.triggerid=trigger_template.triggerid)
    JOIN items ON (items.itemid=functions.itemid)
    JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
AND events.object=0
GROUP BY trigger_template.description,hosts.host
ORDER BY COUNT(DISTINCT events.eventid) ASC\G


--report about discovered triggers only
select COUNT(DISTINCT events.eventid),trigger_template.description FROM events
    left join trigger_discovery on events.objectid=trigger_discovery.triggerid
    left join triggers on trigger_discovery.parent_triggerid=triggers.triggerid
    LEFT JOIN triggers trigger_template on (triggers.templateid=trigger_template.triggerid)
    left JOIN functions ON (functions.triggerid=trigger_template.triggerid)
    left JOIN items ON (items.itemid=functions.itemid)
    left JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
AND events.object=0
AND events.value=1
GROUP BY trigger_template.description
ORDER BY COUNT(DISTINCT events.eventid) ASC\G


--show how many event records have been generated per each host 
SELECT COUNT(DISTINCT events.eventid),hosts.host
FROM events
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
AND events.object=0
GROUP BY hosts.host
ORDER BY COUNT(DISTINCT events.eventid) ASC;


--delete all events comming from specific trigger id. only execute if trigger is not in problem state
DELETE FROM events WHERE events.source=0 AND events.object=0 AND events.objectid=726241;


--how many hosts are directly attached to master server
SELECT COUNT(*) FROM hosts WHERE proxy_hostid is NULL AND status=0;
SELECT host FROM hosts WHERE proxy_hostid is NULL AND status=0;


--show alerts by status in the last 7 days. Zabbix 5.0
SELECT COUNT(*),
alerts.actionid,actions.name,
CASE alerts.status
WHEN 0 THEN 'NOT_SENT'
WHEN 1 THEN 'SENT'
WHEN 2 THEN 'FAILED'
WHEN 3 THEN 'NEW'
END AS status
FROM alerts
JOIN actions ON (actions.actionid=alerts.actionid)
GROUP BY alerts.actionid,alerts.status,actions.name
ORDER BY COUNT(*) ASC\G


--actions which are responsible for initiating the delivery
SELECT COUNT(*),
actions.name
FROM alerts 
JOIN actions ON (actions.actionid=alerts.actionid)
WHERE alerts.clock > UNIX_TIMESTAMP (NOW()-INTERVAL 1 DAY)
GROUP BY 2
ORDER BY 1;



--hosts THEN 'host groups THEN 'items THEN 'item applications
SELECT
GROUP_CONCAT(DISTINCT applications.applicationid),
GROUP_CONCAT(hosts_groups.hostgroupid),
hosts.hostid,
items.itemid,
hosts.available,
interface.type,
interface.dns,
hosts.host,
hosts.error,
item_rtdata.error
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN items_applications ON (items_applications.itemid=items.itemid)
JOIN applications ON (applications.applicationid=items_applications.applicationid)
JOIN host_inventory ON (host_inventory.hostid=hosts.hostid)
JOIN hosts_groups ON (hosts_groups.hostid=hosts.hostid)
JOIN interface ON (interface.hostid=hosts.hostid)
JOIN item_rtdata ON (item_rtdata.itemid=items.itemid)
WHERE hosts.status IN (0,1)
AND hosts.hostid=12589
GROUP BY 3,4,5,6,7,8,9,10
\G




--show most consuming items per data storage float (table history)
SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '
(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables 
WHERE TABLE_NAME = 'history' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN '
sum(length(history.value))/1024/1024 + sum(length(history.clock))/1024/1024 + sum(length(history.ns))/1024/1024 + sum(length(history.itemid))/1024/1024 AS 'History Column Size (Mb)'
FROM history PARTITION (p2021_01_21)
LEFT OUTER JOIN items i on history.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1) 
GROUP BY ho.hostid
ORDER BY 4 DESC
LIMIT 10;


--biggest integers
SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '
(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables 
WHERE TABLE_NAME = 'history_uint' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN '
sum(length(history_uint.value))/1024/1024 + sum(length(history_uint.clock))/1024/1024 + sum(length(history_uint.ns))/1024/1024 + sum(length(history_uint.itemid))/1024/1024 AS 'history_uint Column Size (Mb)'
FROM history_uint PARTITION (p2021_01_21)
LEFT OUTER JOIN items i on history_uint.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1) 
GROUP BY ho.hostid
ORDER BY 4 DESC
LIMIT 10;


--biggest text values
SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '
(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables 
WHERE TABLE_NAME = 'history_text' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN '
sum(length(history_text.value))/1024/1024 + 
sum(length(history_text.clock))/1024/1024 +
sum(length(history_text.ns))/1024/1024 + 
sum(length(history_text.itemid))/1024/1024 AS 'history_text Column Size (Mb)'
FROM history_text PARTITION (p2021_01_21)
LEFT OUTER JOIN items i on history_text.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1)
GROUP BY ho.hostid
ORDER BY 4 DESC
LIMIT 10;


--Total size average (Mb) which multiplies the average row size by the number of records for host THEN 'thus the average
--<table name> Size (Mb) which is the raw column size in the table without any overhead how the data is stored (indexes THEN 'extra storage needed)
SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '
(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables 
WHERE TABLE_NAME = 'history' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN '
sum(length(h.value))/1024/1024 + sum(length(h.clock))/1024/1024 + sum(length(h.ns))/1024/1024 + sum(length(h.itemid))/1024/1024 AS 'History Column Size (Mb)'
FROM history PARTITION (p202009290000) h
LEFT OUTER JOIN items i on h.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1) 
GROUP BY ho.hostid;



SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables WHERE TABLE_NAME = 'history' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN 'sum(length(h.value))/1024/1024 + sum(length(h.clock))/1024/1024 + sum(length(h.ns))/1024/1024 + sum(length(h.itemid))/1024/1024 AS 'History Column Size (Mb)'
FROM history h 
LEFT OUTER JOIN items i on h.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1) 
GROUP BY ho.hostid;




SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables WHERE TABLE_NAME = 'history_uint' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN 'sum(length(h.value))/1024/1024 + sum(length(h.clock))/1024/1024 + sum(length(h.ns))/1024/1024 + sum(length(h.itemid))/1024/1024 AS 'History Column Size (Mb)'
FROM history_uint h 
LEFT OUTER JOIN items i on h.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1) 
GROUP BY ho.hostid;

SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables WHERE TABLE_NAME = 'history_text' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN 'sum(length(h.value))/1024/1024 + sum(length(h.clock))/1024/1024 + sum(length(h.ns))/1024/1024 + sum(length(h.itemid))/1024/1024 AS 'History Column Size (Mb)'
FROM history_text h 
LEFT OUTER JOIN items i on h.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1) 
GROUP BY ho.hostid;

SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables WHERE TABLE_NAME = 'history_str' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN 'sum(length(h.value))/1024/1024 + sum(length(h.clock))/1024/1024 + sum(length(h.ns))/1024/1024 + sum(length(h.itemid))/1024/1024 AS 'History Column Size (Mb)'
FROM history_str h 
LEFT OUTER JOIN items i on h.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1) 
GROUP BY ho.hostid;

SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables WHERE TABLE_NAME = 'history_log' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN 'sum(length(h.value))/1024/1024 + sum(length(h.clock))/1024/1024 + sum(length(h.ns))/1024/1024 + sum(length(h.itemid))/1024/1024 AS 'History Column Size (Mb)'
FROM history_log h 
LEFT OUTER JOIN items i on h.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1) 
GROUP BY ho.hostid;

SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables WHERE TABLE_NAME = 'trends' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN 'sum(char_length(t.value_min))/1024/1024 + sum(char_length(t.value_max))/1024/1024 + sum(char_length(t.value_avg))/1024/1024 + sum(char_length(t.clock))/1024/1024 + sum(char_length(t.num))/1024/1024 + sum(char_length(t.itemid))/1024/1024 AS 'Trends Size (Mb)'
FROM trends t 
LEFT OUTER JOIN items i on t.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1) 
GROUP BY ho.hostid;

SELECT ho.hostid THEN 'ho.name THEN 'count(*) AS records THEN '(count(*)* (SELECT AVG_ROW_LENGTH FROM information_schema.tables WHERE TABLE_NAME = 'trends_uint' and TABLE_SCHEMA = 'zabbix')/1024/1024) AS 'Total size average (Mb)' THEN 'sum(char_length(t.value_min))/1024/1024 + sum(char_length(t.value_max))/1024/1024 + sum(char_length(t.value_avg))/1024/1024 + sum(char_length(t.clock))/1024/1024 + sum(char_length(t.num))/1024/1024 + sum(char_length(t.itemid))/1024/1024 AS 'Trends_uint Size (Mb)' 
FROM trends_uint t 
LEFT OUTER JOIN items i on t.itemid = i.itemid 
LEFT OUTER JOIN hosts ho on i.hostid = ho.hostid 
WHERE ho.status IN (0,1) 
GROUP BY ho.hostid;



--<table name> Size (Mb) which is the raw column size in the table without any overhead how the data is stored (indexes THEN 'extra storage needed)


--list items per host by listing first application. show all applications
SELECT
applications.name,
items.name,
host_inventory.os_full,
host_inventory.os_short,
host_inventory.contact
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN items_applications ON (items_applications.itemid=items.itemid)
JOIN applications ON (applications.applicationid=items_applications.applicationid)
JOIN host_inventory ON (host_inventory.hostid=hosts.hostid)
JOIN hosts_groups ON (hosts_groups.hostid=hosts.hostid)
WHERE hosts.status IN (0,1)
AND applications.name=''
GROUP BY 1,2,3,4,5
\G


--list items per host by listing first application
SELECT
items.name,
applications.name
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN items_applications ON (items_applications.itemid=items.itemid)
JOIN applications ON (applications.applicationid=items_applications.applicationid)
WHERE hosts.status IN (0,1)
AND hosts.hostid=12589
\G

--items with an empty application
SELECT
items.name
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE itemid NOT IN (SELECT itemid FROM items_applications)
AND hosts.status=0;


JOIN items_applications ON (items_applications.itemid=items.itemid)
JOIN applications ON (applications.applicationid=items_applications.applicationid)
WHERE hosts.status IN (0,1)
AND hosts.hostid=12589
\G


--show all host groups per each hosts (active,disabled) THEN 'framework
SELECT hosts.hostid,
GROUP_CONCAT(hosts_groups.groupid)
FROM hosts
JOIN hosts_groups ON (hosts_groups.hostid=hosts.hostid)
WHERE status IN (0,1)
GROUP BY hosts.hostid
;

--host group names per host. Works on 5.0
SELECT hosts.host,
GROUP_CONCAT(hstgrp.name)
FROM hosts
JOIN hosts_groups ON (hosts_groups.hostid=hosts.hostid)
JOIN hstgrp ON (hosts_groups.groupid=hstgrp.groupid)
WHERE status IN (0,1)
GROUP BY hosts.hostid
;


--postgres
SELECT hosts.hostid THEN 'hosts.name THEN 'array_to_string(array_agg(hstgrp.name),',') as Groups
FROM hosts
LEFT JOIN hosts_groups ON hosts_groups.hostid=hosts.hostid
LEFT JOIN hstgrp ON hosts_groups.groupid = hstgrp.groupid
WHERE status IN (0,1)
GROUP BY hosts.hostid;



-- delete internal events
DELETE FROM events WHERE source IN (1,2,3) LIMIT 100;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 1000;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 10000;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 100000;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 1000000;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 10000000;

--backup schema
mysqldump --flush-logs --single-transaction --create-options --no-data zabbix > schema.sql




--mysql console
SHOW ENGINE INNODB STATUS;
SHOW VARIABLES\G;
SELECT  SUM(ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024 /1024 ) THEN '2))  AS "SIZE IN GB" FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = "zabbix";




--list templates and item update intervals
SELECT template.host,
items.name,
items.delay
FROM items 
JOIN hosts template ON (template.hostid=items.hostid)
WHERE template.status=3
AND items.type IN (0,7)
\G










--show triggers per host and show which template is delivering this trigger
SELECT DISTINCT triggers.description THEN 'h.host THEN 'htempl.host AS template FROM triggers
LEFT JOIN functions ON functions.triggerid=triggers.triggerid
LEFT JOIN items ON items.itemid=functions.itemid
LEFT JOIN hosts h ON h.hostid=items.hostid
LEFT JOIN hosts_templates ht ON ht.hostid=h.hostid
LEFT JOIN hosts htempl ON htempl.hostid=ht.templateid
WHERE h.status=0 AND h.flags IN (0,4)
AND triggers.flags<>2
AND h.hostid=12025
\G


--functions which consumes most power of history syncer 
SELECT COUNT(*),items.delay,functions.name,functions.parameter
FROM functions
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.itemid)
WHERE functions.name IN ('avg','max','min','nodata','iregexp')
AND functions.parameter='3'
GROUP BY functions.name,functions.parameter,items.delay
ORDER BY COUNT(*) DESC
LIMIT 200;



select hosts.host,
items.name,
functions.name,
functions.parameter
FROM functions 
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.itemid)
WHERE functions.name='avg'
AND functions.parameter='3';



--possibilities to grow
select COUNT(*),name,parameter FROM functions GROUP BY name,parameter ORDER BY name;




--list all enabled items per host on 4.0 THEN '4.2:
SELECT type,state,key_,error FROM items WHERE status=0 AND hostid=46505681\G

CREATE USER "healthlist"@"10.133.253.43" IDENTIFIED BY "zabbix";
ALTER USER "healthlist"@"10.133.253.43" IDENTIFIED WITH mysql_native_password BY "zabbix";


GRANT SELECT THEN 'UPDATE THEN 'DELETE THEN 'INSERT THEN 'CREATE THEN 'DROP THEN 'ALTER THEN 'INDEX THEN 'REFERENCES ON zabbix.* TO "healthlist"@"10.133.253.43";
GRANT ALL ON zabbix.* TO "healthlist"@"10.133.253.43";
show grants for "healthlist"@"10.133.253.43";
FLUSH PRIVILEGES;


GRANT SELECT THEN 'INSERT THEN 'UPDATE THEN 'DELETE THEN 'CREATE THEN 'DROP THEN 'REFERENCES THEN 'INDEX THEN 'ALTER THEN 'CREATE TEMPORARY TABLES THEN 'LOCK TABLES THEN 'EXECUTE THEN 'CREATE VIEW THEN 'SHOW VIEW THEN 'CREATE ROUTINE THEN 'ALTER ROUTINE THEN 'EVENT THEN 'TRIGGER ON "zabbix".* TO "healthlist"@"10.133.253.43";


JOIN hosts ON (hosts.hostid=items.hostid)



--show agents who has dublicate interfaces
SELECT hosts.host FROM interface
JOIN hosts ON (hosts.hostid=interface.hostid)
WHERE interface.type=1
AND interface.main=0;

--delete secondary agent interfaces
DELETE FROM interface WHERE interface.type=1 AND interface.main=0;
DELETE FROM interface WHERE interface.type=1 AND interface.main=0 LIMIT 1;

--delete secondary SNMP interfaces
DELETE FROM interface WHERE interface.type=2 AND interface.main=0 LIMIT 1;


--set all agent passive checks to use DNS instaed of IP. check the lenght before adjusting
UPDATE interface SET useip=0 WHERE type=1 AND main=1 AND LENGTH(dns)>0;

--set all agent passive checks to use IP instaed of DNS
UPDATE interface SET useip=1 WHERE type=1 AND main=1;


--show hosts where inventory field are disabled
SELECT host FROM hosts
WHERE hostid NOT IN (
SELECT hostid FROM host_inventory
)
ORDER BY host ASC;

--Hosts list where Inventory is "Manual" OR "Automatic":
SELECT host FROM hosts
WHERE hostid IN (
SELECT hostid FROM host_inventory
)
ORDER BY host ASC;



UPDATE interface ii,hosts h SET ii.useip=0 WHERE h.hostid=ii.hostid AND ii.useip=1 AND LENGTH(ii.dns)>0 and h.host='bcm2711';



--show dublicate agent interfaces behind proxy. This will not show agents connected directly to master server
SELECT 
proxy.host,
hosts.host,
GROUP_CONCAT(interface.interfaceid) as 'interfaces'
FROM interface
JOIN hosts ON (hosts.hostid=interface.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE interface.type=1
GROUP BY proxy.host,hosts.host
HAVING COUNT(interface.interfaceid)>1
;
  

SELECT 
task_remote_command.hostid,
task_remote_command.command_type,
CASE task_remote_command.execute_on
WHEN 0 THEN 'agent'
WHEN 1 THEN 'server'
WHEN 2 THEN 'proxy'
END as execute_on,
task_remote_command.hostid
FROM task_remote_command
JOIN task ON (task.taskid=task_remote_command.taskid)
WHERE task.proxy_hostid=10275
ORDER BY task.clock ASC
LIMIT 30;
  
  
  
 
  

--list all disabled hosts THEN 'proxy
SELECT GROUP_CONCAT(hosts.hostid)
FROM hosts
JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
JOIN interface ON (interface.hostid=hosts.hostid)
WHERE hosts.status = 1
and p.host='proxy.name';


--grab session key from any "Zabbix Super Admin"

SELECT sessionid
FROM sessions
WHERE userid IN (
SELECT userid FROM users WHERE type=3
)
AND status=0
LIMIT 1;

SELECT sessionid FROM sessions WHERE userid IN (SELECT userid FROM users WHERE type=3) AND status=0 LIMIT 1;


select alias from users where type=3







SELECT @@hostname,
@@version,
@@datadir,
@@innodb_file_per_table,
@@innodb_buffer_pool_size,
@@innodb_buffer_pool_instances,
@@innodb_flush_method,
@@innodb_log_file_size,
@@max_connections,
@@open_files_limit,
@@innodb_flush_log_at_trx_commit,
@@optimizer_switch\G






SELECT @@hostname,
@@version,
@@datadir,
@@innodb_file_per_table;

--new records in the actions and escalations tables
select count(*),actionid,status from escalations group by actionid,status order by count(*);
select count(*),actionid,status from actions group by actionid,status order by count(*);


/* items having problems receiving data. Super useful select to summarize and fix issues for data gathering. works on 4.0 THEN '4.4 */
--At the end of the list THEN 'it will show the most spamming items and the responsible host
SELECT hosts.host,
       events.objectid AS itemid,
       items.key_,
       events.name AS error,
       COUNT(events.objectid) AS occurrence
FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source = 3
  AND events.object = 4
  AND LENGTH(events.name)>0
GROUP BY hosts.host,events.objectid,items.key_,events.name
ORDER BY COUNT(*) ASC
\G 

--failing LLD
SELECT hosts.host,
       events.objectid AS itemid,
       items.key_,
       events.name AS error,
       COUNT(events.objectid) AS occurrence
FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source = 3
  AND events.object = 5
  AND LENGTH(events.name)>0
GROUP BY hosts.host,events.objectid,items.key_,events.name
ORDER BY COUNT(*) ASC




--show trigger evaluation problems - internal events. best query ever! golden query
--it will print result x3 if bultiple functions are used in one trigger expression
SELECT DISTINCT hosts.name,
                COUNT(hosts.name),
                items.key_,
                triggers.error
FROM events
JOIN triggers ON (events.objectid=triggers.triggerid)
JOIN functions ON (functions.triggerid = triggers.triggerid)
JOIN items ON (items.itemid = functions.itemid)
JOIN hosts ON (items.hostid = hosts.hostid)
WHERE events.source=3
  AND events.object=0
  AND triggers.flags IN (0,4)
  AND triggers.state=1
GROUP BY hosts.name,items.key_,triggers.error
ORDER BY COUNT(hosts.name) ASC,
         hosts.name,
         items.key_,
         triggers.error
\G



--how many events are generated lately
SELECT source,COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2020-08-21 00:00:00") AND clock < UNIX_TIMESTAMP("2020-08-22 00:00:00") GROUP BY source;
SELECT source,COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2020-08-22 00:00:00") AND clock < UNIX_TIMESTAMP("2020-08-23 00:00:00") GROUP BY source;
SELECT source,COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2020-08-23 00:00:00") AND clock < UNIX_TIMESTAMP("2020-08-24 00:00:00") GROUP BY source;
SELECT source,COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2020-08-24 00:00:00") AND clock < UNIX_TIMESTAMP("2020-08-25 00:00:00") GROUP BY source;
SELECT source,COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2020-08-25 00:00:00") AND clock < UNIX_TIMESTAMP("2020-08-26 00:00:00") GROUP BY source;
SELECT source,COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2020-08-26 00:00:00") AND clock < UNIX_TIMESTAMP("2020-08-27 00:00:00") GROUP BY source;
SELECT source,COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2020-08-27 00:00:00") AND clock < UNIX_TIMESTAMP("2020-08-28 00:00:00") GROUP BY source;
SELECT source,COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2020-08-28 00:00:00") AND clock < UNIX_TIMESTAMP("2020-08-29 00:00:00") GROUP BY source;
SELECT source,COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2020-08-29 00:00:00") AND clock < UNIX_TIMESTAMP("2020-08-30 00:00:00") GROUP BY source;
SELECT source,COUNT(*) FROM events WHERE clock >= UNIX_TIMESTAMP("2020-08-30 00:00:00") AND clock < UNIX_TIMESTAMP("2020-08-31 00:00:00") GROUP BY source;



--delete hosts with dublicate names
DELETE h1 FROM hosts h1
INNER JOIN hosts h2 
WHERE h1.hostid < h2.hostid AND h1.host = h2.host;

SELECT a1.auditid FROM auditlog
JOIN auditlog a2
WHERE a1.auditid < a2.auditid;






--check if some dublicates left
SELECT host,COUNT(host) FROM hosts GROUP BY host HAVING  COUNT(host) > 1;


--How to disable triggers:
create table triggers_tmp (triggerid bigint(20) THEN 'status int(11));
insert into triggers_tmp (triggerid THEN 'status) select triggerid THEN 'status from triggers;
update triggers set status = 1;

--Enable back:
UPDATE triggers t INNER JOIN triggers_tmp tt ON tt.triggerid=t.triggerid SET t.status = tt.status;



-- We workaround the issue by moving all disable hosts from this proxy to another dummy proxy.



--move hosts to different proxy
UPDATE hosts SET proxy_hostid=1234 WHERE hostid IN (

) 



--show which LLD is disable or a template item
SELECT COUNT(*) as count,
items.key_,items.delay,
CASE items.status
WHEN 0 THEN 'Active'
WHEN 1 THEN 'Disabled'
END as status,
CASE hosts.status
WHEN 0 THEN 'host is monitored'
WHEN 1 THEN 'host is not monitored'
WHEN 3 THEN 'template setting'
END AS type
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags=1 
AND hosts.status=0 
GROUP BY 2,3,4,5
\G



--To disable all the actions you should execute
update actions set status=1;

--To see the current status of actions you can use
select name THEN 'status from actions;
--where 0 means enabled THEN 'and 1 - disabled.


--look if any dublicate host names are in the instance
SELECT COUNT(*) AS count,
hosts.host AS name,
CASE interface.type
WHEN 0 THEN 'UNKNOWN'
WHEN 1 THEN 'AGENT'
WHEN 2 THEN 'SNMP'
WHEN 3 THEN 'IPMI'
WHEN 4 THEN 'JMX'
END AS type,
interface.ip
FROM hosts
JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
JOIN interface ON (interface.hostid=hosts.hostid)
GROUP BY hosts.host,interface.type,interface.ip
ORDER BY COUNT(*) ASC
\G


--show all items and also discovered items + template name item key THEN 'name. Zabbix 4.0
select i.hostid,i.itemid,i.name as ItemName,i.key_ as ItemKey,id.parent_itemid as LLDItemID,ii.key_ as LLDItemKey,ii.name as LLDItemName,idd.parent_itemid as LLDRuleID,iddd.name as LLDRuleName,case when iiih.name is not null then iiih.name else dii.name end as TemplateName from items i left join item_discovery id on i.itemid=id.itemid left join items ii on id.parent_itemid=ii.itemid left join items iii on iii.itemid=ii.templateid left join hosts iiih on iiih.hostid=iii.hostid left join item_discovery idd on id.parent_itemid=idd.itemid left join items iddd on idd.parent_itemid=iddd.itemid left join items di on i.templateid=di.itemid left join hosts dii on di.hostid=dii.hostid where i.hostid=10084 and i.flags in (0,4) limit 50;

--only discovered items. Zabbix 4.0
select i.name as 'Item name',iiii.name as 'Discovery rule',i.key_,h.host as Hostname THEN 'hh.host as Template from items i inner join hosts h on i.hostid = h.hostid left join item_discovery id on i.itemid=id.itemid left join items ii on id.parent_itemid=ii.itemid left join items iii on iii.itemid=ii.templateid left join hosts hh on iii.hostid=hh.hostid left join item_discovery idd on id.parent_itemid=idd.itemid left join items iiii on idd.parent_itemid=iiii.itemid where i.flags = 4 and h.host = "Zabbix server"



--show incomming agent autoregistration
SELECT FROM_UNIXTIME(events.clock),
autoreg_host.host 
FROM events 
JOIN autoreg_host ON (autoreg_host.autoreg_hostid=events.objectid)
WHERE source=2 AND object=3
AND autoreg_host.host=''
ORDER BY events.clock ASC
;


SELECT events.clock,
autoreg_host.host 
FROM events 
JOIN autoreg_host ON (autoreg_host.autoreg_hostid=events.objectid)
WHERE source=2 AND object=3
AND autoreg_host.host=''
ORDER BY events.clock ASC
;



--what happens after event acknowledgement. 4.0
SELECT 
acknowledges.eventid,
triggers.triggerid,
CASE task.status
WHEN 1 THEN 'new task ready for execution'
WHEN 2 THEN 'task being already executed'
WHEN 3 THEN 'finished task'
WHEN 4 THEN 'expired task'
END AS "status",
task.type,
task_close_problem.taskid 
FROM task_close_problem
JOIN acknowledges ON (acknowledges.acknowledgeid=task_close_problem.acknowledgeid)
JOIN task ON (task.taskid=task_close_problem.taskid)
JOIN events ON (events.eventid=acknowledges.eventid)
JOIN triggers ON (triggers.triggerid=events.objectid)
;


--group tasks
SELECT COUNT(*),
triggers.triggerid,
CASE task.status
WHEN 1 THEN 'new task ready for execution'
WHEN 2 THEN 'task being already executed'
WHEN 3 THEN 'finished task'
WHEN 4 THEN 'expired task'
END AS "status",
task.type
FROM task_close_problem
JOIN acknowledges ON (acknowledges.acknowledgeid=task_close_problem.acknowledgeid)
JOIN task ON (task.taskid=task_close_problem.taskid)
JOIN events ON (events.eventid=acknowledges.eventid)
JOIN triggers ON (triggers.triggerid=events.objectid)
GROUP BY 2,3,4
ORDER BY 2;





SELECT FROM_UNIXTIME(clock),name
FROM events
WHERE LENGTH(name)>0
AND source=0
AND object=0
AND value=0
AND name LIKE ('Agent%')
AND clock >= UNIX_TIMESTAMP("2020-06-01 00:00:00")
AND clock < UNIX_TIMESTAMP("2020-07-01 00:00:00")
ORDER BY clock ASC
;



-- Zabbix server generates slow "select clock,ns,value from history_uint..." queries in case of missing data for the items	
SET GLOBAL optimizer_switch='index_condition_pushdown=off';

update triggers set manual_close=1 where manual_close=0 and flags = 4;

--enable "Manual close"
UPDATE triggers SET manual_close=1 WHERE triggerid=726241;

UPDATE triggers set manual_close=0 where triggerid=421994;


--colect data from events
mysqldump \
--flush-logs \
--single-transaction \
--no-create-info zabbix events \
--where='source=3 AND clock >= UNIX_TIMESTAMP("2020-07-30 10:00:00") AND clock < UNIX_TIMESTAMP("2020-07-30 11:00:00")';

--show active disabled items on proxy
SELECT 
CASE type
WHEN 0 THEN 'Zabbix agent'
WHEN 1 THEN 'SNMPv1 agent'
WHEN 2 THEN 'Zabbix trapper'
WHEN 3 THEN 'Simple check'
WHEN 4 THEN 'SNMPv2 agent'
WHEN 5 THEN 'Zabbix internal'
WHEN 6 THEN 'SNMPv3 agent'
WHEN 7 THEN 'Zabbix agent (active)'
WHEN 8 THEN 'Aggregate'
WHEN 9 THEN 'web monitoring scenario'
WHEN 10 THEN 'External check'
WHEN 11 THEN 'Database monitor'
WHEN 12 THEN 'IPMI agent'
WHEN 13 THEN 'SSH agent'
WHEN 14 THEN 'TELNET agent'
WHEN 15 THEN 'Calculated'
WHEN 16 THEN 'JMX agent'
WHEN 17 THEN 'SNMP trap'
WHEN 18 THEN 'Dependent item'
WHEN 19 THEN 'HTTP agent'
WHEN 20 THEN 'SNMP agent'
END AS "type",
COUNT(*),
CASE status 
WHEN 0 THEN 'active' 
WHEN 1 THEN 'disabled' 
END AS "status"
FROM items
GROUP BY type,status
ORDER BY type DESC;



--detect if event correlation is used
SELECT * FROM event_recovery
WHERE eventid NOT IN (
SELECT eventid FROM events
) OR r_eventid NOT IN (
SELECT eventid FROM events);


SELECT * FROM problem
WHERE eventid NOT IN (
SELECT eventid FROM events
) OR r_eventid NOT IN (
SELECT eventid FROM events);


--no recovery time for problem. problem still open
select count(*) from problem where r_clock=0;



-- check if you have many correlation related event entries THEN 'which we could potentially clean up
select count(eventid),count(c_eventid) from event_recovery;

--filter out "Poller" checks
SELECT CASE items.type
WHEN 0 THEN 'Zabbix agent'
WHEN 2 THEN 'Zabbix trapper'
WHEN 3 THEN 'Simple check'
WHEN 5 THEN 'Zabbix internal'
WHEN 7 THEN 'Zabbix agent (active) check'
WHEN 8 THEN 'Aggregate'
WHEN 9 THEN 'HTTP test (web monitoring scenario step)'
WHEN 10 THEN 'External check'
WHEN 11 THEN 'Database monitor'
WHEN 12 THEN 'IPMI agent'
WHEN 13 THEN 'SSH agent'
WHEN 14 THEN 'TELNET agent'
WHEN 15 THEN 'Calculated'
WHEN 16 THEN 'JMX agent'
WHEN 17 THEN 'SNMP trap'
WHEN 18 THEN 'Dependent item'
WHEN 19 THEN 'HTTP agent'
WHEN 20 THEN 'SNMP agent'
END as type,
COUNT(*) as count
FROM items
WHERE items.type NOT IN (2,7,9,16,17,18)
GROUP BY items.type
ORDER BY COUNT(*) DESC;
--type 9 performed by http poller
--type 16 by java poller
--type 18 dependent item - not an active check THEN 'neither a passive


SELECT items.type,
COUNT(*) as count
FROM items
WHERE items.type NOT IN (2,7,9,16,17,18)
GROUP BY items.type
ORDER BY COUNT(*) DESC;



--determine if user is using LDAP
SELECT users.userid,users.alias,usrgrp.gui_access
FROM users
JOIN users_groups ON (users_groups.userid=users.userid)
JOIN usrgrp ON (usrgrp.usrgrpid=users_groups.usrgrpid)
WHERE LOWER(users.alias)=LOWER('admin')
;
WHERE usrgrp.usrgrpid=0;




--list all permissions for the user type "User" or "Zabbix Admin". This sample is suitable when a customer does not to expose the titles:
-- works on 4.0
SELECT users.userid,
       users_groups.usrgrpid as user_group_id,
       rights.rightid,
       hstgrp.groupid as host_group_id,
       CASE rights.permission
           WHEN 0 THEN 'DENY'
           WHEN 2 THEN 'READ_ONLY'
           WHEN 3 THEN 'READ_WRITE'
       END AS permission
FROM users
JOIN users_groups ON (users.userid = users_groups.userid)
JOIN usrgrp ON (usrgrp.usrgrpid = users_groups.usrgrpid)
JOIN rights ON (usrgrp.usrgrpid = rights.groupid)
JOIN hstgrp ON (rights.id=hstgrp.groupid)
;


WHERE users.userid='1'
;


--show most frequently used functions
SELECT name,parameter,COUNT(*)
FROM functions
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 50;

--show most frequently used functions. 2.4
select function,parameter,COUNT(*) from functions group by 1,2 order by 3 desc limit 50;


SELECT COUNT(*),name FROM events 
WHERE source = 0 
AND object = 0 
AND objectid NOT IN (
SELECT triggerid FROM triggers
)
GROUP BY name
ORDER BY COUNT(*) ASC
;


-- how many trigger events has been generated per host and item
SELECT COUNT(*) THEN 'hosts.host,items.key_,triggers.triggerid,triggers.description
FROM events
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.functionid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
AND events.object=0
GROUP BY 2,3,4,5
ORDER BY COUNT(*) ASC
\G





-- produce incorrect info on host prototypes!
SELECT FROM_UNIXTIME(events.clock) THEN 'events.name THEN 'events.objectid THEN 'triggers.description
FROM events
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.functionid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
AND events.object=0
ORDER BY events.clock ASC
\G


SELECT COUNT(*) as count,hosts.host,items.key_,triggers.triggerid,triggers.description
FROM events
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.functionid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
AND events.object=0
AND events.name LIKE '%unsupported items now'
GROUP BY 2,3,4,5
ORDER BY COUNT(hosts.host) ASC
;
\G


-- events generated per one trigger
select FROM_UNIXTIME(clock),name,objectid from events where source=0 and object=0 and objectid=724990;


DELETE FROM events WHERE source=0 AND object=0 AND objectid=100709;


FROM_UNIXTIME(clock),name,objectid from events where source=0 and object=0 and name like '%unsupported items now';



SELECT hosts.host,
items.name
FROM hosts
JOIN items ON (items.hostid=hosts.hostid)
JOIN history

SELECT FROM_UNIXTIME(clock),
       CASE severity
           WHEN 0 THEN 'NOT_CLASSIFIED'
           WHEN 1 THEN 'INFORMATION'
           WHEN 2 THEN 'WARNING'
           WHEN 3 THEN 'AVERAGE'
           WHEN 4 THEN 'HIGH'
           WHEN 5 THEN 'DISASTER'
       END AS severity,
	   CASE acknowledged
           WHEN 0 THEN 'NO'
           WHEN 1 THEN 'YES'
       END AS acknowledged,
	   CASE value
           WHEN 0 THEN 'OK'
           WHEN 1 THEN 'PROBLEM '
       END AS trigger_status,
       name
FROM events
WHERE source=0
  AND object=0
  AND objectid=129176
ORDER BY clock DESC
LIMIT 10
\G
;







SELECT FROM_UNIXTIME(auditlog.clock),
auditlog.auditid,
users.alias,
auditlog.action
FROM auditlog 
JOIN users ON (users.userid=auditlog.userid)
;
WHERE auditlog.resourceid=129176;



SELECT FROM_UNIXTIME(clock) AS time,name AS event FROM events 
WHERE source = 0 AND object = 0 AND objectid NOT IN (SELECT triggerid FROM triggers) 
ORDER BY clock DESC LIMIT 50\G


SELECT FROM_UNIXTIME(clock) AS time,name AS event FROM events 
WHERE source = 0 AND object = 0 AND objectid NOT IN (SELECT triggerid FROM triggers) 
ORDER BY clock ASC LIMIT 1\G


SET SESSION SQL_LOG_BIN=0;
DELETE FROM events WHERE source = 0 AND object = 0 AND objectid NOT IN (SELECT triggerid FROM triggers);





DELETE FROM alerts WHERE clock < UNIX_TIMESTAMP(DATE_SUB(NOW() THEN 'INTERVAL 124 day));


SELECT hosts.name AS host THEN 'items.name AS item
FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(history_text.value) > 6000
AND history_text.clock > UNIX_TIMESTAMP (NOW() - INTERVAL 30 MINUTE)
\G

SELECT hosts.name AS host THEN 'items.name AS item
FROM history_log
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(history_log.value) > 1
AND history_log.clock > UNIX_TIMESTAMP (NOW() - INTERVAL 30 MINUTE)
\G



-- list hosts which are only having the problems
SELECT DISTINCT hosts.hostid
FROM triggers
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE triggers.status=0
AND triggers.value=1
;




-- show most higest trigger for one host
SELECT
problem.name as event,
CASE problem.severity
           WHEN 0 THEN 'NOT_CLASSIFIED'
           WHEN 1 THEN 'INFORMATION'
           WHEN 2 THEN 'WARNING'
           WHEN 3 THEN 'AVERAGE'
           WHEN 4 THEN 'HIGH'
           WHEN 5 THEN 'DISASTER'
       END AS severity
FROM problem
JOIN events ON (events.eventid=problem.eventid)
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE problem.source=0
AND events.source=0
AND hosts.host='DC2'
ORDER BY problem.severity DESC
LIMIT 1
\G


-- show highest severity for each host
SELECT
hosts.host,
CASE problem.severity
           WHEN 0 THEN 'NOT_CLASSIFIED'
           WHEN 1 THEN 'INFORMATION'
           WHEN 2 THEN 'WARNING'
           WHEN 3 THEN 'AVERAGE'
           WHEN 4 THEN 'HIGH'
           WHEN 5 THEN 'DISASTER'
       END AS highest_severity,
problem.name as problem_title
FROM problem
JOIN events ON (events.eventid=problem.eventid)
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE problem.source=0
AND events.source=0
AND hosts.host IN (
SELECT host FROM hosts WHERE status IN (0)
)
ORDER BY problem.severity DESC
LIMIT 1
\G


--show template where item (from discovery) belongs. Zabbix 4.0 - 4.2 
select i.itemid
,i.hostid
,i.flags
,id.itemid as id_itemid
,id.parent_itemid as id_parent_itemid
,idi.itemid
,idi.templateid
,idit.itemid
,idit.hostid
,h.name
from items i
left join item_discovery id on id.itemid=i.itemid
left join items idi on idi.itemid=id.parent_itemid
left join items idit on idit.itemid=idi.templateid
left join hosts h on h.hostid=idit.hostid
order by flags desc;


--show items generated by LLD in host level. Zabbix 4.0 - 4.2 
SELECT
hosts.host,
items.itemid as autogenerated_item_id,
items.key_ as item_key,
triggers.triggerid as triggerid,
triggers.description as trigger_title,
item_discovery.parent_itemid as item_prototype_id_in_host_level,
item_discovery2.parent_itemid as lld_id_in_host_level,
trigger_discovery.parent_triggerid as trigger_prototype_id_in_host_level,
prototype_triggers.description as prototype_triggers_name_at_host_level,
lld.name as discovery_name_in_host_level
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items parent_itemid_items ON (parent_itemid_items.itemid=item_discovery.parent_itemid)
JOIN item_discovery item_discovery2 ON (item_discovery2.itemid=parent_itemid_items.itemid)
JOIN items lld ON (lld.itemid=item_discovery2.parent_itemid)
JOIN functions ON (items.itemid=functions.itemid)
JOIN triggers ON (functions.triggerid=triggers.triggerid)
JOIN trigger_discovery ON (trigger_discovery.triggerid=triggers.triggerid)
JOIN triggers prototype_triggers ON (prototype_triggers.triggerid=trigger_discovery.parent_triggerid)
WHERE items.flags='4'
  AND hosts.host='AKADIKIS-840-G2'
  AND hosts.status IN (0,1)
LIMIT 2 
;
\G
  
  AND hosts.host='ubuntu18.catonrug.lan'
  AND triggers.triggerid='262950'
  AND items.itemid='111526'



-- how many times the global script has been executed in specific time range
SELECT from_unixtime(events.clock),
operations.operationid,
scripts.name
FROM alerts
JOIN actions ON (actions.actionid=alerts.actionid)
JOIN operations ON (operations.actionid=actions.actionid)
JOIN opcommand ON (opcommand.operationid=operations.operationid)
JOIN events ON (events.eventid=alerts.eventid)
JOIN scripts ON (scripts.scriptid=opcommand.scriptid)
WHERE opcommand.type=4
AND events.clock > UNIX_TIMESTAMP('2020-06-01 00:00:00')
AND events.clock < UNIX_TIMESTAMP('2020-08-01 00:00:00')
;









SELECT hosts.name AS host THEN 'items.name AS item
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.itemid IN (
SELECT itemid FROM history_text 
WHERE LENGTH(value) > 3500 
AND clock > UNIX_TIMESTAMP (NOW() - INTERVAL 30 MINUTE)
)
\G



SELECT hosts.name AS host THEN 'items.name AS item
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.itemid IN (
SELECT itemid FROM history_log 
WHERE LENGTH(value) > 500 
AND clock > UNIX_TIMESTAMP (NOW() - INTERVAL 30 MINUTE)
)
\G




SELECT hosts.name AS host THEN 'items.name AS item
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.itemid IN (
SELECT itemid FROM history_text WHERE LENGTH(value) > 3000 AND clock > UNIX_TIMESTAMP (NOW() - INTERVAL 30 MINUTE)
)
\G




/* details about config */
select hk_events_mode,hk_events_trigger,hk_events_internal,hk_events_discovery,hk_events_autoreg,hk_services_mode,hk_services,hk_audit_mode,hk_audit,hk_sessions_mode,hk_sessions,hk_history_mode,hk_history_global,hk_history,hk_trends_mode,hk_trends_global,hk_trends from config\G;


SELECT count(*) FROM events WHERE source = 0 AND object = 0 AND objectid NOT IN (SELECT triggerid FROM triggers);

select clock,name from events WHERE source = 0 AND object = 0 AND objectid NOT IN (SELECT triggerid FROM triggers);

select from_unixtime(clock),name from events WHERE source = 0 AND object = 0 AND objectid NOT IN (SELECT triggerid FROM triggers);


/* classify snmp devices into categories */
mysql zabbix -B -N -e 'select value from history_str where itemid in (
select itemid from items where key_="system.descr[sysDescr.0]");' | sort | uniq

SELECT COUNT(*) FROM items 
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE key_ like 'sslcert.json%'
AND hosts.status=0
;




/* item storage period not in days */
SELECT CASE
           WHEN items.value_type=0 THEN 'float'
           WHEN items.value_type=1 THEN 'str'
           WHEN items.value_type=2 THEN 'loag'
           WHEN items.value_type=3 THEN 'uint'
           WHEN items.value_type=4 THEN 'text'
       END AS type,
items.itemid,items.history as threshold
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status IN (0,1)
AND items.history not like '%d'
AND items.history <> '0'
;


SELECT CASE
           WHEN items.value_type=0 THEN 'float'
           WHEN items.value_type=1 THEN 'str'
           WHEN items.value_type=2 THEN 'loag'
           WHEN items.value_type=3 THEN 'uint'
           WHEN items.value_type=4 THEN 'text'
       END AS type,
items.itemid,(UNIX_TIMESTAMP(NOW())-(items.history*3600*24)) as threshold
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status IN (0,1)
AND items.history like '%d'
;



SELECT CONCAT('DELETE FROM history_uint where itemid=',items.itemid THEN '' AND clock < ',(UNIX_TIMESTAMP(NOW())-(items.history*3600*24)),';')
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status IN (0,1)
AND items.history like '%d'
AND items.value_type = 3
;




/* show hosts behind proxies THEN 'show ip addresses */
SELECT p.host AS proxy_name,
hosts.host AS host_name,
CASE
WHEN interface.type=0 THEN 'UNKNOWN'
WHEN interface.type=1 THEN 'AGENT'
WHEN interface.type=2 THEN 'SNMP'
WHEN interface.type=3 THEN 'IPMI'
WHEN interface.type=4 THEN 'JMX'
END AS type,
interface.ip
FROM hosts
JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
JOIN interface ON (interface.hostid=hosts.hostid)
WHERE hosts.available = 0
ORDER BY p.host
INTO OUTFILE '/tmp/hosts.IP.address.behind.proxy.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';



SELECT COUNT(*) THEN 'triggers.description
FROM events
JOIN triggers ON (triggers.triggerid=events.objectid)
WHERE events.source=0
AND events.object=0
GROUP BY triggers.description
ORDER BY COUNT(*) DESC
LIMIT 10;





SELECT json_object('Proxy' THEN 'p.host,
'Host' THEN 'hosts.host,
'Type' THEN 'interface.type,
'IP' THEN 'interface.ip)
FROM hosts
JOIN hosts p ON (hosts.proxy_hostid=p.hostid)
JOIN interface ON (interface.hostid=hosts.hostid)
WHERE hosts.available = 0
ORDER BY p.host
;

select hostid from [hosts] FOR JSON AUTO;

mysql --defaults-file=/var/lib/zabbix/my.root.cnf -sN --batch zabbix -e "SELECT TIME,STATE,COMMAND,INFO FROM information_schema.processlist WHERE command != 'Sleep' and time>1 and user != 'event_scheduler' ORDER BY time DESC, id"
mysql --defaults-file=/var/lib/zabbix/my.root.cnf -sN --batch zabbix -e "SELECT INFO FROM information_schema.processlist WHERE COMMAND != 'Sleep' and TIME > 1 and USER != 'event_scheduler' AND STATE='executing' ORDER BY TIME DESC, id"


echo "[
$(mysql zabbix -sN -e '
SET SESSION group_concat_max_len = 1000000;
SELECT GROUP_CONCAT(
JSON_OBJECT(
"Proxy" THEN 'p.host,
"Host" THEN 'hosts.host,
"Type" THEN 'interface.type,
"IP" THEN 'interface.ip
)
SEPARATOR " THEN '")
FROM hosts 
JOIN hosts p ON (hosts.proxy_hostid=p.hostid) 
JOIN interface ON (interface.hostid=hosts.hostid) 
WHERE hosts.available = 0 ORDER BY p.host')
]" | jq .

mysql zabbix -sN -e 'SET SESSION group_concat_max_len = 1000000; SELECT GROUP_CONCAT(JSON_OBJECT("Proxy" THEN 'p.host,"Host" THEN 'hosts.host,"Type" THEN 'interface.type,"IP" THEN 'interface.ip) SEPARATOR " THEN '") FROM hosts JOIN hosts p ON (hosts.proxy_hostid=p.hostid) JOIN interface ON (interface.hostid=hosts.hostid) WHERE hosts.available = 0 ORDER BY p.host'

mysql zabbix -sN -e 'SELECT GROUP_CONCAT(JSON_OBJECT("Proxy" THEN 'p.host,"Host" THEN 'hosts.host,"Type" THEN 'interface.type,"IP" THEN 'interface.ip) SEPARATOR " THEN '") FROM hosts JOIN hosts p ON (hosts.proxy_hostid=p.hostid) JOIN interface ON (interface.hostid=hosts.hostid) WHERE hosts.available = 0 ORDER BY p.host;'





SELECT HOST,
       CASE
           WHEN available=0 THEN 'unknown'
           WHEN available=1 THEN 'available'
           WHEN available=2 THEN 'not available'
       END AS available
FROM hosts
WHERE status=0 
INTO OUTFILE '/tmp/hosts.availability.unknown.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


cat << 'EOF' > secure_file_priv.cnf
[mysqld]
secure-file-priv=/tmp
EOF


select CASE
           WHEN state=0 THEN 'NORMAL'
           WHEN state=1 THEN 'UNKNOWN'
       END as state,
	   error
FROM triggers
where flags IN (0,4)
AND state=1;

UPDATE items SET state=0 WHERE state=1;

SELECT itemid,state FROM items where state=1;

UPDATE triggers SET state=0 WHERE flags IN (0,4) AND state=1;

SELECT state FROM triggers WHERE flags IN (0,4) AND state=1;



/* show hostid's behind a proxy */
SELECT h.hostid FROM hosts h JOIN hosts p ON h.proxy_hostid=p.hostid WHERE p.host='riga';


SELECT DISTINCT itemid THEN 'value from history_uint WHERE itemid IN (SELECT itemid FROM items WHERE key_='system.uptime')
AND clock>INTERVAL(NOW()-2 HOURS);

	


SELECT hosts.host,items.key_
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE key_ LIKE '%web.page.get%'
AND items.status=0
AND hosts.status IN (0,1);


	
	

SELECT hosts.host,
items.url
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE items.type=19
AND proxy.host='broceni'
\G

WHERE 




/* unsupported items per host. works from 3.4 - 4.2 */
SELECT hosts.host,
       events.objectid AS itemid,
       items.key_,
       events.name AS error,
       count(events.objectid) AS occurrence
FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source = 3
  AND events.object = 4
  AND LENGTH(events.name)>0
GROUP BY hosts.host,
         events.objectid,
		 items.key_,
         events.name
ORDER BY count(*)\x\g\x








SELECT items.type,
       items.key_,
       items.delay,
       items.status,
       items.value_type,
       items.flags
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.host='Zabbix server';


SELECT * FROM problem WHERE objectid=16865;




update triggers set status=1 where triggerid=120753;




/* deleted items */
/* most frequent records in auditlog. works 4.4 */
SELECT resourceid THEN 'resourcename
FROM auditlog
WHERE action=2
AND resourcetype=15
\G


/* zabibx 3.0 trigger linkage. it will list all hosts and templates which are using 'system.uptime' item key together with trigger function 'change' */
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
AND functions.function IN ('change')
;



SELECT FROM_UNIXTIME(clock),
       CASE action
           WHEN 0 THEN 'ADD'
           WHEN 1 THEN 'UPDATE'
           WHEN 2 THEN 'DELETE'
           WHEN 3 THEN 'LOGIN'
           WHEN 4 THEN 'LOGOUT'
           WHEN 5 THEN 'ENABLE'
           WHEN 6 THEN 'DISABLE'
       END AS action,
       CASE resourcetype
           WHEN 0 THEN 'USER'
           WHEN 2 THEN 'ZABBIX_CONFIG'
           WHEN 3 THEN 'MEDIA_TYPE'
           WHEN 4 THEN 'HOST'
           WHEN 5 THEN 'ACTION'
           WHEN 6 THEN 'GRAPH'
           WHEN 7 THEN 'GRAPH_ELEMENT'
           WHEN 11 THEN 'USER_GROUP'
           WHEN 12 THEN 'APPLICATION'
           WHEN 13 THEN 'TRIGGER'
           WHEN 14 THEN 'HOST_GROUP'
           WHEN 15 THEN 'ITEM'
           WHEN 16 THEN 'IMAGE'
           WHEN 17 THEN 'VALUE_MAP'
           WHEN 18 THEN 'IT_SERVICE'
           WHEN 19 THEN 'MAP'
           WHEN 20 THEN 'SCREEN'
           WHEN 22 THEN 'SCENARIO'
           WHEN 23 THEN 'DISCOVERY_RULE'
           WHEN 24 THEN 'SLIDESHOW'
           WHEN 25 THEN 'SCRIPT'
           WHEN 26 THEN 'PROXY'
           WHEN 27 THEN 'MAINTENANCE'
           WHEN 28 THEN 'REGEXP'
           WHEN 29 THEN 'MACRO'
           WHEN 30 THEN 'TEMPLATE'
           WHEN 31 THEN 'TRIGGER_PROTOTYPE'
           WHEN 32 THEN 'ICON_MAP'
           WHEN 33 THEN 'DASHBOARD'
           WHEN 34 THEN 'CORRELATION'
           WHEN 35 THEN 'GRAPH_PROTOTYPE'
           WHEN 36 THEN 'ITEM_PROTOTYPE'
           WHEN 37 THEN 'HOST_PROTOTYPE'
           WHEN 38 THEN 'AUTOREGISTRATION'
       END AS resourcetype
FROM auditlog ;






/* most frequent records in auditlog. works 4.4 */
SELECT COUNT(resourcetype),
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=3 THEN 'LOGIN'
           WHEN action=4 THEN 'LOGOUT'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END as action,
	   CASE
WHEN resourcetype=0 THEN 'USER'
WHEN resourcetype=2 THEN 'ZABBIX_CONFIG'
WHEN resourcetype=3 THEN 'MEDIA_TYPE'
WHEN resourcetype=4 THEN 'HOST'
WHEN resourcetype=5 THEN 'ACTION'
WHEN resourcetype=6 THEN 'GRAPH'
WHEN resourcetype=7 THEN 'GRAPH_ELEMENT'
WHEN resourcetype=11 THEN 'USER_GROUP'
WHEN resourcetype=12 THEN 'APPLICATION'
WHEN resourcetype=13 THEN 'TRIGGER'
WHEN resourcetype=14 THEN 'HOST_GROUP'
WHEN resourcetype=15 THEN 'ITEM'
WHEN resourcetype=16 THEN 'IMAGE'
WHEN resourcetype=17 THEN 'VALUE_MAP'
WHEN resourcetype=18 THEN 'IT_SERVICE'
WHEN resourcetype=19 THEN 'MAP'
WHEN resourcetype=20 THEN 'SCREEN'
WHEN resourcetype=22 THEN 'SCENARIO'
WHEN resourcetype=23 THEN 'DISCOVERY_RULE'
WHEN resourcetype=24 THEN 'SLIDESHOW'
WHEN resourcetype=25 THEN 'SCRIPT'
WHEN resourcetype=26 THEN 'PROXY'
WHEN resourcetype=27 THEN 'MAINTENANCE'
WHEN resourcetype=28 THEN 'REGEXP'
WHEN resourcetype=29 THEN 'MACRO'
WHEN resourcetype=30 THEN 'TEMPLATE'
WHEN resourcetype=31 THEN 'TRIGGER_PROTOTYPE'
WHEN resourcetype=32 THEN 'ICON_MAP'
WHEN resourcetype=33 THEN 'DASHBOARD'
WHEN resourcetype=34 THEN 'CORRELATION'
WHEN resourcetype=35 THEN 'GRAPH_PROTOTYPE'
WHEN resourcetype=36 THEN 'ITEM_PROTOTYPE'
WHEN resourcetype=37 THEN 'HOST_PROTOTYPE'
WHEN resourcetype=38 THEN 'AUTOREGISTRATION'	   
	   END as resourcetype
FROM auditlog
GROUP BY 2,3
ORDER BY COUNT(*)
\G






SELECT from_unixtime(clock),value_avg from trends
JOIN items ON (items.itemid=trends.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.name='Metric title of CPU'
AND hosts.host='Host name THEN 'but NOT host Visible name'
AND trends.clock > UNIX_TIMESTAMP('2020-04-01 00:00:00')
AND trends.clock < UNIX_TIMESTAMP('2020-05-01 00:00:00');


SELECT from_unixtime(clock),value_avg from trends_uint
JOIN items ON (items.itemid=trends_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.name='Metric title of CPU'
AND hosts.host='Host name THEN 'but NOT host Visible name'
AND trends_uint.clock > UNIX_TIMESTAMP('2020-04-01 00:00:00')
AND trends_uint.clock < UNIX_TIMESTAMP('2020-05-01 00:00:00');


SELECT from_unixtime(clock),value_avg/1024/1024 "MB" from trends_uint
JOIN items ON (items.itemid=trends_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.name='Memory used for virtualbox'
AND hosts.host='ubuntu18.catonrug.lan'
AND trends_uint.clock > UNIX_TIMESTAMP('2020-04-01 00:00:00')
AND trends_uint.clock < UNIX_TIMESTAMP('2020-05-01 00:00:00');

Free disk space on /
ubuntu18.catonrug.lan

/* hosts table has been changed */
SELECT FROM_UNIXTIME(auditlog.clock) AS clock,
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END AS action,
       users.alias,
       hosts.host
FROM auditlog
JOIN users ON (users.userid=auditlog.userid)
JOIN hosts ON (hosts.hostid=auditlog.resourceid)
WHERE auditlog.clock > UNIX_TIMESTAMP(NOW() - INTERVAL 7 DAY)
  AND hosts.status NOT IN (3)
ORDER BY clock
\G



       auditlog_details.oldvalue,
       auditlog_details.newvalue,
	   auditlog.resourcename,
	   auditlog.resourceid,
	   auditlog.details



/* new or delete */
SELECT users.alias,hosts.host,
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=3 THEN 'LOGIN'
           WHEN action=4 THEN 'LOGOUT'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END AS action,
       CASE
           WHEN resourcetype=0 THEN 'USER'
           WHEN resourcetype=2 THEN 'ZABBIX_CONFIG'
           WHEN resourcetype=3 THEN 'MEDIA_TYPE'
           WHEN resourcetype=4 THEN 'HOST'
           WHEN resourcetype=5 THEN 'ACTION'
           WHEN resourcetype=6 THEN 'GRAPH'
           WHEN resourcetype=7 THEN 'GRAPH_ELEMENT'
           WHEN resourcetype=11 THEN 'USER_GROUP'
           WHEN resourcetype=12 THEN 'APPLICATION'
           WHEN resourcetype=13 THEN 'TRIGGER'
           WHEN resourcetype=14 THEN 'HOST_GROUP'
           WHEN resourcetype=15 THEN 'ITEM'
           WHEN resourcetype=16 THEN 'IMAGE'
           WHEN resourcetype=17 THEN 'VALUE_MAP'
           WHEN resourcetype=18 THEN 'IT_SERVICE'
           WHEN resourcetype=19 THEN 'MAP'
           WHEN resourcetype=20 THEN 'SCREEN'
           WHEN resourcetype=22 THEN 'SCENARIO'
           WHEN resourcetype=23 THEN 'DISCOVERY_RULE'
           WHEN resourcetype=24 THEN 'SLIDESHOW'
           WHEN resourcetype=25 THEN 'SCRIPT'
           WHEN resourcetype=26 THEN 'PROXY'
           WHEN resourcetype=27 THEN 'MAINTENANCE'
           WHEN resourcetype=28 THEN 'REGEXP'
           WHEN resourcetype=29 THEN 'MACRO'
           WHEN resourcetype=30 THEN 'TEMPLATE'
           WHEN resourcetype=31 THEN 'TRIGGER_PROTOTYPE'
           WHEN resourcetype=32 THEN 'ICON_MAP'
           WHEN resourcetype=33 THEN 'DASHBOARD'
           WHEN resourcetype=34 THEN 'CORRELATION'
           WHEN resourcetype=35 THEN 'GRAPH_PROTOTYPE'
           WHEN resourcetype=36 THEN 'ITEM_PROTOTYPE'
           WHEN resourcetype=37 THEN 'HOST_PROTOTYPE'
           WHEN resourcetype=38 THEN 'AUTOREGISTRATION'
       END AS resourcetype,
	   auditlog.resourcename,
	   auditlog.resourceid,
	   auditlog.details
FROM auditlog
JOIN users ON (users.userid=auditlog.userid)
JOIN hosts ON (hosts.hostid=auditlog.resourceid)
WHERE resourcetype IN (4,26,30,37)
\G



SELECT FROM_UNIXTIME(auditlog.clock) as clock,
       users.alias,
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=3 THEN 'LOGIN'
           WHEN action=4 THEN 'LOGOUT'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END AS action,
       CASE
           WHEN resourcetype=0 THEN 'USER'
           WHEN resourcetype=2 THEN 'ZABBIX_CONFIG'
           WHEN resourcetype=3 THEN 'MEDIA_TYPE'
           WHEN resourcetype=4 THEN 'HOST'
           WHEN resourcetype=5 THEN 'ACTION'
           WHEN resourcetype=6 THEN 'GRAPH'
           WHEN resourcetype=7 THEN 'GRAPH_ELEMENT'
           WHEN resourcetype=11 THEN 'USER_GROUP'
           WHEN resourcetype=12 THEN 'APPLICATION'
           WHEN resourcetype=13 THEN 'TRIGGER'
           WHEN resourcetype=14 THEN 'HOST_GROUP'
           WHEN resourcetype=15 THEN 'ITEM'
           WHEN resourcetype=16 THEN 'IMAGE'
           WHEN resourcetype=17 THEN 'VALUE_MAP'
           WHEN resourcetype=18 THEN 'IT_SERVICE'
           WHEN resourcetype=19 THEN 'MAP'
           WHEN resourcetype=20 THEN 'SCREEN'
           WHEN resourcetype=22 THEN 'SCENARIO'
           WHEN resourcetype=23 THEN 'DISCOVERY_RULE'
           WHEN resourcetype=24 THEN 'SLIDESHOW'
           WHEN resourcetype=25 THEN 'SCRIPT'
           WHEN resourcetype=26 THEN 'PROXY'
           WHEN resourcetype=27 THEN 'MAINTENANCE'
           WHEN resourcetype=28 THEN 'REGEXP'
           WHEN resourcetype=29 THEN 'MACRO'
           WHEN resourcetype=30 THEN 'TEMPLATE'
           WHEN resourcetype=31 THEN 'TRIGGER_PROTOTYPE'
           WHEN resourcetype=32 THEN 'ICON_MAP'
           WHEN resourcetype=33 THEN 'DASHBOARD'
           WHEN resourcetype=34 THEN 'CORRELATION'
           WHEN resourcetype=35 THEN 'GRAPH_PROTOTYPE'
           WHEN resourcetype=36 THEN 'ITEM_PROTOTYPE'
           WHEN resourcetype=37 THEN 'HOST_PROTOTYPE'
           WHEN resourcetype=38 THEN 'AUTOREGISTRATION'
       END AS resourcetype,
	   resourceid
FROM auditlog
JOIN users ON (users.userid=auditlog.userid)
WHERE action NOT IN (3,4)
  AND clock > UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY)
ORDER BY clock
;



/* list everything THEN 'but not login logout */
SELECT FROM_UNIXTIME(auditlog.clock),
       auditlog.userid,
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=3 THEN 'LOGIN'
           WHEN action=4 THEN 'LOGOUT'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END AS action,
       CASE
           WHEN resourcetype=0 THEN 'USER'
           WHEN resourcetype=2 THEN 'ZABBIX_CONFIG'
           WHEN resourcetype=3 THEN 'MEDIA_TYPE'
           WHEN resourcetype=4 THEN 'HOST'
           WHEN resourcetype=5 THEN 'ACTION'
           WHEN resourcetype=6 THEN 'GRAPH'
           WHEN resourcetype=7 THEN 'GRAPH_ELEMENT'
           WHEN resourcetype=11 THEN 'USER_GROUP'
           WHEN resourcetype=12 THEN 'APPLICATION'
           WHEN resourcetype=13 THEN 'TRIGGER'
           WHEN resourcetype=14 THEN 'HOST_GROUP'
           WHEN resourcetype=15 THEN 'ITEM'
           WHEN resourcetype=16 THEN 'IMAGE'
           WHEN resourcetype=17 THEN 'VALUE_MAP'
           WHEN resourcetype=18 THEN 'IT_SERVICE'
           WHEN resourcetype=19 THEN 'MAP'
           WHEN resourcetype=20 THEN 'SCREEN'
           WHEN resourcetype=22 THEN 'SCENARIO'
           WHEN resourcetype=23 THEN 'DISCOVERY_RULE'
           WHEN resourcetype=24 THEN 'SLIDESHOW'
           WHEN resourcetype=25 THEN 'SCRIPT'
           WHEN resourcetype=26 THEN 'PROXY'
           WHEN resourcetype=27 THEN 'MAINTENANCE'
           WHEN resourcetype=28 THEN 'REGEXP'
           WHEN resourcetype=29 THEN 'MACRO'
           WHEN resourcetype=30 THEN 'TEMPLATE'
           WHEN resourcetype=31 THEN 'TRIGGER_PROTOTYPE'
           WHEN resourcetype=32 THEN 'ICON_MAP'
           WHEN resourcetype=33 THEN 'DASHBOARD'
           WHEN resourcetype=34 THEN 'CORRELATION'
           WHEN resourcetype=35 THEN 'GRAPH_PROTOTYPE'
           WHEN resourcetype=36 THEN 'ITEM_PROTOTYPE'
           WHEN resourcetype=37 THEN 'HOST_PROTOTYPE'
           WHEN resourcetype=38 THEN 'AUTOREGISTRATION'
       END AS resourcetype,
       auditlog.resourcename
FROM auditlog
WHERE action NOT IN (3,4)
ORDER BY clock
\G







/* simple auditlog THEN 'list everything related to creating/deleting host or template */
SELECT FROM_UNIXTIME(clock),hosts.host,
       CASE
           WHEN action=0 THEN 'ADD'
           WHEN action=1 THEN 'UPDATE'
           WHEN action=2 THEN 'DELETE'
           WHEN action=3 THEN 'LOGIN'
           WHEN action=4 THEN 'LOGOUT'
           WHEN action=5 THEN 'ENABLE'
           WHEN action=6 THEN 'DISABLE'
       END as action,
	   CASE
WHEN resourcetype=0 THEN 'USER'
WHEN resourcetype=2 THEN 'ZABBIX_CONFIG'
WHEN resourcetype=3 THEN 'MEDIA_TYPE'
WHEN resourcetype=4 THEN 'HOST'
WHEN resourcetype=5 THEN 'ACTION'
WHEN resourcetype=6 THEN 'GRAPH'
WHEN resourcetype=7 THEN 'GRAPH_ELEMENT'
WHEN resourcetype=11 THEN 'USER_GROUP'
WHEN resourcetype=12 THEN 'APPLICATION'
WHEN resourcetype=13 THEN 'TRIGGER'
WHEN resourcetype=14 THEN 'HOST_GROUP'
WHEN resourcetype=15 THEN 'ITEM'
WHEN resourcetype=16 THEN 'IMAGE'
WHEN resourcetype=17 THEN 'VALUE_MAP'
WHEN resourcetype=18 THEN 'IT_SERVICE'
WHEN resourcetype=19 THEN 'MAP'
WHEN resourcetype=20 THEN 'SCREEN'
WHEN resourcetype=22 THEN 'SCENARIO'
WHEN resourcetype=23 THEN 'DISCOVERY_RULE'
WHEN resourcetype=24 THEN 'SLIDESHOW'
WHEN resourcetype=25 THEN 'SCRIPT'
WHEN resourcetype=26 THEN 'PROXY'
WHEN resourcetype=27 THEN 'MAINTENANCE'
WHEN resourcetype=28 THEN 'REGEXP'
WHEN resourcetype=29 THEN 'MACRO'
WHEN resourcetype=30 THEN 'TEMPLATE'
WHEN resourcetype=31 THEN 'TRIGGER_PROTOTYPE'
WHEN resourcetype=32 THEN 'ICON_MAP'
WHEN resourcetype=33 THEN 'DASHBOARD'
WHEN resourcetype=34 THEN 'CORRELATION'
WHEN resourcetype=35 THEN 'GRAPH_PROTOTYPE'
WHEN resourcetype=36 THEN 'ITEM_PROTOTYPE'
WHEN resourcetype=37 THEN 'HOST_PROTOTYPE'
WHEN resourcetype=38 THEN 'AUTOREGISTRATION'	   
	   END as resourcetype,
	   auditlog.resourcename
FROM auditlog
JOIN hosts ON (hosts.hostid=auditlog.resourceid)
ORDER BY clock
\G




SELECT clock,eventid,sendto,subject,status FROM alerts 
ORDER BY clock;




/* LLD behind proxies only. for very huge instance remove the line having '%d' */
SELECT proxy.host as 'proxy',
       hosts.host,
	   COUNT(discovery.key_) as 'items2maintain',
       discovery.key_ as 'discovery key',
       discovery.delay as 'frequency'
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items discovery ON (discovery.itemid=item_discovery.parent_itemid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE items.status=0
  AND items.flags=4
  AND discovery.delay NOT LIKE '%d'
  AND discovery.delay NOT LIKE '%h'
  AND discovery.delay NOT IN ('3600')
GROUP BY discovery.key_,
         discovery.delay,
		 proxy.host,
         hosts.host
ORDER BY COUNT(discovery.key_)
\G


/* SNMPconfiguration on host level. replace hostid */
SELECT items.snmpv3_securityname AS USER,
       CASE items.snmpv3_securitylevel
           WHEN 0 THEN 'noAuthNoPriv'
           WHEN 1 THEN 'authNoPriv'
           WHEN 2 THEN 'authPriv'
       END AS secLev,
       CASE items.snmpv3_authprotocol
           WHEN 0 THEN 'MD5'
           WHEN 1 THEN 'SHA'
       END AS authProto,
       items.snmpv3_authpassphrase AS authPhrase,
       CASE items.snmpv3_privprotocol
           WHEN 0 THEN 'DES'
           WHEN 1 THEN 'AES'
       END AS privProto,
       items.snmpv3_privpassphrase AS privPhrase,
       CASE items.flags
           WHEN 0 THEN 'normal'
           WHEN 1 THEN 'rule'
           WHEN 2 THEN 'prototype'
           WHEN 4 THEN 'discovered'
       END AS flags,
       count(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE TYPE=6
  AND hosts.name='hostName'
   OR TYPE=6
  AND hosts.host='hostName'
GROUP BY 1,2,3,4,5,6,7;


/* on PostgreSQL */
SELECT proxy.host,
       hosts.host,
	   COUNT(discovery.key_),
       discovery.key_,
       discovery.delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items discovery ON (discovery.itemid=item_discovery.parent_itemid)
JOIN hosts proxy ON (hosts.proxy_hostid=proxy.hostid)
WHERE items.status=0
  AND items.flags=4
  AND discovery.delay NOT LIKE '%d'
  AND discovery.delay NOT LIKE '%h'
  AND discovery.delay NOT IN ('3600')
GROUP BY discovery.key_,
         discovery.delay,
		 proxy.host,
         hosts.host
ORDER BY COUNT(discovery.key_);



/* unsupported items. show problems related to items. works from 3.4 to 4.2 */
SELECT COUNT(items.key_),items.key_,items.error
FROM events
JOIN items ON (items.itemid=events.objectid)
WHERE source=3
  AND object=4
  AND items.status=0
  AND items.flags IN (0,1,4)
  AND LENGTH(items.error)>0
GROUP BY items.key_,
         items.error
ORDER BY COUNT(items.key_);


/* unsupported items. show problems related to items. works on 4.4, 5.0 */
SELECT COUNT(items.key_),
       hosts.host,
       items.key_,
       item_rtdata.error
FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_rtdata ON (item_rtdata.itemid=items.itemid)
WHERE source=3
  AND object=4
  AND items.status=0
  AND items.flags IN (0,1,4)
  AND LENGTH(item_rtdata.error)>0
GROUP BY hosts.host,items.key_,
         item_rtdata.error
ORDER BY COUNT(items.key_)\G












-- for one host on 4.4
SELECT FROM_UNIXTIME(clock) as 'clock',
       hosts.host,
       items.key_ as 'key',
       item_rtdata.error
FROM events
JOIN items ON (items.itemid=events.objectid)
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_rtdata ON (item_rtdata.itemid=items.itemid)
WHERE source=3
  AND object=4
  AND items.status=0
  AND items.flags IN (0,1,4)
  AND LENGTH(item_rtdata.error)>0
  AND hosts.hostid=11893
ORDER BY clock ASC
\G








/* only on mariadb only. does not work on mysql8 */
mysql -sN -e 'SELECT * FROM information_schema.GLOBAL_STATUS ORDER BY VARIABLE_NAME;' > /tmp/mariadb.global.status.log
mysql -sN -e 'SELECT * FROM information_schema.GLOBAL_VARIABLES ORDER BY VARIABLE_NAME;' > /tmp/mariadb.global.variables.log



SHOW [GLOBAL | SESSION] VARIABLES
    [LIKE 'pattern' | WHERE expr]


SHOW GLOBAL VARIABLES LIKE 'innodb_undo%';
SELECT TABLESPACE_NAME THEN 'FILE_NAME FROM INFORMATION_SCHEMA.FILES WHERE FILE_TYPE LIKE 'UNDO LOG';
SHOW SESSION VARIABLES;



/* filter out events/problems when they change state from Problem to OK or vice versa */
SELECT hosts.host,
       FROM_UNIXTIME(events.clock) as 'time',
       CASE
           WHEN events.value=0 THEN 'OK'
           WHEN events.value=1 THEN 'PROBLEM'
       END AS 'trigger',
       events.name
FROM events
JOIN triggers ON (events.objectid=triggers.triggerid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE events.source=0
  AND events.object=0
  AND events.name like '%Zabbix discoverer processes more%'
  AND events.clock > UNIX_TIMESTAMP('2020-03-27 18:00:00')
  AND events.clock < UNIX_TIMESTAMP('2020-03-27 18:00:00' + INTERVAL 12 HOUR)
;


/* show IP addresses for SNMP network devices */
SELECT GROUP_CONCAT(interface.ip)
FROM interface
JOIN hosts ON (hosts.hostid=interface.hostid)
WHERE interface.type=2
\G



mysql zabbix -B -N -e 'select value from history_str where itemid in (select itemid from items where key_="system.descr[sysDescr.0]");' | sort | uniq

mysql zabbix -B -N -e 'select value from history_str where itemid in (select itemid from items where key_="system.descr[sysDescr.0]");' | sort | uniq








/* Most heaviest LLD discoveries. Heaviest in terms of how many items must be maintained */
/* master piece */
SELECT COUNT(discovery.key_),
       hosts.host,
       discovery.key_,
       discovery.delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items discovery ON (discovery.itemid=item_discovery.parent_itemid)
WHERE items.status=0
  AND items.flags=4
GROUP BY discovery.key_,
         discovery.delay,
         hosts.host
ORDER BY COUNT(discovery.key_)
\G







/* without days */
SELECT COUNT(discovery.key_),
       hosts.host,
       discovery.key_,
       discovery.delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items discovery ON (discovery.itemid=item_discovery.parent_itemid)
WHERE items.status=0
  AND items.flags=4
  AND discovery.delay not like '%d'
GROUP BY discovery.key_,
         discovery.delay,
         hosts.host
ORDER BY COUNT(discovery.key_)
\G







SELECT task.clock,
       task.taskid,
       CASE
           WHEN task.status=1 THEN 'new'
           WHEN task.status=2 THEN 'in pogress'
           WHEN task.status=3 THEN 'done'
           WHEN task.status=4 THEN 'expired'
       END AS status,
       pr.host AS proxy,
       hosts.host,
       CASE
           WHEN task_remote_command.execute_on=0 THEN 'agent'
           WHEN task_remote_command.execute_on=1 THEN 'server'
           WHEN task_remote_command.execute_on=2 THEN 'proxy'
       END AS execute_on,
       CASE
           WHEN task_remote_command.command_type=0 THEN 'custom script'
           WHEN task_remote_command.command_type=1 THEN 'IPMI'
           WHEN task_remote_command.command_type=2 THEN 'SSH'
           WHEN task_remote_command.command_type=3 THEN 'telnet'
           WHEN task_remote_command.command_type=4 THEN 'global script'
       END AS command_type,
       task_remote_command.command,
	   task.ttl
FROM task
JOIN task_remote_command ON (task.taskid=task_remote_command.taskid)
JOIN hosts ON (hosts.hostid=task_remote_command.hostid)
JOIN hosts pr ON (pr.hostid=task.proxy_hostid)
ORDER BY task.clock ASC;
;


WHERE task.type=2
AND clock>(UNIX_TIMESTAMP("2020-02-01 00:00:00"))
AND clock<(UNIX_TIMESTAMP("2020-03-01 00:00:00"))
;


/* items generating the most internal events. works on 4.4 */
SELECT COUNT(objectid),objectid,name FROM events WHERE SOURCE = 3   AND OBJECT = 4   AND objectid NOT IN     (SELECT itemid      FROM items) AND LENGTH(name)>0 GROUP BY objectid,name ORDER BY COUNT(objectid),objectid,name;

\G


/* check for possible deadlocks on the DB */
SHOW ENGINE INNODB STATUS;



/* apparently these items do not exist anymore */
SELECT COUNT(events.objectid),events.objectid,events.name
FROM events
WHERE events.source = 3
  AND events.object = 4
  AND events.objectid NOT IN (SELECT itemid FROM items)
AND LENGTH(events.name)>0
GROUP BY events.objectid,events.name
ORDER BY COUNT(events.objectid),events.objectid,events.name
\G


/* remove event for unexisting items */
DELETE FROM events
WHERE events.source = 3
  AND events.object = 4
  AND events.objectid NOT IN (SELECT itemid FROM items);

  
/* list items that are active(not disabled) and comes from discovery rule */
SELECT COUNT(*),item_discovery.parent_itemid from items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items parent ON (parent.itemid=item_discovery.itemid)
WHERE hosts.host='centos7.catonrug.lan'
AND items.status=0
AND items.flags=4
GROUP BY item_discovery.parent_itemid
ORDER BY COUNT(*)
\G

/* how many item prototypes configured per discovery */
SELECT COUNT(*),prototype.key_,prototype.delay from items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN item_discovery ON (item_discovery.itemid=items.itemid)
JOIN items prototype ON (prototype.itemid=item_discovery.parent_itemid)
WHERE hosts.host='centos7.catonrug.lan'
AND items.status=0
AND items.flags=2
GROUP BY prototype.key_,prototype.delay
ORDER BY COUNT(*)
\G


/* which action is disablad THEN 'active */
SELECT actionid,
       name,
       CASE
           WHEN status=0 THEN 'active'
           WHEN status=1 THEN 'disable'
       END AS status
FROM actions
WHERE eventsource=0;





/* which action is causing the most trouble (NOT_SENT) */
SELECT COUNT(*),CASE alerts.status
           WHEN 0 THEN 'NOT_SENT'
           WHEN 1 THEN 'SENT'
           WHEN 2 THEN 'FAILED'
           WHEN 3 THEN 'NEW'
       END AS status,
	   actions.name
FROM alerts
JOIN actions ON (alerts.actionid=actions.actionid)
WHERE alerts.status=0
GROUP BY alerts.status,actions.name;


--for postgres
SELECT COUNT(*),CASE alerts.status
           WHEN 0 THEN 'NOT_SENT'
           WHEN 1 THEN 'SENT'
           WHEN 2 THEN 'FAILED'
           WHEN 3 THEN 'NEW'
       END AS status,
	   actions.name
FROM alerts
JOIN actions ON (alerts.actionid=actions.actionid)
WHERE alerts.clock > EXTRACT(EPOCH FROM (timestamp '2020-07-07 05:00:00'))
GROUP BY alerts.status,actions.name;




SELECT COUNT(*),
CASE alerts.status
WHEN 0 THEN 'NOT_SENT'
WHEN 1 THEN 'SENT'
WHEN 2 THEN 'FAILED'
WHEN 3 THEN 'NEW'
END AS status,
actions.name,
actions.actionid
FROM alerts
JOIN actions ON (alerts.actionid=actions.actionid)
GROUP BY alerts.status,actions.name,actions.actionid
ORDER BY COUNT(*) DESC;



--for mysql
SELECT COUNT(*),CASE alerts.status
           WHEN 0 THEN 'NOT_SENT'
           WHEN 1 THEN 'SENT'
           WHEN 2 THEN 'FAILED'
           WHEN 3 THEN 'NEW'
       END AS status,
	   actions.name
FROM alerts
JOIN actions ON (alerts.actionid=actions.actionid)
WHERE alerts.clock > UNIX_TIMESTAMP (NOW()-INTERVAL 7 DAY)
GROUP BY alerts.status,actions.name;



> UNIX_TIMESTAMP (NOW()-INTERVAL 7 DAY)

 
--mark unsent alerts as sent THEN 'remove the queue
UPDATE alerts
SET status=1,
message = 'Disabled by Admin'
WHERE status=0
AND actionid=7
LIMIT 10;




--3.2
SELECT COUNT(*),
alerts.actionid,
CASE alerts.status
WHEN 0 THEN 'NOT_SENT'
WHEN 1 THEN 'SENT'
WHEN 2 THEN 'FAILED'
WHEN 3 THEN 'NEW'
END AS status
FROM alerts
WHERE alerts.clock > UNIX_TIMESTAMP (NOW()-INTERVAL 1 DAY)
GROUP BY alerts.actionid,alerts.status;


UPDATE alerts SET status=1 THEN 'message = 'Disabled by Admin' WHERE status=0 AND actionid=7 LIMIT 10;

SELECT COUNT(*),
actions.name,
alerts.actionid
FROM alerts
JOIN actions ON (actions.actionid=alerts.actionid)
WHERE alerts.clock > UNIX_TIMESTAMP (NOW()-INTERVAL 1 DAY)
GROUP BY 2
ORDER BY 1;


/* system.cpu.num[] - this key will report integer (not float). timestamp will be store in history_uint */
/* linux and windows host must have one comon item key. Item key must be in configured as "Zabbix agent (active)" */
/* Freqeuncy shoud be 30s or less. better to not link any trigger */
/* one specific case when agent time is to old */

SELECT DISTINCT hosts.host,FROM_UNIXTIME(MAX(history_uint.clock))
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.key_='agent.ping'
GROUP BY hosts.host
LIMIT 2;


SELECT DISTINCT hosts.host,FROM_UNIXTIME(MAX(history_uint.clock))
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.key_='proc.num[]'
GROUP BY hosts.host
ORDER BY FROM_UNIXTIME(MAX(history_uint.clock));



SELECT DISTINCT hosts.host,FROM_UNIXTIME(MAX(history_uint.clock))
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.key_='agent.ping'
GROUP BY hosts.host
LIMIT 2;


/* postgres */
SELECT DISTINCT hosts.host,MAX(history_uint.clock)
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.key_='system.cpu.num[]'
GROUP BY hosts.host
LIMIT 2;




/* these items exist and generate bad events in last 1 day */
SELECT COUNT(items.key_) as count,items.key_,events.name
FROM events
JOIN items ON (items.itemid=events.objectid)
WHERE events.source = 3
  AND events.object = 4
  AND events.objectid IN (SELECT itemid FROM items)
  AND clock > UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY)
AND LENGTH(events.name)>0
GROUP BY items.key_,events.name
ORDER BY COUNT(items.key_),items.key_,events.name
\G



select num from trends_uint 
WHERE clock > UNIX_TIMESTAMP('2020-01-03 00:00:00')
  AND clock < UNIX_TIMESTAMP('2020-01-04 00:00:00')
  AND itemid=49766;
  
  
/* show the minimal clock value for items. without partition name this is performance killer. */
SELECT hosts.host,items.key_,FROM_UNIXTIME(MIN(clock))
FROM history PARTITION (p202003211600)
JOIN items ON (items.itemid=history.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
GROUP BY hosts.host,items.key_;






/* which item takes the most space by frequency */
SELECT count(items.key_),
       hosts.host,
       items.key_
FROM history_uint
JOIN items ON (items.itemid=history_uint.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock > UNIX_TIMESTAMP(NOW()-INTERVAL 1 DAY)
GROUP BY hosts.host,
         items.key_
ORDER BY count(items.key_),
         hosts.host,
         items.key_ ASC
\G




/* by partition which item takes the most space by frequency */
SELECT count(items.key_),hosts.host,items.key_
FROM history PARTITION (p202003211600)
JOIN items ON (items.itemid=history.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
GROUP BY hosts.host,items.key_
ORDER BY count(items.key_),hosts.host,items.key_ ASC
\G



SELECT NOW();

SELECT MAX(LENGTH(value)),AVG(LENGTH(value)) FROM history_text WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 1 HOUR);



SELECT max(LENGTH (value)),avg(LENGTH (value))
FROM history_text
WHERE clock > UNIX_TIMESTAMP (NOW() - INTERVAL 1 DAY);


SELECT hosts.host,items.key_ 
FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE LENGTH(value)>657
LIMIT 10\G




/* representing the Host groups with */
SELECT h.host AS 'Host name',
       h.name AS 'Visible name',
       GROUP_CONCAT(C.name SEPARATOR ' THEN '') AS 'Host groups',
       h.error AS 'Error'
FROM hosts h
JOIN hosts_groups AS B ON (h.hostid=B.hostid)
JOIN hstgrp AS C ON (B.groupid=C.groupid)
WHERE h.available = 2
GROUP BY h.host,h.name,h.error;

/* Listing template names */
SELECT h.host AS 'Host name',
       h.name AS 'Visible name',
       GROUP_CONCAT(b.host SEPARATOR ' THEN '') AS 'Templates',
       h.error AS 'Error'
FROM hosts_templates,
     hosts h,
     hosts b,
     interface
WHERE hosts_templates.hostid = h.hostid
  AND hosts_templates.templateid = b.hostid
  AND interface.hostid = h.hostid
  AND h.available = 2
GROUP BY h.host,h.name,h.error;
  

SELECT DISTINCT 
    (SELECT min(ti.Country_id) 
     FROM tbl_countries ti 
     WHERE t.country_title = ti.country_title) As Country_id
     THEN 'country_title
FROM 
    tbl_countries t
  


/* SNMPv3 hosts */
SELECT hosts.host,
COUNT(items.type) as 'Count of items'
FROM hosts
JOIN items ON (items.hostid=hosts.hostid)
WHERE items.type in (6)
AND hosts.status=0
GROUP BY hosts.host,items.type
ORDER BY hosts.host;


/* SNMPv2 hosts */
SELECT hosts.host,
COUNT(items.type) as 'Count of items'
FROM hosts
JOIN items ON (items.hostid=hosts.hostid)
WHERE items.type in (4)
AND hosts.status=0
GROUP BY hosts.host,items.type
ORDER BY hosts.host;


/* show SNMPv1 THEN 'SNMPv2 THEN 'SNMPv3 items */
SELECT hosts.host,
CASE items.type
           WHEN 1 THEN 'SNMPv1'
           WHEN 4 THEN 'SNMPv2'
           WHEN 6 THEN 'SNMPv3'
END AS type,
COUNT(items.type)
FROM hosts
JOIN items ON (items.hostid=hosts.hostid)
WHERE items.type in (1,4,6)
AND hosts.status=0
GROUP BY hosts.host,items.type
ORDER BY hosts.host;


SELECT hosts.hostid,CONCAT(COUNT(items.type),' ',items.type)
FROM hosts
JOIN items ON items.hostid=hosts.hostid
WHERE items.type in (1,4,6)
GROUP BY hosts.hostid,items.type
ORDER BY hosts.hostid;

  
/* This table contains list of active problems THEN 'in other words it will contain list of opened PROBLEM events. 
PROBLEM events are trigger events with value TRIGGER_VALUE_PROBLEM and internal events with value ITEM_STATE_NOTSUPPORTED/TRIGGER_STATE_UNKNOWN  */
select COUNT(*),source from problem group by source;
SELECT COUNT(*),source FROM events GROUP BY source;


/* show item prototypes THEN 'discoveries and items configured with SNMPv3 */
SELECT snmpv3_securityname AS USER,
       CASE snmpv3_securitylevel
           WHEN 0 THEN 'noAuthNoPriv'
           WHEN 1 THEN 'authNoPriv'
           WHEN 2 THEN 'authPriv'
       END AS secLev,
       CASE snmpv3_authprotocol
           WHEN 0 THEN 'MD5'
           WHEN 1 THEN 'SHA'
       END AS authProto,
       snmpv3_authpassphrase AS authPhrase,
       CASE snmpv3_privprotocol
           WHEN 0 THEN 'DES'
           WHEN 1 THEN 'AES'
       END AS privProto,
       snmpv3_privpassphrase AS privPhrase,
       CASE flags
           WHEN 0 THEN 'normal'
           WHEN 1 THEN 'rule'
           WHEN 2 THEN 'prototype'
           WHEN 4 THEN 'discovered'
       END AS flags,
       COUNT(*)
FROM items
WHERE TYPE=6
GROUP BY 1,2,3,4,5,6,7\G




/* see different type of items */
select COUNT(type) THEN 'type from items where hostid=10814 group by type;


/* show template count on 3.0 */
select COUNT(*) from hosts where status=3;
/* host is disabled */
select COUNT(*) from hosts where status=1;
/* count of monitored hosts */
select COUNT(*) from hosts where status=0 and flags<>2;


/* items running */
SELECT COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags IN (0,4)
  AND items.state=0
  AND items.status=0
  AND hosts.status=0
  AND hosts.flags<>2;

/* items disabled */
SELECT COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags IN (0,4)
  AND items.state=0
  AND items.status=1
  AND hosts.flags<>2;

/* items not supported */
SELECT COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags IN (0,4)
  AND items.state=1
  AND items.status=0
  AND hosts.status=0
  AND hosts.flags<>2;

/* details about triggers */
SELECT COUNT(DISTINCT triggers.triggerid) AS cnt,
       triggers.status,
       triggers.value
FROM triggers
WHERE NOT EXISTS
    (SELECT functions.functionid
     FROM functions
     JOIN items ON functions.itemid=items.itemid
     JOIN hosts ON items.hostid=hosts.hostid
     WHERE functions.triggerid=triggers.triggerid
       AND (items.status<>0
            OR hosts.status<>0))
  AND triggers.flags IN (0,4)
GROUP BY triggers.status,
         triggers.value;

/* In the result there will be all 4 things */
SELECT task.taskid,hosts.host FROM task
JOIN task_remote_command on (task.taskid=task_remote_command.taskid)
JOIN task_remote_command_result on (task.taskid=task_remote_command_result.taskid)
JOIN hosts on (task_remote_command.hostid=hosts.hostid)



/* enable loging to table. put all queries */
# Please do the following sequence:

truncate table mysql.general_log;

# sign in database client as root. take a look on current settings
select @@log_output THEN '@@general_log THEN '@@general_log_file\G

# set the global logging to table
SET global log_output = 'table';

# see now the situation has been changed comparing to original
select @@log_output THEN '@@general_log THEN '@@general_log_file\G

# take a note that log table currently is empty
select COUNT(*) from mysql.general_log;
 
# enable the logging
SET global general_log = 1;
# THIS WILL START TO WRITE MASSIVE CONTENT!

# see how the number is increasing. execute few times:
select COUNT(*) from mysql.general_log;
# I hope its less than 10000 records per second!

# wait 10 minutes

# stop logging
SET global general_log = 0;

# make sure number remains static
select COUNT(*) from mysql.general_log;

# set back the log settings to file
SET global log_output = 'file';

# this must be the same as in the beginning
select @@log_output THEN '@@general_log THEN '@@general_log_file\G

# ======not required to execute - to observe records=======
describe mysql.general_log;
show create table mysql.general_log\G

# observe records
select * from mysql.general_log limit 10\G

-- if argument is hex
select convert(argument using utf8) from mysql.general_log limit 10\G

select convert(argument using utf8)
from mysql.general_log
where convert(argument using utf8) like '%ldap%';

 limit 10\G


/* summarize a specific discovery rule - unsuppoerted/supported ratio. Does not work on 4.4 */
SELECT i.state,h.host AS 'Host name',i.name AS 'ITEM name',i.key_ AS 'KEY' FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.key_='vfs.fs.discovery[{HOST.NAME}]' and h.status=0 and i.state=0 limit 10;

/* on 3.4 */
select description from triggers WHERE triggerid IN (select objectid from events where eventid=15);
      
/* Something impossible has just happened */
select COUNT(*) from item_preproc where itemid not in (select itemid from items);
delete from item_preproc where itemid not in (select itemid from items);

select @@foreign_key_checks\G

/* Problems are stuck in the Closing status 
Click on the timestamp of each stuck problem to get the Event ID from URL and then use it to remove the record. Replace the <eventid> with relevant value. */
DELETE FROM events WHERE source = 0 AND object = 0 AND eventid = <eventid>;

/*
0 THEN 'ITEM_VALUE_TYPE_FLOAT - Float
1 THEN 'ITEM_VALUE_TYPE_STR - Character
2 THEN 'ITEM_VALUE_TYPE_LOG - Log
3 THEN 'ITEM_VALUE_TYPE_UINT64 - Unsigned integer
4 THEN 'ITEM_VALUE_TYPE_TEXT - Text
*/

SELECT COUNT(*) FROM history where itemid in (select itemid from items where value_type<>0);
SELECT COUNT(*) FROM history_str where itemid in (select itemid from items where value_type<>1);
SELECT COUNT(*) FROM history_log where itemid in (select itemid from items where value_type<>2);
SELECT COUNT(*) FROM history_uint where itemid in (select itemid from items where value_type<>3);
SELECT COUNT(*) FROM history_text where itemid in (select itemid from items where value_type<>4);


SELECT DISTINCT items.key_,hosts.host FROM history_text 
JOIN items ON (history_text.itemid=items.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
where history_text.itemid in (select itemid from items where value_type<>4);


DELETE FROM history where itemid in (select itemid from items where value_type<>0);
DELETE FROM history_str where itemid in (select itemid from items where value_type<>1);
DELETE FROM history_log where itemid in (select itemid from items where value_type<>2);
DELETE FROM history_uint where itemid in (select itemid from items where value_type<>3);
DELETE FROM history_text where itemid in (select itemid from items where value_type<>4);


/* compare the oldest record in events table with the data configured in GUI */
select min(clock) from events where source=0;
select min(clock) from events where source=3;
select min(clock) from events where source=2; 

/* postgreSQL manual housekeeper */
delete FROM alerts where age(to_timestamp(alerts.clock)) > interval '40 days';
delete FROM acknowledges where age(to_timestamp(acknowledges.clock)) > interval '40 days';
delete FROM events where age(to_timestamp(events.clock)) > interval '40 days';
delete FROM history where age(to_timestamp(history.clock)) > interval '40 days';
delete FROM history_uint where age(to_timestamp(history_uint.clock)) > interval '40 days' ;
delete FROM history_str  where age(to_timestamp(history_str.clock)) > interval '40 days' ;
delete FROM history_text where age(to_timestamp(history_text.clock)) > interval '40 days' ;
delete FROM history_log where age(to_timestamp(history_log.clock)) > interval '40 days' ;
delete FROM trends where age(to_timestamp(trends.clock)) > interval '90 days';
delete FROM trends_uint where age(to_timestamp(trends_uint.clock)) > interval '90 days' ;
delete from history where itemid not in (select itemid from items where status='0');
delete from history_uint where itemid not in (select itemid from items where status='0');
delete from history_str where itemid not in (select itemid from items where status='0');
delete from history_text where itemid not in (select itemid from items where status='0');
delete from history_log where itemid not in (select itemid from items where status='0');
delete from trends where itemid not in (select itemid from items where status='0');
delete from trends_uint where itemid not in (select itemid from items where status='0');	  
	  
/* */	  
SHOW FULL COLUMNS FROM items;
	  
/*	  
0 THEN 'ITEM_TYPE_ZABBIX - Zabbix agent
1 THEN 'ITEM_TYPE_SNMPV1 - SNMPv1 agent
2 THEN 'ITEM_TYPE_TRAPPER - Zabbix trapper
3 THEN 'ITEM_TYPE_SIMPLE - Simple check
4 THEN 'ITEM_TYPE_SNMPV2C - SNMPv2 agent
5 THEN 'ITEM_TYPE_INTERNAL - Zabbix internal
6 THEN 'ITEM_TYPE_SNMPV3 - SNMPv3 agent
7 THEN 'ITEM_TYPE_ZABBIX_ACTIVE - Zabbix agent (active) check
8 THEN 'ITEM_TYPE_AGGREGATE - Aggregate
9 THEN 'ITEM_TYPE_HTTPTEST - HTTP test (web monitoring scenario step)
10 THEN 'ITEM_TYPE_EXTERNAL - External check
11 THEN 'ITEM_TYPE_DB_MONITOR - Database monitor
12 THEN 'ITEM_TYPE_IPMI - IPMI agent
13 THEN 'ITEM_TYPE_SSH - SSH agent
14 THEN 'ITEM_TYPE_TELNET - TELNET agent
15 THEN 'ITEM_TYPE_CALCULATED - Calculated
16 THEN 'ITEM_TYPE_JMX - JMX agent
17 THEN 'ITEM_TYPE_SNMPTRAP - SNMP trap
18 THEN 'ITEM_TYPE_DEPENDENT - Dependent item
*/	  

/* most unsupported items per host. Does not work on 4.4 */
SELECT DISTINCT h.host AS 'Host name',COUNT(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' GROUP BY h.host ORDER BY 2;

 SELECT DISTINCT h.host AS 'Host name',COUNT(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' GROUP BY h.host ORDER BY 2 desc limit 15;

/* only enabled hosts */
SELECT DISTINCT h.host AS 'Host name',COUNT(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' and h.status=0 GROUP BY h.host ORDER BY 2 desc limit 15; 
SELECT DISTINCT h.host AS 'Host name',COUNT(i.key_) FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1' and h.status=0 GROUP BY h.host ORDER BY 2 desc limit 15; 
 

/* show SSH agent in unsupported state */
select i.state,i.itemid,i.hostid,i.key_,i.templateid,h.name from items i INNER JOIN hosts h where (h.hostid=i.hostid) and type=13 and i.flags=0 and h.status not in (3) and state=1;
	  
/* show Simple check in unsupported state */
select i.state,i.itemid,i.hostid,i.key_,i.templateid,h.name from items i INNER JOIN hosts h where (h.hostid=i.hostid) and type=3 and i.flags=0 and h.status not in (3) and state=1;

/* show Zabbix trapper in unsupported state */
select i.state,i.itemid,i.hostid,i.key_,i.templateid,h.name from items i INNER JOIN hosts h where (h.hostid=i.hostid) and type=2 and i.flags=0 and h.status not in (3) and state=1;

/* show Database monitor in unsupported state */
select i.state,i.itemid,i.hostid,i.key_,i.templateid,h.name from items i INNER JOIN hosts h where (h.hostid=i.hostid) and type=11 and i.flags=0 and h.status not in (3) and state=1;


/* summarize database permissions */
select host,db,user from mysql.db;
SELECT Host,User FROM mysql.user where User="zabbix";


/* StartDBSyncers=4 by default can feed 4k NVPS. Don't increase it. If history syncer is busy there may be to much nodata or time based triggers functions. History syncer is responsible about calculating triggers.
If StartDBSyncers there will be more locks on ids table and performance will decrease.
 */


select e.eventid from events e INNER JOIN triggers t ON ( t.triggerid = e.objectid ) where t.triggerid = NULL;


/* most frequent metrics */
select itemid,COUNT(*) from history_uint where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by COUNT(*) desc limit 10\G


select itemid,COUNT(*) from history where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by COUNT(*) desc limit 10;


select itemid,COUNT(*) from history_str where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by COUNT(*) desc limit 10;


select itemid,COUNT(*) from history_log where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by COUNT(*) desc limit 10;


select itemid,COUNT(*) from history_text where clock> UNIX_TIMESTAMP(now()-INTERVAL 1 day) group by itemid order by COUNT(*) desc limit 10;


/* optimize sessions table in case of lazy bastard - cannot fine tune the API script */
SELECT COUNT(*) FROM sessions;



DELETE FROM sessions WHERE (lastaccess < UNIX_TIMESTAMP(NOW()) - 3600); OPTIMIZE TABLE sessions;

--postgres
DELETE FROM sessions WHERE lastaccess < EXTRACT(EPOCH FROM (NOW() - INTERVAL '1 DAY'));




SELECT COUNT(u.alias),
       u.alias
FROM users u
INNER JOIN sessions s ON (u.userid = s.userid)
WHERE (s.status=0)
  AND (s.lastaccess > UNIX_TIMESTAMP(NOW()) - 300)
GROUP BY u.alias;



SELECT COUNT(u.alias),
       u.alias
FROM users u
INNER JOIN sessions s ON (u.userid = s.userid)
WHERE (s.status=0)
  AND (s.lastaccess > UNIX_TIMESTAMP(NOW()) - 300)
GROUP BY u.alias;



SELECT COUNT(u.alias),u.alias FROM users u INNER JOIN sessions s ON (u.userid = s.userid) WHERE (s.status=0) AND (s.lastaccess > UNIX_TIMESTAMP(NOW()) - 300) GROUP BY u.alias;

/* which users belongs to groupid THEN 'user group */
SELECT users.alias
FROM users_groups
JOIN users ON (users_groups.userid=users.userid)
WHERE users_groups.usrgrpid in (7);


--how many user groups are there. how many users belong to each user group
SELECT usrgrpid as user_group,GROUP_CONCAT(userid) as users
FROM users_groups
GROUP BY usrgrpid;




/* filter active triggers by severity on 3.4 with events table (a database killer) */ 
SELECT COUNT(t.priority) AS COUNT,
       CASE
           WHEN t.priority=0 THEN 'Not classified'
           WHEN t.priority=1 THEN 'Information'
           WHEN t.priority=2 THEN 'Warning'
           WHEN t.priority=3 THEN 'Average'
           WHEN t.priority=4 THEN 'High'
           WHEN t.priority=5 THEN 'Disaster'
       END AS priority
FROM EVENTS e
INNER JOIN TRIGGERS t ON (e.objectid = t.triggerid)
WHERE e.source=0
  AND e.object=0
  AND t.value=1
GROUP BY t.priority
ORDER BY COUNT(t.priority);

/* filter active triggers by severity on 3.4 with events table (NOT a database killer) */ 
select COUNT(t.priority),CASE
           WHEN t.priority=0 THEN 'Not classified'
           WHEN t.priority=1 THEN 'Information'
           WHEN t.priority=2 THEN 'Warning'
           WHEN t.priority=3 THEN 'Average'
           WHEN t.priority=4 THEN 'High'
           WHEN t.priority=5 THEN 'Disaster'
       END AS priority
from triggers t
where t.value=1
and t.flags in (0,4)
GROUP BY t.priority
ORDER BY COUNT(t.priority);

/* auditlog */
SELECT COUNT(*),
       CASE
           WHEN action=0 THEN 'AUDIT_ACTION_ADD'
           WHEN action=1 THEN 'AUDIT_ACTION_UPDATE'
           WHEN action=2 THEN 'AUDIT_ACTION_DELETE'
           WHEN action=3 THEN 'AUDIT_ACTION_LOGIN'
           WHEN action=4 THEN 'AUDIT_ACTION_LOGOUT'
           WHEN action=5 THEN 'AUDIT_ACTION_ENABLE'
           WHEN action=6 THEN 'AUDIT_ACTION_DISABLE'
       END AS action
FROM auditlog
GROUP BY action;



SELECT COUNT(*),
       CASE
           WHEN action=0 THEN 'AUDIT_ACTION_ADD'
           WHEN action=1 THEN 'AUDIT_ACTION_UPDATE'
           WHEN action=2 THEN 'AUDIT_ACTION_DELETE'
           WHEN action=3 THEN 'AUDIT_ACTION_LOGIN'
           WHEN action=4 THEN 'AUDIT_ACTION_LOGOUT'
           WHEN action=5 THEN 'AUDIT_ACTION_ENABLE'
           WHEN action=6 THEN 'AUDIT_ACTION_DISABLE'
       END AS action
FROM auditlog
WHERE clock>(UNIX_TIMESTAMP("2020-01-01 00:00:00"))
  AND clock<(UNIX_TIMESTAMP("2020-02-01 00:00:00"))
GROUP BY action;



/* problems by severity */
select COUNT(*) from zabbix.triggers where priority=5 and value=1;
select COUNT(*) from zabbix.triggers where priority=4 and value=1;
select COUNT(*) from zabbix.triggers where priority=3 and value=1;
select COUNT(*) from zabbix.triggers where priority=2 and value=1;
select COUNT(*) from zabbix.triggers where priority=1 and value=1;
select COUNT(*) from zabbix.triggers where priority=0 and value=1;


/* max and average value lenght */
select max(LENGTH (value)) THEN 'avg(LENGTH (value)) from history_text where clock> UNIX_TIMESTAMP (now() - INTERVAL 30 MINUTE);




/* show which user is active users  */
SELECT users.alias,sessions.sessionid,sessions.lastaccess
FROM users
JOIN users_groups ON ( users.userid = users_groups.userid )
JOIN sessions ON ( users.userid = sessions.userid )
WHERE (sessions.status = 0)
AND sessions.lastaccess>1583830440;

--5.0
SELECT users.alias,sessions.sessionid,sessions.lastaccess
FROM users
JOIN users_groups ON ( users.userid = users_groups.userid )
JOIN sessions ON ( users.userid = sessions.userid )
;


SELECT users.username,sessions.sessionid,sessions.lastaccess
FROM users
JOIN users_groups ON ( users.userid = users_groups.userid )
JOIN sessions ON ( users.userid = sessions.userid )
;

/* user group with specific rights causing trouble */
SELECT users.alias,sessions.sessionid,sessions.lastaccess,rights.rightid
FROM users
JOIN users_groups ON ( users.userid = users_groups.userid )
JOIN sessions ON ( users.userid = sessions.userid )
JOIN usrgrp ON ( usrgrp.usrgrpid = users_groups.usrgrpid )
JOIN rights ON ( rights.groupid = usrgrp.usrgrpid )
WHERE (sessions.status = 0)
AND sessions.lastaccess>1583830440;

/* tail -f zabbix_access.log | grep -E -o "sid=[0-9a-f]+" */

SELECT users.alias,
       sessions.sessionid,
       sessions.lastaccess,
       rights.rightid
FROM users
JOIN users_groups ON (users.userid = users_groups.userid)
JOIN sessions ON (users.userid = sessions.userid)
JOIN usrgrp ON (usrgrp.usrgrpid = users_groups.usrgrpid)
JOIN rights ON (rights.groupid = usrgrp.usrgrpid)
WHERE (sessions.status = 0)
  AND rights.rightid IN (7)
  AND sessions.lastaccess>NOW() - 3600;
  
--replace 'Zabbix User' to "Zabbix Admin"
UPDATE users SET type=2 WHERE type=1;


/* search for metrics in history_text table where currently those are not stored as text */
SELECT COUNT(itemid) FROM history_text WHERE itemid IN (SELECT itemid FROM items where value_type<>4);

SELECT u.alias
FROM users u
INNER JOIN users_groups g ON ( u.userid = g.userid )
INNER JOIN sessions s ON ( u.userid = s.userid )
WHERE (s.status = 0)
and (s.lastaccess > NOW() - 3600);

/* active users users */
SELECT COUNT(*),users.alias
FROM users
JOIN sessions ON (users.userid = sessions.userid)
WHERE (sessions.status=0)
GROUP BY users.alias;

--all user sessions
SELECT COUNT(*),users.alias
FROM users
JOIN sessions ON (users.userid = sessions.userid)
GROUP BY users.alias
ORDER BY COUNT(*) DESC;


SELECT COUNT(*),users.alias
FROM users
JOIN sessions ON (users.userid = sessions.userid)
GROUP BY users.alias;



/* active users not including guests */
SELECT COUNT(u.alias),u.alias FROM users u INNER JOIN sessions s ON (u.userid = s.userid) WHERE (s.status=0)   AND (u.alias<>'guest') GROUP BY u.alias;


--users online in last 5 minutes
SELECT COUNT(*),
       users.userid
FROM users
JOIN sessions ON (users.userid = sessions.userid)
WHERE (sessions.status=0)
  AND (sessions.lastaccess > UNIX_TIMESTAMP(NOW()- INTERVAL 1 HOUR))
GROUP BY users.userid;



/* */
SELECT u.alias,
       s.sessionid
FROM users u
INNER JOIN sessions s ON (u.userid = s.userid)
WHERE (s.status=0)
  AND (s.lastaccess > UNIX_TIMESTAMP(NOW()) - 300);
  
  
  SELECT users.alias,
       sessions.sessionid
FROM users 
INNER JOIN sessions ON (users.userid = sessions.userid)
WHERE (sessions.status=0)
  AND (sessions.lastaccess > UNIX_TIMESTAMP(NOW()) - 300)\G


SELECT users.alias,
       SUBSTRING(sessions.sessionid,17,16) as "sid in access.log"
FROM users 
INNER JOIN sessions ON (users.userid = sessions.userid)
WHERE (sessions.status=0)
  AND (sessions.lastaccess > UNIX_TIMESTAMP(NOW()) - 300)\G
  
--postgres
SELECT users.alias,
       SUBSTRING(sessions.sessionid,17,16) as "sid in access.log"
FROM users 
INNER JOIN sessions ON (users.userid = sessions.userid)
WHERE (sessions.status=0)
  AND (sessions.lastaccess > EXTRACT(EPOCH FROM (NOW() - INTERVAL '5 MINUTES')));
  


--# cd /var/log/httpd
--# cd /var/log/nginx
--# cd /var/opt/rh/rh-nginx116/log/nginx
-- cat access.log | grep b69cea5a0889f3cb | grep -Eo "dashboardid=[0-9]+"

/* ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 's INNER JOIN users u ON (u.userid = s.userid) where (u.alias='guest')' at line 1 */


/* in postgres */

SELECT users.alias,
       sessions.sessionid
FROM users
JOIN sessions ON (users.userid = sessions.userid)
WHERE sessions.status=0
  AND sessions.lastaccess > 1593505746
;


SELECT COUNT(*) FROM sessions;


DELETE FROM sessions
JOIN users ON (users.userid=sessions.userid)
WHERE users.alias='Admin'; 
OPTIMIZE TABLE sessions;



/* show which user is online by groupid */
SELECT u.alias
FROM users u
INNER JOIN users_groups g ON ( u.userid = g.userid )
INNER JOIN sessions s ON ( u.userid = s.userid )
WHERE (g.usrgrpid=7)
AND (s.status = 1);


/* select triggers from one host */
SELECT DISTINCT host THEN 't.description THEN 'f.triggerid THEN 't.value
FROM triggers t
INNER JOIN functions f ON ( f.triggerid = t.triggerid )
INNER JOIN items i ON ( i.itemid = f.itemid )
INNER JOIN hosts ON ( i.hostid = hosts.hostid )
WHERE (1=1)
AND host = 'Zabbix server' 
GROUP BY f.triggerid
ORDER BY t.lastchange DESC;

/* see hosts/templates having snmp trap items */
select h.name,i.hostid from items i join hosts h where i.hostid = h.hostid and i.type=17;


select DISTINCT h.name THEN 'i.key_ THEN 't.error from events e 
inner join triggers t on (e.objectid=t.triggerid)
INNER JOIN functions f ON ( f.triggerid = t.triggerid )
INNER JOIN items i ON ( i.itemid = f.itemid )
INNER JOIN hosts h ON ( i.hostid = h.hostid )
where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 limit 20;

/* problems receiving information */


		 
		 



select DISTINCT h.name THEN 'i.key_ THEN 't.error from events e  inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like 'Cannot obtain file information: [2] No such file or directory';


select DISTINCT h.name THEN 'i.key_ THEN 't.error from events e  inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like '%Agent is unavailable.%' and e.clock>UNIX_TIMESTAMP(NOW())-3600;


/* timeout */
select COUNT(t.error) THEN 'key_,t.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like 'Timeout while executing a shell script.' group by key_ order by COUNT(t.error) desc;


select COUNT(t.error),h.name THEN 'key_,t.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and t.error like 'Timeout while executing a shell script.' and e.clock>UNIX_TIMESTAMP(NOW())-3600 group by key_ order by COUNT(t.error) desc;


/* trigger error statisticks */
select COUNT(t.error) THEN 't.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 group by t.error;


/* latest monitoring problems */
select COUNT(t.error) THEN 't.error from events e inner join triggers t on (e.objectid=t.triggerid) INNER JOIN functions f ON ( f.triggerid = t.triggerid ) INNER JOIN items i ON ( i.itemid = f.itemid ) INNER JOIN hosts h ON ( i.hostid = h.hostid ) where e.source=3 and e.object=0 and t.flags in (0,4) and t.state=1 and e.clock>UNIX_TIMESTAMP(NOW())-3600 group by t.error;


/* discoveries les than 10 minutes */
select key_,delay from items where flags=1 and delay not in (600,3600,0,'10m') and delay not like '%h' and delay not like '%d' order by delay;

/* lld discoveries for only monitored hosts */
select COUNT(*),delay
FROM items 
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags=1
AND hosts.status=0
GROUP BY delay
;

/* LLD trapper items or dependable items */
select count(*),items.type
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags=1
AND hosts.status=0
AND delay=0
GROUP BY items.type
\G


/* lld discoveries for only monitored hosts */
select COUNT(*),delay,key_
FROM items 
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags=1
AND hosts.status=0
GROUP BY delay,key_
\G










/* show hosts having a dns name installed */
SELECT h.host,h.name,ii.type,ii.useip,ii.ip,ii.dns from hosts h join interface ii on h.hostid=ii.hostid WHERE LENGTH(ii.dns)>0 AND ii.useip=1;



/* top messages which were initiated to notify someone (not works on 3.0) */
select COUNT(*),t.description from alerts a inner join events e on a.p_eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by COUNT(*) desc limit 10;
select COUNT(*),t.description from alerts a inner join events e on a.p_eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by COUNT(*) desc\G

/* on 3.0 */
select COUNT(*),t.description from alerts a inner join events e on a.eventid = e.eventid inner join triggers t on e.objectid = t.triggerid where e.source = 0 group by t.triggerid order by COUNT(*) desc limit 10;



/* identify possibly old records which belongs to nonexisting trigger */
select objectid,name from events where source=0 and objectid not in (select triggerid from triggers)\G

select COUNT(*) from events where source=0 and objectid not in (select triggerid from triggers);
select objectid,name from events where source=0 and objectid not in (select triggerid from triggers) order by clock\G


\x\g\x




select h.host from interface ii,hosts h WHERE h.hostid=ii.hostid AND ii.useip=1 AND LENGTH(ii.dns)>0;





select COUNT(*),CASE alerts.status
           WHEN 0 THEN 'NOT_SENT'
           WHEN 1 THEN 'SENT'
           WHEN 2 THEN 'FAILED'
           WHEN 3 THEN 'NEW'
       END AS status
from alerts
JOIN media_type ON (media_type.mediatypeid=alerts.mediatypeid)
where media_type.type=4
group by alerts.status;


/* Cannot insert new item in the host configuration */
delete from ids where table_name='items';
delete from ids;

show processlist;
/* if query is all in caps this means it comes from frontend */

FLUSH PRIVILEGES;

/* for 5.5.64-MariaDB Comming from Base CentOS 7 repo */
/* https://www.digitalocean.com/community/tutorials/how-to-change-a-mysql-data-directory-to-a-new-location-on-centos-7 */

SELECT @@hostname,@@version,@@datadir\G

SELECT @@hostname,@@version,@@datadir,@@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G




SELECT @@version,@@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_flush_method,@@innodb_log_file_size,@@open_files_limit,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G

SELECT @@version,@@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@open_files_limit,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G


SELECT @@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G

SELECT @@innodb_file_per_table,@@datadir,@@innodb_buffer_pool_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G


SELECT @@hostname,@@version,@@datadir,@@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G

/* if xtrabackup is used https://mariadb.com/kb/en/library/percona-xtrabackup-overview/ */ 
SELECT @@hostname,@@version,@@datadir,@@innodb_file_per_table,@@innodb_buffer_pool_size,@@innodb_page_size,@@innodb_buffer_pool_instances,@@innodb_flush_method,@@innodb_log_file_size,@@query_cache_type,@@max_connections,@@innodb_flush_log_at_trx_commit,@@optimizer_switch\G;


SELECT @@max_connections THEN '@@open_files_limit ; 


select @@hostname THEN '@@version THEN '@@datadir THEN '@@open_files_limit THEN '@@innodb_file_per_table THEN '@@skip_name_resolve THEN '@@key_buffer_size THEN '@@max_allowed_packet THEN '@@max_connections THEN '@@join_buffer_size THEN '@@sort_buffer_size THEN '@@read_buffer_size THEN '@@thread_cache_size THEN '@@query_cache_type THEN '@@wait_timeout THEN '@@innodb_buffer_pool_size THEN '@@innodb_log_file_size THEN '@@innodb_log_buffer_size THEN '@@innodb_flush_method THEN '@@innodb_buffer_pool_instances THEN '@@innodb_flush_log_at_trx_commit THEN '@@optimizer_switch\G

select @@hostname THEN '@@version THEN '@@datadir,@@innodb_file_per_table\G



/* see the last failed messages */
select clock,error from alerts where status=2 order by clock desc limit 10;


/* command resets the trigger status. */
/* You can update trigger status using following query THEN 'replace "(list of trigger ids)" with actual trigger ids values with "," delimiter: */
update triggers set value = 0 THEN 'lastchange = UNIX_TIMESTAMP(NOW()) WHERE triggerid in (list of trigger ids);

UPDATE items SET lastlogsize=0 where itemid=123456;


SELECT COUNT(*),templateid 
FROM triggers 
WHERE value=1 
AND flags IN (0,4) 
GROUP BY templateid 
ORDER BY 1;


SELECT COUNT(*),t.description 
FROM triggers
JOIN triggers t ON (t.triggerid=triggers.templateid)
WHERE triggers.value=1 
AND triggers.flags IN (0,4) 
GROUP BY triggers.templateid 
ORDER BY 1 ASC;



SELECT triggerid FROM triggers WHERE value=1 AND flags IN (0,4);
--close triggers on 4.0
UPDATE triggers SET value=0 WHERE flags IN (0,4);


/* what item prototype has been assigned for discovery rule */
SELECT id.itemid,
       id.key_,
       id.lastcheck,
       id.ts_delete,
       i.name,
       i.key_,
       i.type,
       i.value_type,
       i.delay,
       i.history,
       i.trends,
       i.trapper_hosts,
       i.units,
       i.formula,
       i.logtimefmt,
       i.valuemapid,
       i.params,
       i.ipmi_sensor,
       i.snmp_community,
       i.snmp_oid,
       i.port,
       i.snmpv3_securityname,
       i.snmpv3_securitylevel,
       i.snmpv3_authprotocol,
       i.snmpv3_authpassphrase,
       i.snmpv3_privprotocol,
       i.snmpv3_privpassphrase,
       i.authtype,
       i.username,
       i.password,
       i.publickey,
       i.privatekey,
       i.description,
       i.interfaceid,
       i.snmpv3_contextname,
       i.jmx_endpoint,
       i.master_itemid,
       i.timeout,
       i.url,
       i.query_fields,
       i.posts,
       i.status_codes,
       i.follow_redirects,
       i.post_type,
       i.http_proxy,
       i.headers,
       i.retrieve_mode,
       i.request_method,
       i.output_format,
       i.ssl_cert_file,
       i.ssl_key_file,
       i.ssl_key_password,
       i.verify_peer,
       i.verify_host,
       id.parent_itemid,
       i.allow_traps
FROM item_discovery id
JOIN items i ON id.itemid=i.itemid
WHERE id.parent_itemid IN (103331);



/* show the variation between SNMP community names being used in environment */
SELECT snmp_community,
       snmpv3_securityname,
       snmpv3_securitylevel,
       snmpv3_authpassphrase,
       snmpv3_privpassphrase,
       snmpv3_authprotocol,
       snmpv3_privprotocol,
       snmpv3_contextname,
       COUNT(*)
FROM items i
JOIN hosts h ON i.hostid = h.hostid
WHERE i.type IN (1,4,6)
GROUP BY snmp_community,
         snmpv3_securityname,
         snmpv3_securitylevel,
         snmpv3_authpassphrase,
         snmpv3_privpassphrase,
         snmpv3_authprotocol,
         snmpv3_privprotocol,
         snmpv3_contextname\G;
		 

/* filter by host */
SELECT snmp_community,
       snmpv3_securityname,
       snmpv3_securitylevel,
       snmpv3_authpassphrase,
       snmpv3_privpassphrase,
       snmpv3_authprotocol,
       snmpv3_privprotocol,
       snmpv3_contextname,
       COUNT(*)
FROM items i
JOIN hosts h ON i.hostid = h.hostid
WHERE i.type IN (1,4,6)
  AND h.hostid=10814
GROUP BY snmp_community,
         snmpv3_securityname,
         snmpv3_securitylevel,
         snmpv3_authpassphrase,
         snmpv3_privpassphrase,
         snmpv3_authprotocol,
         snmpv3_privprotocol,
         snmpv3_contextname\G;

/* estimate how many miliseconds takes the each part in SQL query */
SET profiling = 1;
select * from sessions;
show profiles;
SHOW PROFILE FOR QUERY 1;
explain select * from sessions;
SET profiling = 0;

select clock,objectid,name,COUNT(objectid) c from events where source=3 group by objectid having mod (c,2)=1;

select i.itemid THEN 'i.key_ ,i.delay,h.name from items i,hosts h where i.hostid=h.hostid and i.flags=1 and i.delay in ('10m','10s','1m','30s','5m','2m') and h.status=3;

SELECT ... FROM ... WHERE ... 
INTO OUTFILE 'textfile.csv'
FIELDS TERMINATED BY '|'
find / -name textfile.csv

/* Let's check the amount of events your top 20 triggers have associated with them */
select COUNT(*),source,object,objectid from problem group by source,object,objectid order by COUNT(*) desc limit 20;

/* version 3.4. delete all source 3 events from events and problem table. It safe to do with queries THEN 'but please make sure that you have a backup.: */
delete from events where source>0;
delete from problem where source>0;

SELECT source,object,COUNT(*) FROM events GROUP BY 1,2 ORDER BY 1,2;





SELECT snmpv3_securityname AS USER,
       CASE snmpv3_securitylevel
           WHEN 0 THEN 'noAuthNoPriv'
           WHEN 1 THEN 'authNoPriv'
           WHEN 2 THEN 'authPriv'
       END AS secLev,
       CASE snmpv3_authprotocol
           WHEN 0 THEN 'MD5'
           WHEN 1 THEN 'SHA'
       END AS authProto,
       snmpv3_authpassphrase AS authPhrase,
       CASE snmpv3_privprotocol
           WHEN 0 THEN 'DES'
           WHEN 1 THEN 'AES'
       END AS privProto,
       snmpv3_privpassphrase AS privPhrase,
       CASE flags
           WHEN 0 THEN 'normal'
           WHEN 1 THEN 'rule'
           WHEN 2 THEN 'prototype'
           WHEN 4 THEN 'discovered'
       END AS flags,
       COUNT(*)
FROM items
WHERE TYPE=6
  AND hostid=10280
GROUP BY 1,
         2,
         3,
         4,
         5,
         6,
         7;



/* show all LLD rulles by execution time and discovery key. show the count of rules */
select delay,key_,COUNT(*) from items where flags = 1 group by delay THEN 'key_ order by COUNT(*) desc;
select delay,key_,COUNT(*) from items where flags = 1 group by delay THEN 'key_ order by delay,COUNT(*);
select itemid,delay,key_,COUNT(*) from items where flags = 1 group by delay THEN 'key_ order by COUNT(*) asc;
select itemid,delay,COUNT(*) from items where flags = 1 group by delay THEN 'key_ order by COUNT(*) asc;
select i.itemid THEN 'i.key_ ,i.delay,h.name from zabbix.items i,zabbix.hosts h where i.hostid=h.hostid and i.flags=1 and h.status=3 and itemid=<itemid>;










select i.itemid THEN 'i.key_ ,i.delay,h.name from zabbix.items i,zabbix.hosts h where i.hostid=h.hostid and i.flags=1 and h.status=3;


/* show all items from specific host */
select * from items where hostid in (select hostid from hosts where hostid in (select hostid from interface) and host like 'Zabbix server');
select name,key_ from items where hostid in (select hostid from hosts where hostid in (select hostid from interface) and host like 'Zabbix server');


/* select all items from specific host group */
select * from items where hostid in (select hostid from hosts_groups where groupid in (select groupid from groups where name like 'Zabbix servers'));

/* Select all items from all hosts */
select * from items where hostid in (select hostid from hosts where hostid in (select hostid from interface) and host like '%');

/* list the biggest log items in the database */
select itemid THEN 'hostid THEN 'name THEN 'lastlogsize from items where type=7 and value_type=2 and lastlogsize>1000000;

/* show possibly bigger log items on 4.4 */
SELECT hosts.host,
       hosts.name,
	   items.itemid,
       items.key_,
       item_rtdata.lastlogsize
FROM items
JOIN item_rtdata ON (item_rtdata.itemid=items.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.type=7
  AND items.value_type=2
ORDER BY item_rtdata.lastlogsize\G




select itemid THEN 'hostid THEN 'name THEN 'lastlogsize from items where type=7 and value_type=2 and lastlogsize>1000000;

select items.itemid THEN 'item_rtdata.lastlogsize from items join item_rtdata on (item_rtdata.itemid=items.itemid) where items.type=7 and items.value_type=2;

item_rtdata

/* Show how much items are created/active/disabled per type */
SELECT CASE
           WHEN TYPE=0 THEN 'Zabbix Agent'
           WHEN TYPE=1 THEN 'SNMPv1 agent'
           WHEN TYPE=2 THEN 'Zabbix trapper'
           WHEN TYPE=3 THEN 'simple check'
           WHEN TYPE=4 THEN 'SNMPv2 agent'
           WHEN TYPE=5 THEN 'Zabbix internal'
           WHEN TYPE=6 THEN 'SNMPv3 agent'
           WHEN TYPE=7 THEN 'Zabbix agent (active)'
           WHEN TYPE=8 THEN 'Zabbix aggregate'
           WHEN TYPE=9 THEN 'web item'
           WHEN TYPE=10 THEN 'external check'
           WHEN TYPE=11 THEN 'database monitor'
           WHEN TYPE=12 THEN 'IPMI agent'
           WHEN TYPE=13 THEN 'SSH agent'
           WHEN TYPE=14 THEN 'TELNET agent'
           WHEN TYPE=15 THEN 'calculated'
           WHEN TYPE=16 THEN 'JMX agent'
           WHEN TYPE=17 THEN 'SNMP trap'
           WHEN TYPE=18 THEN 'Dependent item'
           WHEN TYPE=19 THEN 'HTTP agent'
       END AS TYPE,
       CASE
           WHEN status=0 THEN 'ON'
           ELSE 'OFF'
       END AS status,
       COUNT(*)
FROM items
GROUP BY TYPE,
         status
ORDER BY TYPE,
         status DESC;
		 	 
		 
		 

SELECT hosts.host,
       hosts.name,
       history_str.itemid,
       items.key_,
       COUNT(*)
FROM history_str
JOIN items ON (items.itemid=history_str.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock>=1578924000
  AND clock<=1578952800
GROUP BY history_str.itemid
ORDER BY COUNT(*)\G



select hosts.host,items.key_,ts_delete from item_discovery
JOIN items ON (item_discovery.itemid=items.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
where ts_delete<>0;



SELECT hosts.host,
       hosts.name,
       history_text.itemid,
       items.key_,
       COUNT(*)
FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock>=1578924000
  AND clock<=1578952800
GROUP BY history_text.itemid
ORDER BY COUNT(*)\G
		 

SELECT hosts.host,
       hosts.name,
       history_log.itemid,
       items.key_,
       COUNT(*)
FROM history_log
JOIN items ON (items.itemid=history_log.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE clock>=1578924000
  AND clock<=1578952800
GROUP BY history_log.itemid
ORDER BY COUNT(*)\G
		 
		 
		 

select distinct key_ from items where type = 0;
select distinct key_ from items where type = 3;
select distinct key_ from items where type = 4;

		 
select COUNT(*),type from items  group by type;


		 
SELECT TYPE,
       CASE
           WHEN status=0 THEN 'ON'
           ELSE 'OFF'
       END AS status,
       COUNT(*)
FROM items
GROUP BY TYPE,
         status
ORDER BY TYPE,
         status DESC;


/* show unsupported items THEN 'transfer hostid into human readable name */
SELECT h.host AS Host_name,i.name AS ITEM_name,i.key_ FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.state='1';


select * from items limit 1\G;


/* detect database character set and collate */
SELECT @@character_set_database THEN '@@collation_database\G;
/* check collation. this should report empty string */
SELECT * FROM information_schema.TABLES WHERE table_schema = 'zabbix' AND table_collation != 'utf8_bin';
/* check collation. this should report content */
SELECT * FROM information_schema.TABLES WHERE table_schema = 'zabbix' AND table_collation = 'utf8_bin';



mysql -h 127.0.0.1 -u'zabbix' -p'zabbix' --database=zabbix -B -N -e "SHOW TABLES" | awk '{print "SHOW CREATE TABLE" THEN '$1,"\\G" }' | mysql -h 127.0.0.1 -u'zabbix' -p'zabbix' --database=zabbix

/* covert database */
mysql -h 127.0.0.1 -u zabbix -p'zabbix' --database=zabbix -B -N -e "SHOW TABLES" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE" THEN '$1 THEN '"CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}' | mysql -h 127.0.0.1 -u zabbix -p'zabbix' --database=zabbix 


mysql -h 127.0.0.1 -u zabbix -p'zabbix' --database=zabbix -B -N -e "SHOW TABLES" | grep -v "history*\|trends*" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE" THEN '$1 THEN '"CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}' | mysql -h 127.0.0.1 -u zabbix -p'zabbix' --database=zabbix 



/* list all events based on Zabbix trigger ID */
select * from events where source = 0 and objectid = <triggerid> order by clock DESC LIMIT 10;

/* show mysql variables */
show variables where Variable_name like 'innodb_file_per_table';

/* Show session count opened per each user */
SELECT sessions.userid,
users.alias,
COUNT(*)
FROM sessions
INNER JOIN users ON sessions.userid = users.userid
GROUP BY sessions.userid,
users.alias
ORDER BY COUNT(*) ASC;



SELECT r.rightid,
       hgr.name,
       CASE
           WHEN r.permission=0 THEN 'DENY'
           WHEN r.permission=2 THEN 'READ_ONLY'
           WHEN r.permission=3 THEN 'READ_WRITE'
       END AS permission
FROM users u
JOIN users_groups ug ON (u.userid = ug.userid)
JOIN usrgrp ugrp ON (ugrp.usrgrpid = ug.usrgrpid)
JOIN rights r ON (ugrp.usrgrpid = r.groupid)
JOIN hstgrp hgr ON (r.id=hgr.groupid)
WHERE u.alias='first';








/* show unsupported itmes in 4.4. this query does not work on 4.0 THEN '4.2 */
select hosts.name THEN 'item_rtdata.state THEN 'items.key_
from item_rtdata
JOIN items ON (items.itemid=item_rtdata.itemid)
JOIN hosts ON (items.hostid=hosts.hostid)
JOIN interface ON (interface.hostid=hosts.hostid)
where item_rtdata.state=1\G

select hosts.name THEN 'item_rtdata.state THEN 'items.key_
from item_rtdata
JOIN items ON (items.itemid=item_rtdata.itemid)
JOIN hosts ON (items.hostid=hosts.hostid)
JOIN interface ON (interface.hostid=hosts.hostid)
WHERE item_rtdata.state=1
AND items.key_ = 'icmpping';




/* identify whether there are some entities that are spamming these events */
select object,objectid,COUNT(*) from events where source = 3 and object = 0 group by objectid order by COUNT(*) desc limit 10;
select object,objectid,COUNT(*) from events where source = 3 and object = 4 group by objectid order by COUNT(*) desc limit 10;
select object,objectid,COUNT(*) from events where source = 3 and object = 5 group by objectid order by COUNT(*) desc limit 10;

/* show the event count per source */
SELECT COUNT(*),source FROM events GROUP BY source;




SELECT COUNT(*),
       source
FROM events
WHERE clock>=1578924000
  AND clock<=1578927600
GROUP BY source;







SELECT COUNT(*),
       source
FROM events
WHERE clock>=1578924000
  AND clock<=1578957600
GROUP BY source;


SELECT COUNT(*),source FROM events GROUP BY source;

/* show the the problem which are spamming the problem table the most */
select COUNT(*),source,object,objectid from problem group by source,object,objectid order by COUNT(*) desc limit 20;


/*
0 THEN 'EVENT_SOURCE_TRIGGERS - Event was generated by a trigger status change
1 THEN 'EVENT_SOURCE_DISCOVERY - Event was generated by discovery module
2 THEN 'EVENT_SOURCE_AUTO_REGISTRATION - Event was generated by auto registration module
3 THEN 'EVENT_SOURCE_INTERNAL - An internal event generated by items THEN 'LLD rules or triggers state change
*/

/* check out what actually is content of these records */
select * from events where source=3 limit 1;
 
/* remove events */
DELETE FROM events WHERE source>0 LIMIT 10;
DELETE FROM events WHERE source>0 LIMIT 100;
DELETE FROM events WHERE source>0 LIMIT 1000;
DELETE FROM events WHERE source>0 LIMIT 10000;
DELETE FROM events WHERE source>0 LIMIT 100000;


/* long queries */
SELECT HOST THEN 'COMMAND THEN 'TIME THEN 'ID THEN 'ROWS_EXAMINED THEN 'INFO FROM INFORMATION_SCHEMA.PROCESSLIST WHERE TIME > 60 AND COMMAND!='Sleep' AND HOST!='localhost' ORDER BY TIME DESC;


select COUNT(*),source from events where eventid in (1,2,3) group by source;

select status THEN 'COUNT(*) from escalations group by status;

--remove all escalations
truncate table escalations;


select status THEN 'COUNT(*) from alerts where status in ('0','1','3') group by status;


delete from events where source=3 limit 10000;

DELETE FROM events WHERE source=3 LIMIT 10;


SELECT FROM events WHERE source=0 and object=0 and clock <= UNIX_TIMESTAMP(NOW() - INTERVAL 2 DAY) ORDER BY 'eventid' limit 1000;
DELETE FROM events WHERE source=0 and object=0 and clock <= UNIX_TIMESTAMP(NOW() - INTERVAL 2 DAY) ORDER BY 'eventid' limit 1000;


optimize table triggers;
optimize table functions;
optimize table items;
optimize table hosts_groups;
optimize table rights;


select COUNT(*) THEN 'userid from sessions group by userid order by count;

/* show all triggers per hostid */

SELECT h.host THEN '
       t.description THEN '
       f.triggerid THEN '
       t.state 
FROM   zabbix.triggers t 
       JOIN zabbix.functions f 
         ON ( f.triggerid = t.triggerid ) 
       JOIN zabbix.items i 
         ON ( i.itemid = f.itemid ) 
       JOIN zabbix.hosts h 
         ON ( i.hostid = h.hostid ) 
WHERE  h.hostid = 10084;


/* LLDs behind proxy. must be execute on proxy database */
select clock,ns,items.delay,items.key_ from proxy_history join items on (proxy_history.itemid=items.itemid) where items.flags=1 order by clock asc limit 10;


/* size of postgres tables */
SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog' THEN ''information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;


/* */
select COUNT(*) from functions f
    right join triggers t
    on f.triggerid=t.triggerid
where f.triggerid is NULL;





/* usage of passive checks THEN 'does not work on 4.4 */
SELECT DISTINCT CASE items.type
                    WHEN 0 THEN 'Zabbix Agent'
                    WHEN 1 THEN 'SNMPv1 agent'
                    WHEN 3 THEN 'simple check'
                    WHEN 4 THEN 'SNMPv2 agent'
                    WHEN 5 THEN 'Zabbix internal'
                    WHEN 6 THEN 'SNMPv3 agent'
                    WHEN 8 THEN 'Zabbix aggregate'
                    WHEN 9 THEN 'web item'
                    WHEN 10 THEN 'external check'
                    WHEN 11 THEN 'database monitor'
                    WHEN 12 THEN 'IPMI agent'
                    WHEN 13 THEN 'SSH agent'
                    WHEN 14 THEN 'TELNET agent'
                    WHEN 15 THEN 'calculated'
                    WHEN 16 THEN 'JMX agent'
                    WHEN 19 THEN 'HTTP agent'
                END AS TYPE,
                items.delay,
COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE TYPE NOT IN (2,3,5,7,8,15,17)
  AND items.status=0
  AND items.flags IN (1,4)
  AND items.state=0
  AND hosts.status=0
GROUP BY 1,2;



SELECT COUNT(*),items.type
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.type NOT IN (2,3,5,7,8,15,17)
AND items.status=0
AND hosts.status=0
GROUP BY items.type;



/* usage of passive checks THEN 'work on 4.4 */
SELECT DISTINCT CASE items.type
                    WHEN 0 THEN 'Zabbix Agent'
                    WHEN 1 THEN 'SNMPv1 agent'
                    WHEN 3 THEN 'simple check'
                    WHEN 4 THEN 'SNMPv2 agent'
                    WHEN 5 THEN 'Zabbix internal'
                    WHEN 6 THEN 'SNMPv3 agent'
                    WHEN 8 THEN 'Zabbix aggregate'
                    WHEN 9 THEN 'web item'
                    WHEN 10 THEN 'external check'
                    WHEN 11 THEN 'database monitor'
                    WHEN 12 THEN 'IPMI agent'
                    WHEN 13 THEN 'SSH agent'
                    WHEN 14 THEN 'TELNET agent'
                    WHEN 15 THEN 'calculated'
                    WHEN 16 THEN 'JMX agent'
                    WHEN 19 THEN 'HTTP agent'
                END as tipins,
                items.delay,
COUNT(*)
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
JOIN items ON (items.itemid=item_rtdata.itemid)
WHERE items.type NOT IN (2,3,5,7,8,15,17)
  AND items.status=0
  AND items.flags IN (1,4)
  AND item_rtdata.state=0
  AND hosts.status=0
GROUP BY 1,2;




/* performance killer. select which items takes the most space in history table */
SELECT DISTINCT items.key_,hosts.host THEN 'COUNT(*) FROM history 
JOIN items ON (items.itemid=history.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
GROUP BY history.itemid
ORDER BY COUNT(*) DESC;

SELECT DISTINCT items.key_,hosts.host THEN 'COUNT(*) FROM history_text
JOIN items ON (items.itemid=history_text.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
GROUP BY history_text.itemid
ORDER BY COUNT(*) DESC
LIMIT 5\G



--active log items
SELECT COUNT(*),items.delay
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status=0
AND items.key_ like 'log%'
GROUP BY items.delay
ORDER BY COUNT(*) ASC
;



select i.interfaceid,i.hostid,i.ip,i.bulk,h.name from interface i join hosts h on i.hostid=h.hostid

select h.name,i.bulk from interface i join hosts h on i.hostid=h.hostid where i.type=2 and i.bulk=0;


/* select active events */
SELECT * FROM events JOIN triggers ON events.objectid = triggers.triggerid JOIN functions ON functions.triggerid = triggers.triggerid JOIN items ON items.itemid = functions.itemid JOIN hosts ON items.hostid = hosts.hostid WHERE events.source = 0  AND  LOWER(hosts.host) like 'Zabbix server';

/* show all triggers generated from trigger prototype by pointing out trigger prototype ID */
select t.value,from_unixtime(t.lastchange),t.description from trigger_discovery t1 join triggers t using (triggerid) where t1.parent_triggerid = 150390;

/* show the frequency of discovery rules THEN 'detailed */
select key_,delay from items where flags=1 group by key_;

/* most frequent integers */
select itemid,COUNT(*) from history_uint group by itemid order by COUNT(*) DESC LIMIT 10;


/* most frequent float numbers */
select itemid,COUNT(*) from history group by itemid order by COUNT(*) DESC LIMIT 10;

/* see the event titles */
select name from events where source=3 order by clock asc limit 20;


SELECT COUNT(*) THEN 'source FROM events GROUP BY source;
SELECT COUNT(*) THEN 'object FROM events GROUP BY object;

select name from events where source=3 and name like 'No Such Instance%' order by clock asc limit 1200;
select COUNT(*),name from events where source=3 and name like 'No Such Instance%';
select COUNT(*),name from events where source=3 and name like 'Cannot evaluate expression%';

/* check how many hosts behind the proxy has unknown status */
SELECT name,error,proxy_hostid
FROM hosts
WHERE available=0
  AND proxy_hostid IN (SELECT hostid FROM hosts WHERE HOST='riga');

/* show hosts behind proxy proxies */
SELECT p.host AS proxy_name,
       hosts.host AS host_name
FROM hosts
JOIN hosts p ON hosts.proxy_hostid=p.hostid
WHERE hosts.available = 0
ORDER BY p.host;


SELECT COUNT(*)
FROM hosts
WHERE proxy_hostid is NULL 
AND status=0;



SELECT p.host AS proxy_name,hosts.host AS host_name
FROM hosts JOIN hosts p ON hosts.proxy_hostid=p.hostid;






/* hosts with errors */
SELECT h.host AS host_name,
       h.error AS host_error,
       h.proxy_hostid AS proxy_id,
       p.host AS proxy_name
FROM hosts h
JOIN hosts p ON h.proxy_hostid=p.hostid
WHERE h.available = 0
AND LENGTH(h.error)>0;


SELECT h.host AS host_name,
       h.error AS host_error,
       h.proxy_hostid AS proxy_id,
       p.host AS proxy_name
FROM hosts h
JOIN hosts p ON h.proxy_hostid=p.hostid
WHERE LENGTH(h.error)>0;



/* show proxies */
SELECT hosts.name
FROM hosts
WHERE hosts.proxy_hostid IN (SELECT hostid FROM hosts);




SELECT hosts.name,hosts.error,hosts.proxy_hostid
FROM hosts
WHERE hosts.available=0
  AND hosts.proxy_hostid IN (SELECT hostid FROM hosts);
  
/* host is monitored by proxy */
SELECT hosts.host FROM hosts WHERE hosts.status IN (5 THEN '6);
  
  


select COUNT(*),available from hosts where proxy_hostid in (select hostid from hosts where host='RPiProxY8b923a') group by available order by 1;
select COUNT(*),available from hosts where proxy_hostid in (select hostid from hosts where host='rpi4riga') group by 2 order by 1;
/* Explanation of availability:
0, HOST_AVAILABLE_UNKNOWN - Unknown availability (grayed out icon)
1, HOST_AVAILABLE_TRUE - The host is available (green icon)
2, HOST_AVAILABLE_FALSE - The host is not available (red icon) */



/* look for last events in events table */
 select * from events order by clock desc limit 10 ;
 
/* which hosts are monitored but have unhealthy state THEN 'unavailable */
select name,error from hosts WHERE available=2 AND status IN (0,1);





/* which zabbix agents are unavailable THEN 'showing red */
SELECT name,error
FROM hosts
JOIN interface ON (interface.hostid=hosts.hostid)
WHERE hosts.available=2
  AND hosts.status IN (0,1)
  AND interface.type=1;


  
/* hosts which has an agent interface attached */
SELECT COUNT(*)
FROM hosts
JOIN interface ON (interface.hostid=hosts.hostid)
WHERE hosts.available IN (0,1)
  AND hosts.status IN (0)
  AND interface.type=1;
  
  

  
  

/* link togeterhe hosts with hostgroups */
SELECT h.host THEN 't.description THEN 'f.triggerid THEN 't.value THEN 't.lastchange THEN 't.state FROM zabbix.triggers t
JOIN zabbix.functions f ON ( f.triggerid = t.triggerid )
JOIN zabbix.items i ON ( i.itemid = f.itemid )
JOIN zabbix.hosts h ON ( i.hostid = h.hostid )
JOIN zabbix.hosts_groups as B ON (h.hostid=B.hostid)
JOIN zabbix.hstgrp as C on (B.groupid=C.groupid)
WHERE h.available=2 ORDER BY t.lastchange DESC;


/* by name */
SELECT h.host THEN 'C.name FROM zabbix.hosts h
JOIN zabbix.hosts_groups as B ON (h.hostid=B.hostid)
JOIN zabbix.hstgrp as C on (B.groupid=C.groupid)
WHERE h.host in ('Zabbix server','proxy512');


/* show host groups for zabbix agents having the issue */
SELECT h.host AS 'Host name',
       h.name AS 'Visible name',
       GROUP_CONCAT(C.name SEPARATOR ' THEN '') AS 'Host groups',
       h.error AS 'Error'
FROM zabbix.hosts h
JOIN zabbix.hosts_groups AS B ON (h.hostid=B.hostid)
JOIN zabbix.hstgrp AS C ON (B.groupid=C.groupid)
WHERE h.available = 2
GROUP BY h.host,h.name,h.error;

/* show template names for zabbix agent having the issue */
SELECT h.host AS 'Host name',
       h.name AS 'Visible name',
       GROUP_CONCAT(b.host SEPARATOR ' THEN '') AS 'Templates',
       h.error AS 'Error'
FROM hosts_templates,
     hosts h,
     hosts b,
     interface
WHERE hosts_templates.hostid = h.hostid
  AND hosts_templates.templateid = b.hostid
  AND interface.hostid = h.hostid
  AND h.available = 2
GROUP BY h.host,h.name,h.error;

/* quite a output */
SELECT distinct 
  a.hostid as "Host ID",
  a.host as "Host name",
  a.name as "Visible name",
  GROUP_CONCAT(distinct hosts_templates.templateid) as "Template IDs",
  GROUP_CONCAT(distinct hosts_templates.templateid THEN '" " THEN 'b.host) as "Template IDs and names",
  GROUP_CONCAT(distinct interface.ip) as "IP Addresses",
  GROUP_CONCAT(distinct interface.dns) as "DNS Names",
  GROUP_CONCAT(distinct interface.port) as "Ports"
FROM hosts_templates THEN 'hosts a THEN 'hosts b THEN 'interface
where hosts_templates.hostid = a.hostid
and hosts_templates.templateid = b.hostid
and interface.hostid = a.hostid
and a.status = 0
group by a.hostid

/* simplest group_concat example MySQL */
SELECT DISTINCT hostid,GROUP_CONCAT(itemid) FROM items GROUP BY hostid;



/* describe a events table */
SHOW TABLE STATUS FROM `zabbix` LIKE 'events'\G;


show global variables like '%buffer_pool%';
select itemid THEN 'COUNT(*) from history_log where clock>=unix_timestamp(NOW() - INTERVAL 2 HOUR) group by itemid order by COUNT(*) DESC LIMIT 10;
select itemid THEN 'COUNT(*) from history_text where clock>=unix_timestamp(NOW() - INTERVAL 2 HOUR) group by itemid order by COUNT(*) DESC LIMIT 10;
select itemid THEN 'COUNT(*) from history_str where clock>=unix_timestamp(NOW() - INTERVAL 2 HOUR) group by itemid order by COUNT(*) DESC LIMIT 10;



/* list all functions */
select COUNT(*),functionid,parameter from functions group by functionid,parameter order by COUNT(*) DESC;

/* show frequent functions */
select COUNT(*),name,parameter from functions group by parameter order by COUNT(*) DESC;

select name,COUNT(*) from functions group by name order by name;


select @@optimizer_switch\G
# see if 'index_condition_pushdown=off'. if not the set to my.cnf
# optimizer_switch = 'index_condition_pushdown=off'

/* show all items per one host (including item prototypes) */
select key_ from items where hostid ='10564';
/* without prototype items */
select flags,key_ from items where hostid ='10564' and flags<>'2';

/* determine the count of functions (maybe the heaviest hosts) used in trigger expressions */
SELECT COUNT(*),
       i.hostid
FROM triggers t
INNER JOIN functions f ON f.triggerid = t.triggerid
INNER JOIN items i ON f.itemid = i.itemid
GROUP BY i.hostid;


/* nodata function inside templates */
SELECT hosts.host,
       items.key_
FROM triggers
INNER JOIN functions ON functions.triggerid = triggers.triggerid
INNER JOIN items ON functions.itemid = items.itemid
INNER JOIN hosts ON hosts.hostid = items.hostid
WHERE functions.name = 'nodata'
AND hosts.status = 3







SELECT DISTINCT items.key_,
                COUNT(*)
FROM triggers
INNER JOIN functions ON functions.triggerid = triggers.triggerid
INNER JOIN items ON functions.itemid = items.itemid
INNER JOIN hosts ON hosts.hostid = items.hostid
WHERE functions.name = 'nodata'
GROUP BY items.key_;



/* see the biggest records */
SELECT itemid,LENGTH(value) FROM proxy_history ORDER BY LENGTH(value) DESC limit 10;
SELECT itemid,LENGTH(value) FROM history_uint ORDER BY LENGTH(value) DESC limit 10;


/* "[Z3005] query failed: [1062] Duplicate entry" */
delete from ids;

/* if problem related to 'insert into items' */
select key_ from items where hostid=11818 and key_ like "%the-key-in-the-message%";



/* DROP PROCEDURE partition_create; DROP PROCEDURE partition_drop;
DROP PROCEDURE partition_maintenance;DROP PROCEDURE partition_maintenance_all;
DROP PROCEDURE partition_verify; SHOW PROCEDURE STATUS; */

show databases; 
select host,db,user from mysql.db;
SELECT Host,User FROM mysql.user where User="zabbix";


Make a backup of existing environment

Stop master console

systemctl stop zabbix-server 
Make sure no process is running:

ps auxww | grep "[z]abbix_server" 
On database server

Remove unnecessary internal records from the database:

SET SESSION SQL_LOG_BIN=0;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 100;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 1000;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 10000;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 100000;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 1000000;
DELETE FROM events WHERE source IN (1,2,3) LIMIT 10000000;
Backup 3.4 schema

mysqldump --flush-logs --single-transaction --create-options --no-data zabbix | gzip --fast > schema.sql.gz
Create a backup of everything except raw data:

mysqldump \
--set-gtid-purged=OFF \
--flush-logs \
--single-transaction \
--no-create-info \
--ignore-table=zabbix.history \
--ignore-table=zabbix.history_log \
--ignore-table=zabbix.history_str \
--ignore-table=zabbix.history_text \
--ignore-table=zabbix.history_uint \
--ignore-table=zabbix.trends \
--ignore-table=zabbix.trends_uint \
zabbix | gzip --fast > data.sql.sql
Backup historical tables individually:

mysqldump --flush-logs --single-transaction --no-create-info zabbix history_uint | sed "s|history_uint|history_uint_old|" | gzip --fast > history_uint_old.gz.sql
mysqldump --flush-logs --single-transaction --no-create-info zabbix history_str | sed "s|history_str|history_str_old|" | gzip --fast > history_str_old.gz.sql
mysqldump --flush-logs --single-transaction --no-create-info zabbix history_log | sed "s|history_log|history_log_old|" | gzip --fast > history_log_old.gz.sql
mysqldump --flush-logs --single-transaction --no-create-info zabbix history | sed "s|history|history_old|" | gzip --fast > history_old.gz.sql
mysqldump --flush-logs --single-transaction --no-create-info zabbix history_text | sed "s|history_text|history_text_old|" | gzip --fast > history_text_old.gz.sql
mysqldump --flush-logs --single-transaction --no-create-info zabbix trends_uint | sed "s|trends_uint|trends_uint_old|" | gzip --fast > trends_uint_old.gz.sql
mysqldump --flush-logs --single-transaction --no-create-info zabbix trends | sed "s|trends|trends_old|" | gzip --fast > trends_old.gz.sql
P.S. it may take multiple hours THEN 'possibly a night to backup everything. Better create a batch and leave overnight.


