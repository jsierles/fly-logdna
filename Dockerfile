FROM alpine:3.12.0 AS s6-alpine
LABEL maintainer="Aleksandar Puharic xzero@elite7haers.net"

ARG FLY_ACCESS_TOKEN

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ADD rootfs /

# s6 overlay Download
ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

# Build and some of image configuration
RUN apk upgrade --update --no-cache \
    && apk add curl \
    && rm -rf /var/cache/apk/* \
    && tar xzf /tmp/s6overlay.tar.gz -C / \
    && rm /tmp/s6overlay.tar.gz

RUN curl -L https://fly.io/install.sh | sh
RUN echo "access_token: ${FLY_ACCESS_TOKEN}" > /root/.fly/config.yml
RUN mkdir -p /etc/s6/services/fly-log /etc/s6/services/fly-log/log /var/log/fly && chmod 777 /var/log/fly
COPY run-fly-log /etc/s6/services/fly-log/run
COPY log-fly-log /etc/s6/services/fly-log/log/run
# Init
ENTRYPOINT [ "/init" ]
