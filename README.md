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
IDENTITY_DB=bema_identity_db

# Application
SPRING_PROFILES_ACTIVE=dev
JWT_SECRET=replace-with-a-minimum-32-character-secret

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

<!-- BEMA-LICENSE-SECTION:START -->
## License and use

Copyright © 2026 Abdul Rasheed Momand.

This repository is part of **Bema**, a demonstration and portfolio project built to present software-engineering, security, observability, containerization, testing, and cloud-deployment skills.

The Bema-authored source code in this repository is licensed under the **MIT License**. The complete controlling terms are available in the repository's [`LICENSE`](LICENSE) file.

### Permitted use

Subject to the MIT License, the software may be:

- viewed and evaluated by recruiters, hiring managers, technical reviewers, and other interested parties;
- used for learning, education, research, experimentation, and personal projects;
- used, copied, modified, merged, published, distributed, sublicensed, or sold;
- incorporated into commercial or noncommercial software.

Copies or substantial portions of the software must retain the copyright notice and MIT License notice.

### No warranty or guarantee

This software is provided **“AS IS”**, without warranty of any kind, express or implied. No guarantee is made regarding its correctness, reliability, availability, security, fitness for a particular purpose, or suitability for production use.

To the extent permitted by applicable law, the author and copyright holder are not liable for claims, damages, losses, or other liability arising from the software or its use.

The [`LICENSE`](LICENSE) file contains the legally controlling terms. This README section is only a practical summary.

### Third-party components

Dependencies, container images, fonts, icons, GitHub Actions, and other third-party materials remain governed by their respective licenses. The MIT License for Bema-authored code does not replace or modify those third-party terms.

Third-party attribution and license notices will be maintained separately where required.
<!-- BEMA-LICENSE-SECTION:END -->
