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
          image: {{ .Values.registry }}/{{ .Values.org }}/vpp-test-common:{{ .Values.tag }}
          imagePullPolicy: {{ .Values.pullPolicy }}
          env:
            - name: TEST_APPLICATION
              value: "vppagent-firewall-nse"
            - name: ADVERTISE_NSE_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: ADVERTISE_NSE_LABELS
              value: "app={{ .Values.prefix }}-proxy"
            - name: OUTGOING_NSC_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: OUTGOING_NSC_LABELS
              value: "app={{ .Values.prefix }}-proxy"
{{- if .Values.global.JaegerTracing }}
            - name: TRACER_ENABLED
              value: "true"
            - name: JAEGER_AGENT_HOST
              value: jaeger
            - name: JAEGER_AGENT_PORT
              value: "6831"
{{- end }}
          resources:
            limits:
              networkservicemesh.io/socket: 1
          volumeMounts:
            - mountPath: /etc/vppagent-firewall/config.yaml
              subPath: config.yaml
              name: vppagent-firewall-config-volume
        - name: nginx
          image: {{ .Values.registry }}/{{ .Values.org }}/nginx:latest
      volumes:
        - name: vppagent-firewall-config-volume
          configMap:
            name: vppagent-firewall-config-file
metadata:
  name: {{ .Values.prefix }}-proxy
  namespace: {{ .Release.Namespace }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: vppagent-firewall-config-file
  namespace: {{ .Release.Namespace }}
data:
  config.yaml: |
    aclRules:
      "Allow ICMP": "action=reflect,icmptype=8"
      "Allow TCP 80": "action=reflect,tcplowport=80,tcpupport=80"
