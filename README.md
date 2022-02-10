# Docker for Magento
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This repository allows the creation of a Docker environment that meets
[Magento 1](http://devdocs.magento.com/guides/m1x/system-requirements.html) requirements.

:warning: **The `master` branch uses PHP 7.2 which is not compatible with Magento by default. The latest version with
PHP 5.6 is available under the tag [v2.3](https://github.com/EmakinaFR/docker-magento/releases/tag/v2.3) if you do not
plan to upgrade your PHP version.** :warning:

## Architecture
* `apache`: [httpd:2.4-alpine](https://github.com/EmakinaFR/docker-magento/blob/master/apache/Dockerfile) custom image with Apache 2.4 (web server).
* `blackfire`: [blackfire/blackfire:latest](https://hub.docker.com/r/blackfire/blackfire/) image (application profiling).
* `maildev`: [djfarrelly/maildev:latest](https://hub.docker.com/r/djfarrelly/maildev/) image (emails debugging).
* `mongo`: [mongo:3.6](https://store.docker.com/images/mongo) image (additional database).
* `mysql`: [mysql:5.7](https://store.docker.com/images/mysql) image (Magento database).
* `php` : [php:7.2-fpm-alpine](https://github.com/EmakinaFR/docker-magento/blob/master/php/Dockerfile) custom image with PHP-FPM 7.2.
* `redis`: [redis:4-alpine](https://store.docker.com/images/redis) image (Magento session and caches).

## Additional Features
Since this environment is designed for a local usage, it comes with features helping the development workflow.

The `apache` and `php` containers have a mount point used to share source files.
By default, the `~/www/` directory is mounted from the host. It's possible to change this path by editing
the `docker-compose.yml` file.

It's also possible to add custom virtual hosts: all `./apache/vhosts/*.conf` files are copied in the Apache directory
during the image build process.

And the `./php/custom.ini` file is used to customize the PHP configuration during the image build process. 

## Installation
This process assumes that [Docker Engine](https://www.docker.com/docker-engine)
and [Docker Compose](https://docs.docker.com/compose/) are installed.
Otherwise, you should have a look to [Install Docker Engine](https://docs.docker.com/engine/installation/)
before proceeding further.

### Clone the repository
```bash
$ git clone git@github.com:EmakinaFR/docker-magento.git magento1
```
It's also possible to download it as a [ZIP archive](https://github.com/EmakinaFR/docker-magento/archive/master.zip).

### Configure the environment variables (optional)
```bash
$ make env
```

### Build the environment
```bash
$ make install
```

### Check the containers
```bash
$ make ps
        Name                      Command               State              Ports
--------------------------------------------------------------------------------------------
magento1_apache_1      httpd-foreground                 Up      0.0.0.0:443->443/tcp, 80/tcp
magento1_blackfire_1   blackfire-agent                  Up      8707/tcp
magento1_maildev_1     bin/maildev --web 80 --smtp 25   Up      25/tcp, 0.0.0.0:1080->80/tcp
magento1_mongo_1       docker-entrypoint.sh mongod      Up      0.0.0.0:27017->27017/tcp
magento1_mysql_1       docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp
magento1_php_1         docker-custom-entrypoint p ...   Up      9000/tcp
magento1_redis_1       docker-entrypoint.sh redis ...   Up      6379/tcp
```
Note: You will see something slightly different if you do not clone the repository in a `magento1` directory.
The container prefix depends on your directory name.
