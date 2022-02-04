// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string
param location string
param tags object = {}
param networkInterfaceName string
param size string
param adminUsername string
@secure()
@minLength(14)
param adminPassword string
param publisher string
param offer string
param sku string
param version string
param createOption string
param storageAccountType string

resource networkInterface 'Microsoft.Network/networkInterfaces@2018-11-01' existing = {
  name: networkInterfaceName
}

resource windowsVirtualMachine 'Microsoft.Compute/virtualMachines@2017-03-30' = {
  name: name
  location: location
  tags: tags

  properties: {
    hardwareProfile: {
      vmSize: size 
    }
    osProfile: {
      computerName: take(name, 15)
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: publisher
        offer: offer
        sku: sku
        version: version 
      }
      osDisk: {
        createOption: createOption
        managedDisk: {
          storageAccountType: storageAccountType          
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        { 
          id: networkInterface.id
        }
      ]
    }
  }
}

output windowsVm object = windowsVirtualMachine
output windowsVmName string = windowsVirtualMachine.name
