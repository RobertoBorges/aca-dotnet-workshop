---
canonical_url: 'https://bitoftech.net/2022/08/25/deploy-microservice-application-azure-container-apps/'
---

# Module 1 - Deploy Backend API to Azure Containers Apps (ACA)
!!! info "Module Duration"
    30 minutes

In this module, we will start by creating the first microservice named `ACA Web API – Backend` as illustrated in the [architecture diagram](../../assets/images/00-workshop-intro/ACA-Architecture-workshop.jpg). Followed by that we will provision the  Azure resources needed to deploy the service to Azure Container Apps using the Azure CLI.

### 1. Deploy Web API Backend Project to ACA
We will be using Azure CLI to deploy the Web API Backend to ACA as shown in the following steps:

- We will start with Installing/Upgrading the Azure Container Apps Extension.
    ```shell
    # Upgrade Azure CLI
    az upgrade
    # Login to Azure
    az login --use-device-code
    # Only required if you have multiple subscriptions
    az account set --subscription <name or id>
    # Install/Upgrade Azure Container Apps Extension
    az extension add --name containerapp --upgrade
    ```  

- Define the variables below in the PowerShell console to use them across the different modules in the workshop. You should change the values of those variables to be able to create the resources successfully. Some of those variables should be unique across all Azure subscriptions such as Azure Container Registry name. Remember to replace the place holders with your own values:

    ```shell
    export RESOURCE_GROUP="tasks-tracker-rg"
    export LOCATION="eastus"
    export ENVIRONMENT="tasks-tracker-containerapps-env"
    export WORKSPACE_NAME="<replace this with your unique app log analytics workspace name>"
    export APPINSIGHTS_NAME="<replace this with your unique app insights name>"
    export BACKEND_API_NAME="tasksmanager-backend-api"
    export ACR_NAME="<replace this with your unique acr name>"
    export YOUR_ACA_ENV_UNIQUE_ID="<replace this with your initialls and the current day, e.g.: rbb053020>"
    ```

- Create a `resource group` to organize the services related to the application, run the below command:
    ```shell
    az group create \
    --name $RESOURCE_GROUP \
    --location "$LOCATION"
    ```

- Create an Azure Container Registry (ACR) instance in the resource group to store images of all Microservices we are going to build during this workshop. Make sure that you set the `admin-enabled` flag to true in order to seamlessly authenticate the Azure container app when trying to create the container app using the image stored in ACR

    ```shell
    az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic \
    --admin-enabled true
    ```
!!! note
    Notice that we create the registry with admin rights `--admin-enabled` flag set to `true` which is not suited for real production, but good for our workshop.

- Create an Azure Log Analytics Workspace which will provide a common place to store the system and application log data from all container apps running in the environment. Each environment should have its own Log Analytics Workspace. To create it, run the command below:
    ```shell
    # create the log analytics workspace
    az monitor log-analytics workspace create \
    --resource-group $RESOURCE_GROUP \
    --workspace-name $WORKSPACE_NAME

    # retrieve workspace ID
    export WORKSPACE_ID=$(az monitor log-analytics workspace show --query customerId \
    -g $RESOURCE_GROUP \
    -n $WORKSPACE_NAME -o tsv)

    # retrieve workspace secret
    export WORKSPACE_SECRET=$(az monitor log-analytics workspace get-shared-keys --query primarySharedKey \
    -g $RESOURCE_GROUP \
    -n $WORKSPACE_NAME -o tsv)
    ```
- Create an [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview?tabs=net) Instance which will be used mainly for [distributed tracing](https://learn.microsoft.com/en-us/azure/azure-monitor/app/distributed-tracing) between different container apps within the ACA environment to provide searching for and visualizing an end-to-end flow of a given execution or transaction. To create it, run the command below:
    ```shell
    # Install the application-insights extension for the CLI
    az extension add -n application-insights
    
    # Create application-insights instance
    az monitor app-insights component create \
    -g $RESOURCE_GROUP \
    -l $LOCATION \
    --app $APPINSIGHTS_NAME \
    --workspace $WORKSPACE_NAME
    
    # Get Application Insights Instrumentation Key
    export APPINSIGHTS_INSTRUMENTATIONKEY=$(az monitor app-insights component show \
    --app $APPINSIGHTS_NAME -g $RESOURCE_GROUP | jq -r '.instrumentationKey')
    ```

- Now we will create an Azure Container Apps Environment. As a reminder of the different ACA component [check this link in the workshop introduction](../../aca/00-workshop-intro/1-aca-core-components.md). The ACA environment acts as a secure boundary around a group of container apps that we are going to provision during this workshop. To create it, run the below command:
    ```shell
    # Create the ACA environment
    az containerapp env create \
    --name $ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --logs-workspace-id $WORKSPACE_ID \
    --logs-workspace-key $WORKSPACE_SECRET \
    --dapr-instrumentation-key $APPINSIGHTS_INSTRUMENTATIONKEY \
    --location $LOCATION
    ```
??? tip "Want to learn what above command does?"
    - It creates an ACA environment and associates it with the Log Analytics Workspace created in the previous step.
    - We are setting the `--dapr-instrumentation-key` value to the instrumentation key of the Application Insights instance. This will come handy when we introduce Dapr in later modules and show how the distributed tracing between microservices/container apps are captured and visualized in Application Insights.  
    > **_NOTE:_**
    You can set the `--dapr-instrumentation-key` after you create the ACA environment but this is not possible via the AZ CLI right now. There is an [open issue](https://github.com/microsoft/azure-container-apps/issues/293) which is being tracked by the product group.

-  Build the Web API project on ACR and push the docker image to ACR. Use the below command to initiate the image build and push process using ACR. The `.` at the end of the command represents the docker build context, in our case, we need to be on the parent directory which hosts the `.csproj`.

    ```shell
    az acr build --registry $ACR_NAME --image "tasksmanager/$BACKEND_API_NAME" --file 'TasksTracker.TasksManager.Backend.Api/Dockerfile' .
    ```
    Once this step is completed you can verify the results by going to the Azure portal and checking that a new repository named `tasksmanager/tasksmanager-backend-api` has been created and there is a new docker image with a `latest` tag is created.

-  The last step here is to create and deploy the Web API to ACA following the below command. Remember to replace the place holders with your own values:

    ```shell
    az containerapp create \
    --name $BACKEND_API_NAME  \
    --resource-group $RESOURCE_GROUP \
    --environment $ENVIRONMENT \
    --image "$ACR_NAME.azurecr.io/tasksmanager/$BACKEND_API_NAME:latest" \
    --registry-server "$ACR_NAME.azurecr.io" \
    --target-port 80 \
    --ingress 'external' \
    --min-replicas 1 \
    --max-replicas 1 \
    --cpu 0.25 --memory 0.5Gi \
    --query configuration.ingress.fqdn
    ```
??? tip "Want to learn what above command does?"
    - Ingress param is set to `external` which means that this container app (Web API) project will be accessible from the public internet. When Ingress is set to `Internal` or `External` it will be assigned a fully qualified domain name (FQDN). Important notes about IP addresses and domain names can be found [here](https://learn.microsoft.com/en-us/azure/container-apps/ingress?tabs=bash#ip-addresses-and-domain-names).
    - The target port param is set to 80, this is the port our Web API container listens to for incoming requests.
    - We didn't specify the ACR registry username and password, `az containerapp create` command was able to look up ACR username and password and add them as a secret under the created Azure container app for future container updates.
    - The minimum and the maximum number of replicas are set. More about this when we cover Autoscaling in later modules. For the time being, only a single instance of this container app will be provisioned as Auto scale is not configured.
    - We set the size of the Container App. The total amount of CPUs and memory requested for the container app must add up to certain combinations, for full details check the link [here](https://docs.microsoft.com/en-us/azure/container-apps/containers#configuration).
    - The `query` property will filter the response coming from the command and just return the FQDN. Take note of this FQDN as you will need it for the next step.

    For full details on all available parameters for this command, please visit this [page](https://docs.microsoft.com/en-us/cli/azure/containerapp?view=azure-cli-latest#az-containerapp-create).  

-  You can now verify the deployment of the first ACA by navigating to the Azure Portal and selecting the resource group named `tasks-tracker-rg` that you created earlier. You should see the 5 recourses created below.
![Azure Resources](../../assets/images/01-deploy-api-to-aca/Resources.jpg)

!!! success
    
    To test the backend api service, copy the FQDN (Application URL) of the Azure container app named `tasksmanager-backend-api`. 
    Issue a `GET` request similar to this one: `https://tasksmanager-backend-api.<your-aca-env-unique-id>.eastus.azurecontainerapps.io/api/tasks/?createdby=tjoudeh@bitoftech.net` and you should receive an array of the 10 tasks similar to the below image.

    !!! tip 
        You can find your azure container app application url on the azure portal overview tab.

    ![Web API Response](../../assets/images/01-deploy-api-to-aca/Response.jpg)

In the next module, we will see how we will add a new Frontend Web App as a microservice and how it will communicate with the backend API.
