@description('Name of the App Service')
@minLength(2)
@maxLength(60)
param name string

@description('Azure region for resource deployment')
param location string

@description('Resource tags to apply')
param tags object = {}

@description('ID of the App Service Plan to host the app')
param appServicePlanId string

@description('Name of the Azure Container Registry')
param containerRegistryName string

@description('Name of the container image')
param containerRegistryImageName string

@description('Tag of the container image')
param containerRegistryImageTag string

// Get reference to ACR
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
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
    principalId: webApp.identity.principalId
  }
}

output name string = webApp.name
output principalId string = webApp.identity.principalId
output uri string = 'https://${webApp.properties.defaultHostName}'
