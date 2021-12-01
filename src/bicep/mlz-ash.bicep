// scope
targetScope = 'subscription'

//main

//// Scaffolding

module hubResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-rg-hub-${nowUtc}'
  params: {
    name: hubResourceGroupName
    location: hubLocation
    tags: calculatedTags
  }
}

// Parameters
param hubResourceGroupName string = '${resourcePrefix}-hub'
param hubLocation string = deployment().location
param uniqueId string = uniqueString(deployment().name)
param resourcePrefix string = 'mlz-${uniqueId}'
param tags object = {}
param nowUtc string = utcNow()

//Variables
var defaultTags = {
  'resourcePrefix': resourcePrefix
  'DeploymentType': 'MissionLandingZoneARM'
}
var calculatedTags = union(tags,defaultTags)
