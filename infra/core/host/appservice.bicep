param name string
param location string
param tags object = {}
param appServicePlanId string
param containerRegistryName string
param containerRegistryImageName string
param containerRegistryImageTag string

// Get reference to ACR
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      acrUseManagedIdentityCreds: true
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/${containerRegistryImageName}:${containerRegistryImageTag}'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
    }
  }
}

// Now use the registry-access module for RBAC
module registryAccess '../security/registry_access.bicep' = {
  name: 'registry-access'
  params: {
    containerRegistryName: containerRegistryName
    principalId: appService.identity.principalId
  }
}

output name string = appService.name
output principalId string = appService.identity.principalId
output uri string = 'https://${appService.properties.defaultHostName}'
