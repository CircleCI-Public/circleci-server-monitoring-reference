# circleci-server-monitoring-reference
A reference for tools, configurations, and documentation used to monitor CircleCI server.

🚧 **Under Development**

This repository is currently under active development and is not yet a supported resource. Please refer to it at your own discretion until further notice.

# server-monitoring-stack

A reference Helm chart for setting up a monitoring stack for CircleCI server

![Version: 0.1.0-alpha.1](https://img.shields.io/badge/Version-0.1.0--alpha.1-informational?style=flat-square)

## Installing the Monitoring Stack

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://grafana.github.io/helm-charts | grafanaoperator(grafana-operator) | 5.16.* |
| https://prometheus-community.github.io/helm-charts | prometheusOperator(prometheus-operator-crds) | 18.0.* |

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

### 3. Add Helm Repository

First, add the CircleCI Server Monitoring Stack Helm repository:
```bash
$ helm repo add server-monitoring-stack https://packagecloud.io/circleci/server-monitoring-stack/helm
$ helm repo update
```

### 3. Install Dependencies

Before installing the full chart, you must first install the dependency subcharts, including the Prometheus Custom Resource Definitions (CRDs) and the Grafana operator chart. This assumes you are installing it in the same namespace as your CircleCI server installation:

```bash
$ helm install server-monitoring-stack server-monitoring-stack/server-monitoring-stack --set global.enabled=false --set prometheusOperator.installCRDs=true --version 0.1.0-alpha.1 -n <your-server-namespace>
```
> **_NOTE:_**  It's possible to install the monitoring stack in a different namespace than the CircleCI server installation. If you do so, set the `prometheus.serviceMonitor.selectorNamespaces` value with the target namespace.

### 4. Install the Helm Chart

Next, install the Helm chart using the following command:

```bash
$ helm upgrade --install server-monitoring-stack server-monitoring-stack/server-monitoring-stack --reset-values --version 0.1.0-alpha.1 -n <your-server-namespace>
```

### 5. Verify Prometheus Is Up and Targeting Telegraf
To verify that Prometheus is working correctly and targeting Telegraf, use the following command to port-forward Prometheus:

```bash
$ kubectl port-forward svc/server-monitoring-prometheus 9090:9090 -n <your-namespace-here>
```

Then visit http://localhost:9090/targets in your browser. Verify that Telegraf appears as a target and that its state is "up".

![Prometheus UI showing Telegraf target as up](docs/images/prometheus-telegraf-targets.png)

### 6. Verify Grafana Is Up and Connected to Prometheus

To verify that Grafana is working correctly and connected to Prometheus, use the following command to port-forward Grafana:
```bash
$ kubectl port-forward svc/server-monitoring-grafana-service 3000:3000 <your-namespace-here>
```

Then visit http://localhost:3000 in your browser. Once logged in with the default credentials, navigate to http://localhost:3000/dashboards and verify that the default dashboards are present and populating with data.

![Prometheus UI showing Telegraf target as up](docs/images/grafana-dashboards.png)

### 7. Next Steps

After ensuring both Prometheus and Grafana are operational, consider these enhancements:

#### Security
Secure Grafana by configuring credentials:
```yaml
grafana:
  credentials:
    adminUser: "admin"
    adminPassword: "<your-secure-password-here>"
    existingSecretName: "<your-secret-here>"
```
> **_NOTE:_** Consider using Kubernetes secrets for dynamic credential management.

#### Expose Grafana Externally

For external access, modify the service or ingress values. For example:
```yaml
grafana:
  service:
    type: LoadBalancer
```

#### Enabling Persistent Storage

Persist data by enabling storage for Prometheus and Grafana:
```yaml
prometheus:
  persistence:
    enabled: true
    storageClass: <your-custom-storage-class>
grafana:
  persistence:
    enabled: true
    storageClass: <your-custom-storage-class>
```
> **_NOTE:_** Use a custom storage class with a 'Retain' policy to secure data integrity.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.enabled | bool | `true` |  |
| global.fullnameOverride | string | `"server-monitoring"` | Override the full name for resources |
| global.imagePullSecrets | list | `[]` | List of image pull secrets to be used across the deployment |
| global.nameOverride | string | `""` | Override the release name |
| grafana.credentials.adminPassword | string | `"admin"` | Grafana admin password. Change from default for production environments. |
| grafana.credentials.adminUser | string | `"admin"` | Grafana admin username. |
| grafana.credentials.existingSecretName | string | `""` | Name of an existing secret for Grafana credentials. Leave empty to create a new secret. |
| grafana.customConfig | string | `""` | Add any custom Grafana configurations you require here. This should be a YAML-formatted string of additional settings for Grafana. |
| grafana.dashboards[0] | object | `{"json":"{\n  \"title\": \"CircleCI API Usage Dashboard\",\n  \"timezone\": \"browser\",\n  \"refresh\": \"5s\",\n  \"panels\": [\n    {\n      \"type\": \"timeseries\",\n      \"title\": \"API v2 Requests Count Over Time\",\n      \"targets\": [\n        {\n          \"expr\": \"circle.http.request.count\"\n        }\n      ]\n    }\n  ],\n  \"time\": {\n    \"from\": \"now-6h\",\n    \"to\": \"now\"\n  }\n}\n","name":"circleci-api-usage-dashboard","resyncPeriod":"30s"}` | Sample dashboards for basic monitoring of a CircleCI server installation. |
| grafana.datasource.jsonData.timeInterval | string | `"5s"` | The time interval for Grafana to poll Prometheus. Specifies the frequency of data requests. |
| grafana.enabled | string | `"-"` |  |
| grafana.image.repository | string | `"grafana/grafana"` | Image repository for Grafana. |
| grafana.image.tag | string | `"11.5.2"` | Tag for the Grafana image. |
| grafana.ingress.className | string | `""` | Specifies the class of the Ingress controller. Required if the Kubernetes cluster includes multiple Ingress controllers. |
| grafana.ingress.enabled | bool | `false` | Enable to create an Ingress resource for Grafana. Disabled by default. |
| grafana.ingress.host | string | `""` | Hostname to use for the Ingress. Must be set if Ingress is enabled. |
| grafana.ingress.tls.enabled | bool | `false` | Enable TLS for Ingress. Requires a TLS secret to be specified. |
| grafana.ingress.tls.secretName | string | `""` | Name of the TLS secret used for securing the Ingress. Must be provided if TLS is enabled. |
| grafana.persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the persistent volume. |
| grafana.persistence.enabled | bool | `false` | Enable persistent storage for Grafana. |
| grafana.persistence.size | string | `"10Gi"` | Size of the persistent volume claim. |
| grafana.persistence.storageClass | string | `""` | Storage class for persistent volume provisioner. You can create a custom storage class with a "retain" policy to ensure the persistent volume remains even after the chart is uninstalled. |
| grafana.replicas | int | `1` | Number of Grafana replicas to deploy. |
| grafana.service.annotations | object | `{}` | Metadata annotations for the service. |
| grafana.service.port | int | `3000` | Port on which the Grafana service will be exposed. |
| grafana.service.type | string | `"ClusterIP"` | Specifies the type of service for Grafana. Options include ClusterIP, NodePort, or LoadBalancer. Use NodePort or LoadBalancer to expose Grafana externally. Ensure that grafana.credentials are set for security purposes. |
| grafanaoperator | object | `{"fullnameOverride":"server-monitoring-grafana-operator","image":{"repository":"quay.io/grafana-operator/grafana-operator","tag":"v5.16.0"}}` | Full values for the Grafana Operator chart can be obtained at: https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/values.yaml |
| grafanaoperator.fullnameOverride | string | `"server-monitoring-grafana-operator"` | Overrides the fully qualified app name. |
| grafanaoperator.image.repository | string | `"quay.io/grafana-operator/grafana-operator"` | Image repository for the Grafana Operator. |
| grafanaoperator.image.tag | string | `"v5.16.0"` | Tag for the Grafana Operator image. |
| prometheus.enabled | string | `"-"` |  |
| prometheus.image.repository | string | `"quay.io/prometheus/prometheus"` | Image repository for Prometheus. |
| prometheus.image.tag | string | `"v3.2.1"` | Tag for the Prometheus image. |
| prometheus.persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the persistent volume. |
| prometheus.persistence.enabled | bool | `false` | Enable persistent storage for Prometheus. |
| prometheus.persistence.size | string | `"10Gi"` | Size of the persistent volume claim. |
| prometheus.persistence.storageClass | string | `""` | Storage class for persistent volume provisioner. You can create a custom storage class with a "retain" policy to ensure the persistent volume remains even after the chart is uninstalled. |
| prometheus.replicas | int | `2` | Number of Prometheus replicas to deploy. |
| prometheus.serviceMonitor.endpoints[0].port | string | `"prometheus-client"` | Port name for the Prometheus client service. |
| prometheus.serviceMonitor.selectorLabels | object | `{"app.kubernetes.io/instance":"circleci-server","app.kubernetes.io/name":"telegraf"}` | Labels to select ServiceMonitors for scraping metrics. By default, it's configured to scrape the existing Telegraf deployment in CircleCI server. |
| prometheus.serviceMonitor.selectorNamespaces | list | `[]` | Namespaces to look for ServiceMonitor objects. Set this if the CircleCI server monitoring stack is deploying in a different namespace than the actual CircleCI server installation. |
| prometheusOperator.crds.annotations."helm.sh/resource-policy" | string | `"keep"` |  |
| prometheusOperator.enabled | string | `"-"` |  |
| prometheusOperator.image.repository | string | `"quay.io/prometheus-operator/prometheus-operator"` | Image repository for Prometheus Operator. |
| prometheusOperator.image.tag | string | `"v0.80.1"` | Tag for the Prometheus Operator image. |
| prometheusOperator.installCRDs | bool | `false` |  |
| prometheusOperator.prometheusConfigReloader.image.repository | string | `"quay.io/prometheus-operator/prometheus-config-reloader"` | Image repository for Prometheus Config Reloader. |
| prometheusOperator.prometheusConfigReloader.image.tag | string | `"v0.80.1"` | Tag for the Prometheus Config Reloader image. |
| prometheusOperator.replicas | int | `1` | Number of Prometheus Operator replicas to deploy. |

## Releasing

Releases are managed by the CI/CD pipeline on the main branch, with an approval job gate called `approve-deploy-chart`. Before releasing, increment the Helm chart version in `Chart.yaml` and regenerate the documentation using `./do helm-docs`. Once approved, the release will be available in the [package repository](https://packagecloud.io/circleci/server-monitoring-stack).
