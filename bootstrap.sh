#!/usr/bin/env bash

#yum -y update
yum -y install \
  httpd \
  mysql-server \
  php \
  php-curl \
  php-devel \
  php-gd \
  php-intl \
  php-pear \
  php-imap \
  php-mcrypt \
  php-mysql \
  php-pdo \
  php-pspell \
  php-recode \
  php-snmp \
  php-tidy \
  php-xmlrpc \
  php-xsl \
  vim

echo '<VirtualHost *:80>
  <Directory /var/www/html/*>
    Options FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>

  Options +ExecCGI +FollowSymLinks -Indexes -MultiViews
  DirectoryIndex index.php index.html index.htm
  UseCanonicalName off
  AddType application/x-httpd-php .php
  ServerName v0.steverobbins.name

  <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteLog "/var/log/httpd/rewrite.log"
    RewriteLogLevel 0

    RewriteCond   %{HTTP_HOST}                         ^[^.]+\.v0\.steverobbins\.name$
    RewriteRule   ^(.+)                                %{HTTP_HOST}$1                  [C]
    RewriteRule   ^([^.]+)\.v0\.steverobbins\.name(.*) /var/www/html/$1/$2             [L]
  </IfModule>
</VirtualHost>
' > /etc/httpd/conf.d/vhost.conf

yum -y groupinstall "Development tools"
pecl channel-update pecl.php.net
pecl install xdebug

echo '
[xdebug]
xdebug.default_enable=1
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_host=localhost
xdebug.remote_port=9000
xdebug.remote_autostart=1
xdebug.profiler_enable_trigger=1
zend_extension=/usr/lib64/php/modules/xdebug.so' >> /etc/php.ini

service httpd start
service mysqld start

mysql -e "
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
"

