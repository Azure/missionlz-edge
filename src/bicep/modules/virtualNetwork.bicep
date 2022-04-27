// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string
param location string
param tags object = {}
param customDNSArray array = []
param addressPrefix string
param subnets array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2018-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: customDNSArray
    }
    subnets: subnets
  }
}

output name string = virtualNetwork.name
output id string = virtualNetwork.id
output subnets array = virtualNetwork.properties.subnets

// The outputs below do not work on the current version of Azure Stack.
// Use the outputs below once support by the Azure Stack API

// output mgmtSubnetId string = virtualNetwork.properties.subnets[0].id
// output intSubnetId string = virtualNetwork.properties.subnets[1].id
// output extSubnetId string = virtualNetwork.properties.subnets[2].id
// output vdmsSubnetId string = virtualNetwork.properties.subnets[3].id
