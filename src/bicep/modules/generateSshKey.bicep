param resourcePrefix string 
param location string
param tenantId string 
param keyVaultAccessPolicyObjectId string
//defaults
param utcValue string = utcNow()
param keyVaultName string = '${resourcePrefix}-kv'

@allowed([
  'add'
  'update'
  'remove'
])
param keyVaultAccessPolicyName string = 'add'
param keyVaultSecretPerms array = [
  'all'
  
]
param generatedSshKey object = json(loadTextContent('../sshkeys.json','utf-8'))

var publicKeySecretName = 'sshPublicKey'
var privateKeySecretName = 'sshPrivateKey'


module keyVault './keyVault.bicep' = {
  name: 'create_${keyVaultName}_${utcValue}'
  params: {
    keyVaultName: keyVaultName
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
    keyVaultName: keyVaultName
    tenantId: tenantId
    keyVaultAccessPolicyObjectId: keyVaultAccessPolicyObjectId
    secretPerms: keyVaultSecretPerms
  }
  dependsOn: [
    keyVault
  ]
}


resource publicKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVaultName}/${publicKeySecretName}'
  properties: {
    value: generatedSshKey.keyinfo.publicKey
  }
  dependsOn: [
    keyVault
    
  ]
}

resource privateKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
 
  name: '${keyVaultName}/${privateKeySecretName}'
  
  properties: {
    value: generatedSshKey.keyinfo.privateKey
  }
  dependsOn: [
    keyVault
    
  ]
}

output publicKey string = generatedSshKey.keyinfo.publicKey
