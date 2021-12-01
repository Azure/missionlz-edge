param name string
param location string
param tags object = {}

param ipConfigurationName string
// param subnetId string
param networkSecurityGroupId string
param privateIPAddressAllocationMethod string

param existingVirtualNetworkName string
param existingSubnetName string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${existingVirtualNetworkName}/${existingSubnetName}'
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2018-11-01' = {
  name: name
  location: location
  tags: tags

  properties: {
    ipConfigurations: [
      {
        name: ipConfigurationName
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: privateIPAddressAllocationMethod
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroupId
    }
  }
}

output id string = networkInterface.id
output name string = networkInterface.name
