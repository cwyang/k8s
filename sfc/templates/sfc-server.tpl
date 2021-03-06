---
apiVersion: apps/v1
kind: Deployment
spec:
  selector:
    matchLabels:
      networkservicemesh.io/app: "{{ .Values.prefix }}-server"
      networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
  replicas: 1
  template:
    metadata:
      labels:
        networkservicemesh.io/app: "{{ .Values.prefix }}-server"
        networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
    spec:
      serviceAccount: nse-acc
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: networkservicemesh.io/app
                    operator: In
                    values:
                      - {{ .Values.prefix }}-server
              topologyKey: "kubernetes.io/hostname"
      containers:
        - name: vpn-gateway
          image: {{ .Values.registry }}/{{ .Values.org }}/test-common:{{ .Values.tag }}
          command: ["/bin/icmp-responder-nse"]
          imagePullPolicy: {{ .Values.pullPolicy }}
          env:
            - name: ADVERTISE_NSE_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: ADVERTISE_NSE_LABELS
              value: "app={{ .Values.prefix }}-server"
            - name: IP_ADDRESS
              value: "172.16.1.0/24"
{{- if .Values.global.JaegerTracing }}
            - name: TRACER_ENABLED
              value: {{ .Values.global.JaegerTracing | default false | quote }}
            - name: JAEGER_AGENT_HOST
              value: jaeger.nsm-system
            - name: JAEGER_AGENT_PORT
              value: "6831"
{{- end }}
          resources:
            limits:
              networkservicemesh.io/socket: 1
        - name: nginx
          image: {{ .Values.registry }}/networkservicemesh/nginx:latest
metadata:
  name: {{ .Values.prefix }}-server
  namespace: {{ .Release.Namespace }}
