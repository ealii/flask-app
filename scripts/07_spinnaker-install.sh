#!/bin/bash

# https://spinnaker.io/docs/setup/install/providers/kubernetes-v2/

CONTEXT=$(kubectl config current-context)

hal config provider kubernetes enable
hal config provider kubernetes account add minikube \
    --context $CONTEXT \
    --only-spinnaker-managed true

# https://spinnaker.io/docs/setup/install/environment/

hal config deploy edit --type distributed --account-name minikube

# https://spinnaker.io/docs/setup/install/storage/minio/

MINIO_ACCESS_KEY=kHeJF3RaY2tsoU6QeJzJ
MINIO_SECRET_KEY=dAMVCQ3QKypG3m7yWJrEvjRwezgvWkhaX090sdsS

echo $MINIO_SECRET_KEY | hal config storage s3 edit \
    --endpoint http://minio.minio:9000 \
    --access-key-id $MINIO_ACCESS_KEY \
    --secret-access-key \
    --path-style-access true

hal config storage edit --type s3

mkdir -p ~/.hal/default/profiles
echo "spinnaker.s3.versioning: false" > ~/.hal/default/profiles/front50-local.yml

# https://spinnaker.io/docs/guides/user/pipeline/pipeline-templates/

hal config features edit --pipeline-templates true
hal config features edit --managed-pipeline-templates-v2-ui true

# https://spinnaker.io/docs/setup/other_config/artifacts/github/

GITHUB_TOKEN=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

hal config artifact github enable
echo $GITHUB_TOKEN | hal config artifact github account add github --token

# https://spinnaker.io/docs/setup/other_config/artifacts/gitrepo/

hal config artifact gitrepo enable
echo $GITHUB_TOKEN | hal config artifact gitrepo account add github.com --token

# https://spinnaker.io/docs/setup/other_config/ci/jenkins/

JENKINS_APIKEY=11abdc5c1d98490e2fd471fbc63ee2aabd

hal config ci jenkins enable
echo $JENKINS_APIKEY | hal config ci jenkins master add jenkins \
    --address http://jenkins.jenkins:8080 \
    --username admin \
    --password \
    --csrf true

# https://spinnaker.io/docs/setup/other_config/canary/#set-up-canary-analysis-for-aws
# https://spinnaker.io/docs/setup/other_config/canary/#set-up-canary-analysis-to-use-prometheus

hal config canary enable
hal config canary prometheus enable
hal config canary prometheus account add prometheus \
    --base-url http://prometheus-prometheus.prometheus:9090
hal config canary aws enable
echo $MINIO_SECRET_KEY | hal config canary aws account add minio \
    --endpoint http://minio.minio:9000 \
    --bucket spin-4f6c3c09-b955-4f99-8d72-6cbd3690d0a7 \
    --access-key-id $MINIO_ACCESS_KEY \
    --secret-access-key
hal config canary aws edit --s3-enabled true
hal config canary edit \
    --default-metrics-store prometheus \
    --default-metrics-account prometheus \
    --default-storage-account minio

# https://spinnaker.io/docs/setup/install/deploy/

# hal version list
hal config stats disable
hal config edit --timezone Europe/Kiev
hal config version edit --version 1.30.2
hal deploy apply
hal deploy connect