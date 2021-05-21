FROM debian:stable-slim
LABEL maintainer="Joshua Sierles joshua@hey.com"

ARG FLY_ACCESS_TOKEN
ARG LOGDNA_TOKEN

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ADD rootfs /

ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

RUN apt-get update \
    && apt-get install -y gnupg curl wget git \
    && tar xzf /tmp/s6overlay.tar.gz -C / \
    && rm /tmp/s6overlay.tar.gz

RUN echo "deb https://repo.logdna.com stable main" | tee /etc/apt/sources.list.d/logdna.list
RUN wget -O- https://repo.logdna.com/logdna.gpg | apt-key add -
RUN apt-get update && apt-get install -y logdna-agent < "/dev/null"

RUN curl -L https://fly.io/install.sh | sh
RUN echo "access_token: ${FLY_ACCESS_TOKEN}" > /root/.fly/config.yml
RUN mkdir -p /etc/s6/services/fly-log /etc/s6/services/fly-log/log /var/log/fly && chmod 777 /var/log/fly
RUN mkdir -p /etc/s6/services/logdna-agent
COPY run-fly-log /etc/s6/services/fly-log/run
COPY log-fly-log /etc/s6/services/fly-log/log/run
COPY run-logdna-agent /etc/s6/services/logdna-agent/run

# Init
ENTRYPOINT [ "/init" ]
