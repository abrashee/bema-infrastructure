#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-eu-central-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-653487753312}"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

build_and_tag() {
  local repo_dir="$1"
  local ecr_repo="$2"
  local dockerfile="${3:-Dockerfile}"
  local target="${4:-}"

  local commit
  commit="$(git -C "${ROOT_DIR}/${repo_dir}" rev-parse --short=12 HEAD)"

  local build_args=()
  if [[ -n "$target" ]]; then
    build_args+=(--target "$target")
  fi

  docker build \
    --file "${ROOT_DIR}/${repo_dir}/${dockerfile}" \
    --tag "${ECR_REGISTRY}/${ecr_repo}:${commit}" \
    --tag "${ECR_REGISTRY}/${ecr_repo}:latest" \
    "${build_args[@]}" \
    "${ROOT_DIR}/${repo_dir}"

  printf '%s\t%s\n' "$ecr_repo" "$commit"
}

build_and_tag "bema-api-gateway"   "bema-api-gateway"
build_and_tag "identity-service"   "bema-identity-service"
build_and_tag "bema-user-service"  "bema-user-service"
build_and_tag "bema-policy-service" "bema-policy-service"
build_and_tag "bema-claim-service" "bema-claim-service"

POSTGRES_COMMIT="$(git -C "$ROOT_DIR/bema-infrastructure" rev-parse --short=12 HEAD)"

docker build \
  --file "$ROOT_DIR/bema-infrastructure/docker/postgres/Dockerfile" \
  --tag "${ECR_REGISTRY}/bema-postgres:${POSTGRES_COMMIT}" \
  --tag "${ECR_REGISTRY}/bema-postgres:latest" \
  "$ROOT_DIR/bema-infrastructure/docker/postgres"

printf '%s\t%s\n' "bema-postgres" "$POSTGRES_COMMIT"
