targetScope = 'resourceGroup'

@description('Backup Policy Name')
param parBackupPolicyName string

@description('Target Recovery Sevices Vault Name')
param parRSVaultName string

@description('Number of days to keep VM Restore Points. DEFAULT : 2')
param parInstantRestorePointRetentionDays int = 2

@description('Number of days to keep Daily Backups. DEFAULT : 3')
param parDailyBackupPointRetentionDays int = 3

@description('Date for the backup start on the format yyyy-MM-dd. DEFAULT: current date')
param parBackupDate string = utcNow('yyyy-MM-dd')

@description('Time for the backup on the format HH:mm:ss. DEFAULT: current time')
param parBackupTime string = utcNow('HH:mm:ss')

@description('Schedule timezone (get-timezone -ListAvailable |sort BaseUtcOffset |ft). DEFAULT: W. Europe Standard Time')
param parTimeZone string = 'W. Europe Standard Time'

@description('Location for all resources.')
param parLocation string = resourceGroup().location

@description('Array of Tags to be applied to all resources in module. Default: empty array')
param parTags object = {}


//var varUTCDAte = '${split(parBackupDate, '/' )[2]}-${split(parBackupDate, '/' )[1]}-${split(parBackupDate, '/' )[0]}'

resource resRSV 'Microsoft.RecoveryServices/vaults@2023-01-01' existing = {
  name: parRSVaultName
}

resource resBackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-01-01' = { 
  name      : parBackupPolicyName
  parent    : resRSV
  location  : parLocation
  properties: {
    backupManagementType         : 'AzureIaasVM'
    instantRpRetentionRangeInDays: parInstantRestorePointRetentionDays
    instantRPDetails             : {}
    schedulePolicy               : {
      schedulePolicyType  : 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes    : [
        '${parBackupDate}T${parBackupTime}Z'
      ]
      scheduleWeeklyFrequency: 0
    }
    retentionPolicy              : {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule      : {
        retentionTimes: [
          '${parBackupDate}T${parBackupTime}Z'
        ]
        retentionDuration: {
          count       : parDailyBackupPointRetentionDays
          durationType: 'Days'
        }
      }
    }    
    timeZone: parTimeZone
  }
  tags: parTags
}

output id string   = resBackupPolicy.id
output name string = resBackupPolicy.name
