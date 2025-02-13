targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string


var tags = {
  'azd-env-name': name
}

var resourceToken = toLower(uniqueString(subscription().id, name, location))

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${name}'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  scope: rg
  name: 'resources'
  params: {
    location: location
    tags: tags
    resourceToken: resourceToken
  }
}

output AZURE_CONTAINER_REGISTRY_NAME string = resources.outputs.acrName
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = resources.outputs.acrLoginServer
output API_URI string = resources.outputs.apiUri
