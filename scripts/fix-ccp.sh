#
if $(rpm -qi --quiet cloudstack-common); then
  cd /usr/share/cloudstack-management/webapps/client/modules/cloudPlatform
  test -f eula.ja.html || ln -s eula.en.html eula.ja.html
  #
  sed -i -e '/session-timeout/s/\(<session-timeout>\).*\(<\/session-timeout>\)/\1120\2/' /etc/cloudstack/management/web.xml
elif $(rpm -qi --quiet cloud-setup); then
  cd /usr/share/cloud/management/webapps/client
  test -f eula.ja.html || ln -s eula.en.html eula.ja.html
  #
  sed -i -e '/session-timeout/s/\(<session-timeout>\).*\(<\/session-timeout>\)/\1120\2/' /etc/cloud/management/web.xml
  #
  cd /usr/share/java
  ln -sf cloud-commons-pool-1.5.6.jar commons-pool.jar
  ln -sf cloud-commons-dbcp-1.4.jar commons-dbcp.jar
fi
#
chkconfig atd			off 2>/dev/null
chkconfig blk-availability	off 2>/dev/null
chkconfig cups			off 2>/dev/null
chkconfig iscsid		off 2>/dev/null
chkconfig lldpad		off 2>/dev/null
chkconfig messagebus		off 2>/dev/null
chkconfig sendmail		off 2>/dev/null
