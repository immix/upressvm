# Instant Development
This folder contains the configuration files necessary to instantly boot a
vagrant virtual machine that serves all web applications within the NOMAD 
project.

```
vagrant up
```

## RSA Key
You will need to create an RSA key before booting up the vagrant machine.
```
ssh-keygen -t rsa -C "your@github.email"
```

## DNS Hosts
To update the dns routing table file on your host computer, you can install the
vagrant plugin `hostsupdater` or add the contents of `hosts` to your hosts file.
```
vagrant plugin install vagrant-hostsupdater
```

Once vagrant is running, add the contents of `hosts` to your operating system's
hosts file.
# Laravel Homestead

The official Laravel local development environment.

Official documentation [is located here](http://laravel.com/docs/homestead?version=4.2).
