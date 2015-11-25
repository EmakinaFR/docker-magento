FROM ubuntu:14.04

MAINTAINER Aurélien GIRY <aurelien.giry@gmail.com>

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN apt-get update && apt-get install -y \
    apache2 \
    php5 \
    libapache2-mod-php5 \
    build-essential

RUN apt-get update && apt-get install -y autoconf \
    cron \
    curl \
    make \
    vim  \
    php5-xdebug \
    php5-cli \
    php5-json \
    php5-curl \
    php-pear \
    php5-dev \
    php5-intl \
    php-apc \
    php5-gmp \
    php5-sqlite \
    php5-mysql \
    php5-gd \
    mysql-client

RUN apt-get update && apt-get install -y python-pip \
    python-dev

RUN pip install --upgrade pip virtualenv Sphinx

RUN \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install phpunit
RUN apt-get install -y -f phpunit

RUN echo 'date.timezone = Europe/Paris' >> /etc/php5/cli/php.ini
RUN echo 'date.timezone = Europe/Paris' >> /etc/php5/apache2/php.ini

RUN pecl update-channels

RUN \
    export PHP_VERSION=`/usr/bin/php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"` && \
    curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${PHP_VERSION} && \
    export PHP_EXT_DIR=`/usr/bin/php -r "echo ini_get('extension_dir');"` && \
    tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp && mv /tmp/blackfire-*.so ${PHP_EXT_DIR}/blackfire.so && \
    chown root ${PHP_EXT_DIR}/blackfire.so && chown :root ${PHP_EXT_DIR}/blackfire.so && chmod 0755 ${PHP_EXT_DIR}/blackfire.so

RUN usermod -u 1000 www-data

ENTRYPOINT ["/usr/local/docker/run.sh"]
