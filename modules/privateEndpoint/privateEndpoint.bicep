@description('The Azure Region to deploy the resources into. Default: resourceGroup().location')
param parLocation string = resourceGroup().location

@description('The Private Endpoint Name')
param parPrivateEndpointName string

@description('The Subnet ID where the PVE shoud be assigned to')
param parSubnetId string

@description('Resource ID of the ')
param parServiceId string

@allowed([
  //storage account
  'blob'
  'dfs'
  'file'
  'queue'
  'web'
  'table'
  //MySQL
  'mysqlServer'
  //REDIS
  'redisCache'
  //WebApp
  'sites'
  //Azure SQL
  'sqlServer'
  //Keyvault
  'vault'
])
@description('Private Endpoint "Target Sub-resource". For more types of sub resource go to the "Create a private endpoint" blade in Azure portal and verify the listed sub-resources for an existing resource as example. Create one if needed.')
param parGroupId string

@description('Object with Tags to be applied to all resources in module. Default: empty ')
param parTags object = {}


resource resPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name      : parPrivateEndpointName
  location  : parLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: parPrivateEndpointName
        properties: {
          privateLinkServiceId: parServiceId
          groupIds: [
            parGroupId
          ]
        }
      }
    ]
    subnet: {
      id: parSubnetId
    }
  }
  tags: parTags
}

output id string   = resPrivateEndpoint.id
output name string = resPrivateEndpoint.name

