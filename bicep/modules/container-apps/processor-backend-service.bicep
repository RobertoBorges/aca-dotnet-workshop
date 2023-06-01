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

@description('The name of the service for the backend processor service. The name is use as Dapr App ID and as the name of service bus topic subscription.')
param backendProcessorServiceName string

@secure()
@description('The Application Insights Instrumentation.')
param appInsightsInstrumentationKey string

// Container Registry & Image
@description('The name of the container registry.')
param containerRegistryName string

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string

@description('The image for the backend processor service.')
param backendProcessorServiceImage string

@description('The dapr port for the backend processor service.')
param backendProcessorPortNumber int

// ------------------
// RESOURCES
// ------------------

resource backendProcessorService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: backendProcessorServiceName
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
      dapr: {
        enabled: true
        appId: backendProcessorServiceName
        appProtocol: 'http'
        appPort: backendProcessorPortNumber
        logLevel: 'info'
        enableApiLogging: true
      }
      secrets: [
        {
          name: 'appinsights-key'
          value: appInsightsInstrumentationKey
        }
      ]
      registries: !empty(containerRegistryName) ? [
        {
          server: '${containerRegistryName}.azurecr.io'
          identity: containerRegistryUserAssignedIdentityId
        }
      ] : []
    }
    template: {
      containers: [
        {
          name: backendProcessorServiceName
          image: backendProcessorServiceImage
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
        maxReplicas: 5
      }
    }
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the container app for the backend processor service.')
output backendProcessorServiceContainerAppName string = backendProcessorService.name
