{{/*
Expand the name of the chart.
*/}}
{{- define "agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "agent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "agent.labels" -}}
helm.sh/chart: {{ include "agent.chart" . }}
{{ include "agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the namespace to use
*/}}
{{- define "agent.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}

{{/*
Create configuration with auto-populated Temporal settings
*/}}
{{- define "agent.config" -}}
{{- $config := deepCopy .Values.config }}
{{- if .Values.temporal.enabled }}
  {{- if not (hasKey $config "services") }}
    {{- $_ := set $config "services" (dict) }}
  {{- end }}
  {{- $services := $config.services }}
  {{- if not (kindIs "map" $services) }}
    {{- $services = dict }}
    {{- $_ := set $config "services" $services }}
  {{- end }}
  {{- $temporalConfig := dict }}
  {{- if hasKey $services "temporal" }}
    {{- if kindIs "map" $services.temporal }}
      {{- $temporalConfig = $services.temporal }}
    {{- end }}
  {{- end }}
  {{- if not (hasKey $temporalConfig "host") }}
    {{- $_ := set $temporalConfig "host" (printf "temporal-frontend.%s.svc.cluster.local" .Release.Namespace) }}
  {{- end }}
  {{- if not (hasKey $temporalConfig "port") }}
    {{- $_ := set $temporalConfig "port" 7233 }}
  {{- end }}
  {{- if not (hasKey $temporalConfig "namespace") }}
    {{- $_ := set $temporalConfig "namespace" "default" }}
  {{- end }}
  {{- $_ := set $services "temporal" $temporalConfig }}
{{- end }}
{{- /* Process template values in login.endpoint */ -}}
{{- if hasKey $config "login" }}
  {{- if hasKey $config.login "endpoint" }}
    {{- $_ := set $config.login "endpoint" (tpl $config.login.endpoint .) }}
  {{- end }}
{{- end }}
{{- toYaml $config }}
{{- end }}

