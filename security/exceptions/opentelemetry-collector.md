# OpenTelemetry Collector Security Exception

## Component

`otel/opentelemetry-collector:0.156.0`

Digest:

`sha256:0beba82d63792511591522a8d582904b9a8ae81710357bfcab731607b8b0ffe2`

License:

Apache License 2.0

## Remaining vulnerability

- CVE: `CVE-2026-39822`
- Package: Go standard library
- Installed version: Go `1.26.4`
- Fixed version: Go `1.26.5`
- Severity: HIGH
- Category: symlink-following vulnerability in `os.Root`

## Upstream status

The exact `0.156.0` release and the current `latest` tag resolve to the same
image digest.

No `0.156.1` image is currently available.

The vulnerability is compiled into the upstream Collector executable and
cannot be removed through operating-system package upgrades.

## Assessment

The OpenTelemetry Collector is an internal observability component.

It is not intended for direct public internet exposure.

Maintaining a downstream fork solely to rebuild this infrastructure component
against a newer Go patch version would create additional maintenance and
supply-chain ownership.

## Mitigation

- exact version pinned
- image digest pinned
- internal Docker networking
- no direct public exposure
- upstream Apache-2.0 license recorded
- monitor upstream Collector releases
- upgrade when an official image built with Go 1.26.5 or later is available

## Review

Review on every OpenTelemetry Collector release or within 30 days.
