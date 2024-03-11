ARG S6_ARCH
FROM --platform=${S6_ARCH:-amd64} ghcr.io/crazy-max/alpine-s6:3.19

RUN apk add --no-cache jq curl bind-tools

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 API=https://dns.hetzner.com/api/v1 RRTYPE=A TTL=86400 CRON="*/5	*	*	*	*"

COPY root /

RUN chmod +x /etc/services.d/crond/run
RUN chmod +x /etc/cont-init.d/30-hetzner-setup
RUN chmod +x /etc/cont-init.d/50-ddns
RUN chmod +x /etc/cont-finish.d/50-remove-record