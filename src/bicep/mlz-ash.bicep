// scope
targetScope = 'subscription'

//main

//// Scaffolding

module hubResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-rg-hub-${nowUtc}'
  params: {
    name: hubResourceGroupName
    location: hubLocation
    tags: calculatedTags
  }
}

module spokeResourceGroups './modules/resourceGroup.bicep' = [for spoke in spokes: {
  name: 'deploy-rg-${spoke.name}-${nowUtc}'
  // scope: subscription(spoke.subscriptionId)
  params: {
    name: spoke.resourceGroupName
    location: spoke.location
    tags: calculatedTags
  }
}]

//// hub and spoke networks

module hubNetwork './modules/hubNetwork.bicep' = {
  name: 'deploy-vnet-hub-${nowUtc}'
  // scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  scope: resourceGroup(hubResourceGroupName)
  params: {
    location: hubLocation
    tags: calculatedTags

    virtualNetworkName: hubVirtualNetworkName
    virtualNetworkAddressPrefix: hubVirtualNetworkAddressPrefix

    networkSecurityGroupName: hubNetworkSecurityGroupName
    networkSecurityGroupRules: hubNetworkSecurityGroupRules

    // subnetName: hubSubnetName
    // subnetAddressPrefix: hubSubnetAddressPrefix

    // firewallName: firewallName
    // firewallSkuTier: firewallSkuTier
    // firewallPolicyName: firewallPolicyName
    // firewallThreatIntelMode: firewallThreatIntelMode
    // firewallDiagnosticsLogs: firewallDiagnosticsLogs
    // firewallDiagnosticsMetrics: firewallDiagnosticsMetrics
    // firewallClientIpConfigurationName: firewallClientIpConfigurationName
    firewallClientSubnetName: firewallClientSubnetName
    firewallClientSubnetAddressPrefix: firewallClientSubnetAddressPrefix
    // firewallClientSubnetServiceEndpoints: firewallClientSubnetServiceEndpoints
    // firewallClientPublicIPAddressName: firewallClientPublicIPAddressName
    // firewallClientPublicIPAddressSkuName: firewallClientPublicIPAddressSkuName
    // firewallClientPublicIpAllocationMethod: firewallClientPublicIpAllocationMethod
    // firewallClientPublicIPAddressAvailabilityZones: firewallClientPublicIPAddressAvailabilityZones
    // firewallManagementIpConfigurationName: firewallManagementIpConfigurationName
    // firewallManagementSubnetName: firewallManagementSubnetName
    // firewallManagementSubnetAddressPrefix: firewallManagementSubnetAddressPrefix
    // firewallManagementSubnetServiceEndpoints: firewallManagementSubnetServiceEndpoints
    // firewallManagementPublicIPAddressName: firewallManagementPublicIPAddressName
    // firewallManagementPublicIPAddressSkuName: firewallManagementPublicIPAddressSkuName
    // firewallManagementPublicIpAllocationMethod: firewallManagementPublicIpAllocationMethod
    // firewallManagementPublicIPAddressAvailabilityZones: firewallManagementPublicIPAddressAvailabilityZones
  }
}

// Parameters
param hubResourceGroupName string = '${resourcePrefix}-hub'
param hubLocation string = deployment().location
param uniqueId string = uniqueString(deployment().name)
param resourcePrefix string = 'mlz-${uniqueId}'
param tags object = {}
param nowUtc string = utcNow()

param hubVirtualNetworkName string = 'hub-vnet'
// param hubSubnetName string = 'hub-subnet'
param hubVirtualNetworkAddressPrefix string = '10.0.100.0/24'
// param hubSubnetAddressPrefix string = '10.0.100.128/27'
param hubNetworkSecurityGroupName string = 'hub-nsg'
param hubNetworkSecurityGroupRules array = []

param firewallClientSubnetAddressPrefix string = '10.0.100.0/26'

param identityResourceGroupName string = replace(hubResourceGroupName, 'hub', 'identity')
param identityLocation string = hubLocation

param operationsResourceGroupName string = replace(hubResourceGroupName, 'hub', 'operations')
param operationsLocation string = hubLocation

param sharedServicesResourceGroupName string = replace(hubResourceGroupName, 'hub', 'sharedServices')
param sharedServicesLocation string = hubLocation

//Variables
var defaultTags = {
  'resourcePrefix': resourcePrefix
  'DeploymentType': 'MissionLandingZoneARM'
}
var calculatedTags = union(tags,defaultTags)
var firewallClientSubnetName = 'Firewall_Client_Subnet'
var spokes = [
  {
    name: 'operations'
    resourceGroupName: operationsResourceGroupName
    location: operationsLocation
    // logStorageAccountName: operationsLogStorageAccountName
    // logStorageSkuName: operationsLogStorageSkuName
    // virtualNetworkName: operationsVirtualNetworkName
    // virtualNetworkAddressPrefix: operationsVirtualNetworkAddressPrefix
    // virtualNetworkDiagnosticsLogs: operationsVirtualNetworkDiagnosticsLogs
    // virtualNetworkDiagnosticsMetrics: operationsVirtualNetworkDiagnosticsMetrics
    // networkSecurityGroupName: operationsNetworkSecurityGroupName
    // networkSecurityGroupRules: operationsNetworkSecurityGroupRules
    // networkSecurityGroupDiagnosticsLogs: operationsNetworkSecurityGroupDiagnosticsLogs
    // networkSecurityGroupDiagnosticsMetrics: operationsNetworkSecurityGroupDiagnosticsMetrics
    // subnetName: operationsSubnetName
    // subnetAddressPrefix: operationsSubnetAddressPrefix
    // subnetServiceEndpoints: operationsSubnetServiceEndpoints
  }
  {
    name: 'identity'
    resourceGroupName: identityResourceGroupName
    location: identityLocation
    // logStorageAccountName: identityLogStorageAccountName
    // logStorageSkuName: identityLogStorageSkuName
    // virtualNetworkName: identityVirtualNetworkName
    // virtualNetworkAddressPrefix: identityVirtualNetworkAddressPrefix
    // virtualNetworkDiagnosticsLogs: identityVirtualNetworkDiagnosticsLogs
    // virtualNetworkDiagnosticsMetrics: identityVirtualNetworkDiagnosticsMetrics
    // networkSecurityGroupName: identityNetworkSecurityGroupName
    // networkSecurityGroupRules: identityNetworkSecurityGroupRules
    // networkSecurityGroupDiagnosticsLogs: identityNetworkSecurityGroupDiagnosticsLogs
    // networkSecurityGroupDiagnosticsMetrics: identityNetworkSecurityGroupDiagnosticsMetrics
    // subnetName: identitySubnetName
    // subnetAddressPrefix: identitySubnetAddressPrefix
    // subnetServiceEndpoints: identitySubnetServiceEndpoints
  }
  {
    name: 'sharedServices'
    resourceGroupName: sharedServicesResourceGroupName
    location: sharedServicesLocation
    // logStorageAccountName: sharedServicesLogStorageAccountName
    // logStorageSkuName: sharedServicesLogStorageSkuName
    // virtualNetworkName: sharedServicesVirtualNetworkName
    // virtualNetworkAddressPrefix: sharedServicesVirtualNetworkAddressPrefix
    // virtualNetworkDiagnosticsLogs: sharedServicesVirtualNetworkDiagnosticsLogs
    // virtualNetworkDiagnosticsMetrics: sharedServicesVirtualNetworkDiagnosticsMetrics
    // networkSecurityGroupName: sharedServicesNetworkSecurityGroupName
    // networkSecurityGroupRules: sharedServicesNetworkSecurityGroupRules
    // networkSecurityGroupDiagnosticsLogs: sharedServicesNetworkSecurityGroupDiagnosticsLogs
    // networkSecurityGroupDiagnosticsMetrics: sharedServicesNetworkSecurityGroupDiagnosticsMetrics
    // subnetName: sharedServicesSubnetName
    // subnetAddressPrefix: sharedServicesSubnetAddressPrefix
    // subnetServiceEndpoints: sharedServicesSubnetServiceEndpoints
  }
]
