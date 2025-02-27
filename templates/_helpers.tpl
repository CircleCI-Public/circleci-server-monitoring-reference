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
