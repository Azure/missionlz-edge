// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// scope
targetScope = 'subscription'

param hubSubscriptionId string
param mlzHubDeploymentName string

var mlzDeploymentVariables = mlzDeployment.properties.outputs

// Load the MLZ hub network deployment and retrieve values.
resource mlzDeployment 'Microsoft.Resources/deployments@2020-06-01' existing = {
  scope: subscription(hubSubscriptionId)
  name: mlzHubDeploymentName
}

output hubsubscriptionId string = mlzDeploymentVariables.hub.Value.subscriptionId
output hubResourceGroupName string = mlzDeploymentVariables.hub.Value.resourceGroupName
output hubVirtualNetworkName string = mlzDeploymentVariables.hub.Value.virtualNetworkName
output firewallPrivateIPAddress string = mlzDeploymentVariables.hub.Value.firewallPrivateIPAddress

