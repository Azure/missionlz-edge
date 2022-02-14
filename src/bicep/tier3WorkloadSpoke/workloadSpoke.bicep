// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// scope
targetScope = 'subscription'

@description('The region to deploy resources into. It defaults to the deployment location.')
param location string = deployment().location

// WORKLOAD PARAMETERS

@minLength(3)
@maxLength(10)
@description('A prefix, 3-10 alphanumeric characters without whitespace, used to prefix resources and generate uniqueness for resources with globally unique naming requirements like Storage Accounts and Log Analytics Workspaces')
param resourcePrefix string

@minLength(3)
@maxLength(6)
@description('A suffix, 3 to 6 characters in length, to append to resource names (e.g. "dev", "test", "prod", "mlz"). It defaults to "mlz".')
param resourceSuffix string = 'mlz'

@minLength(3)
@maxLength(14)
@description('Workload name, 3-14 alphanumeric characters without whitespaces. It defaults to "workload"')
param workloadName string ='workload'

@description('The CIDR Virtual Network Address Prefix for the Shared Services Virtual Network.')
param workloadVirtualNetworkAddressPrefix string = '10.100.0.0/16'

@description('The CIDR Subnet Address Prefix for the default Shared Services subnet. It must be in the Shared Services Virtual Network space.')
param workloadSubnetAddressPrefix string = '10.100.0.0/24'

@description('A string dictionary of tags to add to deployed resources. See https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=json#arm-templates for valid settings.')
param tags object = {}

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

@description('True or False value for adding rules to the MLZ spoke NSGs for workload traffic. Default value is false')
param addSpokeRules bool = false

@description('Priority number to be used for the first rule in the array of rules being added to the MLZ-Spoke Network Security Groups. Default value is 100')
param rulePriority int = 100

// WORKLOAD VARIABLES

var workloadResourceGroupName = '${toLower(resourcePrefix)}-rg-${workloadName}-${toLower(resourceSuffix)}'
var workloadVirtualNetworkName = '${toLower(resourcePrefix)}-vnet-${workloadName}-${toLower(resourceSuffix)}'
var workloadNetworkSecurityGroupName = '${toLower(resourcePrefix)}-nsg-${workloadName}-${toLower(resourceSuffix)}'
var workloadSubnetName = '${toLower(resourcePrefix)}-snet-${workloadName}-${toLower(resourceSuffix)}'
var rulesToAddToMLZSpokeNSGs = [
  {
    description: 'Allows traffic from ${workloadName}'
    protocol: '*'
    sourcePortRange: '*'
    destinationPortRange: '*'
    sourceAddressPrefixes: [
      '${workloadVirtualNetworkAddressPrefix}'
    ]
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: rulePriority
    direction: 'Inbound'
  }
]

// HUB PARAMETERS

@description('The Hub Deployment Name.')
param hubDeploymentName string
@description('The Hub subscription Id.')
param hubSubscriptionId string
@description('Hub Resource Group Name.')
param hubResourceGroupName string

// TAGS

var defaultTags = {
  'resourcePrefix': resourcePrefix
  'resourceSuffix': resourceSuffix
  'DeploymentType': 'T3MissionLandingZoneARM'
}

var calculatedTags = union(tags, defaultTags)


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

module workloadAccessToMLZSpokes 'updateMLZNSGs.bicep' = if (addSpokeRules) {
  scope: resourceGroup(workloadResourceGroupName)
  name: 'add-${workloadName}-rule-to-MLZ-NSGs'
  params: {
    nsgs: hubDeploymentValues.outputs.nsgs.value
    rules: rulesToAddToMLZSpokeNSGs
  }
}

output workloadVirtualNetworkName string = workloadSpokeNetwork.outputs.virtualNetworkName
output workloadVirtualNetworkResourceId string = workloadSpokeNetwork.outputs.virtualNetworkResourceId
output workloadSubnetName string = workloadSpokeNetwork.outputs.subnetName
output workloadSubnetAddressPrefix string = workloadSpokeNetwork.outputs.subnetAddressPrefix
output workloadSubnetResourceId string = workloadSpokeNetwork.outputs.subnetResourceId
output workloadNetworkSecurityGroupName string = workloadSpokeNetwork.outputs.networkSecurityGroupName
output workloadNetworkSecurityGroupResourceId string = workloadSpokeNetwork.outputs.networkSecurityGroupResourceId
