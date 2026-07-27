{{/*
Expand the name of the chart.
*/}}
{{- define "stroom-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stroom-proxy.fullname" -}}
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
{{- define "stroom-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "stroom-proxy.labels" -}}
helm.sh/chart: {{ include "stroom-proxy.chart" . }}
{{ include "stroom-proxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "stroom-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stroom-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "stroom-proxy.serviceAccountName" -}}
{{- .Values.serviceAccount.name | default (include "stroom-proxy.fullname" .) }}
{{- end }}

{{- define "stroom-proxy.image" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end }}

{{- define "stroom-proxy.feedStatusUrl" -}}
{{- printf "%s%s" .Values.stroom.baseUri .Values.stroom.paths.feedStatus }}
{{- end }}

{{- define "stroom-proxy.forwardUrl" -}}
{{- .Values.forwarding.url | default (printf "%s%s" .Values.stroom.baseUri .Values.stroom.paths.datafeed) }}
{{- end }}

{{- define "stroom-proxy.localDataVolumeMounts" -}}
- mountPath: /stroom-proxy/content
  subPath: content
  name: data
- mountPath: /stroom-proxy/db
  subPath: db
  name: data
- mountPath: /stroom-proxy/logs
  subPath: logs
  name: data
- mountPath: /stroom-proxy/data
  subPath: data
  name: data
{{- end }}
