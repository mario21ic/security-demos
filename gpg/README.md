Simetrico:
```
$ echo "Hello moto" > demo.txt
$ gpg --symmetric demo.txt
Enter passphrase:
$ gpg --decrypt demo.txt.gpg > demo.txt.descifrado
$ cat demo.txt.descrifrado
```

Asimetrico:
```
# gpg --full-gen-key
...
Please select what kind of key you want:
   (1) RSA and RSA
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (9) ECC (sign and encrypt) *default*
  (10) ECC (sign only)
  (14) Existing key from card
Your selection? 1
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072) 1024
Requested keysize is 1024 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0
Key does not expire at all
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: mario
Email address: mario@gmail.com
Comment: nada
You selected this USER-ID:
    "mario (nada) <mario@gmail.com>"
Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O

# Listado
$ gpg --list-keys
$ gpg --list-secret-keys

# Exportar public key
$ gpg -a --export -o mario.pub mario

# Importar public key
$ gpg --import mario.pub

# Cifrado / Descifado
gpg --encrypt --recipient mario demo.txt
gpg --decrypt demo.txt.gpg
```
