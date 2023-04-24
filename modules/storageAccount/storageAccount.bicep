targetScope = 'resourceGroup'

@description('Name of the storage account')
param parStorageName string

// Creates a storage account, private endpoints and DNS zones
@description('Azure region of the deployment')
param parLocation string = resourceGroup().location

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
@description('Storage SKU')
param parStorageSkuName string = 'Standard_ZRS'

@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
@description('Storage Kind')
param parStorageKind string = 'StorageV2'

@allowed([
  'Hot'
  'Cool'
  'Premium'
])
@description('Storage Access Tier')
param parAccessTier string = 'Hot'

@allowed([
  'Enabled'
  'Disabled'
])
@description('Configure Public access to the storage account')
param parPublicNetworkAccess string = 'Enabled'

@description('Name of the virtual network that contains the subnets that would access.')
param parVirtualNetworkName string

@description('List of subnet names from the provided Virtual Network that should have access granted.')
param parSubnetNames array = []

@description('List of File Shares to be created')
param parFileShareList array = []

@allowed([
  'Hot'
  'Cool'
  'Premium'
  'TransactionOptimized'
])
@description('File Share Access Tier. DEFAULT: TransactionOptimized')
param parFileAccessTier string = 'TransactionOptimized'

@description('File Share size/quota. DEFAULT: 5120 (5TB)')
param parFileShareQuota int = 5120

@description('Account HierarchicalNamespace enabled if sets to true. DEFAULT: false')
param parHnsEnabled bool = false

@description('NFS 3.0 protocol support enabled if set to true. DEFAULT: false')
param parNfsV3Enabled bool = false

@description('Enables Secure File Transfer Protocol, if set to true. DEFAULT: false')
param parSftpEnabled bool = false

@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
@description('Set the minimum TLS version to be permitted on requests to storage. The default interpretation is TLS 1.0 for this property. DEFAULT: TLS1_2')
param parMinimumTlsVersion string = 'TLS1_2'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Set the minimum TLS version to be permitted on requests to storage. The default interpretation is TLS 1.0 for this property. DEFAULT: TLS1_2')
param parLargeFileSharesState string = 'Disabled'

@allowed([
  'AzureServices'
  'Logging'
  'Metrics'
  'None'
])
@description('Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging|Metrics|AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics.')
param parBypass string = 'AzureServices'

@allowed([
  'Allow'
  'Deny'
])
@description('Specifies the default action of allow or deny when no other rules match. DEFAULT: Deny')
param parNetworkDefaultAction string = 'Deny'

@allowed([
  'InternetRouting'
  'MicrosoftRouting'
])
@description('Routing Choice defines the kind of network routing opted by the user. DEFAULT: MicrosoftRouting')
param parRoutingChoice string = 'MicrosoftRouting'

param parAllowSharedKeyAccess bool = false

@allowed([
  'NFS'
  'SMB' 
])
@description('The authentication protocol that is used for the file share. Can only be specified when creating a share.')
param parFileShareProtocols string = 'SMB'

@description('Tags to add to the resources')
param parTags object = {}

//################################### VARIABLES ###################################
var storageNameCleaned     = replace(parStorageName, '-', '')

resource resStorage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name    : storageNameCleaned
  location: parLocation
  tags    : parTags
  sku     : { name: parStorageSkuName }
  kind      : parStorageKind
  properties: {
    accessTier                 : parAccessTier
    allowCrossTenantReplication: false
    allowSharedKeyAccess       : true
    allowBlobPublicAccess      : true
    encryption                 : {
      keySource                      : 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services                       : {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    isHnsEnabled        : parHnsEnabled
    isNfsV3Enabled      : parNfsV3Enabled
    isSftpEnabled       : parSftpEnabled
    largeFileSharesState: parLargeFileSharesState
    keyPolicy           : {
      keyExpirationPeriodInDays: 7
    }
    minimumTlsVersion   : parMinimumTlsVersion
    networkAcls         : {
      bypass             : parBypass
      defaultAction      : parNetworkDefaultAction
      virtualNetworkRules: [for (subnet,i) in parSubnetNames: {
          action: 'Allow'
          id    : resourceId('Microsoft.Network/virtualNetworks/subnets', parVirtualNetworkName, subnet)
      }]
    }
    publicNetworkAccess: parPublicNetworkAccess
    routingPreference  : {
      publishInternetEndpoints : (parRoutingChoice == 'InternetRouting') ? true : false
      publishMicrosoftEndpoints: (parRoutingChoice == 'MicrosoftRouting') ? true : false
      routingChoice            : parRoutingChoice
    }
    supportsHttpsTrafficOnly: true
  }
}

resource resFileServices 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  name      : 'default'
  parent    : resStorage
  properties: {
    protocolSettings: {
      smb: {
        authenticationMethods: 'NTLMv2;Kerberos'
        multichannel         : contains(parStorageSkuName,'Premium') ? { enabled: true }: null
        versions             : 'SMB2.1;SMB3.0;SMB3.1.1'
      }
    }
    shareDeleteRetentionPolicy: {
      days                : 7
      enabled             : true
    }
  }
}

resource resShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-05-01' = [for (share,i) in parFileShareList: {
    name      : toLower(share)
    parent    : resFileServices
    properties: {
      accessTier       : parFileAccessTier
      enabledProtocols : parFileShareProtocols
      metadata         : {}
      shareQuota       : parFileShareQuota
    } 
}]

output storageId string   = resStorage.id
output storageName string = resStorage.name


