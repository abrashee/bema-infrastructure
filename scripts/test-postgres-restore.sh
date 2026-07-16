#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_ROOT="${BACKUP_ROOT:-$REPO_DIR/backups/postgres}"
BACKUP_DIR="${1:-$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)}"
POSTGRES_IMAGE="bema-postgres:17.10-alpine-patched"
TEST_PASSWORD="restore-test-only-password"
RUN_ID="$(date -u '+%Y%m%dT%H%M%SZ')-$$"

created_containers=""

cleanup() {
  for container in $created_containers; do
    docker rm -f "$container" >/dev/null 2>&1 || true
  done
}

trap cleanup EXIT

command -v docker >/dev/null 2>&1 || {
  echo "ERROR: Docker is required" >&2
  exit 1
}

if [[ -z "$BACKUP_DIR" || ! -d "$BACKUP_DIR" ]]; then
  echo "ERROR: Backup directory not found" >&2
  exit 1
fi

for file in claim.dump identity.dump policy.dump user.dump MANIFEST.txt SHA256SUMS; do
  if [[ ! -s "$BACKUP_DIR/$file" ]]; then
    echo "ERROR: Missing or empty backup artifact: $file" >&2
    exit 1
  fi
done

(
  cd "$BACKUP_DIR"

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum --check SHA256SUMS
  else
    shasum -a 256 --check SHA256SUMS
  fi
)

for name in claim identity policy user; do
  case "$name" in
    claim)
      database="bema_claim_db"
      ;;
    identity)
      database="identity_db"
      ;;
    policy)
      database="bema_policy_db"
      ;;
    user)
      database="bema_user_db"
      ;;
    *)
      echo "ERROR: Unknown restore mapping: $name" >&2
      exit 1
      ;;
  esac

  container="bema-restore-${name}-${RUN_ID}"
  dump_file="$BACKUP_DIR/${name}.dump"
  created_containers="$created_containers $container"

  echo "Starting isolated restore container for database=$database"

  docker run -d \
    --name "$container" \
    --env POSTGRES_USER=bema_admin \
    --env POSTGRES_PASSWORD="$TEST_PASSWORD" \
    --env POSTGRES_DB="$database" \
    "$POSTGRES_IMAGE" \
    >/dev/null

  ready=false

  for attempt in $(seq 1 30); do
    if docker exec "$container" \
      pg_isready \
        --username=bema_admin \
        --dbname="$database" \
        >/dev/null 2>&1
    then
      ready=true
      break
    fi

    sleep 1
  done

  if [[ "$ready" != "true" ]]; then
    docker logs "$container" >&2
    echo "ERROR: Restore container did not become ready: $container" >&2
    exit 1
  fi

  docker cp "$dump_file" "$container:/tmp/${name}.dump"

  docker exec "$container" \
    pg_restore \
      --list \
      "/tmp/${name}.dump" \
    >/dev/null

  docker exec "$container" \
    pg_restore \
      --username=bema_admin \
      --dbname="$database" \
      --no-owner \
      --no-privileges \
      --exit-on-error \
      "/tmp/${name}.dump"

  table_count="$(
    docker exec "$container" \
      psql \
        --username=bema_admin \
        --dbname="$database" \
        --tuples-only \
        --no-align \
        --command="
          SELECT count(*)
          FROM pg_catalog.pg_tables
          WHERE schemaname NOT IN ('pg_catalog', 'information_schema');
        " \
      | tr -d '[:space:]'
  )"

  if [[ -z "$table_count" || "$table_count" -le 0 ]]; then
    echo "ERROR: No application tables restored for $database" >&2
    exit 1
  fi

  echo "database=$database restore_status=passed table_count=$table_count"
done

echo "restore_test_count=4"
echo "restore_test_status=passed"
