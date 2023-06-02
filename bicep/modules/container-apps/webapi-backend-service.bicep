targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource Id of the container apps environment.')
param containerAppsEnvironmentId string

@description('The name of the service for the backend api service. The name is use as Dapr App ID.')
param backendApiServiceName string

// Container Registry & Image
@description('The name of the container registry.')
param containerRegistryName string

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string

@description('The image for the backend api service.')
param backendApiServiceImage string

@secure()
@description('The Application Insights Instrumentation.')
param appInsightsInstrumentationKey string

@description('The target and dapr port for the backend api service.')
param backendApiPortNumber int

// ------------------
// RESOURCES
// ------------------

resource backendApiService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: backendApiServiceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
        '${containerRegistryUserAssignedIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        external: false
        targetPort: backendApiPortNumber
      }
      dapr: {
        enabled: true
        appId: backendApiServiceName
        appProtocol: 'http'
        appPort: backendApiPortNumber
        logLevel: 'info'
        enableApiLogging: true
      }
      registries: !empty(containerRegistryName) ? [
        {
          server: '${containerRegistryName}.azurecr.io'
          identity: containerRegistryUserAssignedIdentityId
        }
      ] : []
      secrets: [
        {
          name: 'appinsights-key'
          value: appInsightsInstrumentationKey
        }
      ]
    }
    template: {
      containers: [
        {
          name: backendApiServiceName
          image: backendApiServiceImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'ApplicationInsights__InstrumentationKey'
              secretRef: 'appinsights-key'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the container app for the backend api service.')
output backendApiServiceContainerAppName string = backendApiService.name

@description('The FQDN of the backend api service.')
output backendApiServiceFQDN string = backendApiService.properties.configuration.ingress.fqdn
