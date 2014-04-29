_domain=sugano.com
openssl req \
  -new \
  -newkey rsa:2048 \
  -keyout ${_domain}.key \
  -batch \
  -nodes \
  -subj "/C=JP/ST=TOKYO/CN=*.${_domain}/" \
  -x509 \
  -out ${_domain}.crt
