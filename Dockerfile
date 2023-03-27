FROM debian:bullseye

ARG DEBIAN_FRONTEND=noninteractive
ENV XDG_DATA_HOME=/config XDG_CONFIG_HOME=/config
ENV TZ=America/Los_Angeles

RUN apt-get update && apt-get install -y curl gpg apt-transport-https && \
    echo "deb https://deb.torproject.org/torproject.org bullseye main" | tee -a /etc/apt/sources.list && \
    echo "deb-src https://deb.torproject.org/torproject.org bullseye main" | tee -a /etc/apt/sources.list && \
    curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import && \
    gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add - && \
    apt-get update && apt-get install -y python3-pip tor deb.torproject.org-keyring && \
    pip install nyx && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 9001 9030
ENV RELAY_TYPE=relay
ENV TOR_ORPort=9001
ENV TOR_DirPort=9030
ENV TOR_DataDirectory=/data
ENV TOR_ContactInfo="Random Person nobody@tor.org"
ENV TOR_RelayBandwidthRate="100 KBytes"
ENV TOR_RelayBandwidthBurst="200 KBytes"

COPY torrc.bridge.default /config/torrc.bridge.default
COPY torrc.relay.default /config/torrc.relay.default
COPY torrc.exit.default /config/torrc.exit.default
COPY entrypoint.sh /entrypoint.sh

RUN chmod ugo+rx /entrypoint.sh && \
    mkdir /data && \
    mkdir /var/run/tor && \
    groupadd -g 1000 appuser && \
    useradd -m -u 1000 -g 1000 -s /bin/bash appuser && \
    chown appuser:appuser /config /var/run/tor /data

USER appuser
VOLUME /data

ENTRYPOINT ["/entrypoint.sh"]