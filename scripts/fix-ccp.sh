cd /usr/share/cloud/management/webapps/client
test -f eula.ja.html || ln -s eula.en.html eula.ja.html
chkconfig atd off
chkconfig cups off
chkconfig iscsi off
chkconfig lldpad off
chkconfig messagebus off
