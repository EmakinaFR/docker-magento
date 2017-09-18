# Docker for Magento [![Build Status](https://travis-ci.org/ajardin/docker-magento.svg?branch=master)](https://travis-ci.org/ajardin/docker-magento)
This repository allows the creation of a Docker environment that meets [Magento 1](http://devdocs.magento.com/guides/m1x/system-requirements.html) requirements.

## Architecture
* `web`: [PHP 5.6 version](https://github.com/ajardin/docker-magento/blob/master/web/Dockerfile) with Apache.
* `blackfire`: [blackfire:latest](https://hub.docker.com/r/blackfire/blackfire/) image.
* `mailcatcher`: [schickling/mailcatcher:latest](https://hub.docker.com/r/schickling/mailcatcher/) image.
* `mysql`: [percona:5.6](https://hub.docker.com/_/percona/) image.
* `mongo`: [mongo:latest](https://hub.docker.com/_/mongo/) image.
* `redis`: [redis:latest](https://hub.docker.com/_/redis/) image.
* `varnish`: [4.0.2 version](https://github.com/ajardin/docker-magento/blob/master/varnish/Dockerfile) with libvmod-header.

## Additional Features
Since this environment is designed for a local usage, it comes with features helping the development workflow.

### Apache/PHP
The `web` container has a mount point used to share source files.
By default, the `~/www/` directory is mounted from the host. It's possible to change this path by editing the `docker-compose.yml` file.

It's also possible to add custom virtual hosts: all `./web/vhosts/*.conf` files are copied in the Apache directory during the image build process.

And the `./web/custom.ini` file is used to customize the PHP configuration during the image build process. 

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
         Name                       Command               State                      Ports
--------------------------------------------------------------------------------------------------------------
magento1_blackfire_1     blackfire-agent                  Up      0.0.0.0:8707->8707/tcp
magento1_mailcatcher_1   mailcatcher -f --ip=0.0.0.0      Up      1025/tcp, 0.0.0.0:1080->1080/tcp
magento1_mongo_1         docker-entrypoint.sh mongod      Up      0.0.0.0:27017->27017/tcp
magento1_mysql_1         docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp
magento1_redis_1         docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
magento1_varnish_1       varnishd -a :8080 -T :6082 ...   Up      0.0.0.0:6082->6082/tcp, 0.0.0.0:80->8080/tcp
magento1_web_1           docker-custom-entrypoint         Up      0.0.0.0:8080->80/tcp
```
Note: You will see something slightly different if you do not clone the repository in a `magento1` directory.
The container prefix depends on your directory name.
