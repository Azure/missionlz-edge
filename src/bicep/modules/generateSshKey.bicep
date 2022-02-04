// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param resourcePrefix string 
param location string
param tenantId string 
param keyVaultAccessPolicyObjectId string
param utcValue string = utcNow()
param newguid string = newGuid()
@allowed([
  'add'
  'update'
  'remove'
])
param keyVaultAccessPolicyName string = 'add'
param keyVaultSecretPerms array = [
  'all'
  
]
param generatedSshKey object = json(loadTextContent('../sshkeys.json'))

var keyVaultNamingConvention = toLower('${resourcePrefix}-kv-unique_token')
var keyVaultUniqueName = replace(keyVaultNamingConvention, 'unique_token', uniqueString(resourcePrefix, substring(newguid,0,9)))
var publicKeySecretName = 'sshPublicKey'
var privateKeySecretName = 'sshPrivateKey'

// Create Key Vault
module keyVault './keyVault.bicep' = {
  name: 'create_${keyVaultUniqueName}_${utcValue}'
  params: {
    keyVaultName: keyVaultUniqueName
    location: location
    tenantId: tenantId
    objectId:keyVaultAccessPolicyObjectId
  }
}

// Create Key Vault Access Policy
module accessPolicy '../modules/keyVaultAccessPolicy.bicep' = {
  name: 'create_keyVaultAccessPolicy_${utcValue}'
  params: {
    keyVaultAccessPolicyName: keyVaultAccessPolicyName
    keyVaultName: keyVaultUniqueName
    tenantId: tenantId
    keyVaultAccessPolicyObjectId: keyVaultAccessPolicyObjectId
    secretPerms: keyVaultSecretPerms
  }
  dependsOn: [
    keyVault
  ]
}

// Store Secret
resource publicKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVaultUniqueName}/${publicKeySecretName}'
  properties: {
    value: generatedSshKey.keyinfo.publicKey
  }
  dependsOn: [
    keyVault
    
  ]
}

// Store Secret
resource privateKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
 
  name: '${keyVaultUniqueName}/${privateKeySecretName}'
  
  properties: {
    value: generatedSshKey.keyinfo.privateKey
  }
  dependsOn: [
    keyVault
    
  ]
}

output publicKey string = generatedSshKey.keyinfo.publicKey
