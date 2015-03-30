Vagrant Box 0
===

* IP Address: 192.168.50.100
* Hostname:   192.168.50.100.xip.io

This box uses rewrites to dynamically serve the document root.  I.e:

* foo.192.168.50.100.xip.io -> /var/www/html/foo
* bar.192.168.50.100.xip.io -> /var/www/html/bar

etc.  No additional configurations or service restarts needed.

# Installation:

```
mkdir ~/Project
git clone https://github.com/steverobbins/Vagrant0.git ~/Project/Vagrant0
cd ~/Project/Vagrant0
vagrant up
```