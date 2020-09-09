/* How many values is in the backlog. does not work on oracle proxy becuase of LIMIT */
select max(id)-(select nextid from ids where table_name = "proxy_history" limit 1) from proxy_history;

select DISTINCT items.key_,hosts.host
FROM items 
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.flags=1 
AND items.delay='1h';



-- This will show which hosts and items which are receiving big metrics:
SELECT clock,
hosts.host,
items.key_,
LENGTH(value)
FROM proxy_history
JOIN items ON (items.itemid = proxy_history.itemid)
JOIN hosts ON (hosts.hostid = items.hostid)
WHERE LENGTH(value)>60000;



SELECT hosts.host,items.key_
FROM proxy_history 
JOIN items ON (items.itemid = proxy_history.itemid)
JOIN hosts ON (hosts.hostid = items.hostid)
WHERE items.itemid in (select itemid from items where flags=1);





SELECT COUNT(*),CASE
WHEN items.type=0 THEN 'ZABBIX'
WHEN items.type=2 THEN 'TRAPPER'
WHEN items.type=3 THEN 'SIMPLE'
WHEN items.type=5 THEN 'INTERNAL'
WHEN items.type=7 THEN 'ZABBIX_ACTIVE'
WHEN items.type=8 THEN 'AGGREGATE'
WHEN items.type=9 THEN 'HTTPTEST'
WHEN items.type=10 THEN 'EXTERNAL'
WHEN items.type=11 THEN 'DB_MONITOR'
WHEN items.type=12 THEN 'IPMI'
WHEN items.type=13 THEN 'SSH'
WHEN items.type=14 THEN 'TELNET'
WHEN items.type=15 THEN 'CALCULATED'
WHEN items.type=16 THEN 'JMX'
WHEN items.type=17 THEN 'SNMPTRAP'
WHEN items.type=18 THEN 'DEPENDENT'
WHEN items.type=19 THEN 'HTTPAGENT'
WHEN items.type=20 THEN 'SNMP'
END AS type
FROM items
GROUP BY 2;


select distinct items.key_
FROM items 
WHERE items.flags=1 
AND items.delay='1h';



select count(items.key_),items.key_,hosts.host from proxy_history
JOIN items ON (items.itemid = proxy_history.itemid)
JOIN hosts ON (hosts.hostid = items.hostid)
where items.itemid in (select itemid from items where flags=1)
group by items.key_,hosts.host
order by count(items.key_) ASC,2,3
LIMIT 10;



SELECT hosts.host,items.key_,items.lastlogsize from items 
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE items.type=7
AND items.value_type=2









/* show the number of unsent values */
select count(*) from proxy_history where id > (select nextid from ids where table_name = 'proxy_history');
SELECT ((SELECT MAX(proxy_history.id) FROM proxy_history)-nextid) FROM ids WHERE field_name='history_lastid';

/* list unsent values, grouped by itemid and sorted by amount of unsent data */
select itemid,count(*) from proxy_history where id > (select nextid from ids where table_name = 'proxy_history') group by itemid order by count(*);

/* frequent LLD behind proxy */
select count(*),delay from items where flags = 1 group by delay order by count(*) desc LIMIT 20;
select count(*),delay from items where flags = 1 group by 2 order by 1 desc;
/* with key */
select count(*),delay,key_ from items where flags = 1 group by 2 order by 1 desc;

/* On 3.0 only! to eliminate the possibility that low level discovery are causing the problem we can remove all the LLD which has been scheduled (in past). New LLD checks will be scheduled starting from no. */
delete from proxy_history where itemid in (select itemid from items where flags=1);


delete from proxy_history where itemid in (select itemid from items where flags=1);


select hosts.host,items.key_ from proxy_history 
JOIN items ON (items.itemid = proxy_history.itemid)
JOIN hosts ON (hosts.hostid = items.hostid)
where items.itemid in (select itemid from items where flags=1);


/* frequency of LLDs */
select count(items.key_),items.key_,hosts.host from proxy_history 
JOIN items ON (items.itemid = proxy_history.itemid)
JOIN hosts ON (hosts.hostid = items.hostid)
where items.itemid in (select itemid from items where flags=1)
group by items.key_,hosts.host
order by 1,2,3;

SELECT table_name, table_rows, data_length, index_length, round(((data_length + index_length) / 1024 / 1024 / 1024),2) "Size in GB" FROM information_schema.tables WHERE table_schema = "zabbix" order by round(((data_length + index_length) / 1024 / 1024 / 1024),2) DESC LIMIT 20;

select @@datadir;




select proxy_history.clock,items.key_,items.delay from proxy_history 
JOIN items ON (items.itemid = proxy_history.itemid)
where proxy_history.itemid in (select itemid from items where flags=1) order by proxy_history.clock desc;


show create table history_uint;

truncate table proxy_history; truncate table ids;


select items.key_ from proxy_history 
JOIN items ON (items.itemid = proxy_history.itemid)
where items.itemid in (select itemid from items where flags=1);



select clock,ns from proxy_history where itemid in (select itemid from items where flags=1);

/* show the exteral sripts used. Usefull to know befere migrating the server or proxy to different kind of OS */
select itemid,name,key_ from items where type=10 and status=0;

/* check current queue to send from Proxy to Server, execute from the database CLI, twice within 1-2 minutes interval: */
SELECT ((SELECT MAX(proxy_history.id) FROM proxy_history)-nextid) FROM ids WHERE field_name='history_lastid';
