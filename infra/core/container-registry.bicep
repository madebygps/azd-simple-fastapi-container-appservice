param name string
param location string = resourceGroup().location
param tags object = {}
param adminUserEnabled bool = true
param skuName string = 'Basic'

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

output name string = acr.name
output loginServer string = acr.properties.loginServer
