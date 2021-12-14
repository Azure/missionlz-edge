// Parameters
param tenantId string
param keyVaultName string
param keyVaultAccessPolicyName string
param keyVaultAccessPolicyObjectId string 
param keyVaultAccessPolicyApplicationId string = ''
param secretPerms array = []
param certPerms array = []
param keyPerms array = []
param storagePerms array = []

// Create Key Vault Access Policy
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/${keyVaultAccessPolicyName}'
  properties: {
    accessPolicies: [
      {
        applicationId: keyVaultAccessPolicyApplicationId
        objectId: keyVaultAccessPolicyObjectId
        permissions: {
          certificates: certPerms
          keys: keyPerms
          secrets: secretPerms
          storage: storagePerms
        }
        tenantId: tenantId
      }
    ]
  }
}
