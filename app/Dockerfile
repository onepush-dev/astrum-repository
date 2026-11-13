# Astrum Repository on Railway: official image, unmodified binary and web UI, plus a small start wrapper.
# Railway changes only: listens on 8080 (the port Railway injects and health-checks), chowns the root-owned
# Railway volume before dropping to the image's own uid 200, waits for Postgres, and on the very first boot
# replaces the random first admin password with ASTRUM_ADMIN_PASSWORD (a per-deploy generated secret), so the
# password is readable in the Railway Variables tab instead of only inside the container.
FROM docker.io/globalartltd/astrum-repository:20261111211020-bea3c1a
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/astrum-repository"
USER 0
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod +x /usr/local/bin/railway-start.sh
ENV ASTRUM_DATA_DIR=/astrum-data \
    ASTRUM_LISTEN=0.0.0.0:8080 \
    ASTRUM_WEB_DIR=/usr/share/astrum/web \
    ASTRUM_LOG_FORMAT=text
EXPOSE 8080
HEALTHCHECK NONE
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD []
