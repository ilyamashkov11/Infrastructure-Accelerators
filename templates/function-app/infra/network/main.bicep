// Address Space
@description('The VNet address space (e.g. ["10.0.0.0/16"]).')
param addressPrefixes array?

param virtualNetworkName string
param useExistingVnet bool

// Subnets
// @description('Address prefix for the App Service integration subnet (e.g. "10.0.1.0/24").')
// param appServiceSubnetAddressPrefix string?

@description('Name for the private endpoints subnet')
param privateEndpointsSubnetName string?

@description('Address prefix for the private endpoints subnet (e.g. "10.0.2.0/24").')
param privateEndpointsSubnetAddressPrefix string?

@description('Whether to depploy private endpoints. AAlso creates a dedicated subnet for the private endpoints')
param usePrivateEndpoints bool

@description('Subnets to deploy into this vNet. If using private endpoints, a dedicated subnet is automatically added to this array')
param subnets array

param networkSecurityGroupConfigs array

@description('Kill switch: when false, all NSG configs are ignored and no NSGs are deployed')
param useNetworkSecurityGroups bool


// TODO: Add existing vNet


module vNet 'virtual-network.bicep' = if (!useExistingVnet) {
  name: 'vnet-module'
  params: {
    tags: {}
    networkSecurityGroupConfigs: networkSecurityGroupConfigs
    subnets: subnets
    useNetworkSecurityGroups: useNetworkSecurityGroups 
    usePrivateEndpoints: usePrivateEndpoints
    virtualNetworkName: virtualNetworkName
    addressPrefixes: addressPrefixes
    privateEndpointsSubnetAddressPrefix: privateEndpointsSubnetAddressPrefix
    privateEndpointsSubnetName: privateEndpointsSubnetName
  }
}


@description('The resource ID of the virtual network.')
output virtualNetworkResourceId string = ''
