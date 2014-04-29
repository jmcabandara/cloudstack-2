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
wget -O ${TOP}/etc/rc.d/init.d/postmaster http://172.16.1.1/scripts/postmaster
chmod 755 ${TOP}/etc/rc.d/init.d/postmaster
cd ${TOP}/etc/rc.d/rc3.d; ln -s ../init.d/postmaster S99zzpostmaster
wget -O ${TOP}/root/cloud-setup-bonding.sh http://172.16.1.1/scripts/cloud-setup-bonding.sh
wget -O ${TOP}/root/.ssh/authorized_keys http://172.16.1.1/dist/id_rsa.pub
chmod 600 ${TOP}/root/.ssh/authorized_keys
#
#
exit 0
