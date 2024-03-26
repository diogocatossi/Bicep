targetScope = 'resourceGroup'

@description('Container Registry that stores private images. Should be provided together with the managed identity name')
param parAzureContainerRegistry string

@description('Primary location for resources')
param parLocation string = resourceGroup().location

@allowed([
  'Basic'
  'Classic'
  'Premium' 
  'Standard'
])
@description('The SKU name of the container registry. Required for registry creation. DEFAULT: Basic')
param parSKU string = 'Basic'

@description('The value that indicates whether the admin user is enabled. DEFAULT: false')
param parAdminUserEnabled bool = false

@description('Tags to add to the resources')
param parTags object = {}

resource resContainerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  sku: {
    name: parSKU
  }
  name      : parAzureContainerRegistry
  location  : parLocation
  tags      : parTags
  properties: {
    adminUserEnabled: parAdminUserEnabled
    networkRuleSet: parSKU != 'Premium' ? null :  {
      defaultAction: 'Allow'
      //ipRules: {}
    }
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type  : 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 7
        status       : 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled     : false
    publicNetworkAccess     : 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy          : 'Disabled'
    anonymousPullEnabled    : false
  }
}

output loginServerFQDN string = resContainerRegistry.properties.loginServer
