// Required parameters
param functionAppName string
param appServicePlanResourceId string

// Networking
param publicNetworkAccess string
param virtualNetworkSubnetResourceId string?

// Security
param forceHttps bool
param e2eEncryptionEnabled bool
param managedIdentity bool
// param requireAuthSettingsV2 bool

// App Settings & Config
param storageAccountResourceId string?
param applicationInsightResourceId string?
param tags object
param isLinux bool
param functionAppKind string
param siteConfig object
param mergedAppSettings object

module functionApp 'br/public:avm/res/web/site:0.22.0' = {
  name: 'functionApp-AVM-module'
  params: {
    name: functionAppName
    kind: functionAppKind
    serverFarmResourceId: appServicePlanResourceId
    reserved: isLinux
    location: resourceGroup().location
    tags: tags
    enabled: true
    httpsOnly: forceHttps
    publicNetworkAccess: publicNetworkAccess
    e2eEncryptionEnabled: e2eEncryptionEnabled
    scmSiteAlsoStopped: true
    managedIdentities: managedIdentity ? { systemAssigned: true } : null
    // keyVaultAccessIdentityResourceId: ''
    virtualNetworkSubnetResourceId: virtualNetworkSubnetResourceId
    basicPublishingCredentialsPolicies: [
      {
        allow: false
        name: 'ftp'
      }
      {
        allow: false
        name: 'scm'
      }
    ]
    siteConfig: siteConfig
    configs: [
      {
        name: 'appsettings'
        properties: mergedAppSettings
        storageAccountResourceId: storageAccountResourceId
        storageAccountUseIdentityAuthentication: managedIdentity && !empty(storageAccountResourceId)
        applicationInsightResourceId: applicationInsightResourceId
      }
      // TODO: AAdd authSettingsV2 functionality
      // (requireAuthSettingsV2) ? {
      //   name: 'authsettingsV2'
      //   properties: {
      //     identityProviders: {
      //       azureActiveDirectory: {
      //         enabled: true
      //       }
      //     }
      //   }
      // } : {}
    ]
    outboundVnetRouting: {
      allTraffic: true
    }
  }
}

output functionAppResourceId string = functionApp.outputs.resourceId
output functionAppName string = functionApp.outputs.name
output functionAppDefaultHostname string = functionApp.outputs.defaultHostname
output systemAssignedMIPrincipalId string = functionApp.outputs.?systemAssignedMIPrincipalId ?? ''
