// Parameters
param deploymentNameSuffix string
param location string
// param networkSecurityGroupId string
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

param extIpForwarding bool
param extIpConfiguration1Name string
// param extIpConfiguration2Name string
param extNicName string
param extPrivateIPAddressAllocationMethod string
param extPublicIPAddressAllocationMethod string
param extInboundPublicIpName string
param extOutboundPublicIpName string
param extSubnetName string
// @allowed([
//   'yes'
//   'no'
// ])
// param extPublicIP string = 'yes'

param intIpForwarding bool
param intIpConfigurationName string
param intNicName string
param intPrivateIPAddressAllocationMethod string
param intSubnetName string
// @allowed([
//   'yes'
//   'no'
// ])
// param intPublicIP string = 'no'

param mgmtIpForwarding bool
param mgmtIpConfigurationName string
param mgmtNicName string
param mgmtPrivateIPAddressAllocationMethod string
param mgmtSubnetName string
// @allowed([
//   'yes'
//   'no'
// ])
// param mgmtPublicIP string = 'no'

param vdmsIpForwarding bool
param vdmsIpConfigurationName string
param vdmsNicName string
param vdmsPrivateIPAddressAllocationMethod string
param vdmsSubnetName string
// @allowed([
//   'yes'
//   'no'
// ])
// param vdmsPublicIP string = 'no'

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
  {
    id: f5vdmsNic.outputs.id
    properties: {
      primary: false
    }
  }
]

var ipConfigs = {
  external: [
    {
      name: extIpConfiguration1Name
      properties: {
        subnet: {
          id: extSubnet.id
        }
        primary: true
        privateIPAllocationMethod: extPrivateIPAddressAllocationMethod
        publicIPAddress: {
          id: fwOutboundPublicIp.outputs.id
        }
      }
    }
  ]
  //   {
  //     name: extIpConfiguration2Name
  //     properties: {
  //       subnet: {
  //         id: extSubnet.id
  //       }
  //       primary: false
  //       privateIPAllocationMethod: extPrivateIPAddressAllocationMethod
  //       publicIPAddress: {
  //         id: fwInboundPublicIp.outputs.id
  //       }
  //     }
  //   }
  // }
  internal: [
    {
      name: intIpConfigurationName
      properties: {
        subnet: {
          id: intSubnet.id
        }
        primary: true
        privateIPAllocationMethod: intPrivateIPAddressAllocationMethod
      }
    }
  ]
  mgmt: [
    {
      name: mgmtIpConfigurationName
      properties: {
        subnet: {
          id: mgmtSubnet.id
        }
        primary: true
        privateIPAllocationMethod: mgmtPrivateIPAddressAllocationMethod
      }
    }
  ]
  vdms: [
    {
      name: vdmsIpConfigurationName
      properties: {
        subnet: {
          id: vdmsSubnet.id
        }
        primary: true
        privateIPAllocationMethod: vdmsPrivateIPAddressAllocationMethod
      }
    }
  ]
}


  // {
  //   name: 'ipconfig1'
  //   properties: {
  //     privateIPAddress: '10.30.1.4'
  //     privateIPAllocationMethod: 'Dynamic'
  //     publicIPAddress: {
  //       id: publicIPAddresses_tst_ubuntu_primary_pip_externalid
  //     }
  //     subnet: {
  //       id: '${virtualNetworks_test_ghes_vn_externalid}/subnets/vm_subnet_1'
  //     }
  //     primary: true
  //     privateIPAddressVersion: 'IPv4'
  //   }
  // }
  // {
  //   name: 'ipconfig2'
  //   properties: {
  //     privateIPAddress: '10.30.1.5'
  //     privateIPAllocationMethod: 'Dynamic'
  //     publicIPAddress: {
  //       id: publicIPAddresses_tst_ubuntu_secondary_pip_externalid
  //     }
  //     subnet: {
  //       id: '${virtualNetworks_test_ghes_vn_externalid}/subnets/vm_subnet_1'
  //     }
  //     primary: false
  //     privateIPAddressVersion: 'IPv4'
  //   }
  // }

// // Create Public IP
// module fwPublicIp './publicIPAddress.bicep' = {
//   name: 'create-fw-pubip-${deploymentNameSuffix}'
//   params: {
//     location: location
//     name: extPublicIpName
//     publicIpAllocationMethod: extPublicIPAddressAllocationMethod
//   }
// }

// Create Outbound Public IP
module fwOutboundPublicIp './publicIPAddress.bicep' = {
  name: 'create-fw_out-pubip-${deploymentNameSuffix}'
  params: {
    location: location
    name: extOutboundPublicIpName
    publicIpAllocationMethod: extPublicIPAddressAllocationMethod
  }
}

// Create Inbound Public IP
module fwInboundPublicIp './publicIPAddress.bicep' = {
  name: 'create-fw_in-pubip-${deploymentNameSuffix}'
  params: {
    location: location
    name: extInboundPublicIpName
    publicIpAllocationMethod: extPublicIPAddressAllocationMethod
  }
}

// Create External NIC
resource extSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${virtualNetworkName}/${extSubnetName}'
}

// module f5externalNic './networkInterface.bicep' = {
//   name: 'create-ext-nic-${deploymentNameSuffix}'
//   params: {
//     enableIPForwarding: extIpForwarding
//     ipConfigurationName: extIpConfigurationName
//     location: location
//     name: extNicName
//     privateIPAddressAllocationMethod: extPrivateIPAddressAllocationMethod
//     publicIP: extPublicIP
//     publicIPAddressId: fwPublicIp.outputs.id
//     subnetId: extSubnet.id
//   }
//   dependsOn: [
//     fwPublicIp
//   ]
// }

module f5externalNic './networkInterface.bicep' = {
  name: 'create-ext-nic-${deploymentNameSuffix}'
  params: {
    enableIPForwarding: extIpForwarding
    ipConfigurations: ipConfigs['external']
    location: location
    name: extNicName
  }
  dependsOn: [
    fwOutboundPublicIp
    fwInboundPublicIp
  ]
}

// Create Internal NIC
resource intSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${virtualNetworkName}/${intSubnetName}'
}

// module f5internalNic './networkInterface.bicep' = {
//   name: 'create-int-nic-${deploymentNameSuffix}'
//   params: {
//     enableIPForwarding: intIpForwarding
//     ipConfigurationName: intIpConfigurationName
//     location: location
//     name: intNicName
//     privateIPAddressAllocationMethod: intPrivateIPAddressAllocationMethod
//     publicIP: intPublicIP
//     subnetId: intSubnet.id
//   }
// }

module f5internalNic './networkInterface.bicep' = {
  name: 'create-int-nic-${deploymentNameSuffix}'
  params: {
    enableIPForwarding: intIpForwarding
    ipConfigurations: ipConfigs['internal']
    location: location
    name: intNicName
  }
}

// Create Management NIC
resource mgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${virtualNetworkName}/${mgmtSubnetName}'
}

// module f5managementNic './networkInterface.bicep' = {
//   name: 'create-mgmt-nic-${deploymentNameSuffix}'
//   params: {
//     enableIPForwarding: mgmtIpForwarding
//     ipConfigurationName: mgmtIpConfigurationName
//     location: location
//     name: mgmtNicName
//     privateIPAddressAllocationMethod: mgmtPrivateIPAddressAllocationMethod
//     publicIP: mgmtPublicIP
//     subnetId: mgmtSubnet.id
//   }
// }

module f5managementNic './networkInterface.bicep' = {
  name: 'create-mgmt-nic-${deploymentNameSuffix}'
  params: {
    enableIPForwarding: mgmtIpForwarding
    ipConfigurations: ipConfigs['mgmt']
    location: location
    name: mgmtNicName
  }
}

// Create VDMS NIC
resource vdmsSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${virtualNetworkName}/${vdmsSubnetName}'
}

// 
module f5vdmsNic './networkInterface.bicep' = {
  name: 'create-vdms-nic-${deploymentNameSuffix}'
  params: {
    enableIPForwarding: vdmsIpForwarding
    ipConfigurations: ipConfigs['vdms']
    location: location
    name: vdmsNicName
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
    f5vdmsNic
  ]
}

output internalIpAddress string = f5internalNic.outputs.ip
