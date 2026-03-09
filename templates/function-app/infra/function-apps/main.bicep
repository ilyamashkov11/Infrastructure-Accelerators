// Required parameters
param functionAppName string
param appServicePlanResourceId string

// Networking
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string
param virtualNetworkSubnetResourceId string?

// Security
param forceHttps bool
param e2eEncryptionEnabled bool
param managedIdentity bool
// param requireAuthSettingsV2 bool

// App Settings & Config
param storageAccountResourceId string?
param applicationInsightsResourceId string?
param appSettings object
param functionsWorkerRuntime string = 'dotnet-isolated'
param functionsExtensionVersion string = '~4'

// Shared Site Config
param alwaysOn bool
param healthCheckPath string
param ftpsState string
param minTlsVersion string


// ──────────────────────────────────────────────
// OS-specific settings
// ──────────────────────────────────────────────
@description('Target operating system for a Function App.')
@allowed(['Linux', 'Windows'])
param operatingSystem string

// Linux-specific
@description('Linux only: Runtime stack and version (e.g. "DOTNET-ISOLATED|8.0", "NODE|20", "PYTHON|3.11").')
param linuxFxVersion string

// Windows-specific
@description('Windows only: .NET Framework version (e.g. "v8.0").')
param windowsNetFrameworkVersion string = ''
@description('Windows only: Use 32-bit worker process. Defaults to false (64-bit).')
param windowsUse32BitWorkerProcess bool = false

param tags object

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

module functionApp 'function-app.bicep' = {
  name: 'function-app-module'
  params: {
    appServicePlanResourceId: appServicePlanResourceId
    applicationInsightResourceId: applicationInsightsResourceId
    e2eEncryptionEnabled: e2eEncryptionEnabled
    forceHttps: forceHttps
    functionAppName: functionAppName
    managedIdentity: managedIdentity
    publicNetworkAccess: publicNetworkAccess
    storageAccountResourceId: storageAccountResourceId
    virtualNetworkSubnetResourceId: virtualNetworkSubnetResourceId
    tags: tags
    functionAppKind: functionAppKind
    isLinux: isLinux
    mergedAppSettings: mergedAppSettings
    siteConfig: siteConfig
  }
}
