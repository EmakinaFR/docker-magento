FROM php-zendserver:8.5-php5.6

MAINTAINER Alexandre JARDIN <aja@emakina.fr>
LABEL maintainer "Alexandre JARDIN <aja@emakina.fr>"

RUN apt-get update \
    && apt-get install -y autoconf nano ssmtp \
    && yes "" | /usr/local/zend/bin/pecl install mongo \
    && rm -rf /var/lib/apt/lists/* \
    && echo "mailhub=mailcatcher:1025\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

ENV PATH=/usr/local/zend/bin:$PATH

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

ENTRYPOINT ["/usr/local/docker/run.sh"]
