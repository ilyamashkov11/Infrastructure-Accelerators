//? ==============================================================================================
//?                             App Service Plan Parameters
//? ==============================================================================================
@description('When set to "true" uses an already existing App Service Plan for this Function App')
param useExistingAppServicePlan bool

@description('Name of the App Service Plan to be created')
param appServicePlanName string

@allowed(['FC1', 'B1'])
@description('Name of the SKU for a new App Service Plan')
param skuName string?

@description('Whether to appply zone redundancy to the Function Apps in this App Service Plan')
param zoneRedundant bool


//? ==============================================================================================
//?                                 Function App Parameters
//? ==============================================================================================
@description('Name of the Function App')
param functionAppName string

@description('Whether to use vNet integration for the Function App')
param useVnetIntegration bool

@allowed(['Linux', 'Windows'])
@description('Operating System for this app service')
param functionAppOsType string

@description('Force all traffic to be HTTPS')
param forceHttps bool

@description('App settings to add to the base settings of the app')
param appSettings object

@description('Whether to have the site always on even when the Function App is down')
param alwaysOn bool

@description('Whether to enable end-to-end encryption')
param e2eEncryptionEnabled bool

@description('FTPS state')
@allowed(['AllAllowed', 'FtpsOnly', 'Disabled'])
param ftpsState string

@description('Path to the health check endpoint for this Function App')
param healthCheckPath string

@description('Linux only: Runtime stack and version (e.g. "DOTNET-ISOLATED|8.0", "NODE|20", "PYTHON|3.11").')
@allowed(['DOTNET-ISOLATED|8.0'])
param linuxFxVersion string

@allowed(['1.0', '1.1', '1.2', '1.3'])
param minTlsVersion string

@description('Public network access to the Function AApp and the site (scm)')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string

@description('Whether to create the Function App with a SAMI (System Assigned Managed Identity)')
param managedIdentity bool


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

@description('Size of the subnet that will be created for the private endpoints')
param privateEndpointsSubnetAddressPrefix string?

@description('Name of thew subnet created for private endpoints')
param privateEndpointsSubnetName string?

@description('Subnets to deploy into the vNet. If using private endpoints, a dedicated subnet is automatically added to this array')
param subnets array?

@description('Whether to provision Network Security Groups as part of the new network deployment')
param useNetworkSecurityGroups bool

@description('Configuration objects for NSGs')
param networkSecurityGroupConfigs array?


//? ==============================================================================================
//?                                 Storage Account Parameters
//? ==============================================================================================
@description('Whether to use a Storage Account with the Function App')
param useStorageAccount bool


//? ==============================================================================================
//?                                 Application Insights Parameters
//? ==============================================================================================
@description('Whether to use a Application Insights with the Function App')
param useApplicationInsights bool 

//? ==============================================================================================
//?                                         Modules
//? ==============================================================================================
module network 'network/main.bicep' = if (useVnetIntegration) {
    name: 'network-main'
    params: {
        networkSecurityGroupConfigs: networkSecurityGroupConfigs!
        subnets: subnets!
        useExistingVnet: useExistingVnet
        useNetworkSecurityGroups: useNetworkSecurityGroups
        usePrivateEndpoints: usePrivateEndpoints
        virtualNetworkName: newVnetName!
        addressPrefixes: [newVnetSize]
        privateEndpointsSubnetAddressPrefix: privateEndpointsSubnetAddressPrefix
        privateEndpointsSubnetName: privateEndpointsSubnetName
    }
}

module AppServicePlan 'app-service-plans/main.bicep' = {
    name: 'app-service-plan-main'
    params: {
        functionAppOsType: functionAppOsType
        useExistingAppServicePlan: useExistingAppServicePlan
        zoneRedundant: zoneRedundant
        appServicePlanName: appServicePlanName
        skuName: skuName
    }
}

module storageAccount 'storage/main.bicep' = if (useStorageAccount) {
    name: 'storage-account-main'
}

module applicationInsights 'application-insights/main.bicep' = if (useApplicationInsights) {
    name: 'application-insights-main'
}

module functionApps 'function-apps/main.bicep' = {
    name: 'function-apps-main'
    params: {
        tags: {}
        alwaysOn: alwaysOn
        appServicePlanResourceId: AppServicePlan.outputs.appServicePlanResourceId
        appSettings: appSettings
        applicationInsightsResourceId: (useApplicationInsights) ? applicationInsights!.outputs.applicationInsightsResourceId : null
        e2eEncryptionEnabled: e2eEncryptionEnabled
        ftpsState: ftpsState
        functionAppName: functionAppName
        healthCheckPath: healthCheckPath
        linuxFxVersion: linuxFxVersion
        managedIdentity: managedIdentity
        minTlsVersion: minTlsVersion
        operatingSystem: functionAppOsType
        storageAccountResourceId: (useStorageAccount) ? storageAccount!.outputs.storageAccountResourceId : null
        // network params
        forceHttps: forceHttps
        publicNetworkAccess: publicNetworkAccess
        virtualNetworkSubnetResourceId: (useVnetIntegration) ? network!.outputs.virtualNetworkResourceId : null
    }
}

