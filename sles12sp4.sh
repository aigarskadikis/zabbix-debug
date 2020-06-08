



[01000][unixODBC][Driver Manager]Can't open lib '/opt/oracle/instantclient_11_2/libsqora.so.11.1


Cant open lib libsqora.so

zypper install libxml2-devel unixODBC-devel net-snmp-devel OpenIPMI-devel libevent-devel openldap2-devel libcurl-devel pcre-devel libssh2-devel mysql-devel -y


# Recommended unixODBC Driver Manager versions for Linux/UNIX For Instant Client 11g: Linux 32bit, 64bit	
zypper remove unixODBC-devel
zypper install unixODBC-devel-2.2.11
zypper install unixODBC-devel-2.2.14


# list odbc versions and paths
odbcinst -j

zypper search -s unixODBC-devel

curl -kL https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.4.15/zabbix-3.4.15.tar.gz/download > zabbix-3.4.15.tar.gz

tar xvf zabbix-3.4.15.tar.gz
cd zabbix-3.4.15

./configure --enable-proxy --enable-agent --with-mysql --with-ldap --with-libcurl --with-libxml2 --with-net-snmp --with-openipmi --with-openssl --with-ssh2 --with-unixodbc --enable-ipv6 --prefix=/usr



https://www.oracle.com/database/technologies/releasenote-odbc-ic.html


mkdir -p /opt/oracle && cd /opt/oracle
unzip instantclient-basic-linux.x64-11.2.0.4.0.zip
unzip instantclient-basiclite-linux.x64-11.2.0.4.0.zip



unzip instantclient-basic-linux.x64-18.5.0.0.0dbru.zip

cd /opt/oracle/instantclient_11_2 && ls -l
ln -s libclntsh.so.11.1 libclntsh.so
ln -s libocci.so.11.1 libocci.so
ls -l /opt/oracle/instantclient_11_2



cd /opt/oracle/instantclient_18_5 && ls -l
ln -s libclntsh.so.11.1 libclntsh.so
ln -s libocci.so.11.1 libocci.so

ls -lh /opt/oracle/instantclient_18_5/libclntsh.so /opt/oracle/instantclient_18_5/libocci.so



sudo sh -c "echo /opt/oracle/instantclient_11_2 > /etc/ld.so.conf.d/oracle-instantclient.conf"
sudo sh -c "echo /opt/oracle/instantclient_18_5 > /etc/ld.so.conf.d/oracle-instantclient.conf"
sudo ldconfig -v



export LD_LIBRARY_PATH=/opt/oracle/instantclient_11_2:/lib64:/lib

strace -fae -o isql.log isql -v dsn


LD_LIBRARY_PATH=/usr/lib:/usr/lib64
/lib64

cd /opt/oracle
unzip instantclient-odbc-linux.x64-11.2.0.4.0.zip
ls -l /opt/oracle/instantclient_11_2

DRIVER_NAME="Oracle 11g ODBC driver"
SO_NAME=libsqora.so.11.1
DRIVER_DESCRIPTION="Oracle ODBC driver for Oracle 11g"
DRIVER_LOCATION=/opt/oracle/instantclient_11_2
DSN="dsn"


cat << EOF >> /etc/unixODBC/odbcinst.ini
[$DRIVER_NAME]
Description     = $DRIVER_DESCRIPTION
Driver          = $DRIVER_LOCATION/$SO_NAME
Setup           =
FileUsage       =
CPTimeout       =
CPReuse         =
EOF


cat << EOF > /etc/unixODBC/odbc.ini
[$DSN]
Application Attributes = T
Attributes = W
BatchAutocommitMode = IfAllSuccessful
BindAsFLOAT = F
CloseCursor = F
DisableDPM = F
DisableMTS = T
Driver = $DRIVER_NAME
DSN = $DSN
EXECSchemaOpt =
EXECSyntax = T
Failover = T
FailoverDelay = 10
FailoverRetryCount = 10
FetchBufferSize = 64000
ForceWCHAR = F
Lobs = T
Longs = T
MaxLargeData = 0
MetadataIdDefault = F
QueryTimeout = T
ResultSets = T
ServerName =
SQLGetData extensions = F
Translation DLL =
Translation Option = 0
DisableRULEHint = T
UserID = zabbix
Password = zabbix
StatementCache=F
CacheBufferSize=20
UseOCIDescribeAny=F
MaxTokenSize=8192
EOF


isql dsn -v


# for 18


unzip instantclient-basic-linux.x64-18.5.0.0.0dbru.zip

mkdir -p /opt/oracle && cd /opt/oracle 
cd /opt/oracle && unzip instantclient-odbc-linux.x64-18.5.0.0.0dbru.zip


DRIVER_NAME="Oracle 18 ODBC driver"
SO_NAME=libsqora.so.18.1
DRIVER_DESCRIPTION="Oracle ODBC driver for Oracle 18"
DRIVER_LOCATION=/opt/oracle/instantclient_18_5
DSN="dsn"


cat << EOF >> /etc/unixODBC/odbcinst.ini
[$DRIVER_NAME]
Description     = $DRIVER_DESCRIPTION
Driver          = $DRIVER_LOCATION/$SO_NAME
Setup           =
FileUsage       =
CPTimeout       =
CPReuse         =
EOF


cat << EOF >> /etc/unixODBC/odbc.ini
[$DSN]
AggregateSQLType = FLOAT
Application Attributes = T
Attributes = W
BatchAutocommitMode = IfAllSuccessful
BindAsFLOAT = F
CacheBufferSize = 20
CloseCursor = F
DisableDPM = F
DisableMTS = T
DisableRULEHint = T
Driver = $DRIVER_NAME
DSN = $DSN
EXECSchemaOpt =
EXECSyntax = T
Failover = T
FailoverDelay = 10
FailoverRetryCount = 10
FetchBufferSize = 64000
ForceWCHAR = F
LobPrefetchSize = 8192
Lobs = T
Longs = T
MaxLargeData = 0
MaxTokenSize = 8192
MetadataIdDefault = F
QueryTimeout = T
ResultSets = T
ServerName = 127.0.0.1
SQLGetData extensions = F
SQLTranslateErrors = F
StatementCache = F
Translation DLL =
Translation Option = 0
UseOCIDescribeAny = F
UserID = zabbix
Password = zabbix
EOF



ldd /opt/oracle/instantclient_11_2/libsqora.so.11.1

ldd /opt/oraClient/11.2.0.4_32/lib/libsqora.so.11.1


sles12sp4:~ # ldd /opt/oracle/instantclient_11_2/libsqora.so.11.1
        linux-vdso.so.1 (0x00007ffc863bc000)
        libdl.so.2 => /lib64/libdl.so.2 (0x00007fd5f9dde000)
        libm.so.6 => /lib64/libm.so.6 (0x00007fd5f9ae1000)
        libpthread.so.0 => /lib64/libpthread.so.0 (0x00007fd5f98c4000)
        libnsl.so.1 => /lib64/libnsl.so.1 (0x00007fd5f96ab000)
        libclntsh.so.11.1 => /opt/oracle/instantclient_11_2/libclntsh.so.11.1 (0x00007fd5f6d3c000)
        libodbcinst.so.1 => not found
        libc.so.6 => /lib64/libc.so.6 (0x00007fd5f6997000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fd5f9fe2000)
        libnnz11.so => /opt/oracle/instantclient_11_2/libnnz11.so (0x00007fd5f65ca000)
        libaio.so.1 => /lib64/libaio.so.1 (0x00007fd5f63c8000)

rm -rf instantclient-basic-linux.x64-11.2.0.4.0.zip instantclient-odbc-linux.x64-11.2.0.4.0.zip

# wget https://download.oracle.com/otn/linux/instantclient/11204/instantclient-odbc-linux.x64-11.2.0.4.0.zip


cd /opt/oracle/instantclient_11_2

ln -s libsqora.so.11.1 libsqora.so


sudo sh -c "echo /opt/oracle/instantclient_11_2 > /etc/ld.so.conf.d/oracle_odbc_11_2.conf"
sudo ldconfig


./odbc_update_ini.sh



echo $LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/oracle/instantclient_11_2:$LD_LIBRARY_PATH

echo $LD_LIBRARY_PATH

LD_LIBRARY_PATH=/opt/oracle/instantclient_11_2
export $LD_LIBRARY_PATH


cd /etc/odbcins.ini
cat << 'EOF' >> 
[Oracle11g]
Description     = Oracle ODBC driver for Oracle 11g
Driver          = /opt/oracle/instantclient_11_2/libsqora.so.11.1
Setup           =
FileUsage       =
CPTimeout       =
CPReuse         =
Driver Logging  = 7


EOF


/etc/unixODBC/odbc.ini


zypper install libxml2-devel
zypper install unixODBC-devel
zypper install net-snmp-devel
zypper install OpenIPMI-devel
zypper install libevent-devel
zypper install openldap2-devel
zypper install libcurl-devel
zypper install pcre-devel


zypper install libxml2-devel unixODBC-devel net-snmp-devel OpenIPMI-devel libevent-devel openldap2-devel libcurl-devel pcre-devel


zypper install libssh2-devel

libssh-devel or libssh2-devel # depending on whether you use --with-libssh or --with-libssh2








Configuration:

  Detected OS:           linux-gnu
  Install path:          /usr/local
  Compilation arch:      linux

  Compiler:              gcc
  Compiler flags:         -g -O2

  Library-specific flags:
    database:               -I/usr/include/mysql
    libXML2:               -I/usr/include/libxml2
    unixODBC:              -I/usr/include
    Net-SNMP:               -I/usr/lib/perl5/5.18.2/x86_64-linux-thread-multi/CORE -I. -I/usr/include
    OpenIPMI:              -I/usr/include
    libssh2:               -I/usr/include
    TLS:                   -I/usr/include
    LDAP:                  -I/usr/include

  Enable server:         no

  Enable proxy:          yes
  Proxy details:
    With database:         MySQL
    WEB Monitoring:        cURL
    SNMP:                  yes
    IPMI:                  yes
    SSH:                   yes
    TLS:                   OpenSSL
    ODBC:                  yes
    Linker flags:             -L/usr/lib64     -L/lib64 -L/usr/lib64  -L/usr/lib64 -L/usr/lib -L/usr/lib  -L/usr/lib -L/usr/lib  -rdynamic
    Libraries:               -lmysqlclient  -lpthread -lz -lm -ldl -lssl -lcrypto    -lxml2  -lodbc  -lnetsnmp -lssh2 -lOpenIPMI -lOpenIPMIposix -levent -lssl -lcrypto -lldap -llber   -lcurl -lm -ldl  -lresolv -lpcre

  Enable agent:          yes
  Agent details:
    TLS:                   OpenSSL
    Linker flags:           -L/usr/lib -L/usr/lib  -rdynamic
    Libraries:              -lssl -lcrypto -lldap -llber   -lcurl -lm -ldl  -lresolv -lpcre

  Enable Java gateway:   no

  LDAP support:          yes
  IPv6 support:          yes

***********************************************************
*            Now run 'make install'                       *
*                                                         *
*            Thank you for using Zabbix!                  *
*              <http://www.zabbix.com>                    *
***********************************************************


make




# "SUSE Linux Enterprise Software Development Kit 12 SP4" must be enabled to install development packages
SUSEConnect -p sle-sdk/12.4/x86_64

# "Web and Scripting Module 12" if you want frontend
SUSEConnect -p sle-module-web-scripting/12/x86_64

# "SUSE Package Hub 12 SP4" for nginx
SUSEConnect -p PackageHub/12.4/x86_64

# De-register if needed with -d option


# Install packages with "zypper install <packages>"
libxml2-devel unixODBC-devel net-snmp-devel OpenIPMI-devel libevent-devel openldap2-devel libcurl-devel pcre-devel

libssh-devel or libssh2-devel # depending on whether you use --with-libssh or --with-libssh2

java-1_8_0-openjdk-devel

mysql-devel
postgresql10-devel

pcre-devel-static # is also available

zypper install libxml2-devel unixODBC-devel net-snmp-devel OpenIPMI-devel libevent-devel openldap2-devel libcurl-devel pcre-devel libssh2-devel mysql-devel


# Will have problems with some dependencies when installing net-snmp-devel
# Choose option 1 if it's ok for the user to downgrade openssl
    linux-qz95:~/zabbix-4.4.7 # zypper install net-snmp-devel
    Refreshing service 'SUSE_Linux_Enterprise_Server_12_SP4_x86_64'.
    Refreshing service 'SUSE_Linux_Enterprise_Software_Development_Kit_12_SP4_x86_64'.
    Loading repository data...
    Reading installed packages...
    Resolving package dependencies...

    Problem: net-snmp-devel-5.7.3-6.6.1.x86_64 requires libopenssl-devel, but this requirement cannot be provided
    uninstallable providers: libopenssl-devel-1.0.2p-1.13.noarch[SUSE_Linux_Enterprise_Server_12_SP4_x86_64:SLES12-SP4-Pool]
                    libopenssl-devel-1.0.2p-1.13.noarch[SUSE_Linux_Enterprise_Software_Development_Kit_12_SP4_x86_64:SLE-SDK12-SP4-Pool]
    Solution 1: deinstallation of libopenssl-1_1-devel-1.1.1d-2.20.1.x86_64
    Solution 2: do not install net-snmp-devel-5.7.3-6.6.1.x86_64
    Solution 3: break net-snmp-devel-5.7.3-6.6.1.x86_64 by ignoring some of its dependencies

    Choose from above solutions by number or cancel [1/2/3/c] (c):
# or don't use snmp


# Frontend dependencies
php72 php72-sockets php72-gettext php2-gd php2-bcmath php2-mbstring php2-xml php2-ldap

apache2-mod_php72 or php72-fpm + nginx





./configure --enable-proxy --with-mysql --with-ldap --with-libcurl --with-libxml2 --with-net-snmp --with-openipmi --with-openssl --with-ssh2 --with-unixodbc --enable-ipv6



