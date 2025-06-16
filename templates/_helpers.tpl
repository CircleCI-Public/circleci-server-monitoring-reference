{{/*
Return the fully qualified name of a resource based on the chart's full name, nameOverride, or fullnameOverride.
*/}}
{{- define "server-monitoring.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.global.nameOverride -}}
{{- printf "%s-%s" $name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Compute if prometheusOperator is enabled.
*/}}
{{- define "prometheusOperator.enabled" -}}
{{- $_ := set . "prometheusOperatorEnabled" (or
  (eq (.Values.prometheusOperator.enabled | toString) "true")
  (and (eq (.Values.prometheusOperator.enabled | toString) "-") (eq (.Values.global.enabled | toString) "true"))) -}}
{{- end -}}

{{/*
Compute if prometheus is enabled.
*/}}
{{- define "prometheus.enabled" -}}
{{- $_ := set . "prometheusEnabled" (or
  (eq (.Values.prometheus.enabled | toString) "true")
  (and (eq (.Values.prometheus.enabled | toString) "-") (eq (.Values.global.enabled | toString) "true"))) -}}
{{- end -}}

{{/*
Compute if grafana is enabled.
*/}}
{{- define "grafana.enabled" -}}
{{- $_ := set . "grafanaEnabled" (or
  (eq (.Values.grafana.enabled | toString) "true")
  (and (eq (.Values.grafana.enabled | toString) "-") (eq (.Values.global.enabled | toString) "true"))) -}}
{{- end -}}

{{/*
Compute if tempo is enabled.
*/}}
{{- define "tempo.enabled" -}}
{{- $_ := set . "tempoEnabled" (or
  (eq (.Values.tempo.enabled | toString) "true")
  (and (eq (.Values.tempo.enabled | toString) "-") (eq (.Values.global.enabled | toString) "true"))) -}}
{{- end -}}
