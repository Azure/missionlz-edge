// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string
param location string
param virtualNetworkName string
param privateIpAllocationMethod string = 'Dynamic'
param publicIPAddressId string
//param tags object = {}
param gatewaySku string

resource vnetGateway 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${name}-config'
        properties: {
          privateIPAllocationMethod: privateIpAllocationMethod
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'GatewaySubnet')
          }
          publicIPAddress: {
            id: publicIPAddressId
          }
        }
      }
    ]
    gatewayType: 'Vpn'
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    vpnType: 'RouteBased'
    enableBgp: true
    bgpSettings: {
      asn: 65010
    }
  }
}

output name string = vnetGateway.name
output id string = vnetGateway.id
