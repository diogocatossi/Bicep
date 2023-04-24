targetScope = 'resourceGroup'

@description('Name of the Vault')
param parVaultName string

@description('Location for all resources.')
param parLocation string = resourceGroup().location

@description('Opt in details of Cross Region Restore feature. DEFAULT: false')
param parEnableCrossRegionRestore bool = false

@allowed([
  'LocallyRedundant'
  'GeoRedundant'
  'ReadAccessGeoZoneRedundant'
  'ZoneRedundant'
])
@description('Storage replication type for Recovery Services vault')
param parVaultStorageType string = 'ZoneRedundant'

@allowed([
  'Enabled'
  'Disabled'
  'Invalid'
])
@description('Vaul data deduplication state for replication')
param parDataDeduplication string = 'Enabled' 

@description('Enable diagnostic logs')
param parEnableDiagnostics bool = true

@description('Log Analytics Workspace name where diagnostics will be stored')
param parLogAnalyticsWorkspaceName string = ''

@description('Storage account resource id. Only required if enableDiagnostics is set to true.')
param parDiagnosticStorageAccountName string = ''

@allowed([
  'Enabled'
  'Disabled'
])
@description('Create alerts for all job failures. DEFAULT: Enabled')
param parAlertsForAllJobFailures string = 'Enabled'

@allowed([
  'Enabled'
  'Disabled'
])
@description('Property to enable or disable resource provider inbound network traffic from public clients. If disabled requires a Private Endpoint creation for access.') 
param parPublicNetworkAccess string = 'Enabled'

@description('Array of Tags to be applied to all resources in module. Default: empty array')
param parTags object = {}

var varDiagnosticsName = 'DIAG-${parVaultName}'

resource resRecoveryServicesVault 'Microsoft.RecoveryServices/vaults@2023-01-01' = {
  name      : parVaultName
  location  : parLocation
  properties: {
    /* monitoringSettings: {
      azureMonitorAlertSettings: {
        alertsForAllJobFailures: parAlertsForAllJobFailures
      }      
    } */
    publicNetworkAccess: parPublicNetworkAccess
  }
  sku       : {
    name    : 'RS0'
    tier    : 'Standard'
  }
  tags : parTags
}

resource resVaultConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2023-01-01' = {
  name      : 'vaultstorageconfig'
  parent    : resRecoveryServicesVault
  location  : parLocation
  properties: {
    dedupState            : parDataDeduplication
    crossRegionRestoreFlag: parEnableCrossRegionRestore
    storageType           : parEnableCrossRegionRestore ? 'GeoRedundant': parVaultStorageType
    storageModelType      : parEnableCrossRegionRestore ? 'GeoRedundant': parVaultStorageType
  }
  tags: parTags
}

resource resDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (parEnableDiagnostics) {
  name      : varDiagnosticsName
  scope     : resRecoveryServicesVault
  properties: {
    workspaceId     : resourceId('Microsoft.OperationalInsights/workspaces', parLogAnalyticsWorkspaceName)
    storageAccountId: resourceId('Microsoft.Storage/storageAccounts', parDiagnosticStorageAccountName)
    logs            : [
      {
        category: 'CoreAzureBackup'
        enabled: true
      }
      {
        category: 'AddonAzureBackupAlerts'
        enabled: true
      }
      {
        category: 'AddonAzureBackupJobs'
        enabled: true
      }
      {
        category: 'AddonAzureBackupPolicy'
        enabled: true
      }
      {
        category: 'AddonAzureBackupProtectedInstance'
        enabled: true
      }
      {
        category: 'AddonAzureBackupStorage'
        enabled: true
      }
      {
        category: 'AzureBackupReport'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryJobs'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryEvents'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryReplicatedItems'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryReplicationStats'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryRecoveryPoints'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryReplicationDataUploadRate'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryProtectedDiskDataChurn'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Health'
        enabled: true
      }
    ]
  }
}

output id string   = resRecoveryServicesVault.id
output name string = resRecoveryServicesVault.name

