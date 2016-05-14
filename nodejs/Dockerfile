FROM ubuntu:14.04

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN apt-get update && apt-get install -y \
        nodejs \
        npm \
        vim

RUN npm install socket.io
RUN npm install forever -g
RUN npm install forever-monitor

ENTRYPOINT ["/usr/local/docker/run.sh"]
