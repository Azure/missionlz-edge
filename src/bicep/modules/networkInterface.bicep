// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string
param location string
param tags object = {}
param enableIPForwarding bool = false
param ipConfigurations array

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
