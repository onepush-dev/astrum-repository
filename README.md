# Astrum Repository — self-hosted artifact repository manager (Docker, npm, Maven, Cargo, PyPI, Go proxy and more). Deploy on Railway with one click.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/XrUWW-)

[Astrum Repository](https://github.com/GlobalArtInc/astrum-repository) (MIT, by GlobalArt) is a Rust artifact repository
manager in the spirit of Nexus/Artifactory: hosted, proxy and group repositories for Docker/OCI, npm, Maven, Cargo, PyPI,
Go modules, Hugging Face and more, with users, roles, tokens, cleanup tasks and an audit log.

This repo wraps the official image `docker.io/globalartltd/astrum-repository:20261111211020-bea3c1a` (upstream commit
`bea3c1a`), binary and web UI unmodified, as `ghcr.io/onepush-dev/astrum-repository:20261111211020-bea3c1a`.
Railway-only changes (`app/railway-start.sh`): listen on 8080, chown the Railway volume and drop to the image's uid 200,
wait for Postgres, and on the first boot replace Astrum's random first `admin` password with `ASTRUM_ADMIN_PASSWORD`.

## What the template sets up
- `astrum` (public, port 8080, health check `/service/rest/v1/status`) with a volume at `/astrum-data`
  (default file blob store, `etc/secrets.key`, logs).
- `astrum-db`: Postgres 16 (`ghcr.io/onepush-dev/astrum-repository-db:16`, private, volume `/var/lib/postgresql/data`).
- Generated per deploy: `ASTRUM_ADMIN_PASSWORD` (sign in as `admin`) and `POSTGRES_PASSWORD`. No inputs.

## Using it
1. Open the public domain and sign in as `admin` with `ASTRUM_ADMIN_PASSWORD` from the `astrum` service Variables tab.
2. Create repositories (e.g. a Docker hosted repo, an npm proxy of registry.npmjs.org) under Settings → Repositories.
3. Point clients at `https://<your-domain>/repository/<name>/`. Docker clients use the same domain (HTTPS on 443).

## Notes
- Changing `ASTRUM_ADMIN_PASSWORD` later does nothing: change the password in the UI instead.
- Back up the volume together with the database: `etc/secrets.key` seals the stored secrets.
- Anonymous access is off by default (Astrum's own default). Large blob stores can use S3 instead of the volume.
