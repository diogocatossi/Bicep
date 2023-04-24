@description('The name of the SQL logical server.')
param parServerName string = uniqueString('sql', resourceGroup().id)

@description('The name of the SQL Database.')
param parSQLDBName string = 'SampleDB'

@description('Location for all resources.')
param parLocation string = resourceGroup().location

@description('The administrator username of the SQL logical server.')
param parAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param parAdministratorLoginPassword string

@allowed(['enabled','disabled'])
@description('Allow public access. DEFAULT: enabled')
param parPublicNetworkAccess string = 'enabled'

@description('Virtual Network name which contains the subnets that should access SQL')
param parVirtualNetworkName string 

@description('List of Subnets from the VNET that should be granted access. DEFAULT: []')
param parVirtualNetworkSubnets array = []

@allowed(['1.0','1.1','1.2'])
@description('Minimum TLS version required for secure connection. DEFAULT: 1.2')
param parMinimumTLS string = '1.2'

@description('Flag to set creation of a DB on top of the instance')
param parDeployDB bool

@description('Database Size in GB. DEFAULT: 500')
param parDBSizeGB int = 500

@description('Database collation. DEFAULT: Latin1_General_100_CI_AS')
param parDBCollation string = 'Latin1_General_100_CI_AS'

//@description('Backup Retention day count. DEFAULT: 7')
//param parBackupRetentionDays int = 7

@description('Add zone redundancy for SQL DB. DEFAULT: true')
param parDBZoneRedundant bool = true

@description('Log Analytics Workspace ID where VM metrics should be stored. If no name is provived no diagnostic settings will be created.')
param parLogAnalyticsWorkspaceId string = ''

@allowed([
  'Local'
  'Geo' 
  'GeoZone' 
  'Zone'
])
@description('The storage account type to be used to store backups for this database. DEFAULT: Geo')
param parBackupStorageRedundancy string = 'Geo'

@description('Database SKU object, containing name, tier and size (key:value pairs). DEFAULT: name: S3, tier: Standard, 500')
param parSKU object = {
  name    : 'S3'
  tier    : 'Standard'
  size    : '500'
}

@description('Array of Tags to be applied to all resources in module. Default: empty array')
param parTags object = {}

//################################### RESOURCES ###################################################
resource resSQLDBServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name    : toLower(parServerName)
  location: parLocation
  tags    : parTags
  properties: {
    administratorLogin        : parAdministratorLogin
    administratorLoginPassword: parAdministratorLoginPassword
    minimalTlsVersion         : parMinimumTLS
    publicNetworkAccess       : parPublicNetworkAccess
  }
}

resource resVNETRules 'Microsoft.Sql/servers/virtualNetworkRules@2022-05-01-preview' =  [for (subnet, i) in parVirtualNetworkSubnets: {
  parent    : resSQLDBServer
  name      : '${subnet}-${padLeft(i,2,'0')}'
  properties: {
    ignoreMissingVnetServiceEndpoint: false
    virtualNetworkSubnetId          : resourceId('Microsoft.Network/virtualNetworks/subnets', parVirtualNetworkName, subnet)
  }  
}]

resource resSQLDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = if (parDeployDB) {
  parent    : resSQLDBServer
  name      : parSQLDBName
  location  : parLocation
  sku       : parSKU
  properties: {
    //licenseType                     : 'BasePrice'
    collation                       : parDBCollation
    maxSizeBytes                    : (parDBSizeGB*1024*1024*1024)
    zoneRedundant                   : parDBZoneRedundant
    requestedBackupStorageRedundancy: parBackupStorageRedundancy
  }
  tags: parTags

  //TODO: fix Bicep policy name format
  /* resource resBackupTermPolicyShort 'backupShortTermRetentionPolicies@2022-05-01-preview' = {
    name: 'ShortTermRetentionPolicy'
    properties: {
      diffBackupIntervalInHours: 24
      retentionDays            : parBackupRetentionDays
    }
  }

  resource resBackupTermPolicyLong 'backupLongTermRetentionPolicies@2022-05-01-preview' = {
    name: 'LongTermRetentionPolicy'
    properties: {
      monthlyRetention: 'PT0S'
      weeklyRetention : 'PT0S'
      weekOfYear      : 0
      yearlyRetention : 'PT0S'
    }
  } */
  

}

resource resDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(parLogAnalyticsWorkspaceId)) {
  name      : 'DIAG-${parServerName}'
  scope     : resSQLDBServer
  properties: { 
    workspaceId: parLogAnalyticsWorkspaceId
    // logs : [
    //   // {
    //   //   category: 'SQLInsights'
    //   //   enabled: true
    //   // }
    //   // {
    //   //   category: 'AutomaticTuning'
    //   //   enabled: true
    //   // }
    //   {
    //     category: 'QueryStoreRuntimeStatistics'
    //     enabled: true
    //   }
    //   {
    //     category: 'QueryStoreWaitStatistics'
    //     enabled: true
    //   }
    //   {
    //     category: 'Errors'
    //     enabled: true
    //   }
    //   {
    //     category: 'DatabaseWaitStatistics'
    //     enabled: true
    //   }
    //   {
    //     category: 'Timeouts'
    //     enabled: true
    //   }
    //   {
    //     category: 'Blocks'
    //     enabled: true
    //   }
    //   {
    //     category: 'Deadlocks'
    //     enabled: true
    //   }
    // ]
    metrics             : [
      {
        category       : 'AllMetrics'
        enabled        : true
        retentionPolicy: {
          enabled: true
          days   : 7
        }
        timeGrain: 'PT1M' //1 minute
      }
    ]
  }
}


output outDBFQDN string = resSQLDBServer.properties.fullyQualifiedDomainName
output outDBId string   = resSQLDBServer.id

