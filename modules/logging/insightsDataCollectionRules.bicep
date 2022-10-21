@description('Specify the region for your OMS workspace.')
param parWorkspaceRegion string

@description('The name of the Managed Cluster resource.')
param parClusterName string

@description('Specify the resource id of the OMS workspace.')
param parOmsWorkspaceId string

param parTags object = {}

resource aksDataCollectionRules 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  location: parWorkspaceRegion
  name: parClusterName
  tags: parTags
  kind: 'Linux'
  properties: {
    dataSources: {
      extensions: [
        {
          name: 'ContainerInsightsExtension'
          streams: [
            'Microsoft-ContainerInsights-Group-Default'
          ]
          extensionName: 'ContainerInsights'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: parOmsWorkspaceId
          name: 'ciworkspace'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-ContainerInsights-Group-Default'
        ]
        destinations: [
          'ciworkspace'
        ]
      }
    ]
  }
}
