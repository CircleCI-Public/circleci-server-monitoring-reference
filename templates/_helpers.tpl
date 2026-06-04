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

{{/*
Return whether a dashboard JSON path should be provisioned for serverMetricsProfile.
Profile legacy: Telegraf-era Server SLIs only. server410: OTEL 4.10+ SLIs only. both: all dashboards.
*/}}
{{- define "grafana.dashboard.include" -}}
{{- $profile := .profile | default "both" -}}
{{- $base := base .path -}}
{{- $isServer410 := contains "server4.10" $base -}}
{{- $isServerSlis := hasPrefix "server-slis" $base -}}
{{- if eq $profile "both" -}}
true
{{- else if eq $profile "legacy" -}}
{{- if $isServer410 -}}false{{- else -}}true{{- end -}}
{{- else if eq $profile "server410" -}}
{{- if $isServer410 -}}true{{- else if $isServerSlis -}}false{{- else -}}true{{- end -}}
{{- else -}}
false
{{- end -}}
{{- end -}}
