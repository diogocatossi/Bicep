@description('Log Analytics Workspace name. - DEFAULT VALUE: alz-log-analytics')
param parLogAnalyticsWorkspaceName string = 'alz-log-analytics'

@description('Log Analytics region name - Ensure the regions selected is a supported mapping as per: https://docs.microsoft.com/azure/automation/how-to/region-mappings - DEFAULT VALUE: resourceGroup().location')
param parLogAnalyticsWorkspaceLocation string = resourceGroup().location

@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
@description('Log Analytics Workspace sku name. - DEFAULT VALUE: PerGB2018')
param parLogAnalyticsWorkspaceSkuName string = 'PerGB2018'

@minValue(30)
@maxValue(730)
@description('Number of days of log retention for Log Analytics Workspace. - DEFAULT VALUE: 365')
param parLogAnalyticsWorkspaceLogRetentionInDays int = 365

@allowed([
  'AgentHealthAssessment'
  'AntiMalware'
  'AzureActivity'
  'ChangeTracking'
  'Security'
  'SecurityInsights'
  'ServiceMap'
  'SQLAdvancedThreatProtection'
  'SQLVulnerabilityAssessment'
  'SQLAssessment'
  'Updates'
  'VMInsights'
])
@description('Solutions that will be added to the Log Analytics Workspace. - DEFAULT VALUE: [AgentHealthAssessment, AntiMalware, AzureActivity, ChangeTracking, Security, SecurityInsights, ServiceMap, SQLAssessment, Updates, VMInsights]')
param parLogAnalyticsWorkspaceSolutions array = [
  'AgentHealthAssessment'
  'AntiMalware'
  'AzureActivity'
  'ChangeTracking'
  'Security'
  'SecurityInsights'
  'ServiceMap'
  'SQLAdvancedThreatProtection'
  'SQLVulnerabilityAssessment'
  'SQLAssessment'
  'Updates'
  'VMInsights'
]

@description('Automation account name. - DEFAULT VALUE: alz-automation-account')
param parAutomationAccountName string = 'alz-automation-account'

@description('Automation Account region name. - Ensure the regions selected is a supported mapping as per: https://docs.microsoft.com/azure/automation/how-to/region-mappings - DEFAULT VALUE: resourceGroup().location')
param parAutomationAccountLocation string = resourceGroup().location

@description('The email address of whom should receive alerts from this workspace')
param parActionGroupNotificationEmail string = ''

@description('Tags you would like to be applied to all resources in this module')
param parTags object = {}

@description('Tags you would like to be applied to Automation Account. - DEFAULT VALUE: parTags value')
param parAutomationAccountTags object = parTags

@description('Tags you would like to be applied to Log Analytics Workspace. - DEFAULT VALUE: parTags value')
param parLogAnalyticsWorkspaceTags object = parTags

@description('Array containing Alert rules that should be created on this workspace. DEFAULT: none')
param parAlertRules array = []

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

  // Customer Usage Attribution Id
var varCuaid = 'f8087c67-cc41-46b2-994d-66e4b661860d'

resource resAutomationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name      : parAutomationAccountName
  location  : parAutomationAccountLocation
  tags      : parAutomationAccountTags
  properties: {
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
    }
  }
}

resource resLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name      : parLogAnalyticsWorkspaceName
  location  : parLogAnalyticsWorkspaceLocation
  tags      : parLogAnalyticsWorkspaceTags
  properties: {
    sku: {
      name: parLogAnalyticsWorkspaceSkuName
    }
    retentionInDays: parLogAnalyticsWorkspaceLogRetentionInDays
  }
}

resource resLogAnalyticsWorkspaceSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in parLogAnalyticsWorkspaceSolutions: {
  name      : '${solution}(${resLogAnalyticsWorkspace.name})'
  location  : parLogAnalyticsWorkspaceLocation
  tags      : parTags
  properties: {
    workspaceResourceId: resLogAnalyticsWorkspace.id
  }
  plan: {
    name         : '${solution}(${resLogAnalyticsWorkspace.name})'
    product      : 'OMSGallery/${solution}'
    publisher    : 'Microsoft'
    promotionCode: ''
  }
}]

resource resLogAnalyticsLinkedServiceForAutomationAccount 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  name      : '${resLogAnalyticsWorkspace.name}/Automation'
  properties: {
    resourceId: resAutomationAccount.id
  }
}

//############################################################## ACTION GROUPS ################################################################################
resource resActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = if (!empty(parActionGroupNotificationEmail))  {
  name      : 'Admins'
  location  : 'Global'
  properties: {
    groupShortName: 'Admins'
    enabled       : true
    emailReceivers: [
      {
        name                : 'ITOrgAdminsEmail'
        emailAddress        : parActionGroupNotificationEmail
        useCommonAlertSchema: false
      }
    ]
    smsReceivers              : []
    webhookReceivers          : []
    eventHubReceivers         : []
    itsmReceivers             : []
    azureAppPushReceivers     : []
    automationRunbookReceivers: []
    voiceReceivers            : []
    logicAppReceivers         : []
    azureFunctionReceivers    : []
    armRoleReceivers          : []
  }
}


//############################################################## ALERT RULES ################################################################################
module modAlertRules './LogAnalyticsAlertRules.bicep' =[for rule in parAlertRules: {
  name: rule.parAlertRuleName
  params: {
    parLocation                 : parLogAnalyticsWorkspaceLocation
    parLogAnalyticsWorkspaceId  : resLogAnalyticsWorkspace.id
    parActionGroupID            : resActionGroup.id
    parAlertRuleName            : rule.parAlertRuleName
    parAlertRuleDisplayName     : rule.parAlertRuleDisplayName
    parAlertRuleDescription     : rule.parAlertRuleDescription
    parAlertRuleSeverity        : rule.parAlertRuleSeverity
    parEvaluationFrequency      : rule.parEvaluationFrequencyMin
    parWindowSize               : rule.parWindowSize
    parAgregation               : rule.parAgregation
    parMetricMeasureColumn      : rule.parMetricMeasureColumn
    parDimensions               : rule.parDimensions
    parQuery                    : rule.parQuery
    parOperator                 : rule.parOperator
    parThreshold                : rule.parThreshold
    parNumberOfEvaluationPeriods: rule.parNumberOfEvaluationPeriods
    parMinFailingPeriodsToAlert : rule.parMinFailingPeriodsToAlert
    parMuteactionsDurationHours : rule.parMuteactionsDurationHours
    parTags                     : parTags
  }
}] 


// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params  //Only to ensure telemetry data is stored in same location as deployment. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  name  : 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}


output outLogAnalyticsWorkspaceName string = resLogAnalyticsWorkspace.name
output outLogAnalyticsWorkspaceId string   = resLogAnalyticsWorkspace.id
output outLogAnalyticsCustomerId string    = resLogAnalyticsWorkspace.properties.customerId
output outLogAnalyticsSolutions array      = parLogAnalyticsWorkspaceSolutions

output outAutomationAccountName string = resAutomationAccount.name
output outAutomationAccountId string   = resAutomationAccount.id
