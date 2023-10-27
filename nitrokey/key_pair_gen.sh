#!/bin/bash

# USER_PIN comes from global env
ID=$1

pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --keypairgen --key-type rsa:1024 --id $ID
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --id 10 --read-object --type pubkey --output-file $ID.spki

