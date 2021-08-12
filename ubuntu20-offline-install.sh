

# install prerequsites to create an offline repository
apt-get update && apt-get install -y apt-rdepends dpkg-dev gzip

# create working direcotry '/repo' will fold the scripts which will do the task. 
# '/repo/offline' will contain all packages together will dependencies
mkdir -p /repo/offline

# because 'apt' utility runs behind a dedicated service user. It's better to set the wokring directory be owned by user '_apt'
chown _apt -R /repo

# navigate to user '_apt'
su - _apt -s /bin/bash

# enter directory where scripts will be located
cd /repo

echo "IyEvdXNyL2Jpbi9lbnYgYmFzaAoKZnVuY3Rpb24gZXJyb3JfZXhpdAp7CiAgZWNobyAiJDEiIDE+JjIKICBlY2hvICJVc2FnZTogLi9nZXRwa2cuc2ggPHBhY2thZ2UtbmFtZT4gPHBhY2thZ2VzLWRpcmVjdG9yeT4iIDE+JjIKICBleGl0IDEKfQoKUEtHPSIkMSIKUEtHRElSPSIkMiIKCmlmIFsgLXogIiRQS0ciIF07IHRoZW4KICBlcnJvcl9leGl0ICJObyBwYWNrYWdlIG5hbWUgc2V0ISIKZmkKCmlmIFsgLXogIiRQS0dESVIiIF07IHRoZW4KICBlcnJvcl9leGl0ICJObyBwYWNrYWdlcyBkaXJlY3RvcnkgcGF0aCBzZXQhIgpmaQoKY2QgJFBLR0RJUgoKZm9yIGkgaW4gJChhcHQtcmRlcGVuZHMgJFBLR3xncmVwIC12ICJeICIpCiAgZG8gISBhcHQtZ2V0IGRvd25sb2FkICRpCmRvbmUK" | base64 --decode > getpkg.sh
chmod +x getpkg.sh


# request to download a base package. this will download all dependencies too.
./getpkg.sh mysql-server offline ; ./getpkg.sh zabbix-server-mysql offline ; ./getpkg.sh zabbix-frontend-php offline ; ./getpkg.sh zabbix-nginx-conf offline ; ./getpkg.sh zabbix-agent offline ; ./getpkg.sh zabbix-agent2 offline ; ./getpkg.sh mysql-server offline

# create a base file which has the linkage to all packages
echo "IyEvdXNyL2Jpbi9lbnYgYmFzaAoKZnVuY3Rpb24gZXJyb3JfZXhpdAp7CiAgZWNobyAiJDEiIDE+JjIKICBlY2hvICJVc2FnZTogLi9ta3JlcG8uc2ggPHBhY2thZ2VzLWRpcmVjdG9yeT4iIDE+JjIKICBleGl0IDEKfQoKUEtHRElSPSIkMSIKCmlmIFsgLXogIiRQS0dESVIiIF07IHRoZW4KICBlcnJvcl9leGl0ICJObyBwYWNrYWdlcyBkaXJlY3RvcnkgcGF0aCBzZXQhIgpmaQoKY2QgJFBLR0RJUgoKZHBrZy1zY2FucGFja2FnZXMgLi8gL2Rldi9udWxsIHwgZ3ppcCAtOWMgPiAuL1BhY2thZ2VzLmd6Cg==" | base64 --decode > mkrepo.sh
chmod +x mkrepo.sh


apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-agent
