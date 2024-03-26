targetScope = 'resourceGroup'

@description('CPU: The number of seconds between consecutive counter measurements (samples). DEFAULT: 60')
param parCPUThresholdSeconds int = 60

@description('RAM: The number of seconds between consecutive counter measurements (samples). DEFAULT: 300')
param parMemoryThresholdSeconds int = 300

@description('Disk: The number of seconds between consecutive counter measurements (samples). DEFAULT: 300')
param parDiskThresholdSeconds int = 300

@description('Network: The number of seconds between consecutive counter measurements (samples). DEFAULT: 120')
param parNetworkThresholdSeconds int = 120

@description('The environment for which the collection rules will be created for. DEFAULT: PRD')
param parEnvironmentShortCode string = 'PRD'

@allowed( [
  'Linux'
  'Windows'
])
@description('The OS type for which the collection rules will be created for. DEFAULT: Windows')
param parOSType string = 'Windows'

@description('Log Analytics Workspace name to collect data to')
param parLogAnalyticsWorkspaceName string 

@description('Managed service identity of the resource. OPTIONAL')
param parIdentityResId string = '' 

@description('Location for all resources.')
param parLocation string = resourceGroup().location

@description('Tags you would like to be applied to all resources in this module. OPTIONAL')
param parTags object = {}

//       RG-JGR-CSP-SCC-ANE-001
//MSVMI-DCR-JGR-CSP-PRD-ANE-001
var varName = replace(replace(resourceGroup().name,'RG-',''),'SCC', parEnvironmentShortCode)

resource resCollectionRules 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name      : 'MSVMI-DCR-${varName}'
  location  : parLocation
  kind      : parOSType
  identity  : empty(parIdentityResId) ? null : {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${parIdentityResId}' : {}
    }
  }
  properties: {
    dataSources: {
      performanceCounters: [
        { 
          streams: [
            'Microsoft-InsightsMetrics'
          ]
          samplingFrequencyInSeconds: parCPUThresholdSeconds
          counterSpecifiers: [
            '\\VmInsights\\DetailedMetrics'
          ]
          name: 'perfCounterDataSource${parCPUThresholdSeconds}'
        }
      ]
      extensions: [
        {
          streams: [
            'Microsoft-ContainerInsights-Group-Default'
          ]
          extensionName: 'ContainerInsights'
          name: 'ContainerInsightsExtension'
        }
        {
          streams: [
            'Microsoft-ServiceMap'
          ]
          extensionName: 'DependencyAgent'
          extensionSettings: {}
          name: 'DependencyAgentDataSource'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name               : 'VMInsightsPerf-Logs-Dest'
          workspaceResourceId: resourceId('Microsoft.OperationalInsights/workspaces', parLogAnalyticsWorkspaceName)
        }
      ]
    }
    dataFlows: [
      {
        destinations: [
          'VMInsightsPerf-Logs-Dest'
        ]
        streams: [
          'Microsoft-InsightsMetrics'
          'Microsoft-ServiceMap'
        ]
      }
    ]
  }
  tags: parTags
}

output name string                     = resCollectionRules.name
output id string                       = resCollectionRules.id
//output dataCollectionEndpointId string = resCollectionRules.properties.dataCollectionEndpointId

