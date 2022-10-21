targetScope = 'subscription'

// ################# Parameters ##########################
@description('Target Subscription Name')
param parSubscriptionName string = subscription().displayName

@description('The region to deploy all resources into. DEFAULTS TO deployment().location')
param parLocation string = deployment().location

@description('Array of Tags to be applied to all resources in module. Default: empty array')
param parTags object = {
  Environment: 'sandbox'
  Tier       : 'backend'
}

@description('')
param parResourceGroupName string = 'RG-AKS'

@description('An array of AAD group object ids to give administrative access.')
param parAdminGroupObjectIDs array = []

@description('Specify the resource id of the Log Analytics (OMS) workspace.')
param parLogAnalyticsWorkspaceName string = '${parResourceGroupName}-LogAnalytics'

@description('Automation account name. - DEFAULT VALUE: aks-automation-account')
param parAutomationAccountName string = 'aks-automation-account'


//################ Orchestration Module Variables ###################################################
var varDeploymentNameWrappers = {
  basePrefix               : 'AKS'
  baseSuffixManagementGroup: '${parLocation}-${uniqueString(parLocation, parSubscriptionName)}-mg'
  baseSuffixSubscription   : '${parLocation}-${uniqueString(parLocation, parSubscriptionName)}-sub'
  baseSuffixResourceGroup  : '${parLocation}-${uniqueString(parLocation, parSubscriptionName)}-rg'
}

var varModuleDeploymentNames = {
  modAKS         : take('${varDeploymentNameWrappers.basePrefix}-modAKS-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modLogAnalytics: take('${varDeploymentNameWrappers.basePrefix}-modlogAnalytics-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
}


//################ Resources and Modules ###################################################
//The recommendation is to create the raw ResourceGroup in the "main" bicep so it can be used as scope for the modules and allowing it to create the dependency
resource resResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: parLocation
  name    : parResourceGroupName
  tags    : parTags
}

module modLogAnalytics '../modules/logging/logging.bicep' = {
  name: varModuleDeploymentNames.modLogAnalytics
  scope: resResourceGroup
  params: {
    parLogAnalyticsWorkspaceLocation: parLocation
    parLogAnalyticsWorkspaceName    : parLogAnalyticsWorkspaceName
    parAutomationAccountName        : parAutomationAccountName
    parTelemetryOptOut              : true
    parTags                         : parTags
  }

}

module modAKS '../modules/aks/aks.bicep' = {
  name: varModuleDeploymentNames.modAKS
  scope: resResourceGroup
  params: {
    parSubscriptionName            : parSubscriptionName
    parLocation                    : parLocation
    parOsDiskSizeGB                : 0
    parCLusterTier                 : 'Free'
    parKubernetesVersion           : '1.24.3'
    parNetworkPlugin               : 'kubenet'
    parAgentCount                  : 3
    parNodeResourceGroup           : '${resResourceGroup.name}-node'
    parAgentVMSize                 : 'standard_d2s_v3'
    parEnableRBAC                  : true
    parAzureRBAC                   : true
    parAdminGroupObjectIDs         : parAdminGroupObjectIDs
    parDisableLocalAccounts        : false
    parEnablePrivateCluster        : false
    parEnableHttpApplicationRouting: true
    parEnableAzurePolicy           : false
    parEnableSecretStoreCSIDriver  : false
    parEnableLogAnalyticsAgent     : true
    parLogAnalyticsWorkspaceId     : modLogAnalytics.outputs.outLogAnalyticsWorkspaceId
    parTags                        : parTags
  }
}
