// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string
param location string
param tags object = {}
param routeName string
param routeAddressPrefix string
param routeNextHopType string
param routeNextHopIpAddress string = ''

//Create the object by whether the routeNextHopIpAddress is empty or not
var propertiesObject = (!empty(routeNextHopIpAddress)) ? {
  addressPrefix: routeAddressPrefix
  nextHopIpAddress: routeNextHopIpAddress
  nextHopType: routeNextHopType
} : {
  addressPrefix: routeAddressPrefix
  nextHopType: routeNextHopType
}

resource routeTable 'Microsoft.Network/routeTables@2018-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    routes: [
      {
        name: routeName
        properties: propertiesObject
      }
    ]
  }
}

output id string = routeTable.id
output name string = routeTable.name
