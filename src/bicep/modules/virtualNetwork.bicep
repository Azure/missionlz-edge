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
// output subnets array = virtualNetwork.properties.subnets
output mgmtSubnetId string = virtualNetwork.properties.subnets[0].id
output intSubnetId string = virtualNetwork.properties.subnets[1].id
output extSubnetId string = virtualNetwork.properties.subnets[2].id
output vdmsSubnetId string = virtualNetwork.properties.subnets[3].id

// output mgmtSubnetId string = resourceId('Microsoft.Network/VirtualNetworks/subnets', name, subnets[0].name)
// output intSubnetId string = resourceId('Microsoft.Network/VirtualNetworks/subnets', name, subnets[1].name)
// output extSubnetId string = resourceId('Microsoft.Network/VirtualNetworks/subnets', name, subnets[2].name)
// output vdmsSubnetId string = resourceId('Microsoft.Network/VirtualNetworks/subnets', name, subnets[3].name)
