#set -x
curl -s -v 'http://172.16.1.2:8080/client/api?command=login&domain=/&username=takashis&password=5ce8b4367b81fabf0869982adc1463bb' | xmllint --format -
