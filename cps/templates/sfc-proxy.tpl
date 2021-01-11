---
apiVersion: apps/v1
kind: Deployment
spec:
  selector:
    matchLabels:
      networkservicemesh.io/app: "{{ .Values.prefix }}-proxy"
      networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
  replicas: 1
  template:
    metadata:
      labels:
        networkservicemesh.io/app: "{{ .Values.prefix }}-proxy"
        networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
    spec:
      serviceAccount: nse-acc
      containers:
        - name: proxy-nse
          image: alpine:latest
          imagePullPolicy: {{ .Values.pullPolicy }}
          command: ['tail', '-f', '/dev/null']
{{- if .Values.global.JaegerTracing }}
          env:
            - name: TEST_APPLICATION
              value: "proxy-nse"
            - name: ADVERTISE_NSE_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: ADVERTISE_NSE_LABELS
              value: "app={{ .Values.prefix }}-proxy"
            - name: IP_ADDRESS
              value: "172.16.1.0/24"
            - name: OUTGOING_NSC_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: OUTGOING_NSC_LABELS
              value: app=test
            - name: TRACER_ENABLED
              value: "true" 
              jvalue: "app={{ .Values.prefix }}-proxy"
           - name: JAEGER_AGENT_HOST
              value: jaeger.nsm-system
            - name: JAEGER_AGENT_PORT
              value: "6831"
{{- end }}
          resources:
            limits:
              networkservicemesh.io/socket: 1
metadata:
  name: {{ .Values.prefix }}-proxy
  namespace: {{ .Release.Namespace }}
  annotations:
    ns.networkservicemesh.io: sfc-{{ .Values.prefix }}
