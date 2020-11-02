
# see help
java -jar jmxterm-1.0.2-uber.jar --help

# connect to management point
java -jar jmxterm-1.0.2-uber.jar --url service:jmx:rmi:///jndi/rmi://127.0.0.1:12345/jmxrmi

# test commands
domains
domain java.lang
beans
bean java.lang:type=Memory
info
get -s -b java.lang:type=Memory HeapMemoryUsage
watch --interval 5 HeapMemoryUsage --stopafter 54
close
bye

# install profile without 'watch' command
cat << 'EOF' > /tmp/jmxcommands
domains
domain java.lang
beans
bean java.lang:type=Memory
info
get -s -b java.lang:type=Memory HeapMemoryUsage
close
bye
EOF

# make direcotry
mkdir -p /tmp/jmxterm

# test directly via command line
java -jar jmxterm-1.0.2-uber.jar \
--url service:jmx:rmi:///jndi/rmi://127.0.0.1:12345/jmxrmi \
--input /tmp/jmxcommands \
--verbose verbose \
--output /tmp/jmxterm/$(date +%Y%m%d%H%M%S).out 

# schedule cronjob
echo '* * * * * root java -jar jmxterm-1.0.2-uber.jar --url service:jmx:rmi:///jndi/rmi://127.0.0.1:12345/jmxrmi --input /tmp/jmxcommands --verbose verbose --output /tmp/jmxterm/$(date "+\%Y\%m\%d\%H\%M\%S").out' | sudo tee /etc/cron.d/jmxmonitor


