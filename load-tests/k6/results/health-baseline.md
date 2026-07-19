# Bema k6 Health Baseline

## Test Target

Endpoint:

```text
https://api.bema.abrashee.dev/actuator/health
```


## Test Configuration

- Tool: k6
- Virtual Users: 10
- Duration: 30s
- Total Requests: 300

## Results

- Success Rate: 100%
- Failed Requests: 0%
- Average Response Time: 27.99ms
- p95 Response Time: 38.32ms
- Maximum Response Time: 50.17ms
- Requests Per Second: 9.68

## Thresholds

| Metric | Threshold | Result |
|---|---|---|
| HTTP failures | <1% | Passed |
| p95 latency | <500ms | Passed |
