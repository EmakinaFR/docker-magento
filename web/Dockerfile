FROM php-zendserver:8.5-php5.5

MAINTAINER Alexandre JARDIN <aja@emakina.fr>

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN apt-get update \
    && apt-get install -y autoconf nano \
    && yes "" | /usr/local/zend/bin/pecl install mongo \
    && rm -rf /var/lib/apt/lists/*

ENV PATH=/usr/local/zend/bin:$PATH

ENTRYPOINT ["/usr/local/docker/run.sh"]
