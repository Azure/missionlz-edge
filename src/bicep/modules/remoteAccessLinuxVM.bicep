param location string
param tags object = {}
param deploymentNameSuffix string
param hubSubnetResourceId string
param linuxNetworkInterfaceName string
param linuxNetworkInterfaceIpConfigurationName string
param linuxNetworkInterfacePrivateIPAddressAllocationMethod string
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

var nics = [
  {
    id: linuxNetworkInterface.outputs.id
    properties: {
      primary: true

    }
  }
]

param linuxNetworkInterfaceIpConfigurations array = [
  {
    name: linuxNetworkInterfaceIpConfigurationName
    properties: {
      subnet: {
        id: hubSubnetResourceId
      }
      primary: true
      privateIPAllocationMethod: linuxNetworkInterfacePrivateIPAddressAllocationMethod
    }
  }
]

module linuxNetworkInterface './networkInterface.bicep' = {
  name: 'deploy-ra-linux-nic-${deploymentNameSuffix}'
  params: {
    name: linuxNetworkInterfaceName
    location: location
    tags: tags    
    ipConfigurations:linuxNetworkInterfaceIpConfigurations
   
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


