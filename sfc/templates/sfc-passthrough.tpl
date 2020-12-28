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
            - name: ENDPOINT_NETWORK_SERVICE
              value: "sfc-{{ .Values.prefix }}"
            - name: ENDPOINT_LABELS
              value: "app={{ .Values.prefix }}-passthrough"
            - name: CLIENT_NETWORK_SERVICE
              value: "sfc-{{ .Values.prefix }}"
            - name: CLIENT_LABELS
              value: "app={{ .Values.prefix }}-passthrough"
            - name: TRACER_ENABLED
              value: {{ .Values.global.JaegerTracing | default false | quote }}
            - name: JAEGER_AGENT_HOST
              value: jaeger.nsm-system
            - name: JAEGER_AGENT_PORT
              value: "6831"
          resources:
            limits:
              networkservicemesh.io/socket: 1
metadata:
  name: {{ .Values.prefix }}-passthrough
  namespace: {{ .Release.Namespace }}
