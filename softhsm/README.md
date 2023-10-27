Instalación
```
sudo apt install -y softhsm

softhsm2-util -v
sudo softhsm2-util --show-slots
```


Inicializando slots:
```
softhsm2-util --init-token --slot 0 --label Token0
sudo softhsm2-util --show-slots

softhsm2-util --init-token --slot 1 --label Token1
sudo softhsm2-util --show-slots
```

Usando pkcs11:
```
sudo pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so --show-info
sudo pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so --list-slots
```
