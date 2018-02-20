# Docker for Magento
[![Build Status](https://travis-ci.org/ajardin/docker-magento.svg?branch=master)](https://travis-ci.org/ajardin/docker-magento)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/18bac8535a8c4e5fb5754d6cb7853a75)](https://www.codacy.com/app/ajardin/docker-magento?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ajardin/docker-magento&amp;utm_campaign=Badge_Grade)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This repository allows the creation of a Docker environment that meets [Magento 1](http://devdocs.magento.com/guides/m1x/system-requirements.html) requirements.

## Architecture
* `apache`: [PHP 5.6 version](https://github.com/ajardin/docker-magento/blob/master/web/Dockerfile) with Apache (web server).
* `blackfire`: [blackfire/blackfire:latest](https://hub.docker.com/r/blackfire/blackfire/) image (application profiling).
* `maildev`: [djfarrelly/maildev:latest](https://hub.docker.com/r/djfarrelly/maildev/) image (emails debugging).
* `mongo`: [mongo:latest](https://hub.docker.com/_/mongo/) image (additional database).
* `mysql`: [percona:5.6](https://hub.docker.com/_/percona/) image (Magento database).
* `nginx` : [nginx:latest](https://hub.docker.com/_/nginx/) image (HTTPS support).
* `redis`: [redis:latest](https://hub.docker.com/_/redis/) image (Magento caches).

## Additional Features
Since this environment is designed for a local usage, it comes with features helping the development workflow.

### Apache/PHP
The `apache` container has a mount point used to share source files.
By default, the `~/www/` directory is mounted from the host. It's possible to change this path by editing the `docker-compose.yml` file.

It's also possible to add custom virtual hosts: all `./apache/vhosts/*.conf` files are copied in the Apache directory during the image build process.

And the `./apache/custom.ini` file is used to customize the PHP configuration during the image build process. 

### Percona
The `./mysql/custom.cnf` file is used to customize the MySQL configuration during the image build process.

## Installation
This process assumes that [Docker Engine](https://www.docker.com/docker-engine) and [Docker Compose](https://docs.docker.com/compose/) are installed.
Otherwise, you should have a look to [Install Docker Engine](https://docs.docker.com/engine/installation/) before proceeding further.

### Clone the repository
```bash
$ git clone git@github.com:ajardin/docker-magento.git magento1
```
It's also possible to download it as a [ZIP archive](https://github.com/ajardin/docker-magento/archive/master.zip).

### Define the environment variables
```bash
$ cp docker-env.dist docker-env
$ nano docker-env
```

### Build the environment
```bash
$ docker-compose up -d
```

### Check the containers
```bash
$ docker-compose ps
        Name                      Command               State                    Ports
--------------------------------------------------------------------------------------------------------
magento1_apache_1      docker-custom-entrypoint a ...   Up      80/tcp
magento1_blackfire_1   blackfire-agent                  Up      8707/tcp
magento1_maildev_1     bin/maildev --web 80 --smtp 25   Up      25/tcp, 0.0.0.0:1080->80/tcp
magento1_mongo_1       docker-entrypoint.sh mongod      Up      0.0.0.0:27017->27017/tcp
magento1_mysql_1       docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp
magento1_nginx_1       docker-custom-entrypoint n ...   Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
magento1_redis_1       docker-entrypoint.sh redis ...   Up      6379/tcp
```
Note: You will see something slightly different if you do not clone the repository in a `magento1` directory.
The container prefix depends on your directory name.
