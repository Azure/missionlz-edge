// Parameters
param deploymentNameSuffix string
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
param extPublicIPAddressAllocationMethod string
param extPublicIpName string
param extSubnetName string
@allowed([
  'yes'
  'no'
])
param extPublicIP string = 'yes'


param intIpConfigurationName string
param intNicName string
param intPrivateIPAddressAllocationMethod string
param intSubnetName string
@allowed([
  'yes'
  'no'
])
param intPublicIP string = 'no'

param mgmtIpConfigurationName string
param mgmtNicName string
param mgmtPrivateIPAddressAllocationMethod string
param mgmtSubnetName string
@allowed([
  'yes'
  'no'
])
param mgmtPublicIP string = 'no'

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

// Create Public IP
module fwPublicIp './publicIPAddress.bicep' = {
  name: 'create-fw-pubip-${deploymentNameSuffix}'
  params: {
    location: location
    name: extPublicIpName
    publicIpAllocationMethod: extPublicIPAddressAllocationMethod
  }
}

// Create External NIC
resource extSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${virtualNetworkName}/${extSubnetName}'
}

module f5externalNic './networkInterface.bicep' = {
  name: 'create-ext-nic-${deploymentNameSuffix}'
  params: {
    ipConfigurationName: extIpConfigurationName
    location: location
    name: extNicName
    networkSecurityGroupId: networkSecurityGroupId
    privateIPAddressAllocationMethod: extPrivateIPAddressAllocationMethod
    publicIP: extPublicIP
    publicIPAddressId: fwPublicIp.outputs.id
    subnetId: extSubnet.id
  }
  dependsOn: [
    fwPublicIp
  ]
}

// Create Internal NIC
resource intSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${virtualNetworkName}/${intSubnetName}'
}

module f5internalNic './networkInterface.bicep' = {
  name: 'create-int-nic-${deploymentNameSuffix}'
  params: {
    ipConfigurationName: intIpConfigurationName
    location: location
    name: intNicName
    networkSecurityGroupId: networkSecurityGroupId
    privateIPAddressAllocationMethod: intPrivateIPAddressAllocationMethod
    publicIP: intPublicIP
    subnetId: intSubnet.id
  }
}

// Create Management NIC
resource mgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${virtualNetworkName}/${mgmtSubnetName}'
}

module f5managementNic './networkInterface.bicep' = {
  name: 'create-mgmt-nic-${deploymentNameSuffix}'
  params: {
    ipConfigurationName: mgmtIpConfigurationName
    location: location
    name: mgmtNicName
    networkSecurityGroupId: networkSecurityGroupId
    privateIPAddressAllocationMethod: mgmtPrivateIPAddressAllocationMethod
    publicIP: mgmtPublicIP
    subnetId: mgmtSubnet.id
  }
}

// Deploy F5 VM
module f5vm './linuxVirtualMachine.bicep' = {
  name: 'create-f5vm-${deploymentNameSuffix}'
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

output internalIpAddress string = f5internalNic.outputs.ip
