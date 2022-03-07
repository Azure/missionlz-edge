// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Parameters
param location string
param tenantId string
param objectId string
param keyVaultName string
param enabledForDeployment bool = true
param enabledForDiskEncryption bool =false
param enabledForTemplateDeployment bool = true
@description('SKU for the vault')
@allowed([
  'standard'
  'premium'  
])
param sku string = 'standard'

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'list'
]

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'list'
]

var accessPolicies= [
  {
    objectId: objectId
    tenantId: tenantId
    permissions: {
      keys: keysPermissions
      secrets: secretsPermissions
    }
  }
]

// Create Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2016-10-01' = {
  name: keyVaultName
  location: location
  tags: {}
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    accessPolicies: accessPolicies
    tenantId: tenantId
    sku: {
      name: sku
      family: 'A'
    }
  }
}

output kvName string = keyVault.name
output fqdn string = replace(split(keyVault.properties.vaultUri,'vault.')[1],'/','')
