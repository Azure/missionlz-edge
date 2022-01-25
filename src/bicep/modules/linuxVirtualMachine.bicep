param name string
param location string
param tags object = {}

param networkInterfaces array

param vmSize string
param osDiskCreateOption string
param osDiskType string
param vmImagePublisher string
param vmImageOffer string
param vmImageSku string
param vmImageVersion string
param adminUsername string
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string
@secure()
@minLength(14)
param adminPasswordOrKey string

var osProfile = {
  sshPublicKey: {
    computerName: name
    adminUsername: adminUsername
    linuxConfiguration: {
      disablePasswordAuthentication: true
      ssh: {
        publicKeys: [
          {
            path: '/home/${adminUsername}/.ssh/authorized_keys'
            keyData: adminPasswordOrKey
          }
        ]
      }
    }
  }
  password: {
    computerName: name
    adminUsername: adminUsername
    adminPassword: adminPasswordOrKey
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: name
  location: location
  tags: tags

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: osDiskCreateOption
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: vmImagePublisher
        offer: vmImageOffer
        sku: vmImageSku
        version: vmImageVersion
      }
    }
    networkProfile: {
      networkInterfaces: networkInterfaces
    }
    osProfile: osProfile[authenticationType]
  }
}

output adminUsername string = adminUsername
output authenticationType string = authenticationType
