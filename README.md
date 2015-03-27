Vagrant Box 0
===

* IP Address: 192.168.50.100
* Hostname:   *.v0.ldev.io

This box uses rewrites to dynamically serve the document root.  I.e:

* foo.v0.ldev.io -> /var/www/html/foo
* bar.v0.ldev.io -> /var/www/html/bar

etc.  No additional configurations or service restarts needed.

# Installation:

```
mkdir ~/Project
git clone https://github.com/steverobbins/Vagrant0.git ~/Project/Vagrant0
cd ~/Project/Vagrant0
vagrant up
```