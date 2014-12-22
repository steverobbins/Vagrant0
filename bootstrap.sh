#!/usr/bin/env bash

cd /tmp/
curl -o epel-release-7-5.noarch.rpm http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum -y install epel-release-7-5.noarch.rpm

yum -y update
yum -y install \
  httpd \
  mariadb-server mariadb \
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
service mysqld mariadb

cd ~

curl -sS https://getcomposer.org/installer | php
chmod +x composer.phar

git clone https://github.com/netz98/n98-magerun.git
cd n98-magerun
php ~/composer.phar install
cd /usr/local/bin
ln -s ~/n98-magerun/bin/n98-magerun magerun

mv ~/composer.phar /usr/local/bin/composer

echo '
alias ls="ls -ahF --color=auto"
alias ll="ls -l"
alias grep="grep --color=auto"
dynmotd () {
  local NONE="\033[0m"    

  # regular colors
  local K="\033[0;30m"    # black
  local R="\033[0;31m"    # red
  local G="\033[0;32m"    # green
  local Y="\033[0;33m"    # yellow
  local B="\033[0;34m"    # blue
  local M="\033[0;35m"    # magenta
  local C="\033[0;36m"    # cyan
  local W="\033[0;37m"    # white

  local PROCCOUNT=`ps -l | wc -l`
  local PROCCOUNT=`expr $PROCCOUNT - 4`

  echo -e "${W}+------------------------------------------------------------------------------+
| ${W}Hostname:$C       `hostname`
${W}| ${W}IP Address:$C     `ifconfig | grep -Eo \"inet (addr:)?([0-9]*\.){3}[0-9]*\" | grep -Eo \"([0-9]*\.){3}[0-9]*\" | grep -v \"127.0.0.1\" | xargs`
${W}| ${W}Uptime:$C         `uptime | sed \"s/.*up \([^,]*\), .*/\1/\" | xargs`
${W}| ${W}Sessions:$C       `who | grep $USER | wc -l | xargs`
${W}| ${W}Processes:$C      $PROCCOUNT$NONE"
}

dynmotd
unset dynmotd

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
' >> /etc/bashrc

echo '[client]
user=root
password=root' >> ~/.my.cnf

echo 'mysql_secure_installation

mysql -e "
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
"' >> ~/setup_mysql.sh

chmod +x ~/setup_mysql.sh

cd ~
ln -s /var/www/html
