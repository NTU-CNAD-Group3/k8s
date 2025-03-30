# K8s

This repository contains three environments for deploying the services: dev, staging, and production (on GKE). Each environment has its own configuration files and setup instructions.

## Dev

To setup the local environment, please make sure you have kubernetes installed. You can install kubernetes by docker desktop or minikube.

```bash
kubectl version
```

To apply the yaml files, run the following command:

```bash
./run.sh --dev
```

Dev environment is a local environment for development and testing our microservices. It is a lightweight environment that uses local resources and does not require many resources.

## Staging

To setup the local environment, please make sure you have kubernetes installed. You can install kubernetes by docker desktop or minikube.

```bash
kubectl version
```

To apply the yaml files, run the following command:

```bash
./run.sh --stage
```

The difference between dev and stage is that the stage environment will be more similar to the production environment. The stage environment will use some HA techniques, such as using sentinel for redis, pgpool for postgres, and service mesh, which will need many memory and CPU resources. So please make sure you have enough resources in your local machine.

## Google Cloud

To setup the google cloud environment, please make sure you have setup the kubernetes context to the google cloud.

```bash
kubectl config get-contexts
kubectl config use-context <context-name>
```

To apply the yaml files, run the following command:

```bash
./run.sh --prod
```
