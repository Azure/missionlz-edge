// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// scope
targetScope = 'subscription'

/*

  PARAMETERS

  Here are all the parameters a user can override.

  These are the required parameters that Mission LZ does not provide a default for:
    - resourcePrefix

*/

// REQUIRED PARAMETERS

@minLength(3)
@maxLength(10)
@description('A prefix, 3-10 alphanumeric characters without whitespace, used to prefix resources and generate uniqueness for resources with globally unique naming requirements like Storage Accounts and Log Analytics Workspaces')
param resourcePrefix string

@minLength(3)
@maxLength(6)
@description('A suffix, 3 to 6 characters in length, to append to resource names (e.g. "dev", "test", "prod", "mlz"). It defaults to "mlz".')
param resourceSuffix string = 'mlz'

@description('The region to deploy resources into. It defaults to the deployment location.')
param location string = deployment().location

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param deploymentNameSuffix string = utcNow()

@description('A string dictionary of tags to add to deployed resources. See https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=json#arm-templates for valid settings.')
param tags object = {}

// NETWORK ADDRESS SPACE PARAMETERS

@description('The CIDR Virtual Network Address Prefix for the Hub Virtual Network. Default value = 10.90.0.0/16')
param hubVirtualNetworkAddressPrefix string = '10.90.0.0/16'

@description('The CIDR Subnet Address Prefix for the Hub management subnet. It must be in the Hub Virtual Network space. Default value = 10.90.0.0/24')
param mgmtSubnetAddressPrefix string = '10.90.0.0/24'

@description('The CIDR Subnet Address Prefix for the Hub external subnet. It must be in the Hub Virtual Network space. Default value = 10.90.1.0/24')
param extSubnetAddressPrefix string = '10.90.1.0/24'

@description('The CIDR Subnet Address Prefix for the Hub internal subnet. It must be in the Hub Virtual Network space. Default value = 10.90.2.0/24')
param intSubnetAddressPrefix string = '10.90.2.0/24'

@description('The CIDR Subnet Address Prefix for the Hub VDMS subnet. It must be in the Hub Virtual Network space. Default value = 10.90.3.0/24')
param vdmsSubnetAddressPrefix string = '10.90.3.0/24'

@description('The CIDR Subnet Address Prefix for the Hub VPN Gateway subnet. It must be in the Hub Virtual Network space. Default value = 10.90.250.0/24')
param gatewaySubnetAddressPrefix string = '10.90.250.0/24'

@description('The CIDR Virtual Network Address Prefix for the Identity Virtual Network. Default value = 10.92.0.0/16')
param identityVirtualNetworkAddressPrefix string = '10.92.0.0/16'

@description('The CIDR Subnet Address Prefix for the default Identity subnet. It must be in the Identity Virtual Network space. Default value = 10.92.0.0/24')
param identitySubnetAddressPrefix string = '10.92.0.0/24'

@description('The CIDR Virtual Network Address Prefix for the Operations Virtual Network. Default value = 10.91.0.0/16')
param operationsVirtualNetworkAddressPrefix string = '10.91.0.0/16'

@description('The CIDR Subnet Address Prefix for the default Operations subnet. It must be in the Operations Virtual Network space. Default value = 10.91.0.0/24')
param operationsSubnetAddressPrefix string = '10.91.0.0/24'

@description('The CIDR Virtual Network Address Prefix for the Shared Services Virtual Network. Default value = 10.93.0.0/16')
param sharedServicesVirtualNetworkAddressPrefix string = '10.93.0.0/16'

@description('The CIDR Subnet Address Prefix for the default Shared Services subnet. It must be in the Shared Services Virtual Network space. Default value = 10.93.0.0/24')
param sharedServicesSubnetAddressPrefix string = '10.93.0.0/24'

// LOCAL NETWORK GATEWAY (TO REMOTE VPN GATEWAY)

@description('The CIDR Subnet Address Prefixes for the remote network that will be routable from the Hub Virtual Network Gateway')
param remoteLocalNetworkAddressPrefixes array

@description('The public IP Address for the remote Virtual Network Gateway')
param remoteGatewayPublicIpAddress string

// HUB NETWORK PARAMETERS

@description('An array of Network Security Group Rules to apply to the Hub Virtual Network. Default adds SSH and RDP to default rule set. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings.')
param hubNetworkSecurityGroupRules array = [
  {
    name: 'allow_SSH'
    properties: {
      description: 'Allows SSH traffic'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
  {
    name: 'allow_RDP'
    properties: {
      description: 'Allows SSH traffic'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3389'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
]

// VIRTUAL NETWORK GATEWAY PARAMETERS

@description('SKU for the virtual network gateway - Cannot use Basic SKU')
@allowed([
  'Standard'
  'HighPerformance'
  'VpnGw1'
  'VpnGw2'
  'VpnGw3'
])
param vnGatewaySku string = 'VpnGw1'

// IDENTITY PARAMETERS

// OPERATIONS PARAMETERS

// SHARED SERVICES PARAMETERS

/*

  NAMING CONVENTION

  Here we define a naming conventions for resources.

  First, we take `resourcePrefix` and `resourceSuffix` by params.
  Then, using string interpolation "${}", we insert those values into a naming convention.
  
  We were inspired for this naming convention by: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming

*/

var resourceToken = 'resource_token'
var nameToken = 'name_token'
var namingConvention = '${toLower(resourcePrefix)}-${toLower(resourceSuffix)}-${nameToken}-${resourceToken}'

/*

  CALCULATED VALUES

  Here we reference the naming conventions described above,
  then use the "replace()" function to insert unique resource abbreviations and name values into the naming convention.

  We were inspired for these abbreviations by: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations

*/

var networkSecurityGroupNamingConvention = replace(namingConvention, resourceToken, 'nsg')
var publicIpAddressNamingConvention = replace(namingConvention, resourceToken, 'pip')
var resourceGroupNamingConvention = replace(namingConvention, resourceToken, 'rg')
var subnetNamingConvention = replace(namingConvention, resourceToken, 'snet')
var virtualNetworkNamingConvention = replace(namingConvention, resourceToken, 'vnet')
var vnetGatewayNamingConvention = replace(namingConvention, resourceToken, 'vgw')
var localNetGatewayNamingConvention = replace(namingConvention, resourceToken, 'lgw')

// HUB VARIABLES

var hubName = 'hub'
var hubResourceGroupName = replace(resourceGroupNamingConvention, nameToken, hubName)
var hubVirtualNetworkName = replace(virtualNetworkNamingConvention, nameToken, hubName)
var hubNetworkSecurityGroupName = replace(networkSecurityGroupNamingConvention, nameToken, hubName)
var mgmtSubnetName = replace(subnetNamingConvention, nameToken, 'mgmt')
var extSubnetName = replace(subnetNamingConvention, nameToken, 'ext')
var intSubnetName = replace(subnetNamingConvention, nameToken, 'int')
var vdmsSubnetName = replace(subnetNamingConvention, nameToken, 'vdms')
var gatewaySubnetName = 'GatewaySubnet' //Note: this subnet must be named 'GatewaySubnet'

var hubSubnets = [
  {
    name: mgmtSubnetName
    properties: {
      addressPrefix: mgmtSubnetAddressPrefix
    }
  }
  {
    name: intSubnetName
    properties: {
      addressPrefix: intSubnetAddressPrefix
    }
  }
  {
    name: extSubnetName
    properties: {
      addressPrefix: extSubnetAddressPrefix
    }
  }
  {
    name: vdmsSubnetName
    properties: {
      addressPrefix: vdmsSubnetAddressPrefix
    }
  }

  {
    name: gatewaySubnetName
    properties: {
      addressPrefix: gatewaySubnetAddressPrefix
    }
  }
]

// VIRTUAL NETWORK GATEWAY PARAMETERS

var vnetGatewayName = replace(vnetGatewayNamingConvention, nameToken, 'hub')
var vnetGatewayPublicIPAddressName = replace(publicIpAddressNamingConvention, nameToken, 'hub-vgw')

// LOCAL GATEWAY PARAMETERS (TO REMOTE VPN GATEWAY)

var remoteLocalNetworkGatewayName = replace(localNetGatewayNamingConvention, nameToken, 'remote')

// IDENTITY VARIABLES

var identityName = 'identity'
var identityResourceGroupName = replace(resourceGroupNamingConvention, nameToken, identityName)
var identityVirtualNetworkName = replace(virtualNetworkNamingConvention, nameToken, identityName)
var identityNetworkSecurityGroupName = replace(networkSecurityGroupNamingConvention, nameToken, identityName)
var identitySubnetName = replace(subnetNamingConvention, nameToken, identityName)
var identityNetworkSecurityGroupRules = [
  {
    name: 'allow_EAST-WEST_traffic'
    properties: {
      description: 'Allows traffic between spokes'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefixes: [
        '${operationsVirtualNetworkAddressPrefix}'
        '${sharedServicesVirtualNetworkAddressPrefix}'
      ]
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 1000
      direction: 'Inbound'
    }
  }
]

// OPERATIONS VARIABLES

var operationsName = 'operations'
var operationsResourceGroupName = replace(resourceGroupNamingConvention, nameToken, operationsName)
var operationsVirtualNetworkName = replace(virtualNetworkNamingConvention, nameToken, operationsName)
var operationsNetworkSecurityGroupName = replace(networkSecurityGroupNamingConvention, nameToken, operationsName)
var operationsSubnetName = replace(subnetNamingConvention, nameToken, operationsName)
var operationsNetworkSecurityGroupRules = [
  {
    name: 'allow_EAST-WEST_traffic'
    properties: {
      description: 'Allows traffic between spokes'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefixes: [
        '${identityVirtualNetworkAddressPrefix}'
        '${sharedServicesVirtualNetworkAddressPrefix}'
      ]
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 1000
      direction: 'Inbound'
    }
  }
]

// SHARED SERVICES VARIABLES

var sharedServicesName = 'sharedServices'
var sharedServicesResourceGroupName = replace(resourceGroupNamingConvention, nameToken, sharedServicesName)
var sharedServicesVirtualNetworkName = replace(virtualNetworkNamingConvention, nameToken, sharedServicesName)
var sharedServicesNetworkSecurityGroupName = replace(networkSecurityGroupNamingConvention, nameToken, sharedServicesName)
var sharedServicesSubnetName = replace(subnetNamingConvention, nameToken, sharedServicesName)
var sharedServicesNetworkSecurityGroupRules = [
  {
    name: 'allow_EAST-WEST_traffic'
    properties: {
      description: 'Allows traffic between spokes'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefixes: [
        '${identityVirtualNetworkAddressPrefix}'
        '${operationsVirtualNetworkAddressPrefix}'
      ]
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 1000
      direction: 'Inbound'
    }
  }
]

// SPOKES

var spokes = [
  {
    name: operationsName
    resourceGroupName: operationsResourceGroupName
    virtualNetworkName: operationsVirtualNetworkName
    virtualNetworkAddressPrefix: operationsVirtualNetworkAddressPrefix
    networkSecurityGroupName: operationsNetworkSecurityGroupName
    networkSecurityGroupRules: operationsNetworkSecurityGroupRules
    subnetName: operationsSubnetName
    subnetAddressPrefix: operationsSubnetAddressPrefix
  }
  {
    name: identityName
    resourceGroupName: identityResourceGroupName
    virtualNetworkName: identityVirtualNetworkName
    virtualNetworkAddressPrefix: identityVirtualNetworkAddressPrefix
    networkSecurityGroupName: identityNetworkSecurityGroupName
    networkSecurityGroupRules: identityNetworkSecurityGroupRules
    subnetName: identitySubnetName
    subnetAddressPrefix: identitySubnetAddressPrefix
  }
  {
    name: sharedServicesName
    resourceGroupName: sharedServicesResourceGroupName
    virtualNetworkName: sharedServicesVirtualNetworkName
    virtualNetworkAddressPrefix: sharedServicesVirtualNetworkAddressPrefix
    networkSecurityGroupName: sharedServicesNetworkSecurityGroupName
    networkSecurityGroupRules: sharedServicesNetworkSecurityGroupRules
    subnetName: sharedServicesSubnetName
    subnetAddressPrefix: sharedServicesSubnetAddressPrefix
  }
]

// TAGS

var defaultTags = {
  'resourcePrefix': resourcePrefix
  'resourceSuffix': resourceSuffix
  'DeploymentType': 'MissionLandingZoneARM'
}

var calculatedTags = union(tags, defaultTags)

/*

  RESOURCES
  Here we create deployable resources.

*/

// CREATE RESOURCE GROUPS

module hubResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-rg-hub-${deploymentNameSuffix}'
  params: {
    name: hubResourceGroupName
    location: location
    tags: calculatedTags
  }
}

module spokeResourceGroups './modules/resourceGroup.bicep' = [for spoke in spokes: {
  name: 'deploy-rg-${spoke.name}-${deploymentNameSuffix}'
  params: {
    name: spoke.resourceGroupName
    location: location
    tags: calculatedTags
  }
}]

//CREATE HUB VIRTUAL NETWORK AND SUBNETS

module hubVirtualNetwork './modules/virtualNetwork.bicep' = {
  name: 'deploy-vnet-hub-${deploymentNameSuffix}'
  scope: resourceGroup(hubResourceGroupName)
  params: {
    name: hubVirtualNetworkName
    location: location
    tags: tags
    addressPrefix: hubVirtualNetworkAddressPrefix
    subnets: hubSubnets
  }
  dependsOn: [
    hubResourceGroup
  ]
}

// CREATE HUB NSG

module hubNetworkSecurityGroup './modules/networkSecurityGroup.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-nsg-hub-${deploymentNameSuffix}'
  params: {
    location: location
    name: hubNetworkSecurityGroupName
    securityRules: hubNetworkSecurityGroupRules
  }
  dependsOn: [
    hubResourceGroup
  ]
}

// CREATE VIRTUAL NETWORK GATEWAY PUBLIC IP

module hubVnGatewayPublicIp './modules/publicIPAddress.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-hub-vgw-pubip-${deploymentNameSuffix}'
  params: {
    location: location
    name: vnetGatewayPublicIPAddressName
    publicIpAllocationMethod: 'Dynamic'
  }
  dependsOn: [
    hubResourceGroup
  ]
}

// Replace the subnet resources below with output from virtualNetwork module
// once supported by the Azure Stack API
resource extSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  scope: resourceGroup(hubResourceGroupName)
  name: '${hubVirtualNetworkName}/${extSubnetName}'
}

resource intSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  scope: resourceGroup(hubResourceGroupName)
  name: '${hubVirtualNetworkName}/${intSubnetName}'
}

resource mgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  scope: resourceGroup(hubResourceGroupName)
  name: '${hubVirtualNetworkName}/${mgmtSubnetName}'
}

resource vdmsSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  scope: resourceGroup(hubResourceGroupName)
  name: '${hubVirtualNetworkName}/${vdmsSubnetName}'
}
//

// CREATE VIRTUAL NETWORK VPN GATEWAY

module hubVpnGateway './modules/virtualNetworkGateway.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-hub-gateway-${deploymentNameSuffix}'
  params: {
    name: vnetGatewayName
    location: location
    virtualNetworkName: hubVirtualNetworkName
    privateIpAllocationMethod: 'Dynamic'
    publicIPAddressId: hubVnGatewayPublicIp.outputs.id
    gatewaySku: vnGatewaySku
  }
  dependsOn: [
    hubVnGatewayPublicIp
  ]
}

// CREATE LOCAL NETWORK GATEWAY (TO REMOTE VPN GATEWAY)

module localNetworkGateway './modules/localNetworkGateway.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-local-network-gateway-${deploymentNameSuffix}'
  params: {
    name: remoteLocalNetworkGatewayName
    location: location
    remoteNetworkAddressPrefixes: remoteLocalNetworkAddressPrefixes
    remoteGatewayPublicIpAddress: remoteGatewayPublicIpAddress
  }
  dependsOn: [
    hubVpnGateway
  ]
}

// CREATE SPOKE VIRTUAL NETWORKS 

module spokeNetworks './modules/spokeNetwork.bicep' = [for spoke in spokes: {
  name: 'deploy-vnet-${spoke.name}-${deploymentNameSuffix}'
  scope: resourceGroup(spoke.resourceGroupName)
  params: {
    location: location
    tags: calculatedTags

    virtualNetworkName: spoke.virtualNetworkName
    virtualNetworkAddressPrefix: spoke.virtualNetworkAddressPrefix

    networkSecurityGroupName: spoke.networkSecurityGroupName
    networkSecurityGroupRules: spoke.networkSecurityGroupRules

    subnetName: spoke.subnetName
    subnetAddressPrefix: spoke.subnetAddressPrefix

    routeTableRouteNextHopType: 'VirtualNetworkGateway'
  }
  dependsOn: [
    spokeResourceGroups
    hubVpnGateway
  ]
}]

// VIRTUAL NETWORK PEERINGS
module hubVirtualNetworkPeerings './modules/virtualNetworkPeering.bicep' = [for spoke in spokes: {
  name: 'deploy-hub-to-${spoke.name}-vnet-peering'
  scope: resourceGroup(hubResourceGroupName)
  params: {
    localVirtualNetworkName: hubVirtualNetworkName
    remoteVirtualNetworkName: spoke.virtualNetworkName
    remoteResourceGroupName: spoke.resourceGroupName
  }
  dependsOn: [
    hubResourceGroup
    hubVirtualNetwork
    spokeNetworks
  ]
}]

module spokeVirtualNetworkPeerings './modules/virtualNetworkPeering.bicep' = [for spoke in spokes: {
  name: 'deploy-${spoke.name}-to-hub-vnet-peering'
  scope: resourceGroup(spoke.resourceGroupName)
  params: {
    allowForwardedTraffic: true
    localVirtualNetworkName: spoke.virtualNetworkName
    remoteVirtualNetworkName: hubVirtualNetworkName
    remoteResourceGroupName: hubResourceGroupName
  }
  dependsOn: [
    spokeResourceGroups
    spokeNetworks
  ]
}]

// OUTPUTS

output hub object = {
  subscriptionId: subscription().subscriptionId
  resourceGroupName: hubResourceGroup.outputs.name
  resourceGroupResourceId: hubResourceGroup.outputs.id
  virtualNetworkName: hubVirtualNetworkName
}

output nsgsArray array = [for (name, i) in spokes: {
  nsgResourceGroupName: spokeNetworks[i].outputs.networkSecurityGroupResourceGroupName
  nsgName: spokeNetworks[i].outputs.networkSecurityGroupName
}]
