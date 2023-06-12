#!/bin/bash

# https://artifacthub.io/packages/helm/prometheus-community/prometheus

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
    --version 46.8.0 \
    --namespace prometheus \
    --create-namespace \
    --wait \
    --set fullnameOverride=prometheus,defaultRules.create=false \
    --set alertmanager.enabled=false,grafana.enabled=false,kubernetesServiceMonitors.enabled=false,nodeExporter.enabled=false \
    --set kubeStateMetrics.enabled=false,prometheus.serviceMonitor.selfMonitor=false,prometheusOperator.serviceMonitor.selfMonitor=false \
    --values - <<EOF
prometheus:
  prometheusSpec:
    storageSpec:
     volumeClaimTemplate:
       spec:
         storageClassName: standard
         accessModes: ["ReadWriteOnce"]
         resources:
           requests:
             storage: 8Gi
EOF

kubectl port-forward svc/prometheus-prometheus 9090 -n prometheus