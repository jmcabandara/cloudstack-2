#set -x
ts=$(date +%s)000
hs1=$(echo -n "command=login&domainid=1&timestamp=${ts}&username=takashis" | openssl sha1 -binary -hmac '0wLWumJ-a12jLev15LZvf5-5ybWCT4mNNyHoQIINLjv8xbx3siSj_2NY49-xf4MzZ6fquZ4oiEJYEhUZXkt3Zw' | openssl base64)
hs2=$(echo -n $hs1 | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg')
curl -s -v "http://172.16.1.2:8080/client/api?command=login&domainid=1&timestamp=${ts}&username=takashis&signature=${hs2}" | xmllint --format -
