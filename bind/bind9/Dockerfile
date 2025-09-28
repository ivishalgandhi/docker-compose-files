FROM ubuntu/bind9:latest

RUN mkdir -p /etc/bind/zones && \
    mkdir -p /var/cache/bind && \
    chown -R bind:bind /etc/bind && \
    chown -R bind:bind /var/cache/bind && \
    mkdir -p /run/named && \
    chown -R bind:bind /run/named

COPY config/named.conf /etc/bind/named.conf
COPY config/named.conf.options /etc/bind/named.conf.options
COPY config/named.conf.local /etc/bind/named.conf.local
COPY config/zones/db.docker.lan /etc/bind/zones/db.docker.lan

# Add entrypoint to ensure runtime dirs/permissions
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
