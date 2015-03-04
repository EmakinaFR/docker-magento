FROM ubuntu:14.04

MAINTAINER Alexandre JARDIN

COPY ./run /usr/local/bin/run
RUN chmod 777 /usr/local/bin/run

COPY ./extra /usr/local/bin/extra
RUN chmod -R 777 /usr/local/bin/extra/*

COPY ./databases /usr/local/bin/databases
COPY ./vhosts /usr/local/bin/vhosts

########## Zend Server installation - START ##########
RUN \
    apt-key adv --keyserver pgp.mit.edu --recv-key 799058698E65316A2E7A4FF42EAE1437F7D2C623 && \
    echo "deb http://repos.zend.com/zend-server/8.0.0-beta/deb_apache2.4 server non-free" >> /etc/apt/sources.list.d/zend-server.list && \
    apt-get update && apt-get install -y autoconf make zend-server-php-5.5 && \
    yes "" | /usr/local/zend/bin/pecl install mongo && \
    /usr/local/zend/bin/zendctl.sh stop

VOLUME ["/var/www/html"]

EXPOSE 8080
EXPOSE 10081
EXPOSE 10082
EXPOSE 10083
########## Zend Server installation - END ##########

########## Varnish installation - START ##########
RUN apt-get update && apt-get install -y \
    automake \
    autotools-dev \
    apt-transport-https \
    curl \
    dpkg-dev \
    git \
    libedit-dev \
    libjemalloc-dev \
    libncurses-dev \
    libpcre3-dev \
    libtool \
    libvarnishapi-dev \
    make \
    pkg-config \
    python-docutils \
    python-sphinx \
    graphviz

RUN \
    curl https://repo.varnish-cache.org/ubuntu/GPG-key.txt | apt-key add - && \
    echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-3.0" >> /etc/apt/sources.list.d/varnish-cache.list && \
    apt-get install -y varnish

RUN \
    apt-get source varnish=3.0.5 && cd /varnish-3.0.5 && ./autogen.sh && ./configure && make && \
    git clone https://github.com/varnish/libvmod-header.git /varnish-libvmod && cd /varnish-libvmod && git checkout 3.0 && \
    ./autogen.sh && ./configure VARNISHSRC=/varnish-3.0.5 && make && make install && \
    cd && rm -rf /varnish*

EXPOSE 80
########## Varnish installation - END ##########

########## Percona installation - START ##########
RUN \
    apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A && \
    echo "deb http://repo.percona.com/apt `lsb_release -cs` main" >> /etc/apt/sources.list.d/percona.list && \
    apt-get update && apt-get install -y percona-server-server-5.6 && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
    sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/my.cnf && \
    echo "mysqld_safe &" > /tmp/config && \
    echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
    echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
    bash /tmp/config && \
    rm -f /tmp/config

VOLUME ["/etc/mysql", "/var/lib/mysql"]

EXPOSE 3306
########## Percona installation - END ##########

########## MongoDB installation - START ##########
RUN \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' >> /etc/apt/sources.list.d/mongodb.list && \
    apt-get update && apt-get install -y mongodb-org && \
    rm -rf /var/lib/apt/lists/*

VOLUME ["/data/db"]

EXPOSE 27017
EXPOSE 28017
########## MongoDB installation - END ##########

CMD ["/usr/local/bin/run"]
