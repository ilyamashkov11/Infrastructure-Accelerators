//? ==============================================================================================
//?                             App Service Plan Parameters
//? ==============================================================================================
@description('When set to "true" uses an already existing App Service Plan for this Function App')
param useExistingAppServicePlan bool

@description('Name of the App Service Plan to be created')
param newAppServicePlanName string?

@description('Name of an existing App Service Plan')
param existingAppServicePlanName string?

@allowed(['FC1', 'B1'])
@description('Name of the SKU for a new App Service Plan')
param skuName string

@description('Whether to appply zone redundancy to the Function Apps in this App Service Plan')
param zoneRedundant bool


//? ==============================================================================================
//?                                 Function App Parameters
//? ==============================================================================================
@description('Whether to use vNet integration for the Function App')
param useVnetIntegration bool

@allowed(['Linux', 'Windows'])
@description('Operating System for this app service')
param functionAppOsType string

@description('Force all traffic to be HTTPS')
param forceHttps bool

@description('App settings to add to the base settings of the app')
param appSettings object


//? ==============================================================================================
//?                                     Network Parameters 
//?                     (only applies when useVnetIntegration setting = true)
//? ==============================================================================================
@description('Whether to use an existing vNet or create a new one')
param useExistingVnet bool

@description('Name of an existing vNet')
param existingVnetName string?

@description('Name of the new vNet')
param newVnetName string?

@description('Size of the new vNet in CIDR notation. e.g. 10.241.0.0/16')
param newVnetSize string?

@description('Whether to deploy private endpoints for the Function App')
param usePrivateEndpoints bool

@description('Name of thew subnet created for private endpoints')
param privateEndpointsSubnetName string?

@description('Subnets to deploy into the vNet. If using private endpoints, a dedicated subnet is automatically added to this array')
param subnets array?

@description('Whether to provision Network Security Groups as part of the new network deployment')
param useNetworkSecurityGroups bool

@description('Configuration objects for NSGs')
param networkSecurityGroupConfigs array?


//? ==============================================================================================
//?                                         Modules
//? ==============================================================================================
//TODO: add existing app service plans

module AppServicePlanLinux 'app-service-plans/asp-linux.bicep' = if (!useExistingAppServicePlan && functionAppOsType == 'Linux') {
    name: 'app-service-plan-linux-main'
    params: {
        appServicePlanName: newAppServicePlanName
        skuName: skuName
        virtualNetworkSubnetId: '' // TODO: allow for creation of vNets
        zoneRedundant: zoneRedundant
    }
}

module AppServicePlanWindows 'app-service-plans/asp-windows.bicep' = if (!useExistingAppServicePlan && functionAppOsType == 'Windows') {
    name: 'app-service-plan-windows-main'
    params: {
        appServicePlanName: newAppServicePlanName
        skuName: skuName
        virtualNetworkSubnetId: '' // TODO: allow for creation of vNets
        zoneRedundant: zoneRedundant
    }
}
