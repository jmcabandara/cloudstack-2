#set -x
#
info=${1:-Zones}
_info=$(echo -n $info | tr [A-Z] [a-z])
#
apikey=$(mysql -N -B -h csms -e 'select api_key from cloud.user where username = "admin";')
_apikey=$(echo -n $apikey | tr [A-Z] [a-z])
#
secret=$(curl -s "http://172.16.1.2:8096/client/api?command=getUser&userApiKey=${apikey}&response=json"|python -mjson.tool|grep secretkey|cut -d: -f2|tr -d '",[:blank:]')
#
hs1=$(echo -n "apikey=${_apikey}&command=list${_info}&response=json" | openssl sha1 -binary -hmac "$secret" | base64)
hs2=$(echo -n $hs1 | perl -p -e 's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg')
#
curl -s -v "http://172.16.1.2:8080/client/api?command=list${info}&apiKey=${apikey}&signature=${hs2}&response=json" | python -mjson.tool
