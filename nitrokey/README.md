Listar readers
```
opensc-tool --list-readers
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
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --init-token --init-pin --so-pin=$SO_PIN --new-pin=$USER_PIN --label="test" --pin=$USER_PIN
```

Generar key pair:
```
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --keypairgen --key-type rsa:1024 --id 10
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --list-objects
```
Otra forma, pero en ECC keys es:
pkcs11-tool —module /usr/local/lib/opensc-pkcs11.so —login —pin $USER_PIN —keypairgen —key-type EC:prime256v1 —label mykey

Extraer la public key del id 10 y guardarlo en pubkey.spki:
```
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --id 10 --read-object --type pubkey --output-file pubkey.spki
```

Opcional: convertir a pem
```
openssl pkey -inform DER -outform PEM -in pubkey.spki -pubin -out pubkey.pem
```

Grabar certificados y data:
```
./openssl_req_der.sh # opcional
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --write-object testcert.der --type cert --id 10
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --write-object testcert.der --type data --label testdata # otra forma, as data
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --list-objects
```


Listado:
```
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --show-info
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --list-interfaces
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --list-mechanisms

pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --list-slots
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --list-token-slots
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --list-objects
```


Eliminar:
```
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --delete-object --type cert --id 10
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --delete-object --type privkey --id 10
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin $USER_PIN --delete-object --type data --label testdata
```

Based on https://github.com/OpenSC/OpenSC/wiki/SmartCardHSM#generate-key-pair
