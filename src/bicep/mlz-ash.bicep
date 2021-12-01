// scope
targetScope = 'subscription'

//main

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
}

module hubNetworkSecurityGroup './modules/networkSecurityGroup.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-nsg-hub-${nowUtc}'
  params: {
    location: location
    name: hubNetworkSecurityGroupName
    securityRules: hubNetworkSecurityGroupRules
  }
}

// Parameters
param hubResourceGroupName string = '${resourcePrefix}-hub'
param location string = deployment().location
param uniqueId string = uniqueString(deployment().name)
param resourcePrefix string = 'mlz-${uniqueId}'
param tags object = {}
param nowUtc string = utcNow()


// Variables
var defaultTags = {
  'resourcePrefix': resourcePrefix
  'DeploymentType': 'MissionLandingZoneARM'
}
var calculatedTags = union(tags,defaultTags)
