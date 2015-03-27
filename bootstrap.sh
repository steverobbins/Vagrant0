#!/usr/bin/env bash

rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm

yum -y install \
  httpd \
  mysql-server \
  php54w \
  php54w-curl \
  php54w-devel \
  php54w-gd \
  php54w-intl \
  php54w-pear \
  php54w-imap \
  php54w-mbstring \
  php54w-mcrypt \
  php54w-mysql \
  php54w-pdo \
  php54w-pspell \
  php54w-recode \
  php54w-pecl-redis \
  php54w-soap \
  php54w-snmp \
  php54w-tidy \
  php54w-xmlrpc \
  php54w-xsl \
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
  ServerName v0.ldev.io
  <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteLog "/var/log/httpd/rewrite.log"
    RewriteLogLevel 0
    RewriteCond   %{HTTP_HOST}                         ^[^.]+\.v0\.ldev\.io$
    RewriteRule   ^(.+)                                %{HTTP_HOST}$1                  [C]
    RewriteRule   ^([^.]+)\.v0\.ldev\.io(.*) /var/www/html/$1/$2             [L]
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

cd ~
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -zxvf ioncube_loaders_lin_x86-64.tar.gz
mv ioncube/ioncube_loader_lin_5.4.so /usr/lib64/php/modules/
rm -rf ioncube ioncube_loaders_lin_x86-64.tar.gz

sed -i '2i\\
zend_extension=/usr/lib64/php/modules/ioncube_loader_lin_5.4.so' /etc/php.ini

sed -i "883i\\
date.timezone = 'America/Los_Angeles'" /etc/php.ini

sed -i '7i\\
max_allowed_packet=1G
innodb_log_buffer_size=1G
innodb_file_per_table' /etc/my.cnf

service httpd start
service mysqld start

mysql -e "
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
"

rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
yum -y install htop

rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum -y install redis

echo 'redis-server /etc/redis.conf' >> /etc/rc.d/rc.local
redis-server /etc/redis.conf

chkconfig httpd on
chkconfig mysqld on

cd ~

curl -sS https://getcomposer.org/installer | php
chmod +x composer.phar
mv composer.phar /usr/local/bin/composer

git clone https://github.com/netz98/n98-magerun.git
cd n98-magerun
/usr/local/bin/composer install
cd /usr/local/bin
ln -s ~/n98-magerun/bin/n98-magerun magerun

echo '
alias ls="ls -ahF --color=auto"
alias ll="ls -l"
alias grep="grep --color=auto"
__cur_dir() {
    pwd
}
bash_prompt() {
  local NONE="\[\033[0m\]"    
  # regular colors
  local K="\[\033[0;30m\]"    # black
  local R="\[\033[0;31m\]"    # red
  local G="\[\033[0;32m\]"    # green
  local Y="\[\033[0;33m\]"    # yellow
  local B="\[\033[0;34m\]"    # blue
  local M="\[\033[0;35m\]"    # magenta
  local C="\[\033[0;36m\]"    # cyan
  local W="\[\033[0;37m\]"    # white
  local UC=$W                 
  [ $UID -eq "0" ] && UC=$R   
  PS1="${W}"
  USERHOST="$USER@$HOSTNAME"
  CNT=$(echo $USERHOST | wc -m)
  CNT=`expr 67 - $CNT`
  SPACES=$(printf "%${CNT}s" | tr " " "-")
  PS1="$PS1\n${W}+ $C$USER@$HOSTNAME$W $SPACES $Y\t$W +"
  PS1="$PS1\n${W}| $G\$(__cur_dir)$NONE"
  PS1="$PS1\n$NONE\\$ "
}
bash_prompt
unset bash_prompt

alias magerun="magerun --ansi"
' >> /etc/bashrc
