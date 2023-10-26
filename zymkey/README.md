Zymkey apps demo

## Dependencias:
```
sudo apt-get install opensc opensc-pkcs11 -y
```

## Inicializar:
```
zk_pkcs11-util --show-slots
zk_pkcs11-util --init-token --slot 0 --label Zymkey
zk_pkcs11-util --show-slots
```

Opcional: eliminar tokens y slots:
```
$ sudo zk_pkcs11-util --delete-token --serial xxxxxxx
$ sudo zk_pkcs11-util --show-slots
```


Usar slot anterior y reemplazarlo por xxxx. Va a preguntar dos PINs, no olvidarlos
```
zk_pkcs11-util --use-zkslot 0 --slot xxxx --label sshkey --id 0001
zk_pkcs11-util --show-slots
pkcs11-tool --list-token
```

Usar modulo para enlazar token (reemplaza por su PIN) y listado de objects:
```
pkcs11-tool --module /usr/lib/libzk_pkcs11.so -l -p xxxx --show-info
pkcs11-tool --module /usr/lib/libzk_pkcs11.so -l -p xxxx --list-slots
pkcs11-tool --module /usr/lib/libzk_pkcs11.so -l -p xxxx --list-token-slots
pkcs11-tool --module /usr/lib/libzk_pkcs11.so -l -p xxxx --token Zymey --list-objects
```

## Configurar SSH key:
```
$ ssh-keygen -D /usr/lib/libzk_pkcs11.so
$ ssh-keygen -D /usr/lib/libzk_pkcs11.so >> mynewkey.pub
$ ssh-copy-id -f -i mynewkey.pub -p 22 usuarioremoto@ip-server
```

Probar:
```
$ sudo ssh -I /usr/lib/libzk_pkcs11.so usuarioremoto@ip-server -p 22
```

No pedir PIN:
```
$ eval $(ssh-agent)
$ ssh-add -s /usr/lib/libzk_pkcs11.so
Enter PIN for 'Zymkey':
Card added: /usr/lib/libzk_pkcs11.so
$ ssh-add -l
$ sudo ssh -I /usr/lib/libzk_pkcs11.so usuarioremoto@ip-server -p 22
```

Based on https://techblog.dac.digital/zymkey-hsm-for-ssh-authentication-b28c7566b648
