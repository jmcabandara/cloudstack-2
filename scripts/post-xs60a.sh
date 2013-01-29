#!/bin/bash
#
TOP=$1
#
# NTP
sed -i -e 's/true/false/' ${TOP}/etc/sysconfig/clock
sed -i -e '/HWCLOCK/s/no/yes/' ${TOP}/etc/sysconfig/ntpd
echo broadcastclient > ${TOP}/etc/ntp.conf
echo 172.16.1.1 >> ${TOP}/etc/ntp/step-tickers
#
# Post install script
wget -O ${TOP}/etc/rc.d/init.d/postslave http://172.16.1.1/scripts/postslave
chmod 755 ${TOP}/etc/rc.d/init.d/postslave
cd ${TOP}/etc/rc.d/rc3.d; ln -s ../init.d/postslave S99zzpostslave
#
#
exit 0
