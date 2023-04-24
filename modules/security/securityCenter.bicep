targetScope = 'subscription'

@allowed([
  'AppServices'
  'Arm'
  'CloudPosture'
  'ContainerRegistry'
  'Containers'
  'CosmosDbs'
  'Dns'
  'KeyVaults'
  'KubernetesService'
  'OpenSourceRelationalDatabases'
  'SqlServerVirtualMachines'
  'SqlServers'
  'StorageAccounts'
  'VirtualMachines'
])
param parEnableSecurityCenterFor array = []

@allowed([
  'Free'
  'Standard'
])
param parTier string = 'Free'

@description('List of email addresses which will get notifications from Microsoft Defender for Cloud by the configurations defined in this security contact. Separated by comma')
param parSecurityContacts string = ''


@allowed([
  'Low'
  'Medium'
  'High'
])
@description('Defines the minimal alert severity which will be sent as email notifications')
param parMinimalSeverity string = 'High'

resource resSecurityCenterPricing 'Microsoft.Security/pricings@2022-03-01' = [for name in parEnableSecurityCenterFor: {
  name      : name
  properties: {
    pricingTier: parTier
  }
}]

resource resSecurityCenterContacts 'Microsoft.Security/securityContacts@2020-01-01-preview' = {
  name      : 'default'
  properties: {
    emails            : parSecurityContacts
    alertNotifications: {
      state          : 'On'
      minimalSeverity: parMinimalSeverity
    }
    notificationsByRole: {
      state: 'On'
      roles: [
          'Owner'

      ]
    }
  }
}
