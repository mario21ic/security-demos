Instalar apps:
```
sudo apt install --reinstall opensc opensc-pkcs11 pcscd pcsc-tools libccid libengine-pkcs11-openssl gnutls-bin
sudo systemctl enable --now pcscd pcscd.socket

dpkg -L opensc-pkcs11 | grep opensc-pkcs11.so
export OPENSC_MODULE=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
export PKCS11_MODULE=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so

# Listado de mecanismos soportados
sudo pkcs11-tool --module $OPENSC_MODULE --list-mechanisms
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
export SO_PIN=1234567890123456
export USER_PIN=123456

sc-hsm-tool --initialize --so-pin $SO_PIN --pin $USER_PIN
```
Nota: so-pin debe de ser de al menos 16 caracteres y user pin de 6.
Otra forma es:
```
sudo pkcs11-tool --module $OPENSC_MODULE --init-token --init-pin --so-pin=$SO_PIN --new-pin=$USER_PIN --label="test" --pin=$USER_PIN
```

### 🗝️ GENERACIÓN DE CLAVES
```
# RSA
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --keypairgen --key-type rsa:1024 --id 10 --label "rsa-1024-key"
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects

sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --keypairgen --key-type rsa:2048 --id 11 --label "rsa-2048-key"
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --keypairgen --key-type rsa:4096 --id 12 --label "rsa-4096-key"


# ECDSA
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --keypairgen --key-type EC:prime256v1 --id 13 --label "my-ec-p256"
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --keypairgen --key-type EC:secp384r1 --id 14 --label "my-ec-p384"


# Listar objects (no requiere login — son públicos por defecto)
sudo pkcs11-tool --module $OPENSC_MODULE --list-objects

# Listar data objects (requiere login por ser privados)
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects


sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects --type privkey
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects --type pubkey
```

Otra forma, pero en ECC keys es:
```
sudo pkcs11-tool —module $OPENSC_MODULE —login —pin $USER_PIN —keypairgen —key-type EC:prime256v1 —label mykey
```


Grabar certificados y data:
```
./openssl_req_der.sh # opcional

sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --write-object testcert.der --type cert --id 10
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --write-object testcert.der --type data --label testdata # otra forma, as data
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects
```

### 📜 PKI — CSR Y CERTIFICADOS (X.509)
```
# Exportar public key 
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --read-object --type pubkey --id 10 --output-file pubkey-10.der
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --read-object --type pubkey --id 13 --output-file pubkey-13.der
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --read-object --type pubkey --id 14 --output-file pubkey-14.der


# RSA: Convertir DER a PEM
sudo openssl pkey -inform DER -outform PEM -in pubkey-10.der -pubin -out pubkey-10.pem

# ECDSA: Convertir DER a PEM
sudo openssl ec -pubin -inform DER -in pubkey-13.der -outform PEM -out pubkey-13.pem
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

$ export GNUTLS_PIN=$USER_PIN
$ certtool   --generate-self-signed   --load-privkey "pkcs11:token=$HSM_TOKEN;id=%10;type=private"   --outfile cert-10.pem   --template /dev/stdin << 'EOF'
cn = "mi-servicio"
organization = "MiOrg"
country = PE
ca
cert_signing_key
expiration_days = 3650
EOF

# Importar certificado de vuelta al HSM
$ sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --write-object cert-10.pem   --type cert   --id 11   --label "mi-cert"

$ sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects
# sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects --type cert

# Leer desde HSM
$ sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --read-object --type cert \
  --id 11 \
  --output-file cert-from-hsm.der
$ sudo file cert-from-hsm.der

# Convertir y verificar contenido
$ sudo openssl x509 -inform DER -in cert-from-hsm.der -text -noout | \
  grep -E "Subject:|Issuer:|Not After"

# Eliminar
$ sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --delete-object --type cert --id 11
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

### FIRMA y VERIFICACION ✍️ 
```
echo "datos a firmar" > data.txt

# Firmar con RSA-SHA256 (clave en HSM)
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --sign \
  --mechanism SHA256-RSA-PKCS \
  --id 10 \
  --input-file data.txt \
  --output-file data.sig

sudo file data.sig
sudo head data.sig

# Firmar con ECDSA
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --sign --mechanism ECDSA-SHA256 \
  --id 13 \
  --input-file data.txt \
  --output-file data-ec.sig
sudo file data-ec.sig
sudo head data-ec.sig

# Verificar con la public key exportada
# RSA
sudo openssl dgst \
  -sha256 \
  -verify pubkey-10.pem \
  -signature data.sig \
  data.txt

# ECDSA
# Script de conversión P1363 → DER
python3 << 'PYEOF'
import sys, struct

with open("data-ec.sig", "rb") as f:
    raw = f.read()

# Para P-384: R y S son cada uno 48 bytes → total 96 bytes
# Para P-256: R y S son cada uno 32 bytes → total 64 bytes
half = len(raw) // 2
r = raw[:half]
s = raw[half:]

def encode_int(n):
    # Eliminar ceros a la izquierda pero mantener signo positivo
    n = n.lstrip(b'\x00')
    if n[0] & 0x80:          # si el bit alto está seteado, agregar 0x00 para signo
        n = b'\x00' + n
    return bytes([0x02, len(n)]) + n

r_enc = encode_int(r)
s_enc = encode_int(s)
seq_body = r_enc + s_enc
der_sig = bytes([0x30, len(seq_body)]) + seq_body

with open("data-ec.sig.der", "wb") as f:
    f.write(der_sig)

print(f"Raw sig: {len(raw)} bytes (R={half}B, S={half}B)")
print(f"DER sig: {len(der_sig)} bytes")
print(f"Guardado en data-ec.sig.der")
PYEOF

# Verificar con la firma convertida
openssl dgst \
  -sha256 \
  -verify pubkey-13.pem \
  -signature data-ec.sig.der \
  data.txt


# Listado de mecanismos soportados por el HSM
$ pkcs11-tool --module $OPENSC_MODULE --list-mechanisms
```


### CIFRAR Y DESCIFRAR 🔐
```
# Cifrar RSA con clave pública (desde el PEM exportado del HSM)
$ sudo openssl pkeyutl \
  -encrypt \
  -pubin \
  -inkey pubkey-10.pem \
  -pkeyopt rsa_padding_mode:oaep \
  -pkeyopt rsa_oaep_md:sha256 \
  -in data.txt \
  -out data.enc

# Descifrar RSA con clave pública 
$ sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN \
  --decrypt --mechanism RSA-PKCS-OAEP \
  --id 10 --input-file data.enc \
  --output-file data.dec
```

### DATA OBJECT 
```
# Crear datos de prueba
echo '{"app":"teleport","env":"homelab","secret":"valor-sensible"}' > mydata.json

# Importar como data object
sudo pkcs11-tool --module $OPENSC_MODULE \
  -l --pin $USER_PIN \
  --write-object mydata.json \
  --type data \
  --id 30 \
  --label "config-teleport" \
  --application-label "teleport-config"

sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --list-objects --type data

# Leer desde HSM
sudo pkcs11-tool --module $OPENSC_MODULE \
  -l --pin $USER_PIN \
  --read-object --type data \
  --label config-teleport \
  --output-file config-teleport-recovered.json

# Grabar un secret aes 256
openssl rand 32 > aes-256.key
echo "Clave AES generada: $(xxd -p aes-256.key)"
sudo pkcs11-tool --module $OPENSC_MODULE   -l --pin $USER_PIN   --write-object aes-256.key   --type data   --id 20   --label "aes-256-key"   --private

# Leer
sudo pkcs11-tool --module $OPENSC_MODULE \
  -l --pin $USER_PIN \
  --read-object --type data \
  --label "aes-256-key" \
  --output-file aes-256-recovered.key

```

Eliminar:
```
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --delete-object --type cert --id 10
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --delete-object --type privkey --id 10
sudo pkcs11-tool --module $OPENSC_MODULE -l --pin $USER_PIN --delete-object --type data --label testdata
```

Based on https://github.com/OpenSC/OpenSC/wiki/SmartCardHSM#generate-key-pair
