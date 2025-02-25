# circleci-server-monitoring-reference
A reference for tools, configurations, and documentation used to monitor CircleCI server.

🚧 **Under Development**

This repository is currently under active development and is not yet a supported resource. Please refer to it at your own discretion until further notice.

# circleci-server-monitoring-stack

A reference Helm chart for setting up a monitoring stack for CircleCI server

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)

## Installing the Monitoring Stack

### 1. Configure Server for the Monitoring Stack

To set up monitoring for a CircleCI server instance, you need to configure Telegraf to set up a Prometheus client and expose a metrics endpoint. Add the following configuration to the CircleCI server Helm chart values:

```yaml
telegraf:
  config:
    outputs:
      - file:
          files: ["stdout"]
      - prometheus_client:
          listen: ":9273"
```

### 2. Install the Helm Chart
Install the Helm chart using the following command. This assumes you are installing it in the same namespace as your CircleCI server:

```bash
$ helm install circleci-server-monitoring-stack . --wait -n <your-server-namespace>
```

> **_NOTE:_**  The `--wait` flag is important to ensure all dependencies are fully installed first.

> **_NOTE:_**  It's possible to install the monitoring stack in a different namespace than the CircleCI server installation. If you do so, set the `prometheus.serviceMonitor.selectorNamespaces` value with the target namespace.

### 3. Verify Prometheus Is Up and Targeting Telegraf
To verify that Prometheus is working correctly and targeting Telegraf, use the following command to port-forward Prometheus:

```bash
$ kubectl port-forward svc/prometheus 9090:9090 -n <your-namespace-here>
```

Then visit http://localhost:9090/targets in your browser. Verify that Telegraf appears as a target and that its state is "up".

![Prometheus UI showing Telegraf target as up](docs/images/prometheus-telegraf-targets.png)

### 4. Next Steps

[TODO: Add next steps]

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://prometheus-community.github.io/helm-charts | prometheus-operator-crds | 18.0.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.imagePullSecrets | list | `[]` | List of image pull secrets to be used across the deployment. |
| prometheus.image.repository | string | `"quay.io/prometheus/prometheus"` | Image repository for Prometheus. |
| prometheus.image.tag | string | `"v3.2.0"` | Tag for the Prometheus image. |
| prometheus.replicas | int | `2` | Number of Prometheus replicas to deploy. |
| prometheus.serviceMonitor.endpoints[0].port | string | `"prometheus-client"` | Port name for the Prometheus client service. |
| prometheus.serviceMonitor.selectorLabels | object | `{"app.kubernetes.io/instance":"circleci-server","app.kubernetes.io/name":"telegraf"}` | By default, it's configured to scrape the existing Telegraf deployment in CircleCI server. |
| prometheus.serviceMonitor.selectorNamespaces | list | `[]` | actual CircleCI server installation. |
| prometheusOperator.image.repository | string | `"quay.io/prometheus-operator/prometheus-operator"` | Image repository for Prometheus Operator. |
| prometheusOperator.image.tag | string | `"v0.80.1"` | Tag for the Prometheus Operator image. |
| prometheusOperator.prometheusConfigReloader.image.repository | string | `"quay.io/prometheus-operator/prometheus-config-reloader"` | Image repository for Prometheus Config Reloader. |
| prometheusOperator.prometheusConfigReloader.image.tag | string | `"v0.80.1"` | Tag for the Prometheus Config Reloader image. |
| prometheusOperator.replicas | int | `1` | Number of Prometheus Operator replicas to deploy. |
