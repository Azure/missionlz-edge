// Parameters
param nowUtc string
param location string
param networkSecurityGroupId string
param virtualNetworkName string

@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'
@secure()
@minLength(14)
param adminPasswordOrKey string
param adminUsername string
param osDiskCreateOption string
param vmName string
param vmOsDiskType string
param vmImageOffer string
param vmImagePublisher string
param vmImageSku string
param vmImageVersion string
param vmSize string

param extIpConfigurationName string
param extNicName string
param extPrivateIPAddressAllocationMethod string
param extSubnetName string

param intIpConfigurationName string
param intNicName string
param intPrivateIPAddressAllocationMethod string
param intSubnetName string

param mgmtIpConfigurationName string
param mgmtNicName string
param mgmtPrivateIPAddressAllocationMethod string
param mgmtSubnetName string

// Variables
var nics = [
  {
    id: f5managementNic.outputs.id
    properties: {
      primary: true
    }
  }
  {
    id: f5externalNic.outputs.id
    properties: {
      primary: false
    }
  }
  {
    id: f5internalNic.outputs.id
    properties: {
      primary: false
    }
  }
]
// Create External NIC
resource extSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${virtualNetworkName}/${extSubnetName}'
}

module f5externalNic './networkInterface.bicep' = {
  name: 'create-ext-nic-${nowUtc}'
  params: {
    ipConfigurationName: extIpConfigurationName
    location: location
    name: extNicName
    networkSecurityGroupId: networkSecurityGroupId
    privateIPAddressAllocationMethod: extPrivateIPAddressAllocationMethod
    subnetId: extSubnet.id
  }
}

// Create Internal NIC
resource intSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${virtualNetworkName}/${intSubnetName}'
}

module f5internalNic './networkInterface.bicep' = {
  name: 'create-int-nic-${nowUtc}'
  params: {
    ipConfigurationName: intIpConfigurationName
    location: location
    name: intNicName
    networkSecurityGroupId: networkSecurityGroupId
    privateIPAddressAllocationMethod: intPrivateIPAddressAllocationMethod
    subnetId: intSubnet.id
  }
}

// Create Management NIC
resource mgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${virtualNetworkName}/${mgmtSubnetName}'
}

module f5managementNic './networkInterface.bicep' = {
  name: 'create-mgmt-nic-${nowUtc}'
  params: {
    ipConfigurationName: mgmtIpConfigurationName
    location: location
    name: mgmtNicName
    networkSecurityGroupId: networkSecurityGroupId
    privateIPAddressAllocationMethod: mgmtPrivateIPAddressAllocationMethod
    subnetId: mgmtSubnet.id
  }
}

// Deploy F5 VM
module f5vm './linuxVirtualMachine.bicep' = {
  name: 'create-f5vm-${nowUtc}'
  params: {
    adminPasswordOrKey: adminPasswordOrKey
    adminUsername: adminUsername
    authenticationType: authenticationType
    location: location
    name: vmName
    networkInterfaces: nics
    osDiskCreateOption: osDiskCreateOption
    osDiskType: vmOsDiskType
    vmImageOffer: vmImageOffer
    vmImagePublisher: vmImagePublisher
    vmImageSku: vmImageSku
    vmImageVersion: vmImageVersion
    vmSize: vmSize
  }
  dependsOn: [
    f5externalNic
    f5internalNic
    f5managementNic
  ]
}
