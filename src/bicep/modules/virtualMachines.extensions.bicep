// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string
param vmName string
param location string
param tags object = {}
param properties object
param protectedSettings object = {}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: '${vmName}/${name}'
  location: location
  tags: tags
  properties: {
    publisher: properties.publisher
    type: properties.type
    typeHandlerVersion: properties.typeHandlerVersion
    autoUpgradeMinorVersion: true
    protectedSettings: protectedSettings
    settings: properties.settings
  }
}
