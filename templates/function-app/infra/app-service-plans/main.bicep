
param useExistingAppServicePlan bool
param functionAppOsType string
param appServicePlanName string
param skuName string?
param zoneRedundant bool

module AppServicePlanLinux 'asp-linux.bicep' = if (functionAppOsType == 'Linux') {
    name: 'app-service-plan-linux-main'
    params: {
        appServicePlanName: appServicePlanName
        skuName: skuName!
        virtualNetworkSubnetId: '' // TODO: allow for creation of vNets
        zoneRedundant: zoneRedundant
        useExistingAppServicePlan: useExistingAppServicePlan
    }
}

module AppServicePlanWindows 'asp-windows.bicep' = if (functionAppOsType == 'Windows') {
    name: 'app-service-plan-windows-main'
    params: {
        appServicePlanName: appServicePlanName
        skuName: skuName!
        virtualNetworkSubnetId: '' // TODO: allow for creation of vNets
        zoneRedundant: zoneRedundant
        useExistingAppServicePlan: useExistingAppServicePlan
    }
}

output appServicePlanResourceId string = (functionAppOsType == 'Linux') ? AppServicePlanLinux!.outputs.appServicePlanResourceId : AppServicePlanWindows!.outputs.appServicePlanResourceId
