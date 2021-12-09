param name string
param location string
param tags object = {}

param ipConfigurationName string
param subnetId string
param networkSecurityGroupId string
param privateIPAddressAllocationMethod string
param publicIP string
param publicIPAddressId string = ''

var ipConfig = {
  yes: [
    {
      name: ipConfigurationName
      properties: {
        subnet: {
          id: subnetId
        }
        privateIPAllocationMethod: privateIPAddressAllocationMethod
        publicIPAddress: {
          id: publicIPAddressId
        }
      }
    }
  ]
  no: [
    {
      name: ipConfigurationName
      properties: {
        subnet: {
          id: subnetId
        }
        privateIPAllocationMethod: privateIPAddressAllocationMethod
      }
    }
  ]
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2018-11-01' = {
  name: name
  location: location
  tags: tags

  properties: {
    ipConfigurations: ipConfig[publicIP]
    networkSecurityGroup: {
      id: networkSecurityGroupId
    }
  }
}

output id string = networkInterface.id
output name string = networkInterface.name
