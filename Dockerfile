FROM alpine:3.23

ARG VERSION

RUN apk --no-cache add unbound=$VERSION su-exec ca-certificates dns-root-hints
ADD etc/ /etc/unbound/
ADD entrypoint.sh /entrypoint.sh
HEALTHCHECK --start-period=5s --timeout=5s CMD nslookup google.com 127.0.0.1
ENTRYPOINT ["/entrypoint.sh"]