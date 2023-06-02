targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param containerRegistryName string

@description('The tags to be assigned to the created resources.')
param tags object = {}

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: containerRegistryName
  location: location
  tags: tags
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
