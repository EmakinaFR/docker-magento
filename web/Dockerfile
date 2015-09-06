FROM ubuntu:14.04

MAINTAINER Alexandre JARDIN <aja@emakina.fr>

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN \
    apt-key adv --keyserver pgp.mit.edu --recv-key 799058698E65316A2E7A4FF42EAE1437F7D2C623 && \
    echo "deb http://repos.zend.com/zend-server/8.5/deb_apache2.4 server non-free" >> /etc/apt/sources.list.d/zend-server.list && \
    apt-get update && apt-get install -y zend-server-php-5.5 && /usr/local/zend/bin/zendctl.sh stop

RUN \
    apt-get update && apt-get install -y autoconf curl make && \
    yes "" | /usr/local/zend/bin/pecl install mongo && \
    /usr/local/zend/bin/zendctl.sh stop

ENTRYPOINT ["/usr/local/docker/run.sh"]
