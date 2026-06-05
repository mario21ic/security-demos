Instalar apps:
```
sudo apt install --reinstall opensc opensc-pkcs11 pcscd pcsc-tools libccid libengine-pkcs11-openssl
sudo systemctl enable --now pcscd pcscd.socket

dpkg -L opensc-pkcs11 | grep opensc-pkcs11.so
export OPENSC_MODULE=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
```

Reconocimiento del hardware:
```
sudo lsusb
sudo pcsc_scan

sudo opensc-tool --list-readers
sudo opensc-tool --reader 0 --atr
sudo opensc-tool --reader 0 --name
```

Definir SO pin y User pin
```
export SO_PIN=$SO_PIN
export USER_PIN=648219

sc-hsm-tool --initialize --so-pin $SO_PIN --pin $USER_PIN
```
Nota: so-pin debe de ser de al menos 16 caracteres y user pin de 6.
Otra forma es:
```
sudo pkcs11-tool --module $OPENSC_MODULE --init-token --init-pin --so-pin=$SO_PIN --new-pin=$USER_PIN --label="test" --pin=$USER_PIN
```

Generar key pair:
```
# RSA
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --keypairgen --key-type rsa:1024 --id 10 --label "rsa-1024-key"
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects

sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --keypairgen --key-type rsa:2048 --id 11 --label "rsa-2048-key"
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --keypairgen --key-type rsa:4096 --id 12 --label "rsa-4096-key"


# ECDSA
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --keypairgen --key-type EC:prime256v1 --id 13 --label "my-ec-p256"
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --keypairgen --key-type EC:secp384r1 --id 14 --label "my-ec-p384"


# Listado privados / publicos
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects

sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects --type privkey
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects --type pubkey
```

Otra forma, pero en ECC keys es:
```
sudo pkcs11-tool —module $OPENSC_MODULE —login —pin $USER_PIN —keypairgen —key-type EC:prime256v1 —label mykey
```

Extraer la public key del id 10 y guardarlo en pubkey.spki:
```
```


Grabar certificados y data:
```
./openssl_req_der.sh # opcional

sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --write-object testcert.der --type cert --id 10
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --write-object testcert.der --type data --label testdata # otra forma, as data
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects
```

📜 PKI — CSR Y CERTIFICADOS
```
# Exportar public key 
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --read-object --type pubkey --id 10 --output-file pubkey-10.der
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --read-object --type pubkey --id 14 --output-file pubkey-14.der

# RSA: Convertir DER a PEM
sudo openssl pkey -inform DER -outform PEM -in pubkey-10.der -pubin -out pubkey-10.pem

# ECDSA: Convertir DER a PEM
sudo openssl ec -pubin -inform DER -in pubkey-14.der -outform PEM -out pubkey-14.pem

# Buscar toke label
sudo pkcs11-tool --module $OPENSC_MODULE --list-token-slots

# Generar CSR usando la clave PRIVADA que está en el HSM
# la clave nunca sale del dispositivo
export HSM_TOKEN="SmartCard-HSM%20%28UserPIN%29"
sudo openssl req \
  -engine pkcs11 \
  -keyform engine \
  -key "pkcs11:token=$HSM_TOKEN;id=%10;type=private" \
  -new -sha256 \
  -subj "/CN=mi-servicio/O=MiOrg/C=PE" \
  -out csr-10.pem
Engine "pkcs11" set.
Enter PKCS#11 token PIN for SmartCard-HSM (UserPIN):

file csr-10.pem
sudo head csr-10.pem
sudo openssl req -in csr-10.pem -text -noout

# Auto-firmar certificado (útil para CA root en lab)
sudo openssl x509 \
  -engine pkcs11 \
  -CAkeyform engine \
  -CAkey "pkcs11:token=$HSM_TOKEN;id=%10;type=private" \
  -req \
  -in csr-10.pem \
  -signkey "pkcs11:token=$HSM_TOKEN;id=%10;type=private" \
  -days 3650 \
  -out cert-10.pem

```


Listado:
```
sudo pkcs11-tool --module $OPENSC_MODULE --show-info
sudo pkcs11-tool --module $OPENSC_MODULE --list-interfaces
sudo pkcs11-tool --module $OPENSC_MODULE --list-mechanisms

sudo pkcs11-tool --module $OPENSC_MODULE --list-slots
sudo pkcs11-tool --module $OPENSC_MODULE --list-token-slots

sudo pkcs11-tool --module $OPENSC_MODULE --list-objects
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects
```


Eliminar:
```
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --delete-object --type cert --id 10
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --delete-object --type privkey --id 10
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --delete-object --type data --label testdata
```

Based on https://github.com/OpenSC/OpenSC/wiki/SmartCardHSM#generate-key-pair
