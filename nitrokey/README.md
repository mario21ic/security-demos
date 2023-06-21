Definir SO pin y User pin
```
sc-hsm-tool --initialize --so-pin 3537363231383830 --pin 648219
```
Nota: so-pin debe de ser de al menos 16 caracteres y user pin de 6.
Otra forma es:
```
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --init-token --init-pin --so-pin=3537363231383830 --new-pin=648219 --label="test" --pin=648219
```

Generar key pair:
```
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin 648219 --keypairgen --key-type rsa:1024 --id 10
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin 648219 --list-objects
```
Otra forma, pero en ECC keys es:
pkcs11-tool —module /usr/local/lib/opensc-pkcs11.so —login —pin 648219 —keypairgen —key-type EC:prime256v1 —label mykey

Extraer la public key del id 10 y guardarlo en pubkey.spki:
```
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin 648219 --id 10 --read-object --type pubkey --output-file pubkey.spki
```

Opcional: convertir a pem
```
openssl pkey -inform DER -outform PEM -in pubkey.spki -pubin -out pubkey.pem
```

Grabar certificados y data:
```
./openssl_req_der.sh # opcional
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin 648219 --write-object testcert.der --type cert --id 10
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin 648219 --write-object testcert.der --type data --label testdata # otra forma, as data
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin 648219 --list-objects
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
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin 648219 --delete-object --type cert --id 10
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin 648219 --delete-object --type privkey --id 10
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so -l --pin 648219 --delete-object --type data --label testdata
```

Based on https://github.com/OpenSC/OpenSC/wiki/SmartCardHSM#generate-key-pair
