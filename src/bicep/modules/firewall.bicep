// Test NIC module
module linuxNetworkInterface './networkInterface.bicep' = {
  name: 'Test-NIC-Module'
  params: {
    ipConfigurationName: linuxNetworkInterfaceIpConfigurationName
    location: location
    name: linuxNetworkInterfaceName
    networkSecurityGroupId: hubNsg.id
    privateIPAddressAllocationMethod: linuxNetworkInterfacePrivateIPAddressAllocationMethod
    subnetId: hubSn.id
  }
}

// Test VM module
module linuxVM './linuxVirtualMachine.bicep' = {
  name: 'Test-linuxVM-Module'
  params: {
    adminPasswordOrKey: linuxVmAdminPasswordOrKey
    adminUsername: linuxVmAdminUsername
    authenticationType: linuxVmAuthenticationType
    location: location
    name: linuxVmName
    networkInterfaceName: linuxNetworkInterface.outputs.name
    osDiskCreateOption: linuxVmOsDiskCreateOption
    osDiskType: linuxVmOsDiskType
    vmImageOffer: linuxVmImageOffer
    vmImagePublisher: linuxVmImagePublisher
    vmImageSku: linuxVmImageSku
    vmImageVersion: linuxVmImageVersion
    vmSize: linuxVmSize
  }
}
