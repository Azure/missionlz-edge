param location string
param tags object = {}
param deploymentNameSuffix string
param mgmtSubnetId string
param hubVirtualNetworkName string

param linuxNetworkInterfaceName string
param linuxNetworkInterfaceIpConfigurationName string
param linuxNetworkInterfacePrivateIPAddressAllocationMethod string
param linuxNetworkInterfaceIpConfigurations array = [
  {
    name: linuxNetworkInterfaceIpConfigurationName
    properties: {
      subnet: {
        id: mgmtSubnetId
      }
      primary: true
      privateIPAllocationMethod: linuxNetworkInterfacePrivateIPAddressAllocationMethod
    }
  }
]
param linuxVmName string
param linuxVmSize string
param linuxVmOsDiskCreateOption string
param linuxVmOsDiskType string
param linuxVmImagePublisher string
param linuxVmImageOffer string 
param linuxVmImageSku string
param linuxVmImageVersion string
param linuxVmAdminUsername string
@allowed([
  'sshPublicKey'
  'password'
])
param linuxVmAuthenticationType string
@secure()
@minLength(14)
param linuxVmAdminPasswordOrKey string

param windowsNetworkInterfaceName string
param windowsNetworkInterfaceIpConfigurationName string
param windowsNetworkInterfacePrivateIPAddressAllocationMethod string
param windowspublicIPAddressId string
param windowsNetworkInterfaceIpConfigurations array = [
  {
    name: windowsNetworkInterfaceIpConfigurationName
    properties: {
      subnet: {
        id: mgmtSubnetId
      }
      primary: true
      privateIPAllocationMethod: windowsNetworkInterfacePrivateIPAddressAllocationMethod
      publicIpAddress: {
        id: windowspublicIPAddressId

      }
    }
  }
]
param windowsVmName string
param windowsVmSize string
param windowsVmAdminUsername string
@secure()
@minLength(14)
param windowsVmAdminPassword string
param windowsVmPublisher string
param windowsVmOffer string
param windowsVmSku string
param windowsVmVersion string
param windowsVmCreateOption string
param windowsVmStorageAccountType string

var nics = [
  {
    id: linuxNetworkInterface.outputs.id
    properties: {
      primary: true

    }
  }
]

resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: hubVirtualNetworkName
}

resource extSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${hubVirtualNetworkName}/test'
}

module linuxNetworkInterface './networkInterface.bicep' = {
  name: 'deploy-ra-linux-nic-${deploymentNameSuffix}'
  params: {
    name: linuxNetworkInterfaceName
    location: location
    tags: tags
    ipConfigurations: linuxNetworkInterfaceIpConfigurations
  }
}

module linuxVirtualMachine './linuxVirtualMachine.bicep' = {
  name: 'deploy-ra-linux-vm-${deploymentNameSuffix}'
  params: {
    name: linuxVmName
    location: location
    tags: tags

    vmSize: linuxVmSize
    osDiskCreateOption: linuxVmOsDiskCreateOption
    osDiskType: linuxVmOsDiskType
    vmImagePublisher: linuxVmImagePublisher
    vmImageOffer: linuxVmImageOffer
    vmImageSku: linuxVmImageSku
    vmImageVersion: linuxVmImageVersion
    adminUsername: linuxVmAdminUsername
    authenticationType: linuxVmAuthenticationType
    adminPasswordOrKey: linuxVmAdminPasswordOrKey
    networkInterfaces: nics
    }
}

module windowsNetworkInterface './networkInterface.bicep' = {
  name: 'deploy-ra-windows-nic-${deploymentNameSuffix}'
  params: {
    name: windowsNetworkInterfaceName
    location: location
    tags: tags
    ipConfigurations: windowsNetworkInterfaceIpConfigurations
  }
}

module windowsVirtualMachine './windowsVirtualMachine.bicep' = {
  name: 'remoteAccess-windowsVirtualMachine'
  params: {
    name: windowsVmName
    location: location
    tags: tags

    size: windowsVmSize
    adminUsername: windowsVmAdminUsername
    adminPassword: windowsVmAdminPassword
    publisher: windowsVmPublisher
    offer: windowsVmOffer
    sku: windowsVmSku
    version: windowsVmVersion
    createOption: windowsVmCreateOption
    storageAccountType: windowsVmStorageAccountType
    networkInterfaceName: windowsNetworkInterface.outputs.name
    }
}

output windowsVm object = windowsVirtualMachine.outputs.windowsVm
output windowsVmName string = windowsVirtualMachine.outputs.windowsVmName
