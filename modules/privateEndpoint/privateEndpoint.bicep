@description('The Private Endpoint Name')
param parPrivateEndpointName string

@description('The Azure Region to deploy the resources into. Default: resourceGroup().location')
param parLocation string = resourceGroup().location

@description('The Resource Group Name where the Virtual Network to be linked is located')
param parVirtualNetworkRG string

@description('The Virtual Network Name where the PVE shoud be assigned to')
param parVirtualNetworkName string

@description('The Subnet ID where the PVE shoud be assigned to')
param parSubnetName string

@description('The Private Link DNS Zone Name')
@allowed([
  'privatelink.azure-automation.net'
  'privatelink.database.windows.net'
  'privatelink.sql.azuresynapse.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.azuresynapse.net'
  'privatelink.blob.core.windows.net'
  'privatelink.table.core.windows.net'
  'privatelink.queue.core.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.web.core.windows.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.documents.azure.com'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.gremlin.cosmos.azure.com'
  'privatelink.table.cosmos.azure.com'
  'privatelink.postgres.database.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.mariadb.database.azure.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.managedhsm.azure.net'
  'privatelink.siterecovery.windowsazure.com'
  'privatelink.servicebus.windows.net'
  'privatelink.azure-devices.net'
  'privatelink.eventgrid.azure.net'
  'privatelink.azurewebsites.net'
  'privatelink.api.azureml.ms'
  'privatelink.notebooks.azure.net'
  'privatelink.service.signalr.net'
  'privatelink.monitor.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.afs.azure.net'
  'privatelink.datafactory.azure.net'
  'privatelink.adf.azure.com'
  'privatelink.redis.cache.windows.net'
  'privatelink.redisenterprise.cache.azure.net'
  'privatelink.purview.azure.com'
  'privatelink.purviewstudio.azure.com'
  'privatelink.digitaltwins.azure.net'
  'privatelink.azconfig.io'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.azurecr.io'
  'privatelink.search.windows.net'
  'privatelink.azurehdinsight.net'
  'privatelink.media.azure.net'
  'privatelink.his.arc.azure.com'
  'privatelink.guestconfiguration.azure.com'
])
param parPrivateLinkDnsZoneName string

@description('The Private Link DNS Zone Resource Group Name.')
param parPrivateLinkDnsZoneRGName string

@description('The resource type that composes a private link resource ID. Ex.: Microsoft.KeyVault/vaults')
param parResourceType string

param parResourceName string

@allowed([
  //storage parRequestMessage
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
param parTargetSubResourceArray array

@description('Object with Tags to be applied to all resources in module. Default: empty ')
param parTags object = {}

resource resPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-06-01' = {
  name      : parPrivateEndpointName
  location  : parLocation
  properties: {
    subnet: {
      id: resourceId(parVirtualNetworkRG, 'Microsoft.Network/virtualNetworks/subnets', parVirtualNetworkName, parSubnetName)
    }
    customNetworkInterfaceName: '${parPrivateEndpointName}.nic.${uniqueString(parPrivateEndpointName)}' 
    privateLinkServiceConnections: [
      {
        name      : parPrivateEndpointName
        properties: {
          privateLinkServiceId: resourceId(parResourceType, parResourceName)
          groupIds            : parTargetSubResourceArray
        }
      }
    ]
  }
  tags: parTags
}

resource resPrivateEndPointConfig 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-06-01' = {
  parent   : resPrivateEndpoint
  name     : 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name      : parPrivateEndpointName
        properties: {
          privateDnsZoneId: resourceId(parPrivateLinkDnsZoneRGName, 'Microsoft.Network/privateDnsZones', parPrivateLinkDnsZoneName)
        }
      }
    ]
  }
}

output id string = resPrivateEndpoint.id
output name string = resPrivateEndpoint.name
