#!/bin/bash

# https://artifacthub.io/packages/helm/bitnami/minio

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install minio bitnami/minio \
    --version 12.6.4 \
    --namespace minio \
    --create-namespace \
    --wait \
    --set fullnameOverride=minio,persistence.storageClass=standard

kubectl port-forward svc/minio 9001 -n minio