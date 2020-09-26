# ubuntu 16


systemctl restart mysql

# make sure its running
systemctl status mysql

# obtain current settings
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

# gracefull stop
systemctl stop mysql

# set flush method:
innodb_flush_method=O_DIRECT

# increase connections
max_connections=2000

open_files_limit = 65535


# increase connection 
systemctl edit mysql
[Service]
LimitNOFILE=65535

systemctl daemon-reload
systemctl restart mysql


# do not allow 'zabbix-server' boot up to overload database 
optimizer_switch=index_condition_pushdown=off

# clear log
> /var/log/mysql/error.log
systemctl start mysql


innodb_buffer_pool_size = 8G
innodb_file_per_table = 8
innodb_log_file_size = 256M


# improve user expierence
query_cache_size = 0
query_cache_type = 0


# implement partitioning
