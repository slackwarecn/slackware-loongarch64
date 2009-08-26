#!/bin/sh
USE_DH=0

openssl req -new -x509 -days 365 -nodes \
  -config ./stunnel.cnf -out stunnel.pem -keyout stunnel.pem

test $USE_DH -eq 0 || openssl gendh 512 >> stunnel.pem

openssl x509 -subject -dates -fingerprint -noout \
  -in stunnel.pem

chmod 600 stunnel.pem
rm -f stunnel.rnd
