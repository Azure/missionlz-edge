param nsgs array
param rules array

module newRule '../modules/nsgRule.bicep' = [ for nsg in nsgs: {
  name: 'create-rule-on-${nsg.nsgName}'
  scope: resourceGroup(nsg.nsgResourceGroupName)
  params: {
    nsgName: nsg.nsgName
    rules: rules
  }
}]
