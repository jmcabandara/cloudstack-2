#set -x
domid=$(mysql -N -B -h csms -e 'select uuid from cloud.domain where name = "ROOT";')
curl -s -v "http://csms:8080/client/api?command=login&domainId=${domid}&username=admin&password=password&response=json" | python -m json.tool
