param parDataCollectionRuleID string
param parLocation string = resourceGroup().location

resource aksContainerInsightsExtension 'Microsoft.Insights/dataCollectionRuleAssociations@2021-04-01' = {
  name: 'aks-${subscription().displayName}-${parLocation}-ContainerInsightsExtension'
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster.'
    dataCollectionRuleId: parDataCollectionRuleID
  }
}
