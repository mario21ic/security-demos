#!/bin/bash
set -xe

pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN $@

#pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --delete-object --type privkey --id 12
