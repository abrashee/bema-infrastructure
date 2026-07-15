# Grafana Security Exception

## Component

`bema-grafana:13.1.0-hardened`

Upstream base:

`grafana/grafana:13.1.0@sha256:121a7a9ece6dc10b969f1f96eed64b4f07dfac0d0b8abc070f7cb83bbde86f63`

License:

AGPL-3.0-only

## Hardening performed

The upstream Grafana image was wrapped in a version-controlled Dockerfile.

The wrapper:

- pins Grafana `13.1.0` by SHA-256 digest
- upgrades available Alpine packages
- removes the unused bundled Elasticsearch data-source plugin
- removes the unused bundled Zipkin data-source plugin
- retains the upstream non-root Grafana user
- does not modify the Grafana executable
- does not add runtime packages

Bema configuration was searched before plugin removal. Neither the Elasticsearch
nor Zipkin data source is configured or used by Bema.

## Vulnerability reduction

Original upstream image scan:

- Critical: 0
- High: 49
- Medium: 27
- Low: 4
- Unknown: 3

Final hardened image scan:

- Critical: 0
- High: 3
- Medium: 3
- Low: 1
- Unknown: 3

## Remaining vulnerabilities

The remaining High findings are compiled into the upstream Grafana executable.

### CVE-2026-21728

- Package: `github.com/grafana/tempo`
- Installed version: `v1.5.1-0.20260427112133-525d1bab07e0`
- Fixed versions: `2.8.4`, `2.9.2`, `2.10.2`
- Severity: HIGH
- Category: denial of service through large Tempo queries

### CVE-2026-28377

- Package: `github.com/grafana/tempo`
- Installed version: `v1.5.1-0.20260427112133-525d1bab07e0`
- Fixed version: `2.10.3`
- Severity: HIGH
- Category: possible S3 encryption-key disclosure through a Tempo status configuration endpoint

### CVE-2026-39822

- Package: Go standard library
- Installed version: Go `1.26.4`
- Fixed versions: Go `1.25.12`, `1.26.5`, or later
- Severity: HIGH
- Category: symlink-following vulnerability in `os.Root`

## Assessment

The remaining findings cannot be removed through Alpine package upgrades or
removal of unused bundled plugins because they are compiled into the upstream
Grafana executable.

No Grafana `13.1.1` image was available during this review.

Bema does not configure Grafana with S3 encryption credentials.

Grafana is an internal observability component and is not intended for direct
public internet exposure.

Maintaining a downstream Grafana source fork solely to rebuild the executable
would add substantial long-term maintenance and supply-chain responsibility.

## Mitigation

- exact upstream Grafana version pinned
- upstream image digest pinned
- fixable operating-system vulnerabilities upgraded
- unused vulnerable bundled plugins removed
- non-root upstream runtime user retained
- no new runtime packages added
- no direct public exposure intended
- no S3 encryption credentials configured
- hardened image scanned and SBOM generated
- monitor official Grafana releases
- upgrade when an upstream build removes the residual findings

## Phase 5 optimization preservation

The hardening wrapper does not undo the previous container optimization work:

- no build tools added
- no diagnostic shell packages added
- no HTTP probe packages added
- no extra runtime service added
- no application data copied into the image
- upstream non-root execution retained
- unused plugin content removed, reducing image contents

## Review

Review on every Grafana release or within 30 days.
