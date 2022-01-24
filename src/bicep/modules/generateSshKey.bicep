param resourcePrefix string 
param location string
param tenantId string 
param keyVaultAccessPolicyObjectId string
//defaults
param utcValue string = utcNow()
var keyVaultNamingConvention = toLower('${resourcePrefix}-kv-unique_token')
param newguid string = newGuid()

var keyVaultUniqueName = replace(keyVaultNamingConvention, 'unique_token', uniqueString(resourcePrefix, substring(newguid,0,9)))

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

var publicKeySecretName = 'sshPublicKey'
var privateKeySecretName = 'sshPrivateKey'


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


resource publicKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVaultUniqueName}/${publicKeySecretName}'
  properties: {
    value: generatedSshKey.keyinfo.publicKey
  }
  dependsOn: [
    keyVault
    
  ]
}

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
