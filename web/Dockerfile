FROM ubuntu:latest

MAINTAINER Alexandre JARDIN <aja@emakina.fr>

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN \
    apt-key adv --keyserver pgp.mit.edu --recv-key 799058698E65316A2E7A4FF42EAE1437F7D2C623 && \
    echo "deb http://repos.zend.com/zend-server/8.5.1/deb_apache2.4 server non-free" >> /etc/apt/sources.list.d/zend-server.list && \
    apt-get update && apt-get install -y zend-server-php-5.5 && \
    echo "export PATH=$PATH:/usr/local/zend/bin" >> /root/.bashrc

RUN \
    apt-get update && apt-get install -y autoconf cron curl make nano && \
    yes "" | /usr/local/zend/bin/pecl install mongo

RUN \
    export PHP_VERSION=`/usr/local/zend/bin/php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"` && \
    curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${PHP_VERSION} && \
    export PHP_EXT_DIR=`/usr/local/zend/bin/php -r "echo ini_get('extension_dir');"` && \
    tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp && mv /tmp/blackfire-*.so ${PHP_EXT_DIR}/blackfire.so && \
    chown root ${PHP_EXT_DIR}/blackfire.so && chown :root ${PHP_EXT_DIR}/blackfire.so && chmod 0755 ${PHP_EXT_DIR}/blackfire.so

RUN \
    apt-get update && apt-get install -y php5-redis

RUN usermod -u 1000 www-data

ENTRYPOINT ["/usr/local/docker/run.sh"]
