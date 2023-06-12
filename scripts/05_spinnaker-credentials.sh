#!/bin/bash

# https://spinnaker.io/docs/setup/install/providers/kubernetes-v2/#optional-create-a-kubernetes-service-account

CONTEXT=$(kubectl config current-context)

kubectl apply --context $CONTEXT -f ../manifests/spinnaker.yaml
kubectl config set-credentials ${CONTEXT}-token-user --token \
    $(kubectl get secret --context $CONTEXT \
        spinnaker-service-account-token \
        -n spinnaker \
        -o jsonpath='{.data.token}' | base64 --decode) && \
kubectl config set-context $CONTEXT --user ${CONTEXT}-token-user

kubectl config view --flatten > /tmp/config && mv /tmp/config ~/.kube/config
chmod 744 ~/.kube/config