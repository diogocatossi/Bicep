targetScope = 'resourceGroup'

@description('Backup Policy Name')
param parBackupPolicyName string

@description('Target Recovery Sevices Vault Name')
param parRSVaultName string

@metadata({
  policyName: 'Backup policy name'
  properties: 'Object containing backup policy settings'
})
@description('Array containing backup policies')
param parBackupPolicies array


@allowed([
  'AzureIaasVM'
  'AzureSql'
  'AzureStorage'
  'AzureWorkload'
  'GenericProtectionPolicy'
  'MAB'
])
@description('Set the object type')
param paramBackupManagementType string = 'GenericProtectionPolicy'

@description('Location for all resources.')
param parLocation string = resourceGroup().location

@description('Array of Tags to be applied to all resources in module. Default: empty array')
param parTags object = {}

var varBackupManagementType = {
  AzureIaasVM            : {
    backupManagementType: 'AzureIaasVM'
    instantRPDetails: {
      azureBackupRGNamePrefix: 'string'
      azureBackupRGNameSuffix: 'string'
    }
    instantRpRetentionRangeInDays: int
    policyType                   : 'string'
    retentionPolicy              : {
      retentionPolicyType: 'string'
      // For remaining properties, see RetentionPolicy objects
    }
    schedulePolicy: {
      schedulePolicyType: 'string'
      // For remaining properties, see SchedulePolicy objects
    }
    tieringPolicy: {}
    timeZone     : 'string'
  }
  AzureSql               : {
    backupManagementType: 'AzureSql'
    retentionPolicy: {
      retentionPolicyType: 'string'
      // For remaining properties, see RetentionPolicy objects
    }
  }
  AzureStorage           : {
    backupManagementType: 'AzureStorage'
    retentionPolicy: {
      retentionPolicyType: 'string'
      // For remaining properties, see RetentionPolicy objects
    }
    schedulePolicy: {
      schedulePolicyType: 'string'
      // For remaining properties, see SchedulePolicy objects
    }
    timeZone: 'string'
    workLoadType: 'string'
  }
  AzureWorkload          : {
    backupManagementType: 'AzureWorkload'
    makePolicyConsistent: bool
    settings: {
      isCompression: bool
      issqlcompression: bool
      timeZone: 'string'
    }
    subProtectionPolicy: [
      {
        policyType: 'string'
        retentionPolicy: {
          retentionPolicyType: 'string'
          // For remaining properties, see RetentionPolicy objects
        }
        schedulePolicy: {
          schedulePolicyType: 'string'
          // For remaining properties, see SchedulePolicy objects
        }
        tieringPolicy: {}
      }
    ]
    workLoadType: 'string'
  }
  GenericProtectionPolicy: {
    backupManagementType: 'GenericProtectionPolicy'
    fabricName: 'string'
    subProtectionPolicy: [
      {
        policyType: 'string'
        retentionPolicy: {
          retentionPolicyType: 'string'
          // For remaining properties, see RetentionPolicy objects
        }
        schedulePolicy: {
          schedulePolicyType: 'string'
          // For remaining properties, see SchedulePolicy objects
        }
        tieringPolicy: {}
      }
    ]
    timeZone: 'string'
  }
  MAB                    : {
    backupManagementType: 'MAB'
    retentionPolicy: {
      retentionPolicyType: 'string'
      // For remaining properties, see RetentionPolicy objects
    }
    schedulePolicy: {
      schedulePolicyType: 'string'
      // For remaining properties, see SchedulePolicy objects
    }
  }
}


resource resRSV 'Microsoft.RecoveryServices/vaults@2023-01-01' existing = {
  name: parRSVaultName
}


resource resBackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-01-01' = { 
  name      : parBackupPolicyName
  parent    : resRSV
  location  : parLocation
  properties: {
    protectedItemsCount: int
    resourceGuardOperationRequests: [
      'string'
    ]
    backupManagementType: 'string'
    // For remaining properties, see ProtectionPolicy objects
  }
  tags : parTags
}

output id string   = resBackupPolicy.id
output name string = resBackupPolicy.name
