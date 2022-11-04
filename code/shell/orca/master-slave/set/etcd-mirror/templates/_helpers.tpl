{{/*
Expand the name of the chart.
*/}}
{{- define "etcd-mirror.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "etcd-mirror.fullname" -}}
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

{{- define "etcd-mirror.endpoints.master" -}}
{{- $master_endpoints := "" }}
{{- if .Values.endpoints.master }}
{{- $master_endpoints = .Values.endpoints.master }}
{{- else }}
{{- $dp := (lookup "apps/v1" "Deployment" .Release.Namespace (include "etcd-mirror.fullname" .)) }}
{{- if $dp }}
{{- $master_endpoints = index $dp.annotations "master_endpoints" }}
{{- end }}
{{- end }}
{{- printf "%s" $master_endpoints }}
{{- end }}

{{- define "etcd-mirror.endpoints.slave" -}}
{{- $slave_endpoints := "" }}
{{- if .Values.endpoints.slave }}
{{- $slave_endpoints = .Values.endpoints.slave }}
{{- else }}
{{- $dp := (lookup "apps/v1" "Deployment" .Release.Namespace (include "etcd-mirror.fullname" .)) }}
{{- if $dp }}
{{- $slave_endpoints = index $dp.annotations "slave_endpoints" }}
{{- end }}
{{- end }}
{{- printf "%s" $slave_endpoints }}
{{- end }}

{{- define "etcd-mirror.configmap" -}}
{{- $master_etcd_cert := "" }}
{{- if ne .Values.configmap.master_etcd_auth.master_etcd_cert .Values.configmap.master_etcd_auth.master_etcd_cert_default }}
{{- $master_etcd_cert = .Values.configmap.master_etcd_auth.master_etcd_cert }}
{{- else }}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.configmap.master_etcd_auth.name) }}
{{- if $secret }}
{{- $master_etcd_cert = index $secret.data "master_etcd_cert" }}
{{- end }}
{{- end }}
{{- $master_etcd_cacert := "" }}
{{- if ne .Values.configmap.master_etcd_auth.master_etcd_cacert .Values.configmap.master_etcd_auth.master_etcd_cacert_default }}
{{- $master_etcd_cacert = .Values.configmap.master_etcd_auth.master_etcd_cacert }}
{{- else }}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.configmap.master_etcd_auth.name) }}
{{- if $secret }}
{{- $master_etcd_cacert = index $secret.data "master_etcd_cacert" }}
{{- end }}
{{- end }}
{{- $master_etcd_key := "" }}
{{- if ne .Values.configmap.master_etcd_auth.master_etcd_key .Values.configmap.master_etcd_auth.master_etcd_key_default }}
{{- $master_etcd_key = .Values.configmap.master_etcd_auth.master_etcd_key }}
{{- else }}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.configmap.master_etcd_auth.name) }}
{{- if $secret }}
{{- $master_etcd_key = index $secret.data "master_etcd_key" }}
{{- end }}
{{- end }}
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    control-plane: orca-etcd-mirror
  name: {{ .Values.configmap.master_etcd_auth.name }}
  namespace: {{ .Release.Namespace }}
data:
  ca.crt: |-
    {{ $master_etcd_cacert | toString | nindent 4 }}
  server.crt: |-
    {{ $master_etcd_cert | toString | nindent 4 }}
  server.key: |-
    {{ $master_etcd_key | toString | nindent 4 }}
{{- end }}

{{- define "system_default_registry" -}}
{{- if .Values.global.orcaRegistry -}}
{{- printf "%s/" .Values.global.orcaRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{- define "registry_url" -}}
{{- if .Values.global.privateRegistry.registryUrl -}}
{{- printf "%s/" .Values.global.privateRegistry.registryUrl -}}
{{- else -}}
{{ include "system_default_registry" . }}
{{- end -}}
{{- end -}}

{{- define "capabilities.crd.version" -}}
{{- if and (.Capabilities.APIVersions.Has "apiextensions.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) -}}
{{- print "v1" -}}
{{- else -}}
{{- print "v1beta1" -}}
{{- end -}}
{{- end -}}
