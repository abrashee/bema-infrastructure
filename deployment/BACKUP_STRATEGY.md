# Backup Strategy

## Purpose

This document defines the backup requirements for the Bema production platform.

Its purpose is to ensure that production data can be recovered after infrastructure failures, software defects, operational mistakes, or disaster recovery events.

This document defines required backup behavior.

The concrete production automation is implemented during Phase 6.

---

# Backup scope

The following production data must be backed up.

## PostgreSQL databases

The platform contains four independent databases.

- User Database
- Policy Database
- Claim Database
- Identity Database

Each database must be backed up independently.

Each backup must be recoverable without requiring restoration of unrelated databases.

---

## Persistent observability data

Observability data is operational rather than business-critical.

Persistent volumes include:

- Prometheus metrics
- Grafana configuration
- Tempo traces

These volumes may be backed up according to operational requirements.

Loss of observability data must not prevent production recovery.

---

## Excluded data

The following data is intentionally excluded from backups.

- Redis cache
- Redis rate limiting counters
- revoked access token cache
- temporary application caches
- Docker images
- containers
- generated build artifacts

These components are recreated during deployment.

---

# Backup format

Database backups use PostgreSQL custom format.
pg_dump
--format=custom
--compress=9
--no-owner
--no-privileges


Benefits include:

- compressed output
- compatibility with pg_restore
- selective restore support
- version compatibility

---

# Backup verification

Every backup must be verified.

Requirements:

- backup file successfully created
- backup file is non-empty
- SHA-256 checksum generated
- checksum verification passes
- manifest generated
- restrictive filesystem permissions applied

A backup is not considered valid until verification succeeds.

---

# Restore requirements

Recovery must support restoring any individual database independently.

Required tools:

- pg_restore
- matching PostgreSQL major version
- verified backup files
- checksum verification before restore

Backups must never be restored before integrity verification.

---

# Backup frequency

Production minimum requirements:

- daily scheduled backup
- additional backup before every production deployment
- additional backup before every schema migration
- additional backup before major maintenance operations

Organizations may choose shorter backup intervals.

---

# Retention policy

Minimum production retention:

- daily backups: 30 days
- weekly backups: 12 weeks
- monthly backups: 12 months

Retention policies may be extended for regulatory or business requirements.

---

# Recovery objectives

Minimum production objectives:

Recovery Point Objective (RPO)

- less than or equal to 24 hours

Recovery Time Objective (RTO)

- less than or equal to 2 hours

Organizations with stricter requirements may reduce these targets.

---

# Backup testing

Backups must be tested regularly.

Testing includes:

- checksum verification
- restore into isolated environment
- application startup verification
- data integrity verification
- authentication verification
- API smoke tests

Backups that cannot be restored are considered invalid.

---

# Local Docker Compose implementation

The local development environment provides:

- manual PostgreSQL backup script
- SHA-256 verification
- backup manifest generation
- restrictive backup permissions
- Git exclusion for generated backups

Docker Compose does not provide:

- automated scheduling
- off-site storage
- backup replication
- production retention management
- disaster recovery orchestration

These capabilities are intentionally deferred.

---

# Phase 6 production implementation

Production deployment must implement automated backups using the selected production platform's managed backup capabilities.

The production implementation must include:

- automated scheduled backups
- encrypted backup storage
- off-site redundancy
- retention enforcement
- backup monitoring
- restore testing
- recovery documentation

The specific production backup implementation is part of Phase 6.

---

# Success criteria

Backup strategy is complete when:

- every production database is included
- backup format is defined
- verification process is defined
- restore requirements are defined
- retention policy is defined
- recovery objectives are defined
- backup testing is defined
- production implementation requirements are documented