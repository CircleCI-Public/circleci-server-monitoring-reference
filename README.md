# circleci-server-monitoring-reference
A reference for tools, configurations, and documentation used to monitor CircleCI server.

🚧 **Under Development**

This repository is currently under active development and is not yet a supported resource. Please refer to it at your own discretion until further notice.

# circleci-server-monitoring-stack

A reference Helm chart for setting up a monitoring stack for CircleCI server

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://prometheus-community.github.io/helm-charts | prometheus-operator-crds | 18.0.0 |

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
