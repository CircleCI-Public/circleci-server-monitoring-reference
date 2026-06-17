# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**circleci-server-monitoring-reference** is a Helm chart that provides a reference monitoring stack for CircleCI Server. It uses Prometheus for metrics, Grafana for visualization, and optionally Tempo for distributed tracing. The chart manages CRDs and deployments for Prometheus Operator, Grafana Operator, and related monitoring components.

## Architecture

### Key Components

- **Prometheus Operator** (`prometheusOperator`): Manages Prometheus instances and ServiceMonitor resources for metric scraping
- **Grafana Operator** (`grafanaoperator`): Manages Grafana deployment, datasources, and dashboard provisioning
- **Tempo** (optional): Distributed tracing system for OpenTelemetry data; requires manual Tempo Operator installation
- **Telegraf Integration** (Server ≤4.9): CircleCI Server exports metrics on port 9273 via Telegraf's Prometheus client
- **OpenTelemetry Collector** (Server 4.10+): CircleCI Server exports both metrics and traces via OTEL collector

### Dashboard Organization

Dashboards are version-specific due to metric differences between CircleCI Server versions:
- `dashboards/server-slis.json` — for Server ≤4.9 (Telegraf metrics)
- `dashboards/server-slis-server4.10.json` — for Server 4.10+ (OTEL metrics)

Grafana operators provision these dashboards automatically during Helm deployment.

### Helm Chart Structure

- **Chart.yaml**: Chart metadata and dependency declarations (prometheus-operator-crds, grafana-operator)
- **values.yaml**: Default configuration values for all components (Prometheus, Grafana, Tempo, operators)
- **templates/**: Helm templates for generating Kubernetes manifests
  - Prometheus, PrometheusRule, ServiceMonitor
  - Grafana, GrafanaDataSource, GrafanaDashboard
  - TempoMonolithic (when Tempo is enabled)
  - ConfigMaps for dashboard JSON files
- **tests/**: Helm unit tests for template rendering and configuration validation

### ServiceMonitor Configuration

Prometheus discovers metrics via `ServiceMonitor` CRDs. The chart supports:
- **Single-namespace discovery** (default): Monitors only the namespace where the monitoring stack is deployed
- **Cross-namespace discovery**: Prometheus can scrape ServiceMonitors from multiple namespaces via `prometheus.serviceMonitor.selectorNamespaces`

Configure which namespaces Prometheus searches in `values.yaml`:
```yaml
prometheus:
  serviceMonitor:
    selectorNamespaces: []  # Empty = all namespaces; ['ns1', 'ns2'] = specific namespaces
```

### Infrastructure ServiceMonitors

The chart can optionally scrape infrastructure metrics from your Kubernetes cluster. These are disabled by default but can be enabled for system-level observability:

- **CoreDNS** (`prometheus.infraServiceMonitors.coredns`): DNS query rates and latencies
- **kubelet** (`prometheus.infraServiceMonitors.kubelet`): Node resource usage and cAdvisor container metrics
- **kube-state-metrics** (`prometheus.infraServiceMonitors.kubeStateMetrics`): Kubernetes object state (pods, deployments, etc.)
- **node-exporter** (`prometheus.infraServiceMonitors.nodeExporter`): Host-level metrics (CPU, memory, disk, network)

Enable any of these by setting them to `enabled: true` in `values.yaml`. The chart will automatically create ServiceMonitor resources that match the operator's label selectors.

## Development Workflow

### Common Commands

All commands use the `./do` task runner. Run `./do help` to see all available tasks.

```bash
# View the current chart version
./do version

# Run Helm unit tests
./do unit-tests

# Run a single test file
./do unit-tests tests/grafana/grafana_test.yaml

# Lint Grafana dashboards (validates JSON structure)
./do lint-dashboards

# Validate dashboard configuration (ensures proper export format and UIDs)
./do validate-dashboards

# Validate Kubernetes manifests using kubeconform
./do kubeconform

# Generate Helm documentation (updates README.md from Chart.yaml and templates)
./do helm-docs

# Package the Helm chart for distribution
./do package-chart

# Package and cryptographically sign the chart
./do package-chart sign
```

### Modifying Grafana Dashboards

When updating dashboards:

1. Edit the dashboard in Grafana UI or select **Edit** → **Save dashboard** → **Save copy**
2. Export the dashboard as JSON via **Export** → **Export JSON** (ensure "Export dashboard use in another instance" is toggled on)
3. Download and replace the corresponding file in `./dashboards/` (use `server-slis.json` for ≤4.9 or `server-slis-server4.10.json` for 4.10+)
4. Run `./do validate-dashboards` to ensure the JSON has correct title, UID, and Prometheus input configuration
5. Test with `./do lint-dashboards` to validate the dashboard JSON structure
6. Commit and open a PR for the On-Prem team to review

### Testing & Validation

- **Unit tests** verify that Helm templates generate correct Kubernetes manifests under various configuration scenarios (tests written in YAML using the helm-unittest plugin)
- **Dashboard validation** ensures dashboards are properly exported for external Prometheus datasources and have correct metadata
- **Kubeconform** validates that generated manifests conform to Kubernetes OpenAPI schemas (includes custom schemas for Tempo CRDs)

## Key Files & Responsibilities

| Path | Purpose |
|------|---------|
| `Chart.yaml` | Chart version, dependencies (prometheus-operator-crds, grafana-operator) |
| `values.yaml` | Configuration defaults for all components (replicas, storage, credentials, resource limits) |
| `templates/` | Helm templates that render Kubernetes manifests based on values.yaml |
| `dashboards/*.json` | Pre-built Grafana dashboards for different CircleCI Server versions |
| `tests/` | Helm unit tests for validating template rendering and conditional logic |
| `scripts/validate_dashboards.sh` | Script to ensure dashboards have correct title, UID, and Prometheus datasource input |
| `do` | Task runner; defines all development and CI/CD tasks |
| `README.md` | User documentation (auto-generated from README.md.gotmpl) |

## Dependencies & Tools

- **Helm 3.x** (required)
- **Kubernetes 1.24+** (for deployed clusters)
- **kubectl** (for verification after installation)
- **jq** (used in validation scripts)
- **Python 3** (used by kubeconform schema generation)
- Optional: **docker** (helm-docs can run in a container if not installed locally)

Plugins installed on-demand via `./do`:
- `helm-unittest` — for running unit tests
- `helm-kubeconform` — for manifest validation
- `dashboard-linter` (as a Go binary) — for Grafana dashboard linting

## CI/CD & Release

Releases are automated via CircleCI on the main branch:
1. Increment the chart `version` in `Chart.yaml`
2. Run `./do helm-docs` to regenerate documentation
3. Commit and push to main
4. An approval job (`approve-deploy-chart`) gates the release
5. After approval, the chart is published to [packagecloud.io](https://packagecloud.io/circleci/server-monitoring-stack)

Chart signing is optional and requires GPG setup (KEY and KEYRING env vars).

## Conventions & Notes

- **No editable manifests**: All Kubernetes manifests are generated from Helm templates using `values.yaml`. Manually editing generated files will be overwritten on redeploy.
- **Datasource configuration**: Grafana is auto-configured with a Prometheus datasource pointing to the Prometheus instance deployed by this chart.
- **OTEL support**: Tracing configuration requires CircleCI Server 4.9+ and manual Tempo Operator installation; the chart integrates but does not deploy the Tempo Operator itself.
- **Feature flags**: The chart uses Helm's conditional logic (`condition` fields in Chart.yaml) to enable/disable components (e.g., `prometheusOperator.installCRDs`, `grafanaoperator.enabled`, `tempo.enabled`).

## Troubleshooting

- **Tests fail with plugin not found**: Run `./do unit-tests` to auto-install missing plugins.
- **Dashboard validation fails**: Ensure dashboards are exported for external Prometheus instances (not embedded) and have correct UIDs set by `validate_dashboards.sh`.
- **Kubeconform errors on Tempo CRDs**: The `kubeconform` task automatically fetches missing schemas; this is expected on first run.
