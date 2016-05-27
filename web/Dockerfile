FROM php-zendserver:8.5-php5.5

MAINTAINER Alexandre JARDIN <aja@emakina.fr>

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN apt-get update \
    && apt-get install -y autoconf nano \
    && yes "" | /usr/local/zend/bin/pecl install mongo \
    && rm -rf /var/lib/apt/lists/*

ENV PATH=/usr/local/zend/bin:$PATH

RUN export PHP_VERSION=`php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"` \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${PHP_VERSION} \
    && export PHP_EXT_DIR=`php -r "echo ini_get('extension_dir');"` \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp && mv /tmp/blackfire-*.so ${PHP_EXT_DIR}/blackfire.so \
    && chown root ${PHP_EXT_DIR}/blackfire.so && chown :root ${PHP_EXT_DIR}/blackfire.so && chmod 0755 ${PHP_EXT_DIR}/blackfire.so

ENTRYPOINT ["/usr/local/docker/run.sh"]
