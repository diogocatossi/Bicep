targetScope = 'resourceGroup'

@description('Subscription Name for the resource')
param parSubscriptionName string

@description('The name of the Managed Cluster resource.')
param parClusterName string = 'aks-${parSubscriptionName}-${resourceGroup().location}'

@description('The location of the Managed Cluster resource.')
param parLocation string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param parDnsPrefix string = '${parClusterName}-dns'

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param parOsDiskSizeGB int = 0

@description('The tier of a managed cluster SKU.')
@allowed([
  'Free'
  'Paid'
])
param parCLusterTier string = 'Free'

@description('The version of Kubernetes.')
param parKubernetesVersion string = '1.24.3'

@description('Network plugin used for building Kubernetes network.')
@allowed([
  'azure'
  'kubenet'
])
param parNetworkPlugin string = 'kubenet'

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param parAgentCount int = 3

@description('The name of the resource group containing agent pool nodes.')
param parNodeResourceGroup string = '${resourceGroup().name}-node'

@description('The size of the Virtual Machine.')
param parAgentVMSize string = 'standard_d2s_v3'

//@description('User name for the Linux Virtual Machines.')
//param parLinuxAdminUsername string

//@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
//param parSshRSAPublicKey string

@description('Boolean flag to turn on and off of RBAC.')
param parEnableRBAC bool = false

@description('Enable or disable Azure RBAC.')
param parAzureRBAC bool = false

@description('An array of AAD group object ids to give administrative access.')
param parAdminGroupObjectIDs array = []

@description('Enable or disable local accounts.')
param parDisableLocalAccounts bool = false

@description('Enable private network access to the Kubernetes cluster.')
param parEnablePrivateCluster bool = true

@description('Boolean flag to turn on and off http application routing.')
param parEnableHttpApplicationRouting bool = true

@description('Boolean flag to turn on and off Azure Policy addon.')
param parEnableAzurePolicy bool = false

@description('Boolean flag to turn on and off secret store CSI driver.')
param parEnableSecretStoreCSIDriver bool = false

@description('Boolean flag to turn on and off Log Analytics (omsagent) addon.')
param parEnableLogAnalyticsAgent bool = true

@description('Specify the region for your Log Analytics (OMS) workspace.')
param parLogAnalyticsWorkspaceRegion string = resourceGroup().location

@description('Specify the resource id of the Log Analytics (OMS) workspace.')
param parLogAnalyticsWorkspaceId string

@description('Tags you would like to be applied to all resources in this module')
param parTags object = {}

//param DCRALocation string = 'northeurope'

module aks_monitoring_msi_dcr '../logging/insightsDataCollectionRules.bicep' = {
  name: '${parClusterName}-monitoring-dcr'
  scope: resourceGroup(split(parLogAnalyticsWorkspaceId, '/')[2], split(parLogAnalyticsWorkspaceId, '/')[4])
  params: {
    parWorkspaceRegion: parLogAnalyticsWorkspaceRegion
    parClusterName: parClusterName
    parOmsWorkspaceId: parLogAnalyticsWorkspaceId
  }
  dependsOn: []
}

// module aks_monitoring_msi_dcra '../logging/insightsDataCollectionRuleAssociations.bicep' = {
//   name: '${parClusterName}-monitoring-dcra'
//   scope: resourceGroup(subscription().subscriptionId, resourceGroup().name)
//   params: {
//     parDataCollectionRuleID: resourceId(split(parLogAnalyticsWorkspaceId, '/')[2], split(parLogAnalyticsWorkspaceId, '/')[4], 'Microsoft.Insights/dataCollectionRules', 'MSCI-aks-Sytac-westeurope-westeurope')
//     parLocation: DCRALocation
//   }
//   dependsOn: [
//     resAKS
//     aks_monitoring_msi_dcr
//   ]
// }


resource resAKS 'Microsoft.ContainerService/managedClusters@2022-07-01' = {
  name: parClusterName
  location: parLocation
  tags: parTags
  sku: {
    name: 'Basic'
    tier: parCLusterTier
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: parKubernetesVersion
    enableRBAC: parEnableRBAC
    dnsPrefix: parDnsPrefix
    nodeResourceGroup: parNodeResourceGroup
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: parOsDiskSizeGB
        count: parAgentCount
        enableAutoScaling: true
        minCount: 1
        maxCount: 5
        vmSize: parAgentVMSize
        osType: 'Linux'
        mode: 'System'
        maxPods: 110
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeTaints: []
        enableNodePublicIP: false
        tags: parTags
      }
    ]
    // linuxProfile: {
    //   adminUsername: parLinuxAdminUsername
    //   ssh: {
    //     publicKeys: [
    //       {
    //         keyData: parSshRSAPublicKey
    //       }
    //     ]
    //   }
    // }
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: parNetworkPlugin
    }
    disableLocalAccounts: parDisableLocalAccounts
    aadProfile: {
      managed: true
      adminGroupObjectIDs: parAdminGroupObjectIDs
      enableAzureRBAC: parAzureRBAC
    }
    apiServerAccessProfile: {
      enablePrivateCluster: parEnablePrivateCluster
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: parEnableHttpApplicationRouting
      }
      azurepolicy: {
        enabled: parEnableAzurePolicy
      }
      azureKeyvaultSecretsProvider: {
        enabled: parEnableSecretStoreCSIDriver
        config: {
          enableSecretRotation: 'false'
          rotationPollInterval: '2m'
        }
      }
      omsAgent: {
        enabled: parEnableLogAnalyticsAgent
        config: {
          logAnalyticsWorkspaceResourceID: parLogAnalyticsWorkspaceId
          useAADAuth: 'true'
        }
      }
    }
  }
}


output controlPlaneFQDN string =  parEnablePrivateCluster ?  resAKS.properties.privateFQDN : resAKS.properties.fqdn



