# Tempo Security Exception

## Component

`grafana/tempo:2.10.7`

Digest:

`sha256:032b3acb51ed02c4b801473d54bb63e9e9f13738d215126d9843c30283794f4b`

## Upgrade decision

Tempo was upgraded from `2.8.2` to `2.10.7`.

Tempo `2.8.2` was rejected because its image contained:

- 2 Critical vulnerabilities
- 37 High vulnerabilities

Tempo `2.10.7` was selected because:

- its embedded binary reports version `v2.10.7`
- the existing Bema Tempo configuration validates successfully
- it preserves the existing Tempo 2.x single-binary architecture
- it has no Critical vulnerabilities
- it removes the Tempo-specific vulnerabilities found in older releases

Tempo 3.x was not selected because it replaces the Tempo 2.x ingestion
architecture with Kafka-backed ingestion, live-store, block-builder,
backend-scheduler, and backend-worker components. That is an architecture
migration and is outside the scope of container image license review.

## Remaining vulnerabilities

The following findings remain in the upstream Tempo binary:

### CVE-2026-27145

- Package: Go standard library
- Installed version: Go `1.26.3`
- Fixed version: Go `1.26.4`
- Severity: HIGH
- Category: excessive processing of DNS SAN entries

### CVE-2026-39822

- Package: Go standard library
- Installed version: Go `1.26.3`
- Fixed version: Go `1.26.5`
- Severity: HIGH
- Category: symlink-following vulnerability in `os.Root`

### CVE-2026-42504

- Package: Go standard library
- Installed version: Go `1.26.3`
- Fixed version: Go `1.26.4`
- Severity: HIGH
- Category: denial of service through malicious MIME headers

## Assessment

The remaining vulnerabilities are compiled into the upstream Tempo binary.

No later compatible Tempo 2.x image with the required Go fixes was available
during this review.

Tempo is an internal observability component and is not exposed directly to
the public internet.

A downstream Tempo fork is not maintained solely to rebuild the binary with a
newer Go patch release.

## Mitigation

- exact Tempo version pinned
- image digest pinned
- no direct public exposure
- existing configuration validated against the selected image
- no cloud object-storage credentials are configured
- monitor upstream Tempo releases
- upgrade when a compatible image built with fixed Go versions is available

## Review

Review on every Tempo release or within 30 days.
