targetScope = 'resourceGroup'

@description('Alert Rule short name')
param parAlertRuleName string 

@description('Alert Rule Long display name')
param parAlertRuleDisplayName string 

@description('Alert Rule functionality description')
param parAlertRuleDescription string = ''

@description('Severity of the alert. Should be an integer between [0-4]. Value of 0 is severest. Relevant and required only for rules of the kind LogAlert. DEFAULT: 1')
param parAlertRuleSeverity int = 1

@description('How often the scheduled query rule is evaluated (in minutes). Relevant and required only for rules of the kind LogAlert.')
param parEvaluationFrequency int = 5

@description('The period of time (in minutes) on which the Alert query will be executed (bin size). Relevant and required only for rules of the kind LogAlert. DEFAULT: 60. NOTE: Values greater than 60 will be rounded to Hour times')
param parWindowSize int = 60

@description(' example: ProtectionStatus\n| summarize Rank = max(ProtectionStatusRank) by Computer\n| where Rank == "250"\n\n')
param parQuery string 

@allowed([
  'Average'
  'Count'
  'Maximum'
  'Minimum' 
  'Total' 
])
@description('')
param parAgregation string = 'Average'

@allowed([
  'Equals' 
  'GreaterThan' 
  'GreaterThanOrEqual' 
  'LessThan'
  'LessThanOrEqual' 
])
@description('The criteria operator. Relevant and required only for rules of the kind LogAlert. DEFAULT: GreaterThan')
param parOperator string = 'GreaterThan'

@description('The column containing the metric measure number. Relevant only for rules of the kind LogAlert.')
param parMetricMeasureColumn string = '' 

@description('List of Dimensions conditions')
param parDimensions array = []

@description('The criteria threshold value that activates the alert. Relevant and required only for rules of the kind LogAlert.')
param parThreshold int = 0

@description('The number of aggregated lookback points. The lookback time window is calculated based on the aggregation granularity (windowSize) and the selected number of aggregated points. Default value is 1')
param parNumberOfEvaluationPeriods int = 1

@description('The number of violations to trigger an alert. Should be smaller or equal to numberOfEvaluationPeriods. Default value is 1')
param parMinFailingPeriodsToAlert int = 1 

@description('Mute actions for the chosen period of time (in Hours) after the alert is fired. Relevant only for rules of the kind LogAlert. Default value is 0')
param parMuteactionsDurationHours int = 0

@description('Resource IDs that this alert rule is scoped to.')
param parLogAnalyticsWorkspaceId string

@description('The Action Group associated with the rule resource ID')
param parActionGroupID string

@description('Log Analytics region name - Ensure the regions selected is a supported mapping as per: https://docs.microsoft.com/azure/automation/how-to/region-mappings - DEFAULT VALUE: resourceGroup().location')
param parLocation string = resourceGroup().location

@description('Tags you would like to be applied to all resources in this module')
param parTags object = {}

resource resAlertRuleAntimalwareSignaturesOOD 'Microsoft.Insights/scheduledQueryRules@2022-08-01-preview' = {
  name    : parAlertRuleName
  location: parLocation
  tags    : parTags
  properties: {
    displayName        : parAlertRuleDisplayName
    description        : parAlertRuleDescription
    severity           : parAlertRuleSeverity
    enabled            : true
    evaluationFrequency: 'PT${string(parEvaluationFrequency)}M'
    scopes             : [ 
      parLogAnalyticsWorkspaceId
    ]
    targetResourceTypes: [
      'Microsoft.OperationalInsights/workspaces'
    ]
    windowSize: (parWindowSize == 0) ? null : ( (parWindowSize > 59) ? 'PT${string(int(parWindowSize/60))}H' : 'PT${string(parWindowSize)}M' )
    criteria: {
      allOf: [
        {
          query              : parQuery
          timeAggregation    : parAgregation
          metricMeasureColumn: !empty(parMetricMeasureColumn) ? parMetricMeasureColumn : null
          dimensions         : parDimensions
          operator           : parOperator
          threshold          : parThreshold
          failingPeriods     : {
            numberOfEvaluationPeriods: parNumberOfEvaluationPeriods
            minFailingPeriodsToAlert : parMinFailingPeriodsToAlert
          }
        }
      ]
    }
    autoMitigate       : false
    muteActionsDuration: (parMuteactionsDurationHours > 0) ? 'PT${string(parMuteactionsDurationHours)}H' : null
    actions            : {
      actionGroups: [
        parActionGroupID
      ]
      customProperties: {
      }
    }
  }
}
