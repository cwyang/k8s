---
apiVersion: apps/v1
kind: Deployment
spec:
  selector:
    matchLabels:
      networkservicemesh.io/app: "{{ .Values.prefix }}-passthrough"
      networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
  replicas: 1
  template:
    metadata:
      labels:
        networkservicemesh.io/app: "{{ .Values.prefix }}-passthrough"
        networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
    spec:
      serviceAccount: nse-acc
      containers:
        - name: passthrough-nse
          image: {{ .Values.registry }}/{{ .Values.org }}/vpp-test-common:{{ .Values.tag }}
          imagePullPolicy: {{ .Values.pullPolicy }}
          env:
            - name: TEST_APPLICATION
              value: "vppagent-firewall-nse"
            - name: ADVERTISE_NSE_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: ADVERTISE_NSE_LABELS
              value: "app={{ .Values.prefix }}-passthrough"
            - name: OUTGOING_NSC_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: OUTGOING_NSC_LABELS
              value: "app={{ .Values.prefix }}-passthrough"
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
metadata:
  name: {{ .Values.prefix }}-passthrough
  namespace: {{ .Release.Namespace }}
