---
apiVersion: apps/v1
kind: Deployment
spec:
  selector:
    matchLabels:
      networkservicemesh.io/app: "{{ .Values.prefix }}-proxy1"
      networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
  replicas: 1
  template:
    metadata:
      labels:
        networkservicemesh.io/app: "{{ .Values.prefix }}-proxy1"
        networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
    spec:
      serviceAccount: nse-acc
      containers:
        - name: alpine-img
          image: alpine:latest
          imagePullPolicy: {{ .Values.pullPolicy }}
          command: ['tail', '-f', '/dev/null']
          env:
            - name: ADVERTISE_NSE_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: ADVERTISE_NSE_LABELS
              value: "app={{ .Values.prefix }}-proxy1"
            - name: OUTGOING_NSC_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: OUTGOING_NSC_LABELS
              value: "app={{ .Values.prefix }}-proxy1"
metadata:
  name: {{ .Values.prefix }}-proxy1
  namespace: {{ .Release.Namespace }}
  annotations:
    ns.networkservicemesh.io: sfc-{{ .Values.prefix }}
