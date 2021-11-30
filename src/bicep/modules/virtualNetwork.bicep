param name string
param location string
param tags object = {}
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
    subnets: subnets
  }
}

output name string = virtualNetwork.name
output id string = virtualNetwork.id
output subnets array = virtualNetwork.properties.subnets
