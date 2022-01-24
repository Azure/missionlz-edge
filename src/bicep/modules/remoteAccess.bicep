param location string
param tags object = {}

param hubVirtualNetworkName string
param hubSubnetResourceId string
param hubNetworkSecurityGroupResourceId string

param linuxNetworkInterfaceName string
param linuxNetworkInterfaceIpConfigurationName string
param linuxNetworkInterfacePrivateIPAddressAllocationMethod string

param publicIP string
param publicIPAddressId string
//param networkInterfaces array
param WindowspublicIPAddressId string

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


//param nowUtc string = utcNow()

resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: hubVirtualNetworkName
}

// Create External NIC
resource extSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${hubVirtualNetworkName}/test'
}

// Create Public IP
module PublicIp './publicIPAddress.bicep' = {
  name: 'create-pubip'
  params: {
    location: location
    name: 'extPublicIpName'
    publicIpAllocationMethod: 'Dynamic'
  }
}


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
    publicIP: publicIP
    publicIPAddressId: publicIPAddressId
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

module windowsNetworkInterface './networkInterface.bicep' = {
  name: 'remoteAccess-windowsNetworkInterface'
  params: {
    name: windowsNetworkInterfaceName
    location: location
    tags: tags
    
    ipConfigurationName: windowsNetworkInterfaceIpConfigurationName
    networkSecurityGroupId: hubNetworkSecurityGroupResourceId
    privateIPAddressAllocationMethod: windowsNetworkInterfacePrivateIPAddressAllocationMethod
    subnetId: hubSubnetResourceId
    publicIP: publicIP
    publicIPAddressId: WindowspublicIPAddressId
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
