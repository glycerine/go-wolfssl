#!/bin/bash

mkdir -p certs

## warning/helpful: these are good for 100 years.

## This will be a self-signed certificate authority.
##    openssl verify -CAfile ca.crt ca.crt
## will return OK, demonstrating this.


openssl req -x509 -newkey rsa:2048 -days 36600 -keyout ca-key.pem -out ca-cert.pem -config ca.cnf -nodes

## openssl req -x509 -newkey ed25519 -days 36600 -keyout ca-key.pem -out ca-cert.pem -config ca.cnf -nodes

## verify that CA:TRUE is there.
echo "verify that CA:TRUE is there on ca-cert.pem"
openssl x509 -in ca-cert.pem -text -noout | grep -A 1 "X509v3 Basic Constraints"

mv ca-cert.pem certs/ca.crt
cp ca-key.pem  certs/ca.key

echo "verify that CA:TRUE is there on ca.crt"
openssl x509 -in certs/ca.crt -text -noout | grep -A 1 "X509v3 Basic Constraints"

openssl genpkey -algorithm RSA -out certs/client.key -pkeyopt rsa_keygen_bits:2048
##openssl genpkey -algorithm ed25519 -out certs/certs/client.key
##openssl pkey -in certs/certs/client.key -pubout -out certs/certs/client.crt

openssl genpkey -algorithm RSA -out certs/node.key -pkeyopt rsa_keygen_bits:2048

##openssl genpkey -algorithm ed25519 -out certs/certs/node.key

##openssl genpkey -algorithm ed25519 -out ed25519-private.pem
##openssl pkey -in ed25519-private.pem -pubout -out ed25519-public.pem

##openssl ecparam -genkey -name prime256v1 -out certs/certs/client.key
##openssl ecparam -genkey -name prime256v1 -out certs/certs/node.key

openssl req -new -key certs/client.key -out certs/client.csr  -config openssl-san.cnf
openssl req -new -key certs/node.key -out certs/node.csr -config openssl-san.cnf

openssl x509 -req -in certs/node.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/node.crt -days 36660 -extfile openssl-san.cnf -extensions req_ext

openssl x509 -req -in certs/client.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/client.crt -days 36600  -extfile openssl-san.cnf -extensions req_ext
