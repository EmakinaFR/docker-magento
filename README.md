# Docker for Magento [![Build Status](https://travis-ci.org/ajardin/docker-magento.svg?branch=master)](https://travis-ci.org/ajardin/docker-magento)
This repository allows the creation of a Docker environment that meets [Magento 1](http://devdocs.magento.com/guides/m1x/system-requirements.html) requirements.

## Architecture
* `mongo`: This container uses the [mongo:latest](https://hub.docker.com/_/mongo/) image.
* `percona`: This container uses the [percona:5.6](https://hub.docker.com/_/percona/) image.
* `redis`: This container uses the [redis:latest](https://hub.docker.com/_/redis/) image.
* `varnish`: This container uses a custom [3.0.5 version](https://github.com/ajardin/docker-magento/blob/master/varnish/Dockerfile).
* `web`: This container uses a custom [PHP 5.6 version](https://github.com/ajardin/docker-magento/blob/master/web/Dockerfile).

## Additional Features
Since this environment is designed for a local usage, it comes with features helping the development workflow.

### Zend Server
The `web` container has a mount point used to share source files.
By default, the `~/www/` directory is mounted from the host. It's possible to change this path by editing the `docker-compose.yml` file.

It's also possible to create multiple virtual hosts during the container creation.
All `./web/extra/*.dev` files will be sent to the Zend Server API. Only two things to keep in mind:
- the filename must be the exact domain you want to create and the top-level domain must be `.dev`.
- the content must be the exact format used by Zend Server.

### Percona
The `./docker/percona/` directory is mounted as `/etc/mysql/conf.d/`, thus it's possible to modify the MySQL configuration from your host.
By creating a `custom.cnf` file for instance and by restarting the MySQL container when a change is made.

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
       Name                     Command               State                                                      Ports
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
magento1_mongo_1     /entrypoint.sh mongod            Up      0.0.0.0:27017->27017/tcp
magento1_percona_1   docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp
magento1_redis_1     docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
magento1_varnish_1   varnishd -a :8080 -T :6082 ...   Up      0.0.0.0:6082->6082/tcp, 0.0.0.0:80->8080/tcp
magento1_web_1       /usr/local/docker/run.sh         Up      0.0.0.0:10081->10081/tcp, 0.0.0.0:10082->10082/tcp, 0.0.0.0:10083->10083/tcp, 443/tcp, 0.0.0.0:8080->80/tcp
```
Note: You will see something slightly different if you do not clone the repository in a `magento1` directory.
The container prefix depends on your directory name.
