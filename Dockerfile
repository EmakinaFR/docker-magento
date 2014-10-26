FROM ubuntu:14.04

MAINTAINER Alexandre JARDIN

COPY ./run /usr/local/bin/run
RUN chmod 777 /usr/local/bin/run

########## Zend Server installation - START ##########
RUN apt-key adv --keyserver pgp.mit.edu --recv-key 799058698E65316A2E7A4FF42EAE1437F7D2C623
RUN echo "deb http://repos.zend.com/zend-server/7.0/deb_apache2.4 server non-free" >> /etc/apt/sources.list.d/zend-server.list
RUN apt-get update && apt-get install -y zend-server-php-5.5 && /usr/local/zend/bin/zendctl.sh stop
########## Zend Server installation - END ##########

EXPOSE 80
EXPOSE 10081

CMD ["/usr/local/bin/run"]
