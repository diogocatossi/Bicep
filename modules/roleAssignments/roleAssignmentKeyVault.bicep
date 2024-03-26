targetScope = 'resourceGroup'

metadata name = 'ALZ Bicep - Role Assignment to Key Vault'
metadata description = 'Role Assignment to Key Vault'

@sys.description('Role Definition Id (i.e. GUID, Reader Role Definition ID: acdd72a7-3385-48ef-bd42-f606fba81ae7)')
param parRoleDefinitionId string

@description('Principal type of the assignee.  Allowed values are \'Group\' (Security Group) or \'ServicePrincipal\' (Service Principal or System/User Assigned Managed Identity)')
@allowed([
  'Group'
  'ServicePrincipal'
])
param parAssigneePrincipalType string

@description('Object ID of groups, service principals or managed identities. For managed identities use the principal id. For service principals, use the object ID and not the app ID')
param parAssigneeObjectId string

@sys.description('A GUID representing the role assignment name.')
param parRoleAssignmentNameGuid string = guid(resourceGroup().id, parRoleDefinitionId, parAssigneeObjectId)

@description('Key Vault Name that will be used to store secrets and certificates used by the resources in this module. Default: empty string')
param parKeyVaultName string = ''

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaid = '59c2ac61-cd36-413b-b999-86a3e0d958fb'

resource resKeyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name     : parKeyVaultName
}

resource resRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name      : parRoleAssignmentNameGuid
  scope     : resKeyvault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', parRoleDefinitionId)
    principalId     : parAssigneeObjectId
    principalType   : parAssigneePrincipalType
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut) {
  name  : 'pid-${varCuaid}-${uniqueString(subscription().subscriptionId, parAssigneeObjectId)}'
  scope : resourceGroup()
  params: {}
}
