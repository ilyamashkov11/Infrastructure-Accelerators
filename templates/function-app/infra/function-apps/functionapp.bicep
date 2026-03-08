// Required parameters
param functionAppName string
param appServicePlanResourceId string

// Networking
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string
param virtualNetworkSubnetResourceId string

// Security
param forceHttps bool
param e2eEncryptionEnabled bool
param managedIdentity bool
// param requireAuthSettingsV2 bool

// App Settings & Config
param storageAccountResourceId string
param applicationInsightResourceId string
param appSettings object
param functionsWorkerRuntime string = 'dotnet-isolated'
param functionsExtensionVersion string = '~4'

// Shared Site Config
param alwaysOn bool
@allowed(['AllAllowed', 'FtpsOnly', 'Disabled'])
param ftpsState string
@allowed(['1.0', '1.1', '1.2', '1.3'])
param minTlsVersion string
param healthCheckPath string

// ──────────────────────────────────────────────
// OS-specific settings
// ──────────────────────────────────────────────
@description('Target operating system for the Function App.')
@allowed(['Linux', 'Windows'])
param operatingSystem string

// Linux-specific
@description('Linux only: Runtime stack and version (e.g. "DOTNET-ISOLATED|8.0", "NODE|20", "PYTHON|3.11").')
@allowed(['DOTNET-ISOLATED|8.0'])
param linuxFxVersion string

// Windows-specific
@description('Windows only: .NET Framework version (e.g. "v8.0").')
param windowsNetFrameworkVersion string = ''
// @description('Windows only: Node.js version.')
// param windowsNodeVersion string = ''
// @description('Windows only: PowerShell version.')
// param windowsPowerShellVersion string = ''
// @description('Windows only: Java version.')
// param windowsJavaVersion string = ''
@description('Windows only: Use 32-bit worker process. Defaults to false (64-bit).')
param windowsUse32BitWorkerProcess bool = false

// Tags
param tags object = {}

// ──────────────────────────────────────────────
// Derived values based on OS
// ──────────────────────────────────────────────
var isLinux = operatingSystem == 'Linux'
var functionAppKind = isLinux ? 'functionapp,linux' : 'functionapp'

// Linux site config
var linuxSiteConfig = {
  linuxFxVersion: !empty(linuxFxVersion) ? linuxFxVersion : null
}

// Windows site config
var windowsSiteConfig = {
  use32BitWorkerProcess: windowsUse32BitWorkerProcess
  netFrameworkVersion: !empty(windowsNetFrameworkVersion) ? windowsNetFrameworkVersion : null
  // nodeVersion: !empty(windowsNodeVersion) ? windowsNodeVersion : null
  // powerShellVersion: !empty(windowsPowerShellVersion) ? windowsPowerShellVersion : null
  // javaVersion: !empty(windowsJavaVersion) ? windowsJavaVersion : null
}

// Shared site config
var sharedSiteConfig = {
  alwaysOn: alwaysOn
  ftpsState: ftpsState
  minTlsVersion: minTlsVersion
  healthCheckPath: !empty(healthCheckPath) ? healthCheckPath : null
  vnetRouteAllEnabled: true
  publicNetworkAccess: publicNetworkAccess
}

// Merge shared + OS-specific site config
var siteConfig = union(sharedSiteConfig, isLinux ? linuxSiteConfig : windowsSiteConfig)

// Build the app settings properties object
var baseAppSettings = {
  FUNCTIONS_EXTENSION_VERSION: functionsExtensionVersion
  FUNCTIONS_WORKER_RUNTIME: functionsWorkerRuntime
}
var mergedAppSettings = union(baseAppSettings, appSettings)

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
    virtualNetworkSubnetResourceId: !empty(virtualNetworkSubnetResourceId) ? virtualNetworkSubnetResourceId : null
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
        storageAccountResourceId: !empty(storageAccountResourceId) ? storageAccountResourceId : null
        storageAccountUseIdentityAuthentication: managedIdentity && !empty(storageAccountResourceId)
        applicationInsightResourceId: !empty(applicationInsightResourceId) ? applicationInsightResourceId : null
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
