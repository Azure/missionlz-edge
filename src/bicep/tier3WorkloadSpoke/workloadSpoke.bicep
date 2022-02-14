// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// scope
targetScope = 'subscription'

@minLength(3)
@maxLength(14)
@description('Workload name, 3-14 alphanumeric characters without whitespaces. It defaults to "workload"')
param workloadName string ='workload'
@minLength(3)
@maxLength(10)
@description('A prefix, 3-10 alphanumeric characters without whitespace, used to prefix resources and generate uniqueness for resources with globally unique naming requirements like Storage Accounts and Log Analytics Workspaces')
param resourcePrefix string
@minLength(3)
@maxLength(6)
@description('A suffix, 3 to 6 characters in length, to append to resource names (e.g. "dev", "test", "prod", "mlz"). It defaults to "mlz".')
param resourceSuffix string = 'mlz'
@description('A string dictionary of tags to add to deployed resources. See https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=json#arm-templates for valid settings.')
param tags object = {}

// Hub Resources
@description('The Hub Deployment Name.')
param hubDeploymentName string
@description('The Hub subscription Id.')
param hubSubscriptionId string
@description('Hub Resource Group Name.')
param hubResourceGroupName string
// @description('Hub Virtual Network Name to peer with.')
// param hubVirtualNetworkName string
// @description('Hub Firewall Private IP Address.')
// param firewallPrivateIPAddress string
//

@description('The region to deploy resources into. It defaults to the deployment location.')
param location string = deployment().location

@description('An array of Network Security Group rules to apply to the SharedServices Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings.')
param workloadNetworkSecurityGroupRules array = [
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

var workloadResourceGroupName = '${toLower(resourcePrefix)}-rg-${workloadName}-${toLower(resourceSuffix)}'
var workloadVirtualNetworkName = '${toLower(resourcePrefix)}-vnet-${workloadName}-${toLower(resourceSuffix)}'
var workloadNetworkSecurityGroupName = '${toLower(resourcePrefix)}-nsg-${workloadName}-${toLower(resourceSuffix)}'
var workloadSubnetName = '${toLower(resourcePrefix)}-snet-${workloadName}-${toLower(resourceSuffix)}'

// TAGS

var defaultTags = {
  'resourcePrefix': resourcePrefix
  'resourceSuffix': resourceSuffix
  'DeploymentType': 'T3MissionLandingZoneARM'
}

var calculatedTags = union(tags, defaultTags)

@description('The CIDR Virtual Network Address Prefix for the Shared Services Virtual Network.')
param workloadVirtualNetworkAddressPrefix string = '10.100.0.0/16'

@description('The CIDR Subnet Address Prefix for the default Shared Services subnet. It must be in the Shared Services Virtual Network space.')
param workloadSubnetAddressPrefix string = '10.100.0.0/24'

resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: workloadResourceGroupName
  location: location
  tags: calculatedTags
}

module hubDeploymentValues './hubDeploymentValues.bicep' = {
  name: 'HubValues'
  params: {
    hubSubscriptionId:hubSubscriptionId
    mlzHubDeploymentName:hubDeploymentName    
  }
}

module workloadSpokeNetwork '../modules/spokeNetwork.bicep' = {
  name: 'workLoadSpokeNetwork'
  scope: az.resourceGroup(workloadResourceGroupName)
  params: {
    tags: calculatedTags    
    firewallPrivateIPAddress: hubDeploymentValues.outputs.firewallPrivateIPAddress
    virtualNetworkName: workloadVirtualNetworkName
    virtualNetworkAddressPrefix: workloadVirtualNetworkAddressPrefix
    networkSecurityGroupName: workloadNetworkSecurityGroupName
    networkSecurityGroupRules: workloadNetworkSecurityGroupRules
    subnetName: workloadSubnetName
    subnetAddressPrefix: workloadSubnetAddressPrefix
    
  }
  dependsOn:[
    hubDeploymentValues
  ]
}

module hubVirtualNetworkPeerings '../modules/virtualNetworkPeering.bicep' = {
  name: 'deploy-hub-to-${workloadName}-vnet-peering'
  scope: az.resourceGroup(hubResourceGroupName)
  params: {
    localVirtualNetworkName: hubDeploymentValues.outputs.hubVirtualNetworkName
    remoteVirtualNetworkName: workloadVirtualNetworkName
    remoteResourceGroupName: workloadResourceGroupName
  }
  dependsOn: [
    hubDeploymentValues
    workloadSpokeNetwork
  ]
}

module workloadVirtualNetworkPeerings '../modules/virtualNetworkPeering.bicep' =  {
  name: 'deploy-workload-to-hub-vnet-peering'
  scope: az.resourceGroup(workloadResourceGroupName)
  params: {
    localVirtualNetworkName: workloadVirtualNetworkName
    remoteVirtualNetworkName: hubDeploymentValues.outputs.hubVirtualNetworkName
    remoteResourceGroupName: hubDeploymentValues.outputs.hubResourceGroupName
  }
  dependsOn: [
    hubDeploymentValues
    workloadSpokeNetwork
  ]
}

output workloadVirtualNetworkName string = workloadSpokeNetwork.outputs.virtualNetworkName
output workloadVirtualNetworkResourceId string = workloadSpokeNetwork.outputs.virtualNetworkResourceId
output workloadSubnetName string = workloadSpokeNetwork.outputs.subnetName
output workloadSubnetAddressPrefix string = workloadSpokeNetwork.outputs.subnetAddressPrefix
output workloadSubnetResourceId string = workloadSpokeNetwork.outputs.subnetResourceId
output workloadNetworkSecurityGroupName string = workloadSpokeNetwork.outputs.networkSecurityGroupName
output workloadNetworkSecurityGroupResourceId string = workloadSpokeNetwork.outputs.networkSecurityGroupResourceId
