using '../main.bicep'

// fill with company specific information
var orgName = ''
var environmentCode = ''  //? e.g. "dev" for Development
var locationCode = ''     //? e.g. "aue" for australiaeast
var instanceSuffix = ''

// use these suffixes to maintain a standardised naming for Azure resources deployed by this template
var resourceSuffix = (empty(instanceSuffix)) ? '${orgName}-${environmentCode}-${locationCode}' : '${orgName}-${environmentCode}-${locationCode}-${instanceSuffix}'
var resourceSuffixNoHyphens = (empty(instanceSuffix)) ? '${orgName}${environmentCode}${locationCode}' : '${orgName}${environmentCode}${locationCode}${instanceSuffix}'


//? ==============================================================================================
//?                             App Service Plan Configuration
//? ==============================================================================================
param useExistingAppServicePlan = false
param appServicePlanName = '' //? If using an existing App Service Plan, put its name here

// Only fill if provisioning a new App Service Plan (i.e. useExistingAppServicePlan = false)
param skuName = 'FC1'
param zoneRedundant = false


//? ==============================================================================================
//?                               Function App Configuration
//? ==============================================================================================
param functionAppName = ''
param useVnetIntegration = false
param publicNetworkAccess = 'Enabled'
param useStorageAccount = false
param useApplicationInsights = false
param functionAppOsType = 'Linux'
param forceHttps = true
param alwaysOn = true
param e2eEncryptionEnabled = true
param ftpsState = 'FtpsOnly'
param linuxFxVersion = 'DOTNET-ISOLATED|8.0'
param healthCheckPath = ''
param managedIdentity = true
param minTlsVersion = '1.2'

param appSettings = {
  minTlsVersion: '1.2'
}


//? ==============================================================================================
//?                                  Network Configuration
//?                     (only applies when useVnetIntegration setting = true)
//? ==============================================================================================
param useExistingVnet = false

// Fill the below setting if using an existing vNet (i.e. useExistingVnet = true). The rest in this section can be ignored
param existingVnetName = null

// Fill the below if provisioning a new vNet (i.e. useExistingVnet = false)
param newVnetName = null
param newVnetSize = null
param usePrivateEndpoints = true        //? NOTE: Be sure to also accordingly set the publicNetworkAccess setting on the Function App
param privateEndpointsSubnetName = null
param subnets = [
  //? Copy the commented out block to configure and create subnets as necessary (some settings are opptional)
  //! For use of an App Service Plan, a subnet delegated to "Microsoft.Web/serverfarms" is required
  // {
  //   name: 'snet-{purpose}-${resourceSuffix}' - required
  //   addressPrefix: cidrSubnet(base, size, offset) - required
  //!   networkSecurityGroupResourceId: !empty(defaultSubnetNsgResourceId) ? defaultSubnetNsgResourceId : null
  //   delegation: ''
  // }
]

param useNetworkSecurityGroups = false

// Only fill the below if using using NSGs (i.e. useNetworkSecurityGroups = true)
param networkSecurityGroupConfigs = [
  //? Copy the commented out block to configure and create subnets as necessary (some settings are opptional)
  // {
  //   subnet: 'name of subnet to attach to (from above subnet config)'
  //   config: {
  //     name: 'nsg name'
  //     rules: [
  //     {
  //       name: 'security rule name'
  //       properties: {
  //         access: 'Allow'      //? 'Allow' | 'Deny'
  //         direction: 'Inbound' //? 'Inbound' | 'Outbound'
  //         priority: 100        //? 100 -> 4096
  //         protocol: 'Tcp'      //? '*' | 'Ah' | 'Esp' | 'Icmp' | 'Tcp' | 'Udp'
  //       }
  //     }
  //   ]
  //   }
  // }
]

// Only fill the below if NOT using using NSGs (i.e. useNetworkSecurityGroups = false) 
