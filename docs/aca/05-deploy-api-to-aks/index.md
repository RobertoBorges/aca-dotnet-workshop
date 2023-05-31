---
canonical_url: https://bitoftech.net/2022/08/29/azure-container-apps-state-store-with-dapr-state-management-api/
---

# Module 4 - Deploy Frontend App to Azure App Service and integrate with Azure Container intance App running Backend API
!!! info "Module Duration"
    20 minutes

In this module, we will deploy the frontend web app to Azure App Service and integrate it with the backend API running on Azure Container Instances.

The goal is to confirm that images you build to run on Azure can run in multiple environments. In this case, we will run the frontend web app on Azure App Service and the backend API on Azure Container Instances.

### Overview of App Service

Azure App Service is a fully managed web hosting service for building web apps, mobile back ends, and RESTful APIs. It provides out-of-the-box support for authentication, push notifications, offline sync, and more. You can also add your own REST APIs to enable your app scenarios.

## Deploy an App Service plan

```shell
az appservice plan create --resource-group $RESOURCE_GROUP --name pam$FRONTEND_WEBAPP_NAME --sku S1 --is-linux
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