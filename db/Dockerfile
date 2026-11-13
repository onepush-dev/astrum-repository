# Postgres 16 for Astrum Repository (Astrum supports 16+; it creates the astrum schema and pg_trgm itself).
# Plain defaults are baked in because Railway templates only keep references and secrets.
FROM postgres:16-bookworm@sha256:5264710be20f409750ac6dc4e5706dcef929c87e241605463f0f9aefa932a8d9
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/astrum-repository"
ENV POSTGRES_USER=astrum \
    POSTGRES_DB=astrum \
    PGDATA=/var/lib/postgresql/data/pgdata
