#!/bin/bash

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
print_header() {
    echo -e "\n${BLUE}==== $1 ====${NC}\n"
}
print_success() { echo -e "${GREEN}✔ $1${NC}"; }
print_error() { echo -e "${RED}✖ $1${NC}"; }
print_info() { echo -e "${YELLOW}• $1${NC}"; }
ENV_FILE=""
COMPOSE_FILE="docker/docker-compose.yml"
OBS_FILE="docker/docker-compose.observability.yml"
check_docker() {
    command -v docker >/dev/null || { print_error "Docker missing"; exit 1; }
load_env() {
    set -a
    source "$ENV_FILE"
    set +a
validate_ports() {
    print_info "Validating port configuration..."
    local errors=0
    # Expected ports (single source of truth)
    declare -A expected_ports=(
        ["gateway"]=8080
        ["user"]=8081
        ["policy"]=8082
        ["claim"]=8083
        ["identity"]=8084
        ["frontend"]=4200
    )
    # Check for duplicates in compose (basic safety)
    ports=$(grep -R "ports:" -A1 "$COMPOSE_FILE" | grep -oE "[0-9]+:[0-9]+" | cut -d: -f1)
    dup=$(echo "$ports" | sort | uniq -d)
    if [[ ! -z "$dup" ]]; then
        print_error "Duplicate exposed ports detected: $dup"
        errors=1
    fi
    # Claim service special case (must match env PORT if used)
    if grep -q "claim-service" "$COMPOSE_FILE"; then
        if ! grep -q "8083:8083" "$COMPOSE_FILE"; then
            print_error "Claim service port mismatch (expected 8083:8083)"
            errors=1
        fi
    if [[ $errors -eq 1 ]]; then
        exit 1
    print_success "Port validation passed"
validate_env() {
    print_info "Validating required env vars..."
    required=(
        DB_USER
        DB_PASSWORD
        USER_DB
        POLICY_DB
        CLAIM_DB
        IDENTITY_DB
        JWT_SECRET
        SPRING_PROFILES_ACTIVE
    missing=0
    for var in "${required[@]}"; do
        if [[ -z "${!var}" ]]; then
            print_error "Missing env: $var"
            missing=1
    done
    [[ $missing -eq 1 ]] && exit 1
    print_success "Environment validation passed"
run_compose() {
    CMD="docker compose \
        -f $COMPOSE_FILE \
        -f $OBS_FILE \
        --env-file $ENV_FILE"
    if [[ "$1" == "detach" ]]; then
        CMD="$CMD up -d"
    else
        CMD="$CMD up"
    print_info "Running stack"
    echo "$CMD"
    eval "$CMD"
print_header "BEMA Infrastructure Startup"
MODE="${1:-dev}"
SHIFT="${2:-}"
case "$MODE" in
  dev)
    ENV_FILE="env/.env.dev"
    ;;
  prod)
    ENV_FILE="env/.env.prod"
  *)
    print_error "Usage: ./startup.sh [dev|prod] [--detach]"
    exit 1
esac
check_docker
[[ -f "$ENV_FILE" ]] || { print_error "Missing $ENV_FILE"; exit 1; }
load_env
validate_env
validate_ports
if [[ "$SHIFT" == "--detach" || "$SHIFT" == "-d" ]]; then
    run_compose "detach"
else
    run_compose "live"
fi
print_success "Infrastructure started"
