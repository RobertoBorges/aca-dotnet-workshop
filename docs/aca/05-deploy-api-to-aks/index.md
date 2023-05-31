---
canonical_url: https://bitoftech.net/2022/08/29/azure-container-apps-state-store-with-dapr-state-management-api/
---

# Module 5 - Deploy Frontend and Backend to Azure Kubernetes Service (AKS)
!!! info "Module Duration"
    30 minutes

In this module we will deploy the frontend and backend to Azure Kubernetes Service (AKS). We will use the same images deployed to Azure Container Registry (ACR) in the previous module.

The goal is to see how different services in Azure can accomodate your strategy to deploy containerized applications.

### Overview of Azure Kubernetes Service (AKS)

Azure Kubernetes Service (AKS) manages your hosted Kubernetes environment, making it quick and easy to deploy and manage containerized applications without container orchestration expertise. It also eliminates the burden of ongoing operations and maintenance by provisioning, upgrading, and scaling resources on demand, without taking your applications offline.

### Deploy an AKS integrated with Azure Container Registry (ACR)

```shell
az aks create --resource-group $RESOURCE_GROUP --name aks-$YOUR_ACA_ENV_UNIQUE_ID --node-count 1 --enable-addons monitoring --generate-ssh-keys --attach-acr $ACR_NAME
```

### Get AKS credentials
    
```shell
az aks get-credentials --resource-group $RESOURCE_GROUP --name aks-$YOUR_ACA_ENV_UNIQUE_ID
```

### Configure your yaml files

Edit the file deploy-frontend.yaml and replace the value <replace with your ACR name> with your ACR name.

Edit the file deploy-backend.yaml and replace the value <replace with your ACR name> with your ACR name.

### Deploy frontend and backend to AKS

```shell
cd docs/aca/05-deploy-api-to-aks

kubectl apply -f ./deploy-backend.yaml

kubectl apply -f ./deploy-frontend.yaml

```

### Get the IP address of the frontend web app

```shell
kubectl get service frontend-service

```

If the previous command doesn't return the IP address of the frontend web app, you can use the following wait and try again after 10 seconds.

!!! success
    Browse the web app using the IP you got from the previous command, use the following email: tjoudeh@bitoftech.net , you should be able to see the same results and access the backend API endpoints from the Web App but now we are using Kubernetes services.