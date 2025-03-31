#!/bin/bash

ENV=$1

if [ -z "$ENV" ]; then
  tput setaf 3; echo "No environment specified. Defaulting to dev."; tput sgr0
  ENV=dev
fi

if [ "$ENV" != "dev" ] && [ "$ENV" != "stage" ] && [ "$ENV" != "prod" ]; then
  tput setaf 1; echo "Invalid environment specified. Use 'dev', 'stage', or 'prod'."; tput sgr0
  exit 1
fi
tput setaf 2; echo "Building kubernetes resources for $ENV environment."; tput sgr0

if [ "$ENV" == "dev" ]; then
  CONFIG_DIR=dev

  docker build -t cnad-gateway:latest -f ../gateway/Dockerfile.dev ../gateway
  docker build -t cnad-notification:latest -f ../notification/Dockerfile.dev ../notification
  docker build -t cnad-auth:latest -f ../auth/Dockerfile.dev ../auth
elif [ "$ENV" == "stage" ]; then
  CONFIG_DIR=stage
  
  docker build -t cnad-gateway:latest -f ../gateway/Dockerfile.prd ../gateway
  docker build -t cnad-notification:latest -f ../notification/Dockerfile.prd ../notification
  docker build -t cnad-auth:latest -f ../auth/Dockerfile.prd ../auth
elif [ "$ENV" == "prod" ]; then
  CONFIG_DIR=prod
fi

if [ ! "$ENV" == "prod" ] && [ ! -f "$CONFIG_DIR/secret/secrets.yaml" ]; then
  tput setaf 1; echo "Secrets file not found. Please create $CONFIG_DIR/secrets/secrets.yaml."; tput sgr0 
  exit 1
fi


apply_kubectl() {
  kubectl apply -f "$1" --recursive
  if [ $? -ne 0 ]; then
    tput setaf 1; echo "Error applying resources in $1"; tput sgr0
  fi
}

apply_kubectl "$CONFIG_DIR/common"
# only apply secrets if not in prod
if [ ! "$ENV" == "prod" ]; then
  apply_kubectl "$CONFIG_DIR/secret"
fi
apply_kubectl "$CONFIG_DIR/redis"
apply_kubectl "$CONFIG_DIR/postgres-auth"
apply_kubectl "$CONFIG_DIR/rabbitmq"
apply_kubectl "$CONFIG_DIR/gateway"
apply_kubectl "$CONFIG_DIR/notification"
apply_kubectl "$CONFIG_DIR/auth"

if [ "$ENV" == "dev" ]; then
  tput setaf 3; echo "Applying ingress-nginx controller."; tput sgr0
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.1/deploy/static/provider/cloud/deploy.yaml
  if [ $? -ne 0 ]; then
    tput setaf 1; echo "Error applying ingress-nginx controller."; tput sgr0
  fi
fi

tput setaf 3; echo "Waiting for all pods to be in running state."; tput sgr0
kubectl wait --for=condition=Ready pod -l app=redis --timeout=60s --namespace=redis
kubectl wait --for=condition=Ready pod -l app=queue --timeout=60s --namespace=queue
kubectl wait --for=condition=Ready pod -l app=postgres-auth --timeout=60s --namespace=postgres-auth

echo
tput setaf 3; echo "Deleting all pods in all namespaces."; tput sgr0
tput setaf 2; echo "Pods will be recreated automatically."; tput sgr0
kubectl delete --all pods --namespace=gateway
kubectl delete --all pods --namespace=notification
kubectl delete --all pods --namespace=auth

echo 
tput setaf 2; echo "Successfully applied kubernetes resources for $ENV environment."; tput sgr0

echo
tput setaf 3; echo "Cleaning up old images."; tput sgr0
docker image prune -f
tput setaf 2; echo "Successfully cleaned up old images."; tput sgr0