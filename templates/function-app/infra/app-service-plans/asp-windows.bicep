// Required parameters
param appServicePlanName string
param location string = resourceGroup().location

@description('Whether to use an existing App Service Plan')
param useExistingAppServicePlan bool

@description('The SKU name for the App Service Plan (e.g. F1, B1, P1v3, EP1).')
param skuName string

@description('Number of workers. Defaults to 3 for zone redundancy on Premium/ElasticPremium SKUs.')
param skuCapacity int = 3

@description('Resource ID of the subnet for VNet integration.')
param virtualNetworkSubnetId string

@description('Enable zone redundancy. Only supported on Premium (P*) and ElasticPremium (EP*) SKUs in ZRS-supported regions.')
param zoneRedundant bool

param tags object = {}

module newAppServicePlan 'br/public:avm/res/web/serverfarm:0.7.0' = if (!useExistingAppServicePlan) {
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

resource existingAppServicePlan 'Microsoft.Web/serverfarms@2025-03-01' existing = if (useExistingAppServicePlan) {
  name: appServicePlanName
}

@description('The resource ID of the App Service Plan.')
output appServicePlanResourceId string = (useExistingAppServicePlan) ? existingAppServicePlan.id : newAppServicePlan!.outputs.resourceId

@description('The name of the App Service Plan.')
output appServicePlanName string = (useExistingAppServicePlan) ? existingAppServicePlan.name : newAppServicePlan!.outputs.name
