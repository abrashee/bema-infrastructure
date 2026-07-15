# postgres-exporter Security Exception

## Component

prometheuscommunity/postgres-exporter:v0.20.1

Digest:

sha256:ac5ec343104fae0e2d84a27bb8d69b38430a11910c5382cad85d478d2bab713e

## Remaining vulnerability

CVE-2026-39822

Package:

Go standard library

Installed:

Go 1.26.4

Fixed:

Go 1.26.5

Severity:

HIGH

## Assessment

This vulnerability exists in the upstream postgres-exporter binary.

No newer upstream image is currently available.

The exporter is used only inside the observability network.

It is not internet-facing.

No custom rebuild is performed to avoid maintaining a downstream fork of an infrastructure component.

## Mitigation

- image pinned by digest
- internal Docker network only
- no public exposure
- monitor upstream releases
- upgrade immediately when upstream publishes a rebuilt image

## Review

Review on every dependency update or within 30 days.
