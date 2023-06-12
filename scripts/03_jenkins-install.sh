#!/bin/bash

# https://artifacthub.io/packages/helm/jenkinsci/jenkins

helm repo add jenkinsci https://charts.jenkins.io/
helm install jenkins jenkinsci/jenkins \
    --version 4.3.26 \
    --namespace jenkins \
    --create-namespace \
    --wait \
    --set fullnameOverride=jenkins,persistence.storageClass=standard

kubectl port-forward svc/jenkins 8080 -n jenkins