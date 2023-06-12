#!/bin/bash

minikube start \
    --driver virtualbox \
    --cpus 4 \
    --memory 24g \
    --cni calico \
    --addons dashboard,default-storageclass,ingress,metrics-server