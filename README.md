# 🏗️ BEMA Infrastructure

Complete DevOps setup for the BEMA insurance platform with Docker Compose, Observability Stack, and CI/CD pipeline.

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Directory Structure](#directory-structure)
- [Services](#services)
- [Environment Configuration](#environment-configuration)
- [Running the System](#running-the-system)
- [Observability](#observability)
- [CI/CD Pipeline](#cicd-pipeline)

## 🚀 Quick Start

```bash
# Start the entire system (dev environment)
docker compose -f docker/docker-compose.yml \
               -f docker/docker-compose.observability.yml \
               --env-file env/.env.dev up

# System will be available at:
# - Frontend: http://localhost:4200
# - User Service: http://localhost:8081
# - Policy Service: http://localhost:8082
# - Claim Service: http://localhost:8083 (+ WebSocket 3000)
# - Grafana: http://localhost:3001
# - Prometheus: http://localhost:9090
# - Tempo: http://localhost:3200
```

## 📁 Directory Structure

```
bema-infrastructure/
├── docker/
│   ├── docker-compose.yml              # Core services
│   └── docker-compose.observability.yml # Observability
├── observability/
│   ├── prometheus.yaml
│   ├── tempo.yaml
│   └── grafana/provisioning/
├── env/
│   ├── .env.example                    # Safe template
│   ├── .env.dev                        # Development
│   └── .env.prod                       # Production
├── ci/
│   └── github-actions.yml              # CI/CD
└── README.md
```

## 🎯 Services

### Application Services

| Service | Port | Database |
|---------|------|----------|
| User Service | 8081 | postgres-user |
| Policy Service | 8082 | postgres-policy |
| Claim Service | 8083, 3000 | postgres-claim |
| Frontend | 4200 | N/A |

### Observability Stack

| Service | Port |
|---------|------|
| Prometheus | 9090 |
| Tempo | 3200, 4317, 4318 |
| Grafana | 3001 |

**✅ Databases are INTERNAL (not exposed externally)**

## ⚙️ Environment Configuration

### Available Variables

```bash
# Database
DB_USER=bema_admin
DB_PASSWORD=secure_password
USER_DB=bema_user_db
POLICY_DB=bema_policy_db
CLAIM_DB=bema_claim_db

# Application
SPRING_PROFILES_ACTIVE=dev
JWT_SECRET=min_32_character_secret

# Frontend
FRONTEND_API_BASE_URL=http://localhost:8081

# Grafana
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin_password
```

## 🚀 Running the System

### Full Stack (Dev)
```bash
docker compose -f docker/docker-compose.yml \
               -f docker/docker-compose.observability.yml \
               --env-file env/.env.dev up
```

### Core Services Only
```bash
docker compose -f docker/docker-compose.yml \
               --env-file env/.env.dev up
```

### Background Mode
```bash
docker compose -f docker/docker-compose.yml \
               -f docker/docker-compose.observability.yml \
               --env-file env/.env.dev up -d
```

### Check Status
```bash
docker compose ps
```

### View Logs
```bash
docker compose logs -f user-service
```

### Stop All Services
```bash
docker compose down
docker compose down -v  # Include volumes
```

## 📊 Observability

### Prometheus (Metrics)
- **URL:** http://localhost:9090
- **Scrapes:** All services + Grafana + Tempo

### Tempo (Tracing)
- **URL:** http://localhost:3200
- **OTLP Endpoints:** 
  - gRPC: `localhost:4317`
  - HTTP: `localhost:4318`

### Grafana (Dashboards)
- **URL:** http://localhost:3001
- **Default:** admin / admin_dev_123
- **Datasources:** Auto-configured Prometheus + Tempo

## 🔒 Security Highlights

✅ **Database Isolation**
- No external DB port exposure
- Internal network communication only

✅ **Secrets Management**
- `.env.example` is safe to commit
- Use secrets manager for production

✅ **Service Communication**
- Uses service names (e.g., `user-service:8081`)
- No localhost references inside containers

## 🔄 CI/CD Pipeline

GitHub Actions workflow automatically:
1. Builds all services
2. Runs tests
3. Validates Docker images
4. Scans for hardcoded secrets
5. Ensures no credentials in repo

**To enable:** Copy `ci/github-actions.yml` to `.github/workflows/`

## 🆘 Troubleshooting

### Services won't start
```bash
docker compose logs -f
```

### Database connection errors
```bash
docker compose logs postgres-user
```

### Port already in use
```bash
lsof -i :4200
```

### Clear everything and restart
```bash
docker compose down -v
docker system prune
docker compose up
```

## 📚 Next Steps

1. ✅ Start system: `docker compose ... up`
2. ✅ Access frontend: http://localhost:4200
3. ✅ View metrics: http://localhost:9090
4. ✅ Monitor dashboards: http://localhost:3001
5. ✅ Check logs: `docker compose logs -f`

---

**Last updated:** May 2026
