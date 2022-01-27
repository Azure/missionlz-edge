// Parameters
param deploymentNameSuffix string
param location string
param tags object = {}

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
param vmPlanName string
param vmPlanProduct string
param vmPlanPublisher string
param vmSize string

param extIpForwarding bool
param extIpConfiguration1Name string
param extIpConfiguration2Name string
param extNicName string
param extPrivateIPAddressAllocationMethod string
param extInboundPublicIpId string
param extOutboundPublicIpId string
param extSubnetId string
param extIpConfigurations array = [
  {
    name: extIpConfiguration1Name
    properties: {
      subnet: {
        id: extSubnetId
      }
      primary: true
      privateIPAllocationMethod: extPrivateIPAddressAllocationMethod
      publicIPAddress: {
        id: extOutboundPublicIpId
      }
    }
  }
  {
    name: extIpConfiguration2Name
    properties: {
      subnet: {
        id: extSubnetId
      }
      primary: false
      privateIPAllocationMethod: extPrivateIPAddressAllocationMethod
      publicIPAddress: {
        id: extInboundPublicIpId
      }
    }
  }

]

param intIpForwarding bool
param intIpConfigurationName string
param intNicName string
param intPrivateIPAddressAllocationMethod string
param intSubnetId string
param intIpConfigurations array = [
  {
    name: intIpConfigurationName
    properties: {
      subnet: {
        id: intSubnetId
      }
      primary: true
      privateIPAllocationMethod: intPrivateIPAddressAllocationMethod
    }
  }
]

param mgmtIpForwarding bool
param mgmtIpConfigurationName string
param mgmtNicName string
param mgmtPrivateIPAddressAllocationMethod string
param mgmtSubnetId string
param mgmtIpConfigurations array = [
  {
    name: mgmtIpConfigurationName
    properties: {
      subnet: {
        id: mgmtSubnetId
      }
      primary: true
      privateIPAllocationMethod: mgmtPrivateIPAddressAllocationMethod
    }
  }
]

param vdmsIpForwarding bool
param vdmsIpConfigurationName string
param vdmsNicName string
param vdmsPrivateIPAddressAllocationMethod string
param vdmsSubnetId string
param vdmsIpConfigurations array = [
  {
    name: vdmsIpConfigurationName
    properties: {
      subnet: {
        id: vdmsSubnetId
      }
      primary: true
      privateIPAllocationMethod: vdmsPrivateIPAddressAllocationMethod
    }
  }
]

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

var osProfile = {
  sshPublicKey: {
    computerName: vmName
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
    computerName: vmName
    adminUsername: adminUsername
    adminPassword: adminPasswordOrKey
  }
}

// Create External NIC
module f5externalNic './networkInterface.bicep' = {
  name: 'create-ext-nic-${deploymentNameSuffix}'
  params: {
    enableIPForwarding: extIpForwarding
    ipConfigurations: extIpConfigurations
    location: location
    name: extNicName
  }
}

// Create Internal NIC
module f5internalNic './networkInterface.bicep' = {
  name: 'create-int-nic-${deploymentNameSuffix}'
  params: {
    enableIPForwarding: intIpForwarding
    ipConfigurations: intIpConfigurations
    location: location
    name: intNicName
  }
}

// Create Management NIC
module f5managementNic './networkInterface.bicep' = {
  name: 'create-mgmt-nic-${deploymentNameSuffix}'
  params: {
    enableIPForwarding: mgmtIpForwarding
    ipConfigurations: mgmtIpConfigurations
    location: location
    name: mgmtNicName
  }
}

// Create VDMS NIC
module f5vdmsNic './networkInterface.bicep' = {
  name: 'create-vdms-nic-${deploymentNameSuffix}'
  params: {
    enableIPForwarding: vdmsIpForwarding
    ipConfigurations: vdmsIpConfigurations
    location: location
    name: vdmsNicName
  }
}

resource f5vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: location
  tags: tags

  plan: {
    name: vmPlanName
    product: vmPlanProduct
    publisher: vmPlanPublisher
    }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: osDiskCreateOption
        managedDisk: {
          storageAccountType: vmOsDiskType
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
      networkInterfaces: nics
    }
    osProfile: osProfile[authenticationType]
  }
  dependsOn: [
    f5externalNic
    f5internalNic
    f5managementNic
    f5vdmsNic
  ]
}

output adminUsername string = adminUsername
output internalIpAddress string = f5internalNic.outputs.ip
