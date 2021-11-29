param name string
param remoteVirtualNetworkResourceId string

resource virtualNetworkPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2018-11-01' = {
  name: name
  properties: {
    remoteVirtualNetwork: {
      id: remoteVirtualNetworkResourceId
    }
  }
}
