#!/usr/bin/env bash

set -euo pipefail
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_ROOT="${BACKUP_ROOT:-$REPO_DIR/backups/postgres}"
TIMESTAMP="$(date -u '+%Y%m%dT%H%M%SZ')"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
DB_USER="${DB_USER:-bema_admin}"
BACKUP_COMPLETE=false

cleanup_incomplete_backup() {
  if [[ "$BACKUP_COMPLETE" != "true" && -d "$BACKUP_DIR" ]]; then
    rm -rf "$BACKUP_DIR"
  fi
}

trap cleanup_incomplete_backup EXIT

command -v docker >/dev/null 2>&1 || {
  echo "ERROR: Docker is required" >&2
  exit 1
}

command -v sha256sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1 || {
  echo "ERROR: sha256sum or shasum is required" >&2
  exit 1
}

mkdir -p "$BACKUP_DIR"

checksum_file() {
  local file="$1"
  local directory
  local filename

  directory="$(dirname "$file")"
  filename="$(basename "$file")"

  if command -v sha256sum >/dev/null 2>&1; then
    (
      cd "$directory"
      sha256sum "$filename"
    )
  else
    (
      cd "$directory"
      shasum -a 256 "$filename"
    )
  fi
}

for name in claim identity policy user; do
  case "$name" in
    claim)
      container="bema-claim-db"
      database="bema_claim_db"
      ;;
    identity)
      container="bema-identity-db"
      database="identity_db"
      ;;
    policy)
      container="bema-policy-db"
      database="bema_policy_db"
      ;;
    user)
      container="bema-user-db"
      database="bema_user_db"
      ;;
    *)
      echo "ERROR: Unknown database mapping: $name" >&2
      exit 1
      ;;
  esac

  output="$BACKUP_DIR/${name}.dump"

  state="$(
    docker inspect "$container" \
      --format '{{.State.Status}}' \
      2>/dev/null || true
  )"

  health="$(
    docker inspect "$container" \
      --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
      2>/dev/null || true
  )"

  if [[ "$state" != "running" || "$health" != "healthy" ]]; then
    echo "ERROR: $container is not running and healthy" >&2
    exit 1
  fi

  echo "Backing up database=$database container=$container"

  docker exec "$container" \
    pg_dump \
      --username="$DB_USER" \
      --dbname="$database" \
      --format=custom \
      --compress=9 \
      --no-owner \
      --no-privileges \
    > "$output"

  if [[ ! -s "$output" ]]; then
    echo "ERROR: Empty backup created for $database" >&2
    exit 1
  fi

  checksum_file "$output" >> "$BACKUP_DIR/SHA256SUMS"
done

cat > "$BACKUP_DIR/MANIFEST.txt" <<MANIFEST
created_at_utc=$TIMESTAMP
postgres_version=17.10
format=pg_dump_custom
database_count=4
claim_database=bema_claim_db
identity_database=identity_db
policy_database=bema_policy_db
user_database=bema_user_db
MANIFEST

chmod 600 "$BACKUP_DIR"/*

BACKUP_COMPLETE=true

echo "backup_directory=$BACKUP_DIR"
echo "backup_count=4"
echo "backup_status=passed"