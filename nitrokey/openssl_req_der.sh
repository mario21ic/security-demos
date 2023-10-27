#!/bin/bash
set -xe

# interactive
#openssl req -x509 -newkey rsa:4096 -keyout mykey.pem -out mycert.pem -sha256 -days 365
openssl req -x509 -newkey rsa:4096 -keyout mykey.pem -out mycert.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"

# convertir
openssl x509 -outform der -in mycert.pem -out testcert.der
