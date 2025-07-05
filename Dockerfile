# Dockerfile
# 1. Build Caddy with the duckdns DNS plugin
FROM caddy:2-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/duckdns

# 2. Copy the custom-built caddy into a slim runtime image
FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
