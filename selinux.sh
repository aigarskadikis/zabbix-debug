yum makecache fast
 
yum provides semanage
yum -y install policycoreutils-python
 
yum provides seinfo
yum -y install setools-console
 
# list zabbix related selinux objects
seinfo -rsystem_r -x | grep zabbix
 
# add zabbix_agent_t to permissive object type
semanage permissive -a zabbix_agent_t
ausearch --raw | grep zabbix_agent_t | audit2allow -M zabbix-agent-policy
semodule -i zabbix-agent-policy.pp
 
# add zabbix_t to permissive object type
semanage permissive -a zabbix_t
ausearch --raw | grep zabbix_t | audit2allow -M zabbix-policy
semodule -i zabbix-policy.pp
 
# add zabbix_script_t to permissive object type
semanage permissive -a zabbix_script_t
ausearch --raw | grep zabbix_script_t | audit2allow -M zabbix-script-policy
semodule -i zabbix-script-policy.pp

# add snmpd_t to permissive object type
semanage permissive -a snmpd_t
ausearch --raw | grep snmpd_t | audit2allow -M snmpd-policy
semodule -i snmpd-policy.pp


seinfo -rsystem_r -x


systemctl restart zabbix-agent

ausearch --raw | grep -E -o ":zabbix.*:"|sort|uniq

:zabbix_t:
:zabbix_t:s0 tcontext=system_u:object_r:zabbix_var_run_t:
:zabbix_t:s0 tcontext=system_u:system_r:zabbix_script_t:
:zabbix_t:s0 tcontext=system_u:system_r:zabbix_t:


:zabbix_agent_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:admin_home_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:auditd_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:cgroup_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:chronyd_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:cloud_init_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:crond_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:dbusd_etc_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:getty_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:gssproxy_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:httpd_config_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:httpd_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:kdump_etc_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:modules_conf_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:mysqld_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:nfsd_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:ntpd_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:postfix_etc_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:power_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:rdisc_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:rpcd_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:rsync_etc_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:shadow_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:sshd_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:svnserve_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:syslog_conf_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:syslogd_var_run_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:system_cron_spool_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:systemd_bootchart_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:systemd_systemctl_exec_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:systemd_unit_file_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:tuned_etc_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:user_home_t:
:zabbix_agent_t:s0 tcontext=system_u:object_r:xserver_etc_t:
:zabbix_agent_t:s0 tcontext=system_u:system_r:init_t:
:zabbix_agent_t:s0 tcontext=system_u:system_r:sshd_t:s0-s0:
:zabbix_agent_t:s0 tcontext=system_u:system_r:zabbix_agent_t:
:zabbix_agent_t:s0 tcontext=unconfined_u:object_r:admin_home_t:
:zabbix_agent_t:s0 tcontext=unconfined_u:object_r:httpd_config_t:
:zabbix_agent_t:s0 tcontext=unconfined_u:object_r:mysqld_unit_file_t:
:zabbix_agent_t:s0 tcontext=unconfined_u:object_r:user_home_t:
:zabbix_agent_t:s0 tcontext=unconfined_u:object_r:zabbix_var_lib_t:
:zabbix_t:
:zabbix_t:s0 tcontext=system_u:object_r:ldconfig_exec_t:
:zabbix_t:s0 tcontext=unconfined_u:object_r:admin_home_t:
