
/* host name */
UPDATE hosts destination
JOIN hosts source ON ( source.hostid = destination.hostid )
SET destination.host = source.hostid;

/* host visiable name */
UPDATE hosts destination
JOIN hosts source ON ( source.hostid = destination.hostid )
SET destination.name = source.hostid;

/* host groups */
UPDATE hstgrp destination
JOIN hstgrp source ON ( source.groupid = destination.groupid )
SET destination.name = source.groupid;

/* user groups */
UPDATE usrgrp destination
JOIN usrgrp source ON ( source.usrgrpid = destination.usrgrpid )
SET destination.name = source.usrgrpid;

/* web scenarios */
UPDATE httptest destination
JOIN httptest source ON ( source.httptestid = destination.httptestid )
SET destination.name = source.httptestid;

/* web scenarios step */
UPDATE httpstep destination
JOIN httpstep source ON ( source.httpstepid = destination.httpstepid )
SET destination.name = source.httpstepid;

/* users */
UPDATE users destination JOIN users source ON ( source.userid = destination.userid ) SET destination.name = source.userid;
UPDATE users destination JOIN users source ON ( source.userid = destination.userid ) SET destination.surname = source.userid;
UPDATE users destination JOIN users source ON ( source.userid = destination.userid ) SET destination.alias = source.userid;

/* host DNS and IP */
UPDATE interface SET dns='localhost'; UPDATE interface SET ip='127.0.0.1';

/* replace items names in templates and hosts. this will not replace item names which come from discovery! */
UPDATE items 
JOIN items source ON ( source.itemid = items.itemid )
JOIN hosts ON ( hosts.hostid=items.hostid )
SET items.name = source.itemid
WHERE items.flags=0;

/* replace discovery names in templates and hosts */
UPDATE items 
JOIN items source ON ( source.itemid = items.itemid )
JOIN hosts ON ( hosts.hostid=items.hostid )
SET items.name = source.itemid
WHERE items.flags=1;

/* update triggers NOT trigger prototypes*/
UPDATE triggers destination JOIN triggers source ON ( source.triggerid = destination.triggerid ) SET destination.description = source.triggerid WHERE destination.flags=0;
UPDATE triggers destination JOIN triggers source ON ( source.triggerid = destination.triggerid ) SET destination.comments = source.triggerid WHERE destination.flags=0;
UPDATE triggers destination JOIN triggers source ON ( source.triggerid = destination.triggerid ) SET destination.url = '' WHERE destination.flags=0;
