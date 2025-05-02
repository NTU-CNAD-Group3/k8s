# K8s

This repository contains three environments for deploying the services: dev, staging, and production (on GKE). Each environment has its own configuration files and setup instructions.

## Environments setup

### Dev

> [!NOTE]
> Dev environment is a local environment for development and testing our microservices. It is a lightweight environment and doesn't provide any additional features like HA or scaling.

1. Install Docker Desktop and enable Kubernetes.

   - Windows : win11
   - docker : Docker Desktop 4.39.0 (184744)
   - kubectl : v1.32.2

2. Setup Secrets

Before starting the dev environment, please make sure you have setup the correct secrets for the services. We provide a template for the secrets in the `/secret/secrets-template.yaml` file. FYI, the secrets should be encoded in base64 format. You can use the following command to encode the secrets: (Windows users can use `git bash` or `wsl` to run this command)

```bash
echo -n 'your-secret' | base64
```

Copy the encoded secret to the `secrets-template.yaml` file and rename it to `secrets.yaml` in the `dev/secret` folder. The secrets will be mounted to the services as environment variables.

3. Setup the k8s cluster

To setup the k8s cluster, please run the following command:

```bash
run.sh --dev
```

This will create the k8s cluster and deploy the services to the cluster. The services will be accessible at `http://kubernetes.docker.internal`

### Staging

> [!WARNING]
> Staging environment haven't completely setup yet. Please use the dev environment for development and testing.

### Google Cloud

We use github actions to deploy the services to GKE. The deployment process is automated and will be triggered on every push to the `main` branch. The deployment process will build the docker images, push them to the GCP artifact registry, and rollout the changes to the GKE cluster.

- connect to GCP

```bash
gcloud auth login
gcloud components install gke-gcloud-auth-plugin
```

- add GKE credentials

```bash
gcloud container clusters get-credentials cnad-prod-gke --zone asia-east1-a --project cnad-group3
```
