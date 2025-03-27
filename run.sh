#!/bin/bash

ENV=$1

if [ "$ENV" == "dev" ]; then
  CONFIG_DIR=local
elif [ "$ENV" == "prd" ]; then
  CONFIG_DIR=gcp
else
  CONFIG_DIR=local
fi

echo "ENV: $ENV"

kubectl apply -f "$CONFIG_DIR" --recursive

echo "Done"