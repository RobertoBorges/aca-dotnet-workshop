targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// -----------------

@description('Name for the container group')
param aciName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The tags to be assigned to the created resources.')
param tags object = {}

@description('Port to open on the container and the public IP address.')
param port int = 80

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2


@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string

@description('The name of the container registry to pull images from.')
param containerRegistryName string

@description('The image for the backend api service.')
param backendApiServiceImage string 

@description('The behavior of Azure runtime if container has stopped.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: aciName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${containerRegistryUserAssignedIdentityId}': {}
    }
  }
  properties: {
    imageRegistryCredentials: [
      {
        server: '${containerRegistryName}.azurecr.io'
        identity: containerRegistryUserAssignedIdentityId
      }
    ]
    containers: [
      {
        name: aciName
        properties: {
          image: backendApiServiceImage
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy 
    ipAddress: {
      type: 'Public'
      dnsNameLabel: aciName
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
  }
}

output backendACIFQDN string = containerGroup.properties.ipAddress.fqdn
