// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param location string
param tags object = {}
param virtualNetworkName string
param virtualNetworkAddressPrefix string
param networkSecurityGroupName string
param networkSecurityGroupRules array
param subnetName string
param subnetAddressPrefix string
param customDNSArray array = []
param firewallPrivateIPAddress string = ''
param routeTableName string = '${subnetName}-routetable'
param routeTableRouteName string = 'default_route'
param routeTableRouteAddressPrefix string = '0.0.0.0/0'
param routeTableRouteNextHopType string

var routeNextHopIpAddress = ((toLower(routeTableRouteNextHopType) == 'virtualappliance') && (!empty(firewallPrivateIPAddress))) ? firewallPrivateIPAddress : ''

module networkSecurityGroup './networkSecurityGroup.bicep' = {
  name: 'networkSecurityGroup'
  params: {
    name: networkSecurityGroupName
    location: location
    tags: tags

    securityRules: networkSecurityGroupRules
  }
}

module routeTable './routeTable.bicep' = {
  name: 'routeTable'
  params: {
    name: routeTableName
    location: location
    tags: tags

    routeName: routeTableRouteName
    routeAddressPrefix: routeTableRouteAddressPrefix
    routeNextHopIpAddress: routeNextHopIpAddress
    routeNextHopType: routeTableRouteNextHopType
  }
}

module virtualNetwork './virtualNetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    name: virtualNetworkName
    location: location
    tags: tags
    customDNSArray: customDNSArray
    addressPrefix: virtualNetworkAddressPrefix
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.outputs.id
          }
          routeTable: {
            id: routeTable.outputs.id
          }
        }
      }
    ]
  }
}

output virtualNetworkName string = virtualNetwork.outputs.name
output virtualNetworkResourceId string = virtualNetwork.outputs.id
output subnetName string = virtualNetwork.outputs.subnets[0].name
output subnetAddressPrefix string = virtualNetwork.outputs.subnets[0].properties.addressPrefix
output subnetResourceId string = virtualNetwork.outputs.subnets[0].id
output networkSecurityGroupName string = networkSecurityGroup.outputs.name
output networkSecurityGroupResourceGroupName string = resourceGroup().name
output networkSecurityGroupResourceId string = networkSecurityGroup.outputs.id
