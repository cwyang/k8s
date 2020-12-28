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
metadata:
  name: {{ .Values.prefix }}-proxy2
  namespace: {{ .Release.Namespace }}
  annotations:
    ns.networkservicemesh.io: sfc-{{ .Values.prefix }}
