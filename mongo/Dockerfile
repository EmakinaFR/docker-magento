FROM mongo:latest

MAINTAINER Alexandre JARDIN <aja@emakina.fr>

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

ENTRYPOINT ["/usr/local/docker/run.sh"]
