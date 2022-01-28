param location string
param tags object = {}
param hubSubnetResourceId string
param hubNetworkSecurityGroupResourceId string
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

module linuxNetworkInterface './networkInterface.bicep' = {
  name: 'remoteAccess-linuxNetworkInterface'
  params: {
    name: linuxNetworkInterfaceName
    location: location
    tags: tags
    
    ipConfigurationName: linuxNetworkInterfaceIpConfigurationName
    networkSecurityGroupId: hubNetworkSecurityGroupResourceId
    privateIPAddressAllocationMethod: linuxNetworkInterfacePrivateIPAddressAllocationMethod
    subnetId: hubSubnetResourceId
    publicIP: 'no'
    
  }
}

module linuxVirtualMachine './linuxVirtualMachine.bicep' = {
  name: 'remoteAccess-linuxVirtualMachine'
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


