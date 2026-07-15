# Bema Rolling Update Strategy

## Scope

This strategy applies to production deployments of Bema application services:

- API Gateway
- Identity service
- User service
- Policy service
- Claim service
- Frontend

Stateful infrastructure components, database migrations, and observability services require separate handling described below.

## Local Docker Compose

Docker Compose is used for local development and integration verification.

Docker Compose does not provide production-grade rolling updates across multiple replicas. A Compose `up -d` operation may recreate a service and briefly interrupt it.

Therefore:

- Docker Compose must not be treated as the production rolling-update mechanism.
- Local Compose verifies image startup, healthchecks, dependencies, and compatibility.
- Production rolling updates must be performed by an orchestrator that supports replica-based deployment controls.

## Production orchestrator requirements

The AWS production platform selected in Phase 6 must support:

- at least two replicas for each user-facing stateless service
- health-based replacement
- gradual deployment of new task or pod revisions
- configurable minimum healthy capacity
- configurable maximum deployment capacity
- automatic removal of unhealthy new instances
- deployment timeout and failure detection
- rollback to the last known-good revision
- immutable image references
- centralized deployment events and logs

Suitable implementations include Amazon ECS rolling deployments or Kubernetes Deployments on Amazon EKS. The final choice remains part of Phase 6 architecture work.

## Recommended rollout policy

For stateless application services:

- minimum healthy capacity: 100%
- maximum deployment capacity: 200%
- deploy one service at a time
- start new instances before stopping old instances
- require readiness or target-group health before receiving traffic
- keep the previous image revision available for rollback
- stop the rollout immediately when healthchecks, error rates, or latency regress

The API Gateway should be updated after its downstream services unless the change is explicitly backward compatible in both directions.

The frontend should be deployed after the gateway and backend services it depends on.

## Deployment order

Use this default order:

1. Database migrations that are backward compatible
2. Identity service
3. User service
4. Policy service
5. Claim service
6. API Gateway
7. Frontend
8. Observability configuration, when required

A release may use a different order only when the dependency analysis documents why it is safe.

## Database migration rules

The claim migration container is a one-shot job and must not use a rolling restart policy.

Database changes must follow expand-and-contract practices:

1. Add backward-compatible schema changes.
2. Deploy application versions that can work with both old and new schema forms.
3. Migrate or backfill data.
4. Remove obsolete schema only in a later release.

Destructive or incompatible migrations must not run automatically during a rolling deployment.

## Stateful services

PostgreSQL, Valkey, Tempo, Prometheus, and Grafana are not updated through the same stateless rolling process.

Their upgrades require:

- backup verification
- compatibility review
- maintenance or failover planning
- explicit rollback instructions
- post-upgrade data and health validation

## Health gates

A new revision must not receive production traffic until its configured healthcheck passes.

The rollout must verify:

- container is running
- healthcheck is healthy
- restart count is stable
- expected application endpoint responds
- dependent service communication succeeds
- Prometheus target is up where applicable
- no new fatal or panic log entries appear

## Failure and rollback triggers

Stop and roll back when any of the following occurs:

- new instances fail readiness or healthchecks
- repeated container restarts occur
- migration job exits non-zero
- authentication or authorization fails
- claim creation or processing fails
- error rate materially increases
- latency exceeds the agreed deployment threshold
- traces or metrics disappear unexpectedly
- data integrity checks fail

## Phase 5 optimization preservation

Rolling-update configuration must not change the approved container images by adding:

- diagnostic packages
- shell utilities
- HTTP probe clients
- build tools
- source files
- development dependencies

Health and readiness decisions must use the existing application endpoints, container healthchecks, load-balancer checks, and external monitoring.

## Phase 6 implementation requirement

Task 12 defines the required deployment behavior. The concrete ECS or Kubernetes configuration must be implemented and runtime-tested during Phase 6 before production deployment.

Task 12 is not evidence that Docker Compose itself provides zero-downtime rolling updates.
