FROM alpine:3.20

ARG VERSION

RUN apk --no-cache add unbound=$VERSION su-exec ca-certificates dns-root-hints
ADD etc/ /etc/unbound/
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]