
# go to frontend server. download 'jq' utility. place it at the home directory
curl -sL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o ~/jq

# set 'jq' utility executable
chmod +x ~/jq

# obtain an authorization key. replace user 'Admin' and password 'zabbix'
curl -sk -X POST -H "Content-Type: application/json" -d "{\"jsonrpc\":\"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\"Admin\",\"password\":\"zabbix\"},\"id\":1,\"auth\":null}" https://127.0.0.1/api_jsonrpc.php | grep -E -o "([0-9a-f]{32,32})"

# 'zabbix_get' utility must exists on the frontend server
yum install zabbix-get

# run the query. replace only authorisation key '6f283c8e02e2e0b6599e0b89afa90d26' with the key from previous step
zabbix_get -s 127.0.0.1 -p 10051 -k '{"request": "queue.get","sid": "6f283c8e02e2e0b6599e0b89afa90d26","type": "details","limit":"500"}' 

# try to format the output more beautiful
zabbix_get -s 127.0.0.1 -p 10051 -k '{"request": "queue.get","sid": "6f283c8e02e2e0b6599e0b89afa90d26","type": "details","limit":"500"}' | ~/jq .

# filter out itemid's involved in queue
zabbix_get -s 127.0.0.1 -p 10051 -k '{"request": "queue.get","sid": "6f283c8e02e2e0b6599e0b89afa90d26","type": "details","limit":"500"}' | ~/jq ."data"[]."itemid" 

# find out which hosts are involved. you may tune the database username 'zabbix', password 'zabbix' and the DB host '127.0.0.1' at the end of this command.
zabbix_get -s 127.0.0.1 -p 10051 -k '{"request": "queue.get","sid": "6f283c8e02e2e0b6599e0b89afa90d26","type": "details","limit":"500"}' | ~/jq ."data"[]."itemid" | xargs -i echo "SELECT h.host,i.name FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.itemid='{}';" | mysql -sN -h'127.0.0.1' -u'zabbix' -p'zabbix' zabbix

# find out only unique host titles
zabbix_get -s 127.0.0.1 -p 10051 -k '{"request": "queue.get","sid": "6f283c8e02e2e0b6599e0b89afa90d26","type": "details","limit":"500"}' | ~/jq ."data"[]."itemid" | xargs -i echo "SELECT h.host FROM hosts h INNER JOIN items i ON h.hostid = i.hostid WHERE i.itemid='{}';" | mysql -sN -h'127.0.0.1' -u'zabbix' -p'zabbix' zabbix | sort | uniq
