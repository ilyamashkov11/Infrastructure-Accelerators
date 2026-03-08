// Required parameters
param appServicePlanName string
param location string = resourceGroup().location

// SKU
@description('The SKU name for the App Service Plan (e.g. F1, B1, P1v3, EP1).')
param skuName string

@description('Number of workers. Defaults to 3 for zone redundancy on Premium/ElasticPremium SKUs.')
param skuCapacity int = 3

// Networking
@description('Resource ID of the subnet for VNet integration.')
param virtualNetworkSubnetId string

// Zone Redundancy
@description('Enable zone redundancy. Only supported on Premium (P*) and ElasticPremium (EP*) SKUs in ZRS-supported regions.')
param zoneRedundant bool

// Tags
param tags object = {}

module appServicePlan 'br/public:avm/res/web/serverfarm:0.7.0' = {
  name: 'asp-windows-AVM-module'
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    kind: 'app'
    reserved: false
    skuName: skuName
    skuCapacity: skuCapacity
    zoneRedundant: zoneRedundant
    virtualNetworkSubnetId: !empty(virtualNetworkSubnetId) ? virtualNetworkSubnetId : null
  }
}

@description('The resource ID of the App Service Plan.')
output appServicePlanResourceId string = appServicePlan.outputs.resourceId

@description('The name of the App Service Plan.')
output appServicePlanName string = appServicePlan.outputs.name
