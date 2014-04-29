#set -x
ts=$(date +%s)111
ssokey=$(curl -s "http://csms:8096/client/api?command=listConfigurations&name=security.singlesignon.key&response=json"|python -mjson.tool|grep value|cut -d: -f2|tr -d '",[:blank:]')
domid=$(mysql -N -B -h csms -e 'select uuid from cloud.domain where name = "ROOT";')
hs1=$(echo -n "command=login&domainid=${domid}&response=json&timestamp=${ts}&username=admin" | openssl sha1 -binary -hmac "$ssokey" | base64)
hs2=$(echo -n $hs1 | perl -p -e 's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg')
curl -s -v "http://csms:8080/client/api?command=login&username=admin&domainId=${domid}&timestamp=${ts}&signature=${hs2}&response=json" | python -mjson.tool
