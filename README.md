# K8s

This repository contains two environments for deploying the services: dev, and production (on GKE). Each environment has its own configuration files and setup instructions.

## Environments setup

### Dev

> [!NOTE]
> Dev environment is a local environment for development and testing our microservices. It is a lightweight environment and doesn't provide any additional features like secret manager and service mesh. It is supplementary method for local development and testing. You should use docker-compose for local development first.

1. Install Docker Desktop and enable Kubernetes.

   - Windows : win11
   - docker : Docker Desktop 4.39.0 (184744)
   - kubectl : v1.32.2

2. Setup Secrets

Before starting the dev environment, please make sure you have setup the correct secrets for the services. We provide a template for the secrets in the `dev/secret/secrets-template.yaml` file. FYI, the secrets should be encoded in base64 format. You can use the following command to encode the secrets: (Windows users can use `git bash` or `wsl` to run this command)

```bash
echo -n 'your-secret' | base64
```

Copy the encoded secret to the `secrets-template.yaml` file and rename it to `secrets.yaml` in the `dev/secret` folder. The secrets will be mounted to the services as environment variables.

3. Setup the k8s cluster

To setup the k8s cluster, please run the following command:

```bash
run.sh --dev
```

This will create the k8s cluster and deploy the services to the cluster. The services will be accessible at `http://kubernetes.docker.internal`.

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

## Service Mesh

To have a better observability and (maybe) for traffic management and canary deployment, we use Istio as our service mesh.

Before deploying the services, please make sure you have installed `istioctl` and added the istioctl to your PATH. You can download the istioctl from the [Istio website](https://istio.io/latest/docs/setup/getting-started/).

After installing istioctl, please run the following command to install Istio in your cluster:

```bash
istioctl install --set profile=minimal -y
```

If your resource is limited, you can modify the default resource requests and limits in the Istio configuration. For example, you can set the CPU and memory requests and limits to 200m and 1Gi respectively. You can do this by modifying the `istio-operator.yaml` file in the `istio` folder.

```yaml
resources:
  requests:
    cpu: 200m
    memory: 1Gi
```

After installing Istio, you can verify the installation by running the following command:

```bash
kubectl -n istio-system get pods
```

After installing the control plane, you need to enable the sidecar injection for the namespaces and also rollout the deployment. You can do this by running the following command for each namespace:

```bash
kubectl label namespace <namespace> istio-injection=enabled --overwrite
```

```bash
kubectl label namespace gateway istio-injection=enabled --overwrite
kubectl rollout restart deployment -n gateway gateway
```
