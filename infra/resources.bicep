targetScope = 'resourceGroup'

@description('The Azure region for resource deployment')
param location string

@description('Resource tags that should be applied to all resources')
param tags object

@description('Name of the container registry')
param containerRegistryName string

@description('Name of the app service')
param appServiceName string

@description('Name of the app service plan')
param appServicePlanName string

module acr 'core/container-registry.bicep' = {
  name: 'acr'
  params: {
    name: containerRegistryName
    location: location
    tags: tags
  }
}

module appServicePlan 'core/host/appservice-plan.bicep' = {
  name: 'appservice-plan'
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    sku: {
      name: 'F1'
    }
  }
}

module api 'core/host/appservice.bicep' = {
  name: 'api'
  params: {
    name: appServiceName
    location: location
    tags: union(tags, {
      'azd-service-name': 'api'
    })
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryName: acr.outputs.name
    containerRegistryImageName: 'fastapi'
    containerRegistryImageTag: 'latest'
  }
}

output acrName string = acr.outputs.name
output acrLoginServer string = acr.outputs.loginServer
output apiUri string = api.outputs.uri
