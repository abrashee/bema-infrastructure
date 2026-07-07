Centralized Metrics (Prometheus scraping)
Collect HTTP + JVM metrics from all Spring services and expose them via /actuator/prometheus.
Distributed Tracing (Tempo + OTLP)
Track request flow across gateway → services → DB calls using OpenTelemetry traces.
Service Dashboard (Grafana System Health)
Visual overview of uptime, request rate, error rate, and latency per service.
Error Rate Monitoring
Track 5xx/4xx trends per service to detect failures early.
Latency Monitoring (P95/P99)
Measure and visualize response time distribution per endpoint/service.
Service Discovery in Observability Layer
Auto-registration of services in Prometheus via static scrape configs or future service discovery.
Log Aggregation Pipeline (future extension)
Centralized logs from all services (likely Loki or ELK stack integration).
Alerting Rules (missing piece)
Alerts for high error rate, service down, or latency spikes (via Alertmanager or Grafana alerts).
Infrastructure Health Monitoring
Track Redis, Postgres, and gateway health as first-class metrics.