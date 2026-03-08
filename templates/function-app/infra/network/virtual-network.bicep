// Required parameters
param virtualNetworkName string
param location string = resourceGroup().location

// Address Space
@description('The VNet address space (e.g. ["10.0.0.0/16"]).')
param addressPrefixes array?

// Subnets
@description('Address prefix for the App Service integration subnet (e.g. "10.0.1.0/24").')
param appServiceSubnetAddressPrefix string?

@description('Name for the private endpoints subnet')
param privateEndpointsSubnetName string?

@description('Address prefix for the private endpoints subnet (e.g. "10.0.2.0/24").')
param privateEndpointsSubnetAddressPrefix string?

// @description('Address prefix for a default/general-purpose subnet (e.g. "10.0.0.0/24").')
// param defaultSubnetAddressPrefix string

@description('Whether to depploy private endpoints. AAlso creates a dedicated subnet for the private endpoints')
param usePrivateEndpoints bool

@description('Subnets to deploy into this vNet. If using private endpoints, a dedicated subnet is automatically added to this array')
param subnets array

// Optional: NSG
@description('Whether to provision Network Security Groups')
param useNetworkSecurityGroups bool
// @description('Resource ID of the NSG to attach to the App Service integration subnet.')
// param appServiceSubnetNsgResourceId string = ''

// @description('Resource ID of the NSG to attach to the private endpoints subnet.')
// param privateEndpointsSubnetNsgResourceId string = ''

// @description('Resource ID of the NSG to attach to the default subnet.')
// param defaultSubnetNsgResourceId string = ''

param tags object

module nsgs 'br/public:avm/res/network/network-security-group:0.5.2' = if (useNetworkSecurityGroups && usePrivateEndpoints) {
  name: 'nsg-AVM-module'
  params: {
    name: ''
    securityRules: []
  }
}

var privateEndpointSubnet = (usePrivateEndpoints) ? [{
  name: privateEndpointsSubnetName
  addressPrefix: privateEndpointsSubnetAddressPrefix
  privateEndpointNetworkPolicies: 'Enabled'
  networkSecurityGroupResourceId: (useNetworkSecurityGroups) ? nsgs!.outputs.resourceId : null
}] : []

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'vnet-AVM-module'
  params: {
    name: virtualNetworkName
    location: location
    tags: tags
    addressPrefixes: addressPrefixes!
    subnets: (usePrivateEndpoints) ? concat(subnets, privateEndpointSubnet) : subnets
  }
}

@description('The resource ID of the virtual network.')
output virtualNetworkResourceId string = virtualNetwork.outputs.resourceId

@description('The name of the virtual network.')
output virtualNetworkName string = virtualNetwork.outputs.name

@description('The resource IDs of all deployed subnets.')
output subnetResourceIds array = virtualNetwork.outputs.subnetResourceIds

@description('The names of all deployed subnets.')
output subnetNames array = virtualNetwork.outputs.subnetNames
