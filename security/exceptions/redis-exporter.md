# Redis Exporter Security Exception

## Component

`oliver006/redis_exporter:v1.86.0`

Digest:

`sha256:2e9795be900db073e9475fdb9c5124db309b07a3e4e75a1770705cb03be1a1c8`

## Remaining vulnerability

- CVE: `CVE-2026-39822`
- Package: Go standard library
- Installed version: Go `1.26.4`
- Fixed version: Go `1.26.5`
- Severity: HIGH

## Assessment

The vulnerability exists in the upstream `redis_exporter` binary.

No newer upstream image containing the fix is currently available.

The exporter is used only inside Bema's internal observability network and is not exposed directly to the public internet.

A downstream fork is not maintained solely to rebuild this infrastructure component against a newer Go patch release.

## Mitigation

- Exact image version pinned.
- Image digest pinned.
- Internal Docker network only.
- No direct public exposure.
- Monitor upstream releases.
- Upgrade immediately when upstream publishes a rebuilt image.

## Review

Review on every dependency update or within 30 days.
