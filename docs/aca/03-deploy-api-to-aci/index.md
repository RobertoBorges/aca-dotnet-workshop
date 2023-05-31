---
canonical_url: https://bitoftech.net/2022/08/29/dapr-integration-with-azure-container-apps/
---

# Module 3 - Deploy the same backend image but now using Azure Container instances 
!!! info "Module Duration"
    20 minutes

In this module, we weill reuse the same backend API and deploy it to Azure Container Instances (ACI). We will then deploy the same frontend web app and integrate both using Azure Container Instances.

### Benefits of using Azure Container Instances

- No VM management required
- No cluster management required
- Fastest and simplest way to run a container in Azure
- Billing by the second
- Integrate with Azure Virtual Network
- Integrate with Azure Container Registry
- Integrate with Azure Monitor
- Integrate with Azure Key Vault
- Etc..

### Deploy Azure container instances using the previous image storage on Azure Container Registry

## Get the ACR Username and Password

```shell
export acrpss=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)
export acrusr=$(az acr credential show --name $ACR_NAME --query "username" -o tsv)

az container create --resource-group $RESOURCE_GROUP --name $BACKEND_API_NAME --image "$ACR_NAME.azurecr.io/tasksmanager/$BACKEND_API_NAME:latest" --registry-login-server "$ACR_NAME.azurecr.io" --registry-username $acrusr --registry-password $acrpss --dns-name-label $BACKEND_API_NAME-$YOUR_ACA_ENV_UNIQUE_ID --ports 80
```

!!! success
    
    To test the backend api service, copy the FQDN (Application URL) of the Azure container app named `tasksmanager-backend-api`. 
    Issue a `GET` request similar to this one: `https://tasksmanager-backend-api<YOUR_ACA_ENV_UNIQUE_ID>.eastus.azurecontainer.io/api/tasks/?createdby=tjoudeh@bitoftech.net` and you should receive an array of the 10 tasks similar to the below image.

    !!! tip 
        You can find your azure container instances app application url on the azure portal overview tab.

    ![Web API Response](../../assets/images/01-deploy-api-to-aca/Response.jpg)
