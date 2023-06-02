targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// -----------------

@description('The name of the service for the frontend web app service. The name is use as Dapr App ID.')
param frontendWebAppServiceName string

@description('The name of the image for the frontend web app service.')
param frontendWebAppServiceImage string

@description('The tags to be assigned to the created resources.')
param tags object = {}

@description('The SKU of App Service Plan')
param sku string = 'S1' // The SKU of App Service Plan

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string

@description('The FQDN of the backend API service.')
param backendACIFQDN string

var appServicePlanName = toLower('AppServicePlan-${frontendWebAppServiceName}')

var webSiteName = toLower('wapp-${frontendWebAppServiceName}')

// ------------------
//    VARIABLES
// -----------------

var linuxFxVersion = 'DOCKER|${frontendWebAppServiceImage}' 

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
        '${containerRegistryUserAssignedIdentityId}': {}
    }
  }  
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: containerRegistryUserAssignedIdentityId
      appSettings: [
        {
          name: 'BackendApiConfig__BaseUrlExternalHttp'
          value: 'http://${backendACIFQDN}/'
        }
      ]
    }
  }
}
