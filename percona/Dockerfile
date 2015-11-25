FROM percona:latest

MAINTAINER Alexandre JARDIN <aja@emakina.fr>

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN apt-get update && apt-get install -y vim pv

ENTRYPOINT ["/usr/local/docker/run.sh"]
