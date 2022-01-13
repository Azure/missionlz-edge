// scope
targetScope = 'subscription'
// Load the MLZ hub network deployment and retrieve values.
param hubSubscriptionId string
param mlzHubDeploymentName string
resource mlzDeployment 'Microsoft.Resources/deployments@2020-06-01' existing = {
  scope: subscription(hubSubscriptionId)
  name: mlzHubDeploymentName
}
var mlzDeploymentVariables = mlzDeployment.properties.outputs
output hubsubscriptionId string = mlzDeploymentVariables.hub.Value.subscriptionId
output hubResourceGroupName string = mlzDeploymentVariables.hub.Value.resourceGroupName
output hubVirtualNetworkName string = mlzDeploymentVariables.hub.Value.virtualNetworkName
output firewallPrivateIPAddress string = mlzDeploymentVariables.hub.Value.firewallPrivateIPAddress

