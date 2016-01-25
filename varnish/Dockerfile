FROM ubuntu:latest

MAINTAINER Alexandre JARDIN <aja@emakina.fr>

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN apt-get update -qq && \
  apt-get upgrade -yqq && \
  apt-get -yqq install varnish=3.0.5-2 && \
  apt-get -yqq clean

# Make our custom VCLs available on the container
ADD default.vcl /etc/varnish/default.vcl

ENV VARNISH_BACKEND_PORT 8080
ENV VARNISH_BACKEND_IP web
ENV VARNISH_PORT 80

# Expose port 80
EXPOSE 80

# Expose volumes to be able to use data containers
VOLUME ["/var/lib/varnish", "/etc/varnish"]

RUN apt-get update && apt-get install -y \
    automake \
    autotools-dev \
    apt-transport-https \
    curl \
    dpkg-dev \
    git \
    libedit-dev \
    libjemalloc-dev \
    libncurses-dev \
    libpcre3-dev \
    libtool \
    libvarnishapi-dev \
    make \
    pkg-config \
    python-docutils \
    python-sphinx \
    graphviz

RUN \
    apt-get source varnish=3.0.5 && cd /varnish-3.0.5 && ./autogen.sh && ./configure && make && \
    git clone https://github.com/varnish/libvmod-header.git /varnish-libvmod && cd /varnish-libvmod && git checkout 3.0 && \
    ./autogen.sh && ./configure VARNISHSRC=/varnish-3.0.5 && make && make install && \
    cd && rm -rf /varnish*

ENTRYPOINT ["/usr/local/docker/run.sh"]
