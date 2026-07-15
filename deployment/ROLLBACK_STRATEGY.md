# Bema Rollback Strategy

## Scope

This strategy covers rollback of Bema production releases for:

- API Gateway
- Identity service
- User service
- Policy service
- Claim service
- Frontend
- deployment configuration

Database, Valkey, and observability rollback require additional stateful-service controls.

## Required release records

Every production release must record:

- release identifier
- Git commit for each repository
- immutable image digest for each deployed image
- deployment timestamp
- database migration version
- configuration revision
- previous known-good release
- operator responsible for the deployment

A release must not begin unless the previous known-good application images and configuration remain available.

## Rollback triggers

Rollback immediately when any of the following occurs after deployment:

- healthchecks fail
- new instances repeatedly restart
- authentication or authorization fails
- registration, login, logout, or token revocation fails
- claim creation or processing fails
- database migrations exit non-zero
- material error-rate or latency regression occurs
- Prometheus targets disappear
- traces stop flowing unexpectedly
- data integrity validation fails
- security controls regress

## Stateless application rollback

For API Gateway, Identity, User, Policy, Claim, and Frontend:

1. Stop the active rollout.
2. Prevent unhealthy new instances from receiving traffic.
3. Redeploy the previous known-good immutable image digest.
4. Restore the previous deployment configuration revision.
5. Wait for all required healthchecks to pass.
6. Verify zero unexpected restarts.
7. Run the release smoke tests.
8. Confirm metrics, logs, and traces have returned to normal.
9. Record the rollback event and cause.

Rollback must use immutable image digests or an orchestrator revision that resolves to the exact previously approved images. Mutable tags must not be used as rollback references.

## Service rollback order

When several services must be rolled back, use the reverse of the deployment order unless dependency analysis requires otherwise:

1. Frontend
2. API Gateway
3. Claim service
4. Policy service
5. User service
6. Identity service

A single affected service should be rolled back independently when compatibility permits.

## Database migration rollback

Database rollback is not assumed to be safe.

Production schema changes must use expand-and-contract deployment practices so that application rollback does not require immediate destructive schema rollback.

Before a migration runs, classify it as:

- backward compatible
- reversible with a tested down migration
- irreversible

For backward-compatible migrations:

- leave the expanded schema in place
- roll back the application images
- remove obsolete schema only in a later controlled release

For a reversible migration:

- stop application writes when required
- create a fresh backup
- run only the tested down migration
- validate schema and data integrity
- redeploy the known-good application version

For an irreversible migration:

- do not attempt an untested reverse migration
- restore from the verified pre-deployment backup
- document the expected recovery-point data loss
- validate the restored system before reopening traffic

## Claim migration job

The claim migration container is a one-shot job with `restart: "no"`.

If it exits non-zero:

- stop the deployment
- do not repeatedly restart it
- inspect the migration logs
- determine whether any migration step committed
- follow the database migration classification above
- rerun only after the failure cause is corrected

## Configuration rollback

Environment values and deployment configuration must be versioned separately from secret values.

Rollback must restore:

- service endpoints
- CORS and WebSocket origins
- rate-limit settings
- resource limits
- healthcheck configuration
- observability endpoints
- deployment parameters

Secrets must be restored through the production secret manager, not from Git history or plaintext files.

## Stateful component rollback

PostgreSQL, Valkey, Tempo, Prometheus, and Grafana must not be rolled back by replacing containers blindly.

Their rollback requires:

- compatibility review
- verified backups where state is involved
- documented version-specific procedures
- explicit data-format compatibility checks
- post-rollback health and integrity validation

Downgrades must not proceed when the newer version has written an incompatible data format.

## Validation after rollback

A rollback is complete only after verifying:

- all required containers or tasks are healthy
- restart counts are stable
- gateway health endpoint responds
- registration and login succeed
- logout and token revocation succeed
- authorized backend requests succeed
- claim creation and final processing succeed
- frontend loads through the intended gateway endpoint
- Prometheus targets are up
- Grafana starts successfully
- Tempo and OpenTelemetry Collector are operational
- PostgreSQL exporters and Redis exporter respond
- no fatal or panic logs are present
- data integrity checks pass

## Local Docker Compose limitation

Docker Compose can recreate a previous local image or configuration, but it does not provide production revision management, traffic shifting, or automatic rollback.

Local Compose rollback testing is limited to integration verification. The concrete automated rollback mechanism must be implemented in Phase 6 using the selected AWS orchestrator.

## Phase 5 optimization preservation

Rollback procedures must reuse approved images. They must not create emergency images containing:

- shells
- diagnostic utilities
- HTTP clients
- build tools
- source code
- development dependencies

Operational diagnostics must use external tooling, existing application endpoints, logs, metrics, and traces.

## Review requirement

Review and test this strategy whenever any of the following changes:

- production orchestrator
- deployment order
- database migration tooling
- image naming or registry strategy
- secret-management mechanism
- backup and restore procedure
- stateful component version
