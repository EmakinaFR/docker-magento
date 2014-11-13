#!/bin/bash

service mysql start
mongod --fork --smallfiles --logpath /var/log/mongodb.log
