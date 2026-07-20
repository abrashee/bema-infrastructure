# Restore Testing

## Scope

This procedure verifies that Bema PostgreSQL backups can be restored successfully without modifying the running development stack.

The restore test covers:

- Claim database
- Identity database
- Policy database
- User database

## Implementation

The restore test is implemented by:

`scripts/test-postgres-restore.sh`

The script:

- selects the latest backup by default, or accepts a backup directory argument
- verifies all required backup artifacts exist
- verifies SHA-256 checksums before restoration
- starts isolated temporary PostgreSQL containers
- uses the approved `bema-postgres:17.10-alpine-patched` image
- restores each custom-format dump with `pg_restore`
- fails immediately on restore errors
- verifies that application tables exist after restoration
- removes all temporary restore containers automatically

The running Bema databases and their volumes are not modified.

## Usage

Test the latest backup:

```bash
./scripts/test-postgres-restore.sh

Test a specific backup:

./scripts/test-postgres-restore.sh backups/postgres/<timestamp>
Success criteria

A restore test passes only when:

all backup artifacts are present and non-empty
all checksums pass
every isolated PostgreSQL container becomes ready
every dump passes pg_restore --list
every restore completes without errors
every restored database contains application tables
all temporary restore containers are removed
Verified result

The initial restore test successfully restored all four databases:

Claim database: 2 application tables
Identity database: 3 application tables
Policy database: 2 application tables
User database: 2 application tables

All checksum and restore assertions passed.

Limitations

This test verifies backup integrity, PostgreSQL compatibility, and schema restoration.

It does not yet verify:

full application startup against restored databases
business-level row counts and data invariants
authentication against restored identity data
full claim-processing workflow
production backup restoration

Those broader disaster-recovery checks are covered by Task 16 and Phase 6 production validation.

Production requirement

Production restore testing must run on a scheduled basis in an isolated environment using encrypted production backups or appropriately sanitized copies.

Production testing must record:

backup identifier
restore start and completion time
restore duration
checksum result
schema and integrity validation results
application smoke-test results
cleanup result
operator or automated workflow identity
