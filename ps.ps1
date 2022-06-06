# list all installed services and its arguments
Get-WmiObject win32_service | ?{$_.Name -like 'Zabbix*'} | select Name, DisplayName, State, PathName



