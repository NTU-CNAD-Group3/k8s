# K8s

This repository contains the Kubernetes yaml files for both the local and google cloud environments.

## Local

To setup the local environment, please make sure you have kubernetes installed. You can install kubernetes by docker desktop or minikube.

```bash
kubectl version
```

To apply the yaml files, run the following command:

```bash
./run.sh --dev
```

## Google Cloud

To setup the google cloud environment, please make sure you have setup the kubernetes context to the google cloud.

```bash
kubectl config get-contexts
kubectl config use-context <context-name>
```

To apply the yaml files, run the following command:

```bash
./run.sh --prd
```

## Introduction

This repository contains the following services:

1. gateway : deployment + service + `nginx-ingress` as ingress controller
2. notification : deployment + service
3. auth : deployment + service
4. postgres_auth : deployment + service + persistent volume claim + storage class
5. rabbitmq : deployment + service + persistent volume claim + storage class
6. redis : deployment + service + persistent volume claim + storage class
7. secret : just use default kubernetes secret for now
