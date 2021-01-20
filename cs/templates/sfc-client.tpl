---
apiVersion: apps/v1
kind: Deployment
spec:
  selector:
    matchLabels:
      networkservicemesh.io/app: "{{ .Values.prefix }}-client"
      networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
  replicas: 1
  template:
    metadata:
      labels:
        networkservicemesh.io/app: "{{ .Values.prefix }}-client"
        networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
    spec:
      serviceAccount: nsc-acc
      containers:
        - name: alpine-img
          image: alpine:latest
          imagePullPolicy: {{ .Values.pullPolicy }}
          command: ['tail', '-f', '/dev/null']
{{- if .Values.global.JaegerTracing }}
          env:
            - name: TRACER_ENABLED
              value: {{ .Values.global.JaegerTracing | default false | quote }}
            - name: JAEGER_AGENT_HOST
              value: jaeger
            - name: JAEGER_AGENT_PORT
              value: "6831"
{{- end }}
metadata:
  name: {{ .Values.prefix }}-client
  namespace: {{ .Release.Namespace }}
  annotations:
    ns.networkservicemesh.io: sfc-{{ .Values.prefix }}
