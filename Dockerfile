FROM alpine:3.20.0
COPY entrypoint /entrypoint
ENTRYPOINT ["/entrypoint"]
