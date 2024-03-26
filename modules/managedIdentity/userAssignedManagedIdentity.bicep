targetScope = 'resourceGroup'

@description('The name of the Managed Identity')
param parManagedIdentityName string

@description('The location of the Managed Identity')
@allowed([
  'westeurope'
  'northeurope'
  'westus'
  'eastus'
  'centralus'
  // Add more allowed locations as needed
])
param parLocation string

@description('The tags of the Managed Identity')
param parTags object = {}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name    : parManagedIdentityName
  location: parLocation
  tags    : parTags
}

output id string          = managedIdentity.id
output name string        = managedIdentity.name
output clientId string    = managedIdentity.properties.clientId
output principalId string = managedIdentity.properties.principalId
