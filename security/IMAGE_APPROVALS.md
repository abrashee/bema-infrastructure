# Container Image Approval Record

## Scope

This record covers every external build image and runtime image referenced by
the Bema repositories during the Task 6 container image review.

Approval requires:

- an exact upstream version
- a pinned upstream digest
- an identified purpose
- an identified upstream license
- vulnerability review
- preservation of required notices
- runtime compatibility verification where applicable

Locally built Bema images use explicit local tags because their bytes are
produced from version-controlled Dockerfiles. Every external base used by those
Dockerfiles is pinned by digest.

## Runtime images

| Component | Approved image | Purpose | Upstream license | Decision |
|---|---|---|---|---|
| Valkey | `valkey/valkey:8.1.8-alpine@sha256:cfe71288f087704b06be45e270afa7a2abbf820093d6b11a23762081f5ff321d` | Cache, rate limiting, token revocation and claim queue | BSD-3-Clause | Approved |
| PostgreSQL | `bema-postgres:17.10-alpine-patched` | Identity, user, policy and claim databases | PostgreSQL License; bundled components retain their licenses | Approved local wrapper |
| Tempo | `grafana/tempo:2.10.7@sha256:032b3acb51ed02c4b801473d54bb63e9e9f13738d215126d9843c30283794f4b` | Distributed trace storage and querying | Apache-2.0 | Approved with documented upstream exception |
| OpenTelemetry Collector | `otel/opentelemetry-collector:0.156.0@sha256:0beba82d63792511591522a8d582904b9a8ae81710357bfcab731607b8b0ffe2` | OTLP trace collection and forwarding | Apache-2.0 | Approved with documented upstream exception |
| PostgreSQL exporter | `prometheuscommunity/postgres-exporter:v0.20.1@sha256:ac5ec343104fae0e2d84a27bb8d69b38430a11910c5382cad85d478d2bab713e` | PostgreSQL metrics | Apache-2.0 | Approved with documented upstream exception |
| Redis exporter | `oliver006/redis_exporter:v1.86.0@sha256:2e9795be900db073e9475fdb9c5124db309b07a3e4e75a1770705cb03be1a1c8` | Valkey-compatible metrics export | MIT | Approved with documented upstream exception |
| Prometheus | `prom/prometheus:v3.13.1@sha256:3c42b892cf723fa54d2f262c37a0e1f80aa8c8ddb1da7b9b0df9455a35a7f893` | Metrics storage and querying | Apache-2.0 | Approved |
| Grafana | `bema-grafana:13.1.0-hardened` | Metrics and tracing visualization | AGPL-3.0-only; bundled components retain their licenses | Approved local wrapper with documented upstream exception |

## Application runtime and build bases

| Repository | Image | Purpose | Upstream license | Decision |
|---|---|---|---|---|
| API Gateway | `maven:3.9.16-eclipse-temurin-21@sha256:2b4496088e7b80ae10a8c9f74e574ea21380325a006ec684532ad6bad5bc7273` | Java build stage | Apache-2.0 with bundled component licenses | Approved build-only image |
| API Gateway | `eclipse-temurin:21.0.11_10-jre-jammy@sha256:d63bd8d9b171999cbed8576f2c76e874dd4856791a358536e5c4d407e77edc13` | Java runtime | GPL-2.0 with Classpath Exception; bundled OS licenses apply | Approved |
| Identity service | Same pinned Maven and Temurin images | Build and runtime | Same as above | Approved |
| User service | Same pinned Maven and Temurin images | Build and runtime | Same as above | Approved |
| Policy service | Same pinned Maven and Temurin images | Build and runtime | Same as above | Approved |
| Claim service | `node:20.20.2-alpine@sha256:fb4cd12c85ee03686f6af5362a0b0d56d50c58a04632e6c0fb8363f609372293` | Build, migration and runtime stages | MIT; bundled Alpine and dependency licenses apply | Approved |
| Frontend | `node:22.23.1-alpine@sha256:16e22a550f3863206a3f701448c45f7912c6896a62de43add43bb9c86130c3e2` | Angular build stage | MIT; bundled Alpine and dependency licenses apply | Approved build-only image |
| Frontend | `nginx:1.31.2-alpine@sha256:54f2a904c251d5a34adf545a72d32515a15e08418dae0266e23be2e18c66fefa` | Static frontend runtime | BSD-2-Clause; bundled Alpine licenses apply | Approved |
| PostgreSQL wrapper | `postgres:17.10-alpine@sha256:742f40ea20b9ff2ff31db5458d127452988a2164df9e17441e191f3b72252193` | Pinned wrapper base | PostgreSQL License; bundled Alpine licenses apply | Approved base |
| Grafana wrapper | `grafana/grafana:13.1.0@sha256:121a7a9ece6dc10b969f1f96eed64b4f07dfac0d0b8abc070f7cb83bbde86f63` | Pinned hardened wrapper base | AGPL-3.0-only; bundled component licenses apply | Approved base with documented exception |

## Compatibility verification

The Redis-to-Valkey replacement was verified for:

- registration and login
- logout and access-token revocation
- login rate limiting
- brute-force account lockout
- claim idempotency
- claim rate limiting
- claim queue insertion
- fraud-worker queue consumption
- final claim-state transition

Tempo `2.10.7` was verified for:

- configuration compatibility
- startup
- readiness
- existing local block loading
- compaction
- zero container restarts

The OpenTelemetry Collector was verified for:

- configuration validation
- startup
- internal health endpoint
- Tempo network connectivity
- removal of the deprecated exporter alias
- zero container restarts

PostgreSQL wrapper containers were verified healthy for all four databases.

## Residual exceptions

See:

- `security/exceptions/tempo.md`
- `security/exceptions/opentelemetry-collector.md`
- `security/exceptions/postgres-exporter.md`
- `security/exceptions/redis-exporter.md`

The Grafana residual findings are documented in:

- `security/exceptions/grafana.md`

The Grafana upstream license and wrapper notice are documented in:

- `security/notices/grafana.md`

## SBOMs

CycloneDX JSON SBOMs are stored under `security/sboms/`.

Application-image SBOMs are generated from the final built application images
during final Task 6 verification.

## Final application-image verification

Final Trivy reports and CycloneDX JSON SBOMs were generated for:

- API Gateway
- Identity service
- User service
- Policy service
- Claim service
- Claim migration image
- Frontend

The evidence is stored under:

- `security/scans/`
- `security/sboms/`

All seven final Bema application images passed with zero Critical and zero High
vulnerabilities.

The frontend runtime image was additionally hardened by removing unused
`curl` and `libcurl` packages from the Nginx runtime stage.

The final frontend image:

- reported zero vulnerability findings
- retained the non-root `nginx` user
- contained no Node.js runtime or build toolchain
- contained no `curl` or `libcurl`
- preserved the multi-stage build
- decreased in size from `26,423,505` bytes to `26,309,655` bytes

## Review policy

Re-review an image when any of the following changes:

- image version
- image digest
- Dockerfile base
- operating-system package set
- upstream license
- vulnerability status
- deployment exposure
