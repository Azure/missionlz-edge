// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string
param location string
param tags object = {}
param securityRules array

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2018-11-01' = {
  name: name
  location: location
  tags: tags

  properties: {
    securityRules: securityRules
  }
}

output id string = networkSecurityGroup.id
output name string = networkSecurityGroup.name
