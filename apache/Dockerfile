FROM php:5.6-apache

MAINTAINER Alexandre Jardin <info@ajardin.fr>
LABEL maintainer="Alexandre Jardin <info@ajardin.fr>"

# Install Magento requirements
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        autoconf \
        git \
        jq \
        libicu-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libpng-dev \
        libssl-dev \
        libxml2-dev \
        libxml2-utils \
        mailutils \
        phing \
        ssh-client \
        ssmtp && \
    docker-php-ext-install -j$(nproc) \
        bcmath \
        gd \
        hash \
        intl \
        mcrypt \
        opcache \
        pdo_mysql \
        soap \
        zip && \
    yes "" | pecl install mongo redis && \
    docker-php-ext-enable mongo redis && \
    rm -rf /var/lib/apt/lists/* && \
    perl -pi -e "s/mailhub=mail/mailhub=maildev/" /etc/ssmtp/ssmtp.conf

# Install Blackfire extension
RUN \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") && \
    curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/"${version}" && \
    tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp && \
    mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so

# Install Composer globally
RUN \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install grunt-cli globally
RUN \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \
    nvm install node && \
    nvm use node && \
    npm install -g grunt-cli

# Install custom Apache configuration
COPY vhosts /etc/apache2/sites-available
RUN \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    a2ensite $(find /etc/apache2/sites-available/ -type f -name "*.conf" -not -name "*default*" -printf "%f\n") && \
    a2enmod headers rewrite && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Install custom PHP configuration
COPY custom.ini /usr/local/etc/php/conf.d/

# Install custom entrypoint
COPY ./entrypoint.sh /usr/local/bin/docker-custom-entrypoint
RUN chmod 777 /usr/local/bin/docker-custom-entrypoint
ENTRYPOINT ["docker-custom-entrypoint"]
