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

@description('Whether to depploy private endpoints. AAlso creates a dedicated subnet for the private endpoints')
param usePrivateEndpoints bool

@description('Subnets to deploy into this vNet. If using private endpoints, a dedicated subnet is automatically added to this array')
param subnets array

param nsgConfigs array

// Optional: NSG
@description('Whether to provision Network Security Groups')
param useNetworkSecurityGroups bool

param tags object

//    {
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



module nsgs 'br/public:avm/res/network/network-security-group:0.5.2' = [for nsgConfig in nsgConfigs: if (useNetworkSecurityGroups) {
  name: 'nsg-${nsgConfig.config.name}-AVM-module'
  params: {
    name: nsgConfig.config.name
    securityRules: nsgConfig.config.rules
  }
}]

var subnetsWithNsgs = [
  for (subnet, i) in subnets: union(subnet, { 
    networkSecurityGroupResourceId: first(filter(nsgConfigs, nsg => nsg.name == subnet.name)) 
  })
]

var privateEndpointSubnet = (usePrivateEndpoints) ? [{
  name: privateEndpointsSubnetName
  addressPrefix: privateEndpointsSubnetAddressPrefix
  privateEndpointNetworkPolicies: 'Enabled'
  networkSecurityGroupResourceId: (useNetworkSecurityGroups) ? first([]) : null
}] : []

module newVirtualNetwork 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'vnet-AVM-module'
  params: {
    name: virtualNetworkName
    location: location
    tags: tags
    addressPrefixes: addressPrefixes!
    subnets: (usePrivateEndpoints) ? (useNetworkSecurityGroups) ? concat(subnetsWithNsgs, privateEndpointSubnet) : concat(subnets, privateEndpointSubnet) : subnets
  }
}

@description('The resource ID of the virtual network.')
output virtualNetworkResourceId string = newVirtualNetwork.outputs.resourceId

@description('The name of the virtual network.')
output virtualNetworkName string = newVirtualNetwork.outputs.name

@description('The resource IDs of all deployed subnets.')
output subnetResourceIds array = newVirtualNetwork.outputs.subnetResourceIds

@description('The names of all deployed subnets.')
output subnetNames array = newVirtualNetwork.outputs.subnetNames
