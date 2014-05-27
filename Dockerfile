FROM       ubuntu:latest
MAINTAINER jtews@300brand.com

# RUN        echo 'Acquire::http { Proxy "http://192.168.20.21:3142"; };' >> /etc/apt/apt.conf.d/01proxy
RUN        sed 's/main$/main universe/' -i /etc/apt/sources.list

# NOTE     To cause an update (and upgrade), change the date below to today
RUN        apt-get update # LAST_UPDATE: May 22, 2014
RUN        apt-get upgrade -y

RUN        apt-get -y install \
               apache2 \
               dnsmasq \
               libapache2-mod-php5 \
               mysql-server \
               openssh-server \
               php5 \
               php5-curl \
               php5-gd \
               php5-mongo \
               php5-mysqlnd \
               php5-sqlite \
               php5-xmlrpc \
               php5-xsl \
               supervisor

#          SUPERVISOR CONFIGURATION
RUN        mkdir -p /var/log/supervisor
RUN        chown nobody:nogroup /var/log/supervisor
ADD        supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD        inet_http_server.conf /etc/supervisor/conf.d/inet_http_server.conf
EXPOSE     9001

#          DNSMASQ CONFIGURATION
ADD        dnsmasq.conf /etc/supervisor/conf.d/dnsmasq.conf
ENV        TLD dev
EXPOSE     53

#          SSH CONFIGURATION
RUN        echo 'root:dev' | chpasswd
RUN        mkdir /var/run/sshd
RUN        sed -e 's/UsePAM yes/UsePAM no/' -i /etc/ssh/sshd_config
RUN        sed -e 's/PermitRootLogin without-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
ADD        sshd.conf /etc/supervisor/conf.d/sshd.conf
EXPOSE     22

#          MYSQL CONFIGURATION
ADD        mysqld.cnf /etc/mysql/conf.d/mysqld.cnf
RUN        chmod 0664 /etc/mysql/conf.d/mysqld.cnf
ADD        mysql_setup.sh /root/mysql_setup.sh
RUN        chmod +x /root/mysql_setup.sh
RUN        /root/mysql_setup.sh
RUN        rm /root/mysql_setup.sh
ADD        mysql.conf /etc/supervisor/conf.d/mysql.conf
VOLUME     ['/var/lib/mysql']
EXPOSE     3306

#          APACHE CONFIGURATION
ADD        apache.conf /etc/supervisor/conf.d/apache.conf
ADD        dev.conf /etc/apache2/sites-available/dev.conf
ADD        50-dev.ini /etc/php5/apache2/conf.d/50-dev.ini
RUN        touch /etc/apache2/mods-available/php5_fix.load
ADD        php5_fix.conf /etc/apache2/mods-available/php5_fix.conf
RUN        a2enmod php5_fix
RUN        a2enmod rewrite
RUN        a2enmod vhost_alias
RUN        a2ensite dev
RUN        a2dissite 000-default
RUN        mkdir -m 0777 /www
VOLUME     ['/www']
EXPOSE     80

CMD        ["/usr/bin/supervisord", "--configuration", "/etc/supervisor/supervisord.conf"]
