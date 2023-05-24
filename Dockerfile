ARG S6_ARCH
FROM oznu/s6-alpine:3.13-${S6_ARCH:-amd64}

RUN apk add --no-cache jq curl bind-tools

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 API=https://dns.hetzner.com/api/v1 RRTYPE=A TTL=86400 CRON="*/5	*	*	*	*"

COPY root /