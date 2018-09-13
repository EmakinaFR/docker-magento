# Docker for Magento
[![Build Status](https://travis-ci.org/ajardin/docker-magento.svg?branch=master)](https://travis-ci.org/ajardin/docker-magento)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/18bac8535a8c4e5fb5754d6cb7853a75)](https://www.codacy.com/app/ajardin/docker-magento?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ajardin/docker-magento&amp;utm_campaign=Badge_Grade)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This repository allows a docker environment where run a [Magento 1](http://devdocs.magento.com/guides/m1x/system-requirements.html).

## Containers used
* `apache`: [httpd:2.4](https://github.com/ajardin/docker-magento/blob/master/apache/Dockerfile) custom image with Apache (web server).
* `blackfire`: [blackfire/blackfire:latest](https://hub.docker.com/r/blackfire/blackfire/) image (application profiling).
* `maildev`: [djfarrelly/maildev:latest](https://hub.docker.com/r/djfarrelly/maildev/) image (emails debugging).
* `mongo`: [mongo:latest](https://hub.docker.com/_/mongo/) image (additional database).
* `mysql`: [mysql:5.7](https://hub.docker.com/_/mysql/) image (Magento database).
* `php` : [php:7.2-fpm](https://github.com/ajardin/docker-magento/blob/master/php/Dockerfile) custom image with PHP-FPM.
* `redis`: [redis:latest](https://hub.docker.com/_/redis/) image (Magento session and caches).


## Installation on Mac
### Installation of Docker for Mac
Follow the instructions from [https://docs.docker.com/docker-for-mac/](https://docs.docker.com/docker-for-mac/)

### Getting the repository
```bash
~/docker » git clone https://github.com/ajardin/docker-magento.git
```
If your project run with php 5, you must checkout on the `v2.3` branch.

### Configuration of the environment variables
```bash
~/docker/docker-magento(2.3) »  make env s
```
In the editor, define your constants as you wish :
```
##### MYSQL
MYSQL_ALLOW_EMPTY_PASSWORD=1
MYSQL_ROOT_PASSWORD=yoursuperpassword
MYSQL_USER=youruser
MYSQL_PASSWORD=yoursuperpassword
MYSQL_DATABASE=
```

### Creation of custom vhosts
In  `~/docker/docker-magento/apache/vhosts/yourconfiguration.conf`, set :
```
<VirtualHost *:443>
	ServerName      www.yoursuperdomain.localhost
	ServerAlias     yoursuperdomain.localhost *.yoursuperdomain.localhost
	DocumentRoot    /var/www/html/yoursuperdomain
</VirtualHost>
```

### Building of the environment
```bash
~/docker/docker-magento(2.3) »  make install 
```

### Management of ssh keys
Put in your `~/.ssh` the rsa keys which will be used in your project.

Then :
```bash
~/docker/docker-magento(2.3) » make ssh
```

### Creation of the files system
Put in your `~/www/yoursuperdomain` all your project files.

Then, probably you use composer so :
```bash
~/www/yoursuperdomain » composer install
```

### Creation of the database
Import your database from a .tar file :
```
/path/to/folder_which_contains_the_tar » docker run --rm --volumes-from docker-magento_mysql_1 -v "$(pwd)":/backup busybox sh -c "tar xvf /backup/backup.tar var/lib/mysql/"
```
This tip come from the blog of [Alexandre Jardin](https://ajardin.fr/2018/01/31/docker-localhost/)

*Note :*
The backup.tar have been created with the command :
```
/path/to/folder_which_contains_the_tar » docker run --rm --volumes-from docker-magento_mysql_1 -v "$(pwd)":/backup busybox sh -c "tar cvf /backup/backup.tar /var/lib/mysql"
```

### Configure the database in Magento
Configure the file `~/www/yoursuperdomain/app/etc/local.xml` with the constants set in the `Configuration of the environment variables` step.

### Creation of host on Mac
Put in your `~/etc/hosts` :

```bash
127.0.0.1 yoursuperdomain.localhost
```

### Restarting of the containers
```bash
~/docker/docker-magento(2.3) » make restart
```
		
### Checking of the containers
```bash
$ make ps
        Name                      Command               State              Ports
--------------------------------------------------------------------------------------------
docker-magento_apache_1      httpd-foreground                 Up      0.0.0.0:443->443/tcp, 80/tcp
docker-magento_blackfire_1   blackfire-agent                  Up      8707/tcp
docker-magento_maildev_1     bin/maildev --web 80 --smtp 25   Up      25/tcp, 0.0.0.0:1080->80/tcp
docker-magento_mongo_1       docker-entrypoint.sh mongod      Up      0.0.0.0:27017->27017/tcp
docker-magento_mysql_1       docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp
docker-magento_php_1         docker-custom-entrypoint p ...   Up      9000/tcp
docker-magento_redis_1       docker-entrypoint.sh redis ...   Up      6379/tcp
```

### Done!
Go to `https://www.yoursuperdomain.localhost`
