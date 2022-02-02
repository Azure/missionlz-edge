param location string
param resourcePrefix string
param tags object = {}
param deploymentNameSuffix string
param keyVaultAccessPolicyObjectId string
param hubResourceGroupName string
param mgmtSubnetId string
param hubVirtualNetworkName string
param linuxNetworkInterfaceName string
param linuxNetworkInterfaceIpConfigurationName string
param linuxNetworkInterfacePrivateIPAddressAllocationMethod string
param deployLinux bool
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
param windowsPublicIpAddressName string
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


resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: hubVirtualNetworkName
}

resource extSubnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' existing = {
  name:'${hubVirtualNetworkName}/test'
}


module remoteLinuxVmSshKeyVault './generateSshKey.bicep' = if(deployLinux && linuxVmAuthenticationType=='sshPublicKey'){
  scope: resourceGroup(hubResourceGroupName)
  name:'deploy-remoteVMSshkv-hub-${deploymentNameSuffix}'
  params: {
    resourcePrefix : resourcePrefix 
    location: location
    tenantId: subscription().tenantId
    keyVaultAccessPolicyObjectId: keyVaultAccessPolicyObjectId
  }
  dependsOn:[
     ]

}
module remoteLinuxVmPasswordKeyVault './secretArtifacts.bicep' = if(deployLinux && linuxVmAuthenticationType=='password'){
  scope: resourceGroup(hubResourceGroupName)
  name:'deploy-remoteLinuxVmPwdkv-hub-${deploymentNameSuffix}'
  params: {
    resourcePrefix : resourcePrefix 
    location: location
    tenantId: subscription().tenantId
    keyVaultAccessPolicyObjectId: keyVaultAccessPolicyObjectId
    securePassword:linuxVmAdminPasswordOrKey
    keySecretName:'remoteLinuxVMPassword'
    vmType:'ra-linux'
  }
  dependsOn:[
    
  ]
}
module remoteWinVmPasswordKeyVault './secretArtifacts.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name:'deploy-remoteWinVmPwdkv-hub-${deploymentNameSuffix}'
  params: {
    resourcePrefix : resourcePrefix 
    location: location
    tenantId: subscription().tenantId
    keyVaultAccessPolicyObjectId: keyVaultAccessPolicyObjectId
    securePassword:windowsVmAdminPassword
    keySecretName:'remoteWinVMPassword'
    vmType:'ra-win'
  }
  dependsOn:[
    
  ]
}

// Create Public IP
module PublicIp './publicIPAddress.bicep' = {
  name: 'create-pubip'
  params: {
    location: location
    name: windowsPublicIpAddressName
    publicIpAllocationMethod: 'Dynamic'
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
  name: 'deploy-ra-windows-vm-${deploymentNameSuffix}'
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

module linuxVirtualMachine './remoteAccessLinuxVM.bicep' = if(deployLinux) {
  name: 'deploy-ra-linux-module-${deploymentNameSuffix}'
  params: {    
    location: location
    tags: tags
    deploymentNameSuffix:deploymentNameSuffix
    hubSubnetResourceId:mgmtSubnetId
    linuxNetworkInterfaceIpConfigurationName:linuxNetworkInterfaceIpConfigurationName
    linuxNetworkInterfaceName:linuxNetworkInterfaceName
    linuxVmAdminPasswordOrKey:linuxVmAdminPasswordOrKey
    linuxVmAdminUsername:linuxVmAdminUsername
    linuxVmAuthenticationType:linuxVmAuthenticationType
    linuxVmImageSku:linuxVmImageSku
    linuxVmImageVersion:linuxVmImageVersion
    linuxNetworkInterfacePrivateIPAddressAllocationMethod:linuxNetworkInterfacePrivateIPAddressAllocationMethod
    linuxVmImagePublisher:linuxVmImagePublisher
    linuxVmSize:linuxVmSize
    linuxVmName:linuxVmName
    linuxVmOsDiskCreateOption:linuxVmOsDiskCreateOption
    linuxVmImageOffer:linuxVmImageOffer
    linuxVmOsDiskType:linuxVmOsDiskType   
    }
}

output windowsVm object = windowsVirtualMachine.outputs.windowsVm
output windowsVmName string = windowsVirtualMachine.outputs.windowsVmName
