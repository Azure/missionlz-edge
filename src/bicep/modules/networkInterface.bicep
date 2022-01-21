param name string
param location string
param tags object = {}

param enableIPForwarding bool = false
param ipConfigurations array

// param ipConfigurationName string
// param subnetId string
// param privateIPAddressAllocationMethod string
// param publicIP string
// param publicIPAddressId string = ''

// var ipConfig = {
//   yes: [
//     {
//       name: ipConfigurationName
//       properties: {
//         subnet: {
//           id: subnetId
//         }
//         privateIPAllocationMethod: privateIPAddressAllocationMethod
//         publicIPAddress: {
//           id: publicIPAddressId
//         }
//       }
//     }
//   ]
//   no: [
//     {
//       name: ipConfigurationName
//       properties: {
//         subnet: {
//           id: subnetId
//         }
//         privateIPAllocationMethod: privateIPAddressAllocationMethod
//       }
//     }
//   ]
// }

// resource networkInterface 'Microsoft.Network/networkInterfaces@2018-11-01' = {
//   name: name
//   location: location
//   tags: tags

//   properties: {
//     enableIPForwarding: enableIPForwarding
//     ipConfigurations: ipConfig[publicIP]
//   }
// }

resource networkInterface 'Microsoft.Network/networkInterfaces@2018-11-01' = {
  name: name
  location: location
  tags: tags

  properties: {
    enableIPForwarding: enableIPForwarding
    ipConfigurations: ipConfigurations
  }
}

output id string = networkInterface.id
output name string = networkInterface.name
output ip string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress
