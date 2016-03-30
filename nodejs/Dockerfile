FROM node:4-onbuild
# replace this with your application's default port
EXPOSE 8888

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN \
    curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -

RUN \
    apt-get install -y \
        nodejs \
        npm

ENTRYPOINT ["/usr/local/docker/run.sh"]