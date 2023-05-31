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

## Deploy an AKS integrated with Azure Container Registry (ACR)

```shell
az aks create --resource-group $RESOURCE_GROUP --name aks-$YOUR_ACA_ENV_UNIQUE_ID --node-count 1 --enable-addons monitoring --generate-ssh-keys --attach-acr $ACR_NAME
```

### Deploy the frontend web app to Azure App Service using the image from Azure Container Registry

```shell

az webapp create --resource-group $RESOURCE_GROUP --plan pam$FRONTEND_WEBAPP_NAME --name $FRONTEND_WEBAPP_NAME-$YOUR_ACA_ENV_UNIQUE_ID --deployment-container-image-name "$ACR_NAME.azurecr.io/tasksmanager/$FRONTEND_WEBAPP_NAME:latest"
```
### Update the backend API URL to the Azure Container Instances App URL

```shell

az webapp config appsettings set --resource-group $RESOURCE_GROUP --name $FRONTEND_WEBAPP_NAME-$YOUR_ACA_ENV_UNIQUE_ID --settings BackendApiConfig__BaseUrlExternalHttp=http://tasksmanager-backend-api-$YOUR_ACA_ENV_UNIQUE_ID.eastus.azurecontainer.io

```
!!! success
    Browse the web app , and you should be able to see the same results and access the backend API endpoints from the Web App but now we are using Web Apps + Container Instances.

In the next module we will start to deploy the same app but now using Azure Kubernetes Service (AKS).