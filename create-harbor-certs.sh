#!/bin/bash

HOST=reg.andrew-net.com

echo "Generate a CA certificate private key."
openssl genrsa -out ca.key 4096

echo "Generate the CA certificate."
openssl req -x509 -new -nodes -sha512 -days 3650 \
  -subj "/C=US/ST=Oregon/L=Portland/O=andrew-net/OU=Personal/CN=$HOST" \
  -key ca.key \
  -out ca.crt

echo "generating $HOST.key"
openssl genrsa -out $HOST.key 4096

echo "generating certificate signing request (CSR)."
openssl req -sha512 -new \
  -subj "/C=US/ST=Oregon/L=Portland/O=andrew-net/OU=Personal/CN=$HOST" \
  -key $HOST.key \
  -out $HOST.csr

echo "generating an x509 v3 extension file."
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$HOST
DNS.2=reg.andrew-net
EOF

echo "generate a certificate for Harbor host"
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in $HOST.csr \
    -out $HOST.crt

echo "moving certs"
sudo mkdir -p /data/cert/
sudo cp $HOST.crt /data/cert/
sudo cp $HOST.key /data/cert/

openssl x509 -inform PEM -in $HOST.crt -out $HOST.cert
mkdir -p /etc/docker/certs.d/$HOST/
cp $HOST.cert /etc/docker/certs.d/$HOST/
cp $HOST.key /etc/docker/certs.d/$HOST/
cp ca.crt /etc/docker/certs.d/$HOST/
