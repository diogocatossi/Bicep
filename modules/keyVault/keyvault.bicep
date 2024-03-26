targetScope = 'resourceGroup'

@description('Azure Region where Resource Group will be created. DEFAULT: Resource Group location')
param parLocation string = resourceGroup().location

@description('The name of the key vault to be created. DEFAULT: keyvault-RESOURCEGROUP')
param parName string = 'kvt-${resourceGroup().name}'

@allowed([
  'standard'
  'premium'
])
@description('The SKU of the vault to be created. DEFAULT: standard')
param parSKU string = 'standard'

@description('The list of object IDs of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies.')
param parAccessObjectIDs array = []

@description('The vault\'s recover mode to indicate whether the vault need to be recovered or not. DEFAULT: false')
param parRecoverMode bool = false

@allowed([
  'enabled'
  'disabled'
])
@description('Property to specify whether the vault will accept traffic from public internet. If set to disabled all traffic except private endpoint traffic and that that originates from trusted services will be blocked. This will override the set firewall rules, meaning that even if the firewall rules are present we will not honor the rules. DEFAULT: disabled' )
param parPublicNetworkAccess string = 'disabled'

@description('Tells if Azure Services traffic can bypass network rules. If not specified the default is true.')
param parAzureServicesBypass bool = true

@allowed([
  'Allow'
  'Deny'
])
@description('	The default action when no rule from ipRules and from virtualNetworkRules match. This is only used after the bypass property has been evaluated. DEFAULT: Deny')
param parNetworkDefaultAction string = 'Deny'

@description('An object containing one or more IPv4 address range in CIDR notation, such as 124.56.78.91 (simple IP address) or 124.56.78.0/24 (all addresses that start with 124.56.78). If no value is provided an empty object will be provided and no access setup')
param parAllowedIPRange array = []

@description('Virtual Network name that contains the subnets that will be allowed access. Ideally "outHubVirtualNetworkName" output from the HubNetwork module')
param parVNETName string = ''

@description('Object containing Full resource id of a vnet subnet, such as "/subscriptions/subid/resourceGroups/rg1/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/subnet1", and ignoreMissingVnetServiceEndpoint - Property to specify whether NRP will ignore the check if parent subnet has serviceEndpoints configured.')
param parAllowedVNETSubnets array          = []

param parEnabledForDeployment bool         = true
param parEnabledForDiskEncryption bool     = true
param parEnabledForTemplateDeployment bool = true
param parEnablePurgeProtection bool        = true
param parEnableRbacAuthorization bool      = true
param parEnableSoftDelete bool             = true
param parSoftDeleteRetentionInDays int     = 7

@description('Object with Tags to be applied to all resources in module. Default: empty ')
param parTags object = {}

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaid = '59c2ac61-cd36-413b-b999-86a3e0d958fb'

resource resKeyvault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name      : parName
  location  : parLocation
  tags      : parTags
  properties: {
    accessPolicies: [ for object in parAccessObjectIDs: empty(object) ? {} :{
        tenantId     : tenant().tenantId
        objectId     : object
        permissions  : {
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
      }
    ]
    createMode                  : parRecoverMode ? 'recover': 'default'
    enabledForDeployment        : parEnabledForDeployment
    enabledForDiskEncryption    : parEnabledForDiskEncryption
    enabledForTemplateDeployment: parEnabledForTemplateDeployment
    enablePurgeProtection       : parEnablePurgeProtection
    enableRbacAuthorization     : parEnableRbacAuthorization
    enableSoftDelete            : parEnableSoftDelete
    networkAcls                 : {
      bypass       : parAzureServicesBypass ? 'AzureServices': 'None'
      defaultAction: parNetworkDefaultAction
      ipRules      : [for ip in parAllowedIPRange: {
          value: ip
      }]
      virtualNetworkRules: [for subnets in parAllowedVNETSubnets: {
          id                              : resourceId('Microsoft.Network/virtualNetworks/subnets', parVNETName, subnets.Name)
          ignoreMissingVnetServiceEndpoint: false
      }]
    }

    provisioningState  : 'Succeeded'
    publicNetworkAccess: parPublicNetworkAccess
    sku                : {
      family: 'A'
      name  : parSKU
    }
    softDeleteRetentionInDays: parSoftDeleteRetentionInDays
    tenantId                 : subscription().tenantId
      //vaultUri: 'string'
    
  }
}

module modCustomerUsageAttribution '../../CRML/customerUsageAttribution/cuaIdSubscription.bicep' = if (!parTelemetryOptOut) {
  name  : 'pid-${varCuaid}-${uniqueString(resourceGroup().name)}'
  scope: subscription()
  params: {}
}

output name string     = resKeyvault.name
output id string       = resKeyvault.id
output vaultUri string = resKeyvault.properties.vaultUri

