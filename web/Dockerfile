FROM zend/php-zendserver:8.0-php5.5

MAINTAINER Alexandre JARDIN <aja@emakina.fr>

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN \
    apt-get update && apt-get install -y autoconf make && \
    yes "" | /usr/local/zend/bin/pecl install mongo && \
    /usr/local/zend/bin/zendctl.sh stop

ENTRYPOINT ["/usr/local/docker/run.sh"]
