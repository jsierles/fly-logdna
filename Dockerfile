FROM debian:stable-slim
LABEL maintainer="Joshua Sierles joshua@hey.com"

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ADD rootfs /

ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

RUN apt-get update \
    && apt-get install -y bc curl \
    && tar xzf /tmp/s6overlay.tar.gz -C / \
    && rm /tmp/s6overlay.tar.gz

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.vector.dev > install.sh && sh install.sh -y
RUN curl -L https://fly.io/install.sh | sh

RUN mkdir -p /etc/s6/services/fly-log /etc/s6/services/fly-log/log /var/log/fly /etc/s6/services/vector /var/lib/vector \
     && chmod 777 /var/log/fly

COPY run-fly-log /etc/s6/services/fly-log/run
COPY log-fly-log /etc/s6/services/fly-log/log/run
COPY run-vector /etc/s6/services/vector/run
COPY vector.toml /etc/vector/vector.toml

# Init
ENTRYPOINT [ "/init" ]
