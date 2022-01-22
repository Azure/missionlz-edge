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

@description('Specifies the tenant ID of a user/subscription')
param tenantId string = subscription().tenantId

@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param keyVaultAccessPolicyObjectId string 

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param deploymentNameSuffix string = utcNow()

@description('A string dictionary of tags to add to deployed resources. See https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=json#arm-templates for valid settings.')
param tags object = {}

// NETWORK ADDRESS SPACE PARAMETERS

@description('The CIDR Virtual Network Address Prefix for the Hub Virtual Network.')
param hubVirtualNetworkAddressPrefix string = '10.90.0.0/16'

@description('The CIDR Subnet Address Prefix for the Hub management subnet. It must be in the Hub Virtual Network space.')
param mgmtSubnetAddressPrefix string = '10.90.0.0/24'

@description('The CIDR Subnet Address Prefix for the Hub external subnet. It must be in the Hub Virtual Network space.')
param extSubnetAddressPrefix string = '10.90.1.0/24'

@description('The CIDR Subnet Address Prefix for the Hub internal subnet. It must be in the Hub Virtual Network space.')
param intSubnetAddressPrefix string = '10.90.2.0/24'

@description('The CIDR Subnet Address Prefix for the Hub VDMS subnet. It must be in the Hub Virtual Network space.')
param vdmsSubnetAddressPrefix string = '10.90.3.0/24'

@description('The CIDR Virtual Network Address Prefix for the Identity Virtual Network.')
param identityVirtualNetworkAddressPrefix string = '10.92.0.0/16'

@description('The CIDR Subnet Address Prefix for the default Identity subnet. It must be in the Identity Virtual Network space.')
param identitySubnetAddressPrefix string = '10.92.0.0/24'

@description('The CIDR Virtual Network Address Prefix for the Operations Virtual Network.')
param operationsVirtualNetworkAddressPrefix string = '10.91.0.0/16'

@description('The CIDR Subnet Address Prefix for the default Operations subnet. It must be in the Operations Virtual Network space.')
param operationsSubnetAddressPrefix string = '10.91.0.0/24'

@description('The CIDR Virtual Network Address Prefix for the Shared Services Virtual Network.')
param sharedServicesVirtualNetworkAddressPrefix string = '10.93.0.0/16'

@description('The CIDR Subnet Address Prefix for the default Shared Services subnet. It must be in the Shared Services Virtual Network space.')
param sharedServicesSubnetAddressPrefix string = '10.93.0.0/24'

// FIREWALL PARAMETERS

@description('The administrator username for the F5 firewall appliance. It defaults to "f5admin".')
param f5VmAdminUsername string = 'f5admin'

@allowed([
  'sshPublicKey'
  'password'
])
@description('[sshPublicKey/password] The authentication type for the F5 firewall appliance. It defaults to "password".')
param f5VmAuthenticationType string = 'sshPublicKey'

@description('The administrator password or public SSH key for the F5 firewall appliance. See https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm- for password requirements.')
@secure()
@minLength(14)
param f5VmAdminPasswordOrKey string =substring(newGuid(), 0,15)

@description('The size of the F5 firewall appliance. It defaults to "Standard_DS3_v2".')
param f5VmSize string = 'Standard_DS3_v2'

@description('The disk creation option of the F5 firewall appliance. It defaults to "FromImage".')
param f5VmOsDiskCreateOption string = 'FromImage'

@description('The disk type of the F5 firewall appliance. It defaults to "Premium_LRS".')
param f5VmOsDiskType string = 'Premium_LRS'

@description('The image publisher of the F5 firewall appliance. It defaults to "f5-networks".')
param f5VmImagePublisher string = 'f5-networks'

@description('The image offer of the F5 firewall appliance. It defaults to "f5-big-ip-best".')
param f5VmImageOffer string = 'f5-big-ip-best'

@description('The image SKU of the F5 firewall appliance. It defaults to "f5-bigip-virtual-edition-best-byol".')
param f5VmImageSku string = 'f5-bigip-virtual-edition-best-byol'

@description('The image version of the F5 firewall appliance. It defaults to "14.0.001000".')
param f5VmImageVersion string = '14.0.001000'

@allowed([
  'Static'
  'Dynamic'
])
@description('[Static/Dynamic] The public IP Address allocation method for the F5 firewall appliance. It defaults to "Dynamic".')
param f5privateIPAddressAllocationMethod string = 'Dynamic'

@description('[true/false] Enable or Disable IP forwarding on a network interface resource.')
param f5IpForwarding bool = true

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
var namingConvention = '${toLower(resourcePrefix)}-${resourceToken}-${nameToken}-${toLower(resourceSuffix)}'

/*

  CALCULATED VALUES

  Here we reference the naming conventions described above,
  then use the "replace()" function to insert unique resource abbreviations and name values into the naming convention.

  We were inspired for these abbreviations by: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations

*/

var ipConfigurationNamingConvention = replace(namingConvention, resourceToken, 'ipconf')
var networkInterfaceNamingConvention = replace(namingConvention, resourceToken, 'nic')
var networkSecurityGroupNamingConvention = replace(namingConvention, resourceToken, 'nsg')
var publicIpAddressNamingConvention = replace(namingConvention, resourceToken, 'pip')
var resourceGroupNamingConvention = replace(namingConvention, resourceToken, 'rg')
var subnetNamingConvention = replace(namingConvention, resourceToken, 'snet')
var virtualMachineNamingConvention = replace(namingConvention, resourceToken, 'vm')
var virtualNetworkNamingConvention = replace(namingConvention, resourceToken, 'vnet')

// HUB VARIABLES

var hubName = 'hub'
var hubResourceGroupName = replace(resourceGroupNamingConvention, nameToken, hubName)
var hubVirtualNetworkName = replace(virtualNetworkNamingConvention, nameToken, hubName)
var hubNetworkSecurityGroupName = replace(networkSecurityGroupNamingConvention, nameToken, hubName)
var mgmtSubnetName = replace(subnetNamingConvention, nameToken, 'mgmt')
var extSubnetName = replace(subnetNamingConvention, nameToken, 'ext')
var intSubnetName = replace(subnetNamingConvention, nameToken, 'int')
var vdmsSubnetName = replace(subnetNamingConvention, nameToken, 'vdms')
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
]

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
      priority: 100
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
      priority: 100
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
      priority: 100
      direction: 'Inbound'
    }
  }
]

// FIREWALL VARIABLES

var f5vm01extIpConfiguration1Name = replace(ipConfigurationNamingConvention, nameToken, 'f5vm01-ext1')
var f5vm01extIpConfiguration2Name = replace(ipConfigurationNamingConvention, nameToken, 'f5vm01-ext2')
var f5vm01intIpConfigurationName = replace(ipConfigurationNamingConvention, nameToken, 'f5vm01-int')
var f5vm01mgmtIpConfigurationName = replace(ipConfigurationNamingConvention, nameToken, 'f5vm01-mgmt')
var f5vm01vdmcIpConfigurationName = replace(ipConfigurationNamingConvention, nameToken, 'f5vm01-vdms')
var f5vm01extNicName = replace(networkInterfaceNamingConvention, nameToken, 'f5vm01-ext')
var f5vm01intNicName = replace(networkInterfaceNamingConvention, nameToken, 'f5vm01-int')
var f5vm01mgmtNicName = replace(networkInterfaceNamingConvention, nameToken, 'f5vm01-mgmt')
var f5vm01vdmsNicName = replace(networkInterfaceNamingConvention, nameToken, 'f5vm01-vdms')
var f5vm01VmName = replace(virtualMachineNamingConvention, nameToken, 'f5-01')
var f5vm01OutboundPublicIPAddressName = replace(publicIpAddressNamingConvention, nameToken, 'f5-out')
var f5vm01InboundPublicIPAddressName = replace(publicIpAddressNamingConvention, nameToken, 'f5-in')
var f5publicIPAddressAllocationMethod = 'Static'

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

// RESOURCE GROUPS

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

// HUB RESOURCES

//Create Hub Virtual Network and Subnets
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

// Create Hub NSG
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

// Create Outbound Public IP
module fwOutboundPublicIp './modules/publicIPAddress.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'create-fw_out-pubip-${deploymentNameSuffix}'
  params: {
    location: location
    name: f5vm01OutboundPublicIPAddressName
    publicIpAllocationMethod: f5publicIPAddressAllocationMethod
  }
  dependsOn: [
    hubResourceGroup
  ]
}

// Create Inbound Public IP
module fwInboundPublicIp './modules/publicIPAddress.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'create-fw_in-pubip-${deploymentNameSuffix}'
  params: {
    location: location
    name: f5vm01InboundPublicIPAddressName
    publicIpAllocationMethod: f5publicIPAddressAllocationMethod
  }
  dependsOn: [
    hubResourceGroup
  ]
}

// Create Key Vault to store F5 SSH key pair
module f5Vm01SshKeyVault './modules/generateSshKey.bicep' = if(f5VmAuthenticationType=='sshPublicKey'){
  scope: resourceGroup(hubResourceGroupName)
  name:'deploy-f5vm01Sshkv-hub-${deploymentNameSuffix}'
  params: {
    resourcePrefix : resourcePrefix 
    location: location
    tenantId: tenantId
    keyVaultAccessPolicyObjectId: keyVaultAccessPolicyObjectId
  }
  dependsOn:[
    hubResourceGroup
  ]

}

// Replace the subnet resources below with output from virtualNetwork module
resource extSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  scope: resourceGroup(hubResourceGroupName)
  name:'${hubVirtualNetworkName}/${extSubnetName}'
}

resource intSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  scope: resourceGroup(hubResourceGroupName)
  name:'${hubVirtualNetworkName}/${intSubnetName}'
}

resource mgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  scope: resourceGroup(hubResourceGroupName)
  name:'${hubVirtualNetworkName}/${mgmtSubnetName}'
}

resource vdmsSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  scope: resourceGroup(hubResourceGroupName)
  name:'${hubVirtualNetworkName}/${vdmsSubnetName}'
}
//

// Create F5 firewall
module f5Vm01 './modules/firewall.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-f5vm01-hub-${deploymentNameSuffix}'
  params: {
    adminPasswordOrKey: f5VmAuthenticationType=='password'?f5VmAdminPasswordOrKey: f5Vm01SshKeyVault.outputs.publicKey
    adminUsername: f5VmAdminUsername
    authenticationType: f5VmAuthenticationType
    extIpConfiguration1Name: f5vm01extIpConfiguration1Name
    extIpConfiguration2Name: f5vm01extIpConfiguration2Name
    extIpForwarding: f5IpForwarding
    extNicName: f5vm01extNicName
    extPrivateIPAddressAllocationMethod: f5privateIPAddressAllocationMethod
    extOutboundPublicIpId: fwOutboundPublicIp.outputs.id
    extInboundPublicIpId: fwInboundPublicIp.outputs.id
    extSubnetId: extSubnet.id
    intIpConfigurationName: f5vm01intIpConfigurationName
    intIpForwarding: f5IpForwarding
    intNicName: f5vm01intNicName
    intPrivateIPAddressAllocationMethod: f5privateIPAddressAllocationMethod
    intSubnetId: intSubnet.id
    location: location
    mgmtIpConfigurationName: f5vm01mgmtIpConfigurationName
    mgmtIpForwarding: f5IpForwarding
    mgmtNicName: f5vm01mgmtNicName
    mgmtPrivateIPAddressAllocationMethod: f5privateIPAddressAllocationMethod
    mgmtSubnetId: mgmtSubnet.id
    deploymentNameSuffix: deploymentNameSuffix
    osDiskCreateOption: f5VmOsDiskCreateOption
    vdmsIpConfigurationName: f5vm01vdmcIpConfigurationName
    vdmsIpForwarding: f5IpForwarding
    vdmsNicName: f5vm01vdmsNicName
    vdmsPrivateIPAddressAllocationMethod: f5privateIPAddressAllocationMethod
    vdmsSubnetId: vdmsSubnet.id
    vmName: f5vm01VmName
    vmOsDiskType: f5VmOsDiskType
    vmImageOffer: f5VmImageOffer
    vmImagePublisher: f5VmImagePublisher
    vmImageSku: f5VmImageSku
    vmImageVersion: f5VmImageVersion
    vmSize: f5VmSize
  }
  dependsOn: [
    hubResourceGroup
    hubVirtualNetwork
    hubNetworkSecurityGroup
    f5Vm01SshKeyVault
  ]
}

module spokeNetworks './modules/spokeNetwork.bicep' = [for spoke in spokes: {
  name: 'deploy-vnet-${spoke.name}-${deploymentNameSuffix}'
  scope: resourceGroup(spoke.resourceGroupName)
  params: {
    location: location
    tags: calculatedTags

    firewallPrivateIPAddress: f5Vm01.outputs.internalIpAddress

    virtualNetworkName: spoke.virtualNetworkName
    virtualNetworkAddressPrefix: spoke.virtualNetworkAddressPrefix

    networkSecurityGroupName: spoke.networkSecurityGroupName
    networkSecurityGroupRules: spoke.networkSecurityGroupRules

    subnetName: spoke.subnetName
    subnetAddressPrefix: spoke.subnetAddressPrefix
  }
  dependsOn: [
    spokeResourceGroups
    f5Vm01
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

output hub object = {
  subscriptionId: subscription().subscriptionId
  resourceGroupName: hubResourceGroup.outputs.name
  resourceGroupResourceId: hubResourceGroup.outputs.id
  virtualNetworkName: hubVirtualNetworkName  
  firewallPrivateIPAddress:f5Vm01.outputs.internalIpAddress
}

