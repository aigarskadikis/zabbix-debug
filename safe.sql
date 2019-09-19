


# check rows to work with
SELECT h.host,h.name,ii.type,ii.useip,ii.ip,ii.dns from hosts h join interface ii on h.hostid=ii.hostid WHERE LENGTH(ii.dns)=0; #should be the old value

# start safe transsaction
START TRANSACTION;

# test update procedure
UPDATE interface ii,hosts h SET ii.dns=h.name WHERE h.hostid=ii.hostid AND ii.useip=1 AND LENGTH(ii.dns)=0;

# check if there is no records any more
SELECT h.host,h.name,ii.type,ii.useip,ii.ip,ii.dns from hosts h join interface ii on h.hostid=ii.hostid WHERE LENGTH(ii.dns)=0; 

# list full list
SELECT h.host,h.name,ii.type,ii.useip,ii.ip,ii.dns from hosts h join interface ii on h.hostid=ii.hostid WHERE LENGTH(ii.dns)>0; #should be the old value

# apply changes
COMMIT;

# or if you want to reset changes 
ROLLBACK;

