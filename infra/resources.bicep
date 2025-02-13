targetScope = 'resourceGroup'

param location string
param tags object
param resourceToken string

module acr 'core/container-registry.bicep' = {
  name: 'acr'
  params: {
    name: 'acr${resourceToken}'
    location: location
    tags: tags
  }
}

module appServicePlan 'core/host/appservice-plan.bicep' = {
  name: 'appservice-plan'
  params: {
    name: 'plan-${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'B1'
    }
  }
}

module api 'core/host/appservice.bicep' = {
  name: 'api'
  params: {
    name: 'app-api-${resourceToken}'
    location: location
    tags: union(tags, {
      'azd-service-name': 'api'
    })
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryName: acr.outputs.name
    containerRegistryImageName: 'fastapi'  // Make sure this matches
    containerRegistryImageTag: 'latest'
  }
}

output acrName string = acr.outputs.name
output acrLoginServer string = acr.outputs.loginServer
output apiUri string = api.outputs.uri
