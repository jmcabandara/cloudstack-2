sed -i.orig \
    -e '/public\.network\.device/s/^# //' \
    -e '/public\.network\.device/s/br0/br1/' \
    -e '/private\.network\.device/s/^# //' \
    -e '/private\.network\.device/s/br1/br0/' \
    /etc/cloudstack/agent/agent.properties
