FROM ubuntu:latest

MAINTAINER Alexandre JARDIN <aja@emakina.fr>

COPY . /usr/local/docker
RUN chmod -R 777 /usr/local/docker

RUN apt-get update && apt-get install -y varnish=3.0.5-2
COPY *.vcl /etc/varnish/

RUN apt-get update && apt-get install -y \
    automake \
    autotools-dev \
    apt-transport-https \
    curl \
    dpkg-dev \
    git \
    graphviz \
    libedit-dev \
    libjemalloc-dev \
    libncurses-dev \
    libpcre3-dev \
    libtool \
    libvarnishapi-dev \
    make \
    pkg-config \
    python-docutils \
    python-sphinx

RUN \
    apt-get source varnish=3.0.5-2 && cd /varnish-3.0.5 && ./autogen.sh && ./configure && make && \
    git clone https://github.com/varnish/libvmod-header.git /varnish-libvmod && cd /varnish-libvmod && git checkout 3.0 && \
    ./autogen.sh && ./configure VARNISHSRC=/varnish-3.0.5 && make && make install && \
    cd && rm -rf /varnish*

ENTRYPOINT ["/usr/local/docker/run.sh"]
