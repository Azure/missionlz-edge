// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param localVirtualNetworkName string
param remoteVirtualNetworkName string
param remoteResourceGroupName string
param allowForwardedTraffic bool = false

resource localVirtualNetwork 'Microsoft.Network/virtualNetworks@2018-11-01' existing = {
  name: localVirtualNetworkName
}

resource remoteVirtualNetwork 'Microsoft.Network/virtualNetworks@2018-11-01' existing = {
  scope: resourceGroup(remoteResourceGroupName)
  name: remoteVirtualNetworkName
}

resource virtualNetworkPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2018-11-01' = {
  name: '${localVirtualNetwork.name}/to-${remoteVirtualNetwork.name}'
  properties: {
    allowForwardedTraffic: allowForwardedTraffic
    remoteVirtualNetwork: {
      id: remoteVirtualNetwork.id
    }
  }
}
