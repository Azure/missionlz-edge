// param nsgs array
param nsgName string
param rules array

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2018-11-01' existing = {
name: nsgName
}

resource addRule 'Microsoft.Network/networkSecurityGroups/securityRules@2018-11-01' = [ for rule in rules: {
  parent: networkSecurityGroup
  name: rule.description
  properties: rule
}]
