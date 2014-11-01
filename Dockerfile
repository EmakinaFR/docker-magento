FROM ubuntu:14.04

MAINTAINER Alexandre JARDIN

COPY ./run /usr/local/bin/run
RUN chmod 777 /usr/local/bin/run
COPY ./vhosts /usr/local/bin/vhosts

########## Zend Server installation - START ##########
RUN apt-key adv --keyserver pgp.mit.edu --recv-key 799058698E65316A2E7A4FF42EAE1437F7D2C623
RUN echo "deb http://repos.zend.com/zend-server/8.0.0-beta/deb_apache2.4 server non-free" >> /etc/apt/sources.list.d/zend-server.list
RUN apt-get update && apt-get install -q -y zend-server-php-5.6 && /usr/local/zend/bin/zendctl.sh stop
########## Zend Server installation - END ##########

########## Varnish installation - START ##########
RUN apt-get install -y apt-transport-https curl
RUN curl https://repo.varnish-cache.org/ubuntu/GPG-key.txt | apt-key add -
RUN echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list
RUN apt-get update && apt-get install -q -y varnish
########## Varnish installation - END ##########

EXPOSE 80
EXPOSE 8080
EXPOSE 10081
EXPOSE 10082
EXPOSE 10083

CMD ["/usr/local/bin/run"]
