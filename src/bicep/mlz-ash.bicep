// scope
targetScope = 'subscription'

//main

// Global Parameters
param hubResourceGroupName string = '${resourcePrefix}-hub'
param location string = deployment().location
param uniqueId string = uniqueString(deployment().name)
param resourcePrefix string = 'mlz-${uniqueId}'
param tags object = {}
param nowUtc string = utcNow()

// Hub Parameters
param hubVirtualNetworkName string = 'hub-vnet'
param hubVirtualNetworkAddressPrefix string = '10.90.0.0/16'
param mgmtSubnetName string = 'mgmt'
param mgmtSubnetAddressPrefix string = '10.90.0.0/24'
param extSubnetName string = 'external'
param extSubnetAddressPrefix string = '10.90.1.0/24'
param intSubnetName string = 'internal'
param intSubnetAddressPrefix string = '10.90.2.0/24'
param vdmsSubnetName string = 'vdms'
param vdmsSubnetAddressPrefix string = '10.90.3.0/24'

param hubNetworkSecurityGroupName string = 'hub-nsg'
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

@allowed([
  'sshPublicKey'
  'password'
])
param f5VmAuthenticationType string = 'password'
@secure()
@minLength(14)
param f5VmAdminPasswordOrKey string
param f5VmAdminUsername string = 'f5admin'
param f5VmOsDiskCreateOption string = 'FromImage'
param f5VmOsDiskType string = 'Premium_LRS'
param f5VmImagePublisher string = 'f5-networks'
param f5VmImageOffer string = 'f5-big-ip-best'
param f5VmImageSku string = 'f5-bigip-virtual-edition-best-byol'
param f5VmImageVersion string = '14.0.001000'
param f5VmSize string = 'Standard_DS3_v2'
param f5extSubnetName string = 'external'
param f5intSubnetName string = 'internal' 
param f5mgmtSubnetName string = 'mgmt' 
param f5privateIPAddressAllocationMethod string = 'Dynamic'

param f5vm01extIpConfigurationName string = 'f5vm01extIpConfiguration'
param f5vm01extNicName string = '${resourcePrefix}-f5vm01-ext-nic'
param f5vm01intIpConfigurationName string = 'f5vm01intIpConfiguration'
param f5vm01intNicName string = '${resourcePrefix}-f5vm01-int-nic'
param f5vm01mgmtIpConfigurationName string = 'f5vm01mgmtIpConfiguration'
param f5vm01mgmtNicName string = '${resourcePrefix}-f5vm01-mgmt-nic'

// Global Variables
var defaultTags = {
  'resourcePrefix': resourcePrefix
  'DeploymentType': 'MissionLandingZoneARM'
}
var calculatedTags = union(tags,defaultTags)

// Hub Variables
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

var f5vm01VmName = '${resourcePrefix}-f5vm01'

//// Scaffolding

module hubResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-rg-hub-${nowUtc}'
  params: {
    name: hubResourceGroupName
    location: location
    tags: calculatedTags
  }
}

//// Create Hub Resources
module hubVirtualNetwork './modules/virtualNetwork.bicep' = {
  name: 'deploy-vnet-hub-${nowUtc}'
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

module hubNetworkSecurityGroup './modules/networkSecurityGroup.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-nsg-hub-${nowUtc}'
  params: {
    location: location
    name: hubNetworkSecurityGroupName
    securityRules: hubNetworkSecurityGroupRules
  }
  dependsOn: [
    hubResourceGroup
  ]
}

module f5Vm01 './modules/firewall.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-f5vm01-hub-${nowUtc}'
  params: {
    adminPasswordOrKey: f5VmAdminPasswordOrKey
    adminUsername: f5VmAdminUsername
    authenticationType: f5VmAuthenticationType
    extIpConfigurationName: f5vm01extIpConfigurationName
    extNicName: f5vm01extNicName
    extPrivateIPAddressAllocationMethod: f5privateIPAddressAllocationMethod
    extSubnetName: f5extSubnetName
    intIpConfigurationName: f5vm01intIpConfigurationName
    intNicName: f5vm01intNicName
    intPrivateIPAddressAllocationMethod: f5privateIPAddressAllocationMethod
    intSubnetName: f5intSubnetName
    location: location
    mgmtIpConfigurationName: f5vm01mgmtIpConfigurationName
    mgmtNicName: f5vm01mgmtNicName
    mgmtPrivateIPAddressAllocationMethod: f5privateIPAddressAllocationMethod
    mgmtSubnetName: f5mgmtSubnetName
    networkSecurityGroupId: hubNetworkSecurityGroup.outputs.id
    nowUtc: nowUtc
    osDiskCreateOption: f5VmOsDiskCreateOption
    virtualNetworkName: hubVirtualNetworkName
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
  ]
}