Vagrant Box 0
===

* IP Address: 192.168.50.100
* Hostname:   192.168.50.100.xip.io

This box uses rewrites to dynamically serve the document root.  I.e:

* foo.192.168.50.100.xip.io -> /var/www/html/foo
* bar.192.168.50.100.xip.io -> /var/www/html/bar

etc.  No additional configurations or service restarts needed.

# What you get

* CentOS 6.5
* Apache 2.2.15
* MySQL 5.1.73
* PHP 5.4
  * ionCube Loader 4.7.5
  * Xdebug 2.3.2
* Redis 2.4.10

# Installation

```
mkdir ~/Project
git clone https://github.com/steverobbins/Vagrant0.git ~/Project/Vagrant0
cd ~/Project/Vagrant0
vagrant up
```