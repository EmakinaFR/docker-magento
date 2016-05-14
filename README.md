Docker for LAMP Server [![Build Status](https://travis-ci.org/aureliengiry/docker-lamp.svg?branch=master)](https://travis-ci.org/aureliengiry/docker-lamp)
======================

## Architecture

Here are the environment containers:

* `web`: This is the Apache/PHP server container (in which the application volume is mounted),
* `mysql`: This is the MySQL (mariaDB) server container
* `blackfire`: This is the Blackfire container (used for profiling the application).
* `nodejs`: This is the Node JS container.