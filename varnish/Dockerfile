FROM ubuntu:trusty

MAINTAINER Alexandre JARDIN <aja@emakina.fr>
LABEL maintainer "Alexandre JARDIN <aja@emakina.fr>"

RUN apt-get update \
    && apt-get install -y \
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
        python-sphinx \
        varnish=3.0.5-2

RUN apt-get source varnish=3.0.5-2 \
    && cd /varnish-3.0.5 && ./autogen.sh && ./configure && make \
    && git clone https://github.com/varnish/libvmod-header.git /varnish-libvmod && cd /varnish-libvmod && git checkout 3.0 \
    && ./autogen.sh && ./configure VARNISHSRC=/varnish-3.0.5 && make && make install \
    && cd && rm -rf /varnish* \
    && rm -rf /var/lib/apt/lists/* \
    && echo 'backend default { .host = "web"; .port = "80"; }' > /etc/varnish/default.vcl

CMD ["-s", "malloc,512m", "-p", "esi_syntax=0x2", "-p", "cli_buffer=32768", "-F"]
ENTRYPOINT ["varnishd", "-a", ":8080", "-T", ":6082", "-f", "/etc/varnish/default.vcl", "-S", "/etc/varnish/secret"]
