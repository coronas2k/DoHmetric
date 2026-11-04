FROM debian:12-slim

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        bind9-dnsutils \
        ca-certificates \
        curl \
        python3 \
    && useradd --create-home --shell /usr/sbin/nologin dohmetric

COPY --chmod=755 dohmetric /usr/local/bin/dohmetric

USER dohmetric

ENTRYPOINT ["dohmetric"]
