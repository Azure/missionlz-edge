// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string
param location string
param remoteNetworkAddressPrefixes array
param remoteGatewayPublicIpAddress string
//param tags object = {}

resource localNetworkGateway 'Microsoft.Network/localNetworkGateways@2021-05-01' = {
  name: name
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: remoteNetworkAddressPrefixes
    }
    gatewayIpAddress: remoteGatewayPublicIpAddress
  }
}
