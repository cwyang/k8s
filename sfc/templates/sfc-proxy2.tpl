---
apiVersion: apps/v1
kind: Deployment
spec:
  selector:
    matchLabels:
      networkservicemesh.io/app: "{{ .Values.prefix }}-proxy2"
      networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
  replicas: 1
  template:
    metadata:
      labels:
        networkservicemesh.io/app: "{{ .Values.prefix }}-proxy2"
        networkservicemesh.io/impl: "sfc-{{ .Values.prefix }}"
    spec:
      serviceAccount: nsc-acc
      containers:
        - name: alpine-img
          image: alpine:latest
          imagePullPolicy: {{ .Values.pullPolicy }}
          command: ['tail', '-f', '/dev/null']
          env:
            - name: ADVERTISE_NSE_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: ADVERTISE_NSE_LABELS
              value: "app={{ .Values.prefix }}-proxy2"
            - name: OUTGOING_NSE_NAME
              value: "sfc-{{ .Values.prefix }}"
            - name: OUTGOING_NSC_LABELS
              value: "app={{ .Values.prefix }}-proxy2"
metadata:
  name: {{ .Values.prefix }}-proxy2
  namespace: {{ .Release.Namespace }}
  annotations:
    ns.networkservicemesh.io: sfc-{{ .Values.prefix }}
