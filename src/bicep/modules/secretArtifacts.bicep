param resourcePrefix string 
param location string
param vmType string
param tenantId string 
param keyVaultAccessPolicyObjectId string
param keySecretName string
@secure()
param securePassword string
//defaults
param utcValue string = utcNow()
var keyVaultNamingConvention = toLower('${resourcePrefix}-${vmType}-kv-unique_token')
param newguid string = newGuid()

var keyVaultUniqueName = substring(replace(keyVaultNamingConvention, 'unique_token', uniqueString(resourcePrefix, substring(newguid,0,9))),0,22)

@allowed([
  'add'
  'update'
  'remove'
])
param keyVaultAccessPolicyName string = 'add'
param keyVaultSecretPerms array = [
  'all'
  
]

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


resource passwordKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVaultUniqueName}/${keySecretName}'
  properties: {
    value: securePassword
  }
  dependsOn: [
    keyVault    
  ]
}




