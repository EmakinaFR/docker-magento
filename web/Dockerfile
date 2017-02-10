FROM php:5.6-apache

MAINTAINER Alexandre JARDIN <aja@emakina.fr>
LABEL maintainer "Alexandre JARDIN <aja@emakina.fr>"

# Magento requirements
RUN apt-get update \
    && apt-get install -y \
        autoconf \
        libicu-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libpng-dev \
        libssl-dev \
        libxml2-dev \
        libxml2-utils \
        ssmtp \
        wget \
    && docker-php-ext-install -j$(nproc) \
        gd \
        hash \
        intl \
        mcrypt \
        opcache \
        pdo_mysql \
        soap \
        zip \
    && yes "" | pecl install mongo \
    && docker-php-ext-enable mongo \
    && rm -rf /var/lib/apt/lists/* \
    && echo "mailhub=mailcatcher:1025\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

# Blackfire extension
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && docker-php-ext-enable blackfire

# Blackfire agent
RUN wget -O - https://packagecloud.io/gpg.key | apt-key add - \
    && echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list \
    && apt-get update \
    && apt-get install -y blackfire-agent

# Add custom PHP configuration
COPY custom.ini /usr/local/etc/php/conf.d/

# Enable custom virtual hosts
COPY vhosts /etc/apache2/sites-available
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf \
    && a2ensite $(find /etc/apache2/sites-available/ -type f -name '*.conf' -not -name '*default*' -printf '%f\n') \
    && a2enmod rewrite \
    && ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

COPY entrypoint.sh /usr/local/bin/docker-custom-entrypoint
ENTRYPOINT ["docker-custom-entrypoint"]
