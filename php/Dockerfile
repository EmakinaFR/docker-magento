FROM php:7.2-fpm

MAINTAINER Alexandre Jardin <info@ajardin.fr>
LABEL maintainer="Alexandre Jardin <info@ajardin.fr>"

# Install Magento requirements
RUN \
    apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
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
        ssh-client \
        ssmtp && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) \
        bcmath \
        gd \
        intl \
        opcache \
        pdo_mysql \
        soap \
        zip && \
    yes "" | pecl install apcu lzf mongodb redis && \
    docker-php-ext-enable apcu lzf mongodb redis && \
    rm -rf /var/lib/apt/lists/* && \
    perl -pi -e "s/mailhub=mail/mailhub=maildev/" /etc/ssmtp/ssmtp.conf && \
    perl -pi -e "s|;pm.status_path = /status|pm.status_path = /php_fpm_status|g" /usr/local/etc/php-fpm.d/www.conf

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

# Install Phing through PEAR
RUN \
    pear channel-discover pear.phing.info && \
    pear install phing/phing

# Install custom PHP configuration
COPY conf/* /usr/local/etc/php/

# Install custom entrypoint
COPY entrypoint.sh /usr/local/bin/docker-custom-entrypoint
RUN chmod 777 /usr/local/bin/docker-custom-entrypoint
CMD ["php-fpm"]
ENTRYPOINT ["docker-custom-entrypoint"]
