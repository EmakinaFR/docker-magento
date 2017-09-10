FROM debian:jessie

MAINTAINER Alexandre JARDIN <aja@emakina.fr>
LABEL maintainer="Alexandre JARDIN <aja@emakina.fr>"

# Install Varnish 4.0 with dependencies
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        automake \
        autotools-dev \
        ca-certificates \
        git \
        libtool \
        libvarnishapi-dev \
        make \
        pkg-config \
        python-docutils \
        varnish=4.0.2-1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure Varnish and libvmod-header
RUN \
    perl -pi -e "s/.host = \".+\"/.host = \"web\"/g; s/.port = \".+\"/.port = \"80\"/g" /etc/varnish/default.vcl && \
    git clone https://github.com/varnish/libvmod-header.git /tmp/libvmod-header && \
    cd /tmp/libvmod-header && git checkout 4.0 && \
    ./autogen.sh && ./configure && make install && \
    rm -rf /tmp/libvmod-header

CMD ["-s", "malloc,512m", "-p", "feature=+esi_disable_xml_check", "-p", "vcc_allow_inline_c=on", "-p", "cli_buffer=32768", "-F"]
ENTRYPOINT ["varnishd", "-a", ":8080", "-T", ":6082", "-f", "/etc/varnish/default.vcl", "-S", "/etc/varnish/secret"]
