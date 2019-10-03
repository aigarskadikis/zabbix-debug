/* How many values is in the backlog */
select max(id)-(select nextid from ids where table_name = "proxy_history" limit 1) from proxy_history;

/* show the number of unsent values */
select count(*) from proxy_history where id > (select nextid from ids where table_name = 'proxy_history');
SELECT ((SELECT MAX(proxy_history.id) FROM proxy_history)-nextid) FROM ids WHERE field_name='history_lastid';

/* list unsent values, grouped by itemid and sorted by amount of unsent data */
select itemid,count(*) from proxy_history where id > (select nextid from ids where table_name = 'proxy_history') group by itemid order by count(*);

/* frequent LLD behind proxy */
select count(*),delay from items where flags = 1 group by delay order by count(*) desc LIMIT 20;
select count(*),delay from items where flags = 1 group by 2 order by 1 desc;

/* On 3.0 only! to eliminate the possibility that low level discovery are causing the problem we can remove all the LLD which has been scheduled (in past). New LLD checks will be scheduled starting from no. */
delete from proxy_history where itemid in (select itemid from items where flags=1);
select clock,ns from proxy_history where itemid in (select itemid from items where flags=1);

/* show the exteral sripts used. Usefull to know befere migrating the server or proxy to different kind of OS */
select itemid,name,key_ from items where type=10 and status=0;

/* check current queue to send from Proxy to Server, execute from the database CLI, twice within 1-2 minutes interval: */
SELECT ((SELECT MAX(proxy_history.id) FROM proxy_history)-nextid) FROM ids WHERE field_name='history_lastid';
