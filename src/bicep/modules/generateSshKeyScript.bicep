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
var generateSshKeyScriptContent = loadTextContent('../../scripts/generateSshKey.sh')
var generateSshKeyScriptName = 'generateSshKey'
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
    value: generateSshKeyScript.properties.outputs.keyinfo.publicKey
  }
  dependsOn: [
    keyVault
    generateSshKeyScript
  ]
}

resource privateKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  //parent: keyVault
  name: '${keyVaultName}/${privateKeySecretName}'
  
  properties: {
    value: generateSshKeyScript.properties.outputs.keyinfo.privateKey
  }
  dependsOn: [
    keyVault
    generateSshKeyScript
  ]
}
resource generateSshKeyScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: generateSshKeyScriptName
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.25.0'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D' // retain script for 1 day
    scriptContent: generateSshKeyScriptContent
    timeout: 'PT30M' // timeout after 30 minutes
  }
}


output privateKey string = generateSshKeyScript.properties.outputs.keyinfo.privateKey
output publicKey string = generateSshKeyScript.properties.outputs.keyinfo.publicKey

