# circleci-server-monitoring-reference
A reference for tools, configurations, and documentation used to monitor CircleCI server.

🚧 **Under Development**

This repository is currently under active development and is not yet a supported resource. Please refer to it at your own discretion until further notice.

# circleci-server-monitoring-stack

A reference Helm chart for setting up a monitoring stack for CircleCI server

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)

## Installing the Monitoring Stack

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://grafana.github.io/helm-charts | grafanaoperator(grafana-operator) | 5.16.0 |
| https://prometheus-community.github.io/helm-charts | prometheus-operator-crds | 18.0.1 |

### 1. Configure Server for the Monitoring Stack

To set up monitoring for a CircleCI server instance, you need to configure Telegraf to set up a Prometheus client and expose a metrics endpoint. Add the following configuration to the CircleCI **server** Helm chart values:

```yaml
telegraf:
  config:
    outputs:
      - file:
          files: ["stdout"]
      - prometheus_client:
          listen: ":9273"
```

### 2. Install the CRDs

Before installing the Prometheus operator, you must first install the Custom Resource Definitions (CRDs) required by it. Follow these steps:

```bash
$ VERSION=$(helm dependency list | grep prometheus-operator-crds | cut -f 2)
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo update
$ helm install prometheus-operator-crds prometheus-community/prometheus-operator-crds --version "${VERSION}"
```

### 3. Install the Helm Chart

Install the Helm chart using the following command. This assumes you are installing it in the same namespace as your CircleCI server:

```bash
$ helm install circleci-server-monitoring-stack . --dependency-update -n <your-server-namespace>
```

> **_NOTE:_**  It's possible to install the monitoring stack in a different namespace than the CircleCI server installation. If you do so, set the `prometheus.serviceMonitor.selectorNamespaces` value with the target namespace.

### 4. Verify Prometheus Is Up and Targeting Telegraf
To verify that Prometheus is working correctly and targeting Telegraf, use the following command to port-forward Prometheus:

```bash
$ kubectl port-forward svc/prometheus 9090:9090 -n <your-namespace-here>
```

Then visit http://localhost:9090/targets in your browser. Verify that Telegraf appears as a target and that its state is "up".

![Prometheus UI showing Telegraf target as up](docs/images/prometheus-telegraf-targets.png)

### 5. Next Steps

[TODO: Add next steps]

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.fullnameOverride | string | `"server-monitoring"` | Override the full name for resources |
| global.imagePullSecrets | list | `[]` | List of image pull secrets to be used across the deployment |
| global.nameOverride | string | `""` | Override the release name |
| grafana.credentials.adminPassword | string | `"admin"` | Grafana admin password. Change from default for production environments. |
| grafana.credentials.adminUser | string | `"admin"` | Grafana admin username. |
| grafana.credentials.existingSecretName | string | `""` | Name of an existing secret for Grafana credentials. Leave empty to create a new secret. |
| grafana.dashboards[0] | object | `{"json":"{\n  \"title\": \"CircleCI API Usage Dashboard\",\n  \"timezone\": \"browser\",\n  \"refresh\": \"5s\",\n  \"panels\": [\n    {\n      \"type\": \"timeseries\",\n      \"title\": \"API v2 Requests Count Over Time\",\n      \"targets\": [\n        {\n          \"expr\": \"circle.http.request.count\"\n        }\n      ]\n    }\n  ],\n  \"time\": {\n    \"from\": \"now-6h\",\n    \"to\": \"now\"\n  }\n}\n","name":"circleci-api-usage-dashboard","resyncPeriod":"30s"}` | Sample dashboards for basic monitoring of a CircleCI server installation. |
| grafana.datasource.jsonData.timeInterval | string | `"5s"` | The time interval for Grafana to poll Prometheus. Specifies the frequency of data requests. |
| grafana.image.repository | string | `"grafana/grafana"` | Image repository for Grafana. |
| grafana.image.tag | string | `"11.5.2"` | Tag for the Grafana image. |
| grafana.persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the persistent volume. |
| grafana.persistence.enabled | bool | `false` | Enable persistent storage for Grafana. |
| grafana.persistence.size | string | `"10Gi"` | Size of the persistent volume claim. |
| grafana.persistence.storageClass | string | `""` | Storage class for persistent volume provisioner. You can create a custom storage class with a "retain" policy to ensure the persistent volume remains even after the chart is uninstalled. |
| grafana.replicas | int | `2` | Number of Grafana replicas to deploy. |
| grafanaoperator | object | `{"fullnameOverride":"server-monitoring-grafana-operator","grafana":{"service":{"type":"ClusterIP"}},"image":{"repository":"quay.io/grafana-operator/grafana-operator","tag":"v5.16.0"}}` | Full values for the Grafana Operator chart can be obtained at: https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/values.yaml |
| grafanaoperator.fullnameOverride | string | `"server-monitoring-grafana-operator"` | Overrides the fully qualified app name. |
| grafanaoperator.grafana.service.type | string | `"ClusterIP"` | Specifies the type of service for Grafana. Options include ClusterIP, NodePort, or LoadBalancer. Use NodePort or LoadBalancer to expose Grafana externally. Ensure that grafana.credentials are set for security purposes. |
| grafanaoperator.image.repository | string | `"quay.io/grafana-operator/grafana-operator"` | Image repository for the Grafana Operator. |
| grafanaoperator.image.tag | string | `"v5.16.0"` | Tag for the Grafana Operator image. |
| prometheus.image.repository | string | `"quay.io/prometheus/prometheus"` | Image repository for Prometheus. |
| prometheus.image.tag | string | `"v3.2.0"` | Tag for the Prometheus image. |
| prometheus.persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the persistent volume. |
| prometheus.persistence.enabled | bool | `false` | Enable persistent storage for Prometheus. |
| prometheus.persistence.size | string | `"10Gi"` | Size of the persistent volume claim. |
| prometheus.persistence.storageClass | string | `""` | Storage class for persistent volume provisioner. You can create a custom storage class with a "retain" policy to ensure the persistent volume remains even after the chart is uninstalled. |
| prometheus.replicas | int | `2` | Number of Prometheus replicas to deploy. |
| prometheus.serviceMonitor.endpoints[0].port | string | `"prometheus-client"` | Port name for the Prometheus client service. |
| prometheus.serviceMonitor.selectorLabels | object | `{"app.kubernetes.io/instance":"circleci-server","app.kubernetes.io/name":"telegraf"}` | Labels to select ServiceMonitors for scraping metrics. By default, it's configured to scrape the existing Telegraf deployment in CircleCI server. |
| prometheus.serviceMonitor.selectorNamespaces | list | `[]` | Namespaces to look for ServiceMonitor objects. Set this if the CircleCI server monitoring stack is deploying in a different namespace than the actual CircleCI server installation. |
| prometheusOperator.image.repository | string | `"quay.io/prometheus-operator/prometheus-operator"` | Image repository for Prometheus Operator. |
| prometheusOperator.image.tag | string | `"v0.80.1"` | Tag for the Prometheus Operator image. |
| prometheusOperator.prometheusConfigReloader.image.repository | string | `"quay.io/prometheus-operator/prometheus-config-reloader"` | Image repository for Prometheus Config Reloader. |
| prometheusOperator.prometheusConfigReloader.image.tag | string | `"v0.80.1"` | Tag for the Prometheus Config Reloader image. |
| prometheusOperator.replicas | int | `1` | Number of Prometheus Operator replicas to deploy. |
| prometheusOperatorCRDs.install | bool | `false` |  |
