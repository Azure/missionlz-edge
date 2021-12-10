param location string = resourceGroup().location
param tags object = {}

param virtualNetworkName string
param virtualNetworkAddressPrefix string

param networkSecurityGroupName string
param networkSecurityGroupRules array

param firewallClientSubnetName string
param firewallClientSubnetAddressPrefix string

// param subnetName string
// param subnetAddressPrefix string

// param routeTableName string = '${subnetName}-routetable'
// param routeTableRouteName string = 'default_route'
// param routeTableRouteAddressPrefix string = '0.0.0.0/0'
// param routeTableRouteNextHopType string = 'VirtualAppliance'

// param supportedClouds array = [
//   'AzureCloud'
//   'AzureUSGovernment'
// ]

// module logStorage './storageAccount.bicep' = {
//   name: 'logStorage'
//   params: {
//     storageAccountName: logStorageAccountName
//     location: location
//     skuName: logStorageSkuName
//     tags: tags
//   }
// }

module networkSecurityGroup './networkSecurityGroup.bicep' = {
  name: 'networkSecurityGroup'
  params: {
    name: networkSecurityGroupName
    location: location
    tags: tags

    securityRules: networkSecurityGroupRules
  }
}

module virtualNetwork './virtualNetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    name: virtualNetworkName
    location: location
    tags: tags

    addressPrefix: virtualNetworkAddressPrefix

    subnets: [
      {
        name: firewallClientSubnetName
        properties: {
          addressPrefix: firewallClientSubnetAddressPrefix
        }
      }
    ]
  }
}

// module routeTable './routeTable.bicep' = {
//   name: 'routeTable'
//   params: {
//     name: routeTableName
//     location: location
//     tags: tags

//     routeName: routeTableRouteName
//     routeAddressPrefix: routeTableRouteAddressPrefix
//     routeNextHopIpAddress: firewall.outputs.privateIPAddress
//     routeNextHopType: routeTableRouteNextHopType
//   }
//   dependsOn: [
//     firewall
//   ]
// }

// resource subnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' = {
//   name: '${virtualNetworkName}/${subnetName}'
//   properties: {
//     addressPrefix: subnetAddressPrefix
//     networkSecurityGroup: {
//       id: networkSecurityGroup.outputs.id
//     }
//     // routeTable: {
//     //   id: routeTable.outputs.id
//     // }
//   }
//   dependsOn: [
//     virtualNetwork
//   ]
// }

// module firewall './firewall.bicep' = {
//   name: 'firewall'
//   params: {
//     name: firewallName
//     location: location
//     tags: tags

//   }
// }

output virtualNetworkName string = virtualNetwork.outputs.name
output virtualNetworkResourceId string = virtualNetwork.outputs.id
// output subnetName string = subnet.name
// output subnetAddressPrefix string = subnet.properties.addressPrefix
// output subnetResourceId string = subnet.id
output networkSecurityGroupName string = networkSecurityGroup.outputs.name
output networkSecurityGroupResourceId string = networkSecurityGroup.outputs.id
// output firewallPrivateIPAddress string = firewall.outputs.privateIPAddress
