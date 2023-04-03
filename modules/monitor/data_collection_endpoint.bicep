param deploymentParams object
param dceParams object
param tags object = resourceGroup().tags
param osKind string


resource r_dceLinux 'Microsoft.Insights/dataCollectionEndpoints@2021-04-01' = {
  name: '${dceParams.endpointName}-${deploymentParams.global_uniqueness}'
  location: deploymentParams.location
  tags: tags
  kind: osKind
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

output DataCollectionEndpointId string = r_dceLinux.id
output DataCollectionEndpointName string = r_dceLinux.name
