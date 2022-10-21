targetScope = 'subscription'

// ################# Parameters ##########################
@description('Target Subscription ID')
param parSubscriptionID string = subscription().subscriptionId

@description('Target Subscription Name')
param parSubscriptionName string = subscription().displayName

@description('The region to deploy all resources into. DEFAULTS TO deployment().location')
param parLocation string = deployment().location

@description('Array of Tags to be applied to all resources in module. Default: empty array')
param parTags object = {
  Environment: 'sandbox'
  Tier       : 'coreinfra'
}

@description('Set Parameter to true to Opt-out of deployment telemetry DEFAULTS TO = true')
param parTelemetryOptOut bool = true

@description('Automation Account name that will be used by various ALZ components')
param parAutomationAccount string

@description('Contact that would be assigned via policy to receive security notifications ')
param parDefenderSecurityContact string

@description('Object ID that should be granted access to Key Vault')
param parKeyVaultAccessObjectID string

@description('')
param parLogRetentionDays int = 365

@description('')
param parResourceGroupName string

@description('Hub network CIDR prefix in the format 10.10')
param parHubCIDRPrefix string = '10.10'

@description('Spoke network CIDR prefix array list in the format 10.11 . Must differ from Hub prefix')
param parSpokeCIDRPrefixArray array = ['10.11.0.0/16', '10.12.0.0/16']

@description('Defines if Azure Firewall should be deployed')
param parAzFirewallEnabled bool = false

var varHubNetworkName   = 'vnet-${parSubscriptionName}-${parLocation}-hub'
var varSpokeNetworkName = 'vnet-${parSubscriptionName}-${parLocation}-spoke'

param parHubSubnets array = [
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '${parHubCIDRPrefix}.253.0/24'
  }
  {
    name: 'GatewaySubnet'
    ipAddressRange: '${parHubCIDRPrefix}.254.0/24'
  }
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '${parHubCIDRPrefix}.255.0/24'
  }
]

//################ Orchestration Module Variables ################
var varDeploymentNameWrappers = {
  basePrefix               : 'ALZ'
  baseSuffixManagementGroup: '${parLocation}-${uniqueString(parLocation, parSubscriptionName)}-mg'
  baseSuffixSubscription   : '${parLocation}-${uniqueString(parLocation, parSubscriptionName)}-sub'
  baseSuffixResourceGroup  : '${parLocation}-${uniqueString(parLocation, parSubscriptionName)}-rg'
}

var varModuleDeploymentNames = {
  modCustomPolicy        : take('${varDeploymentNameWrappers.basePrefix}-modCustomPolicy-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modKeyVault            : take('${varDeploymentNameWrappers.basePrefix}-modKeyvault-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modLogAnalytics        : take('${varDeploymentNameWrappers.basePrefix}-modLogAnalytics-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modNetworkingHub       : take('${varDeploymentNameWrappers.basePrefix}-modNetworkingHub-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modNetworkingHubSubnets: take('${varDeploymentNameWrappers.basePrefix}-modNetworkingHubSubnets-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 61)
  modNetworkingSpoke     : take('${varDeploymentNameWrappers.basePrefix}-modNetworkingSpoke-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 61)
  modPolicyAssignments   : take('${varDeploymentNameWrappers.basePrefix}-modPolicyAssignments-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modPrivateDNSZones     : take('${varDeploymentNameWrappers.basePrefix}-modPrivateDNSZones-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modResourceGroup       : take('${varDeploymentNameWrappers.basePrefix}-modResourceGroup-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modSpokePeeringToHub   : take('${varDeploymentNameWrappers.basePrefix}-modVnetPeering-ToHub-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 61)
  modSpokePeeringFromHub : take('${varDeploymentNameWrappers.basePrefix}-modVnetPeering-FromHub-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 61)
}

//The recommendation is to create the raw ResourceGroup in the "main" bicep so it can be used as scope for the modules and allowing it to create the dependency
resource resResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: parLocation
  name: parResourceGroupName
  tags: parTags
}

module modCustomPolicyDefinitions '../modules/policySubscription/definitions/customPolicyDefinitions.bicep' = {
  name  : varModuleDeploymentNames.modCustomPolicy
  scope : subscription(parSubscriptionID)
  params: {
    parTargetSubscriptionId: parSubscriptionID
  }
}

module modLogAnalytics '../modules/logging/logging.bicep' = {
  name  : varModuleDeploymentNames.modLogAnalytics
  scope : resResourceGroup
  params: {
    parLogAnalyticsWorkspaceName              : '${parResourceGroupName}-alz-log-analytics'
    parLogAnalyticsWorkspaceLocation          : parLocation
    parLogAnalyticsWorkspaceLogRetentionInDays: parLogRetentionDays
    parLogAnalyticsWorkspaceSkuName           : 'PerGB2018'
    parLogAnalyticsWorkspaceTags              : parTags
    parAutomationAccountName                  : parAutomationAccount
    parAutomationAccountLocation              : parLocation
    parTelemetryOptOut                        : parTelemetryOptOut
  }
}

// module modPolicyAssignments '../modules/policySubscription/assignments/alzDefaults/alzDefaultPolicyAssignments.bicep' = {
//   name: varModuleDeploymentNames.modPolicyAssignments
//   scope: subscription(parSubscriptionID)
//   params:{
//     parSubscriptionPrefix                               : subscription().displayName
//     parAutomationAccountName                            : parAutomationAccount
//     parLogAnalyticsWorkSpaceAndAutomationAccountLocation: parLocation
//     parLogAnalyticsWorkspaceLogRetentionInDays          : string(parLogRetentionDays)
//     parLogAnalyticsWorkspaceResourceId                  : modLogAnalytics.outputs.outLogAnalyticsWorkspaceId
//     parMsDefenderForCloudEmailSecurityContact           : parDefenderSecurityContact
//   } 
// }

module modHubNetworking '../modules/hubNetworking/hubNetworking.bicep' = {
  name: varModuleDeploymentNames.modNetworkingHub
  scope: resResourceGroup
  params: {
    parLocation                 : parLocation
    parCompanyPrefix            : parSubscriptionName
    parHubNetworkName           : varHubNetworkName
    parPublicIpSku              : 'Basic'
    parAzBastionEnabled         : false
    parDdosEnabled              : false
    parAzFirewallEnabled        : parAzFirewallEnabled
    parAzFirewallName           : 'azfw-${parSubscriptionName}-${parLocation}'
    parAzFirewallPoliciesName   : 'azfwpolicy-${parSubscriptionName}-${parLocation}'
    parAzFirewallTier           : 'Standard'
    parHubRouteTableName        : '${varHubNetworkName}-routetable'
    parDnsServerIps             : []
    parVpnGatewayConfig         : {}
    parExpressRouteGatewayConfig: {}
    parTags                     : parTags
    parTelemetryOptOut          : parTelemetryOptOut
    parHubNetworkAddressPrefix  : '${parHubCIDRPrefix}.0.0/16'
    parSubnets                  : [] //subnets are created separate in order to add service endpoints not supported in this module
  }
}

@batchSize(1)
module modSubnets '../modules/subnets/subnets.bicep' = [for (subnet, i) in parHubSubnets: {
  name: '${varModuleDeploymentNames.modNetworkingHubSubnets}-${i}'
  scope: resResourceGroup
  params: {
    parLocation          : parLocation
    parSubnetName        : subnet.name
    parSubnetCIDR        : subnet.ipAddressRange
    parVirtualNetworkName: modHubNetworking.outputs.outHubVirtualNetworkName
    parTelemetryOptOut   : parTelemetryOptOut
  }
}]

module modSpokeNetworking '../modules/spokeNetworking/spokeNetworking.bicep' = [for (spokeCIDR, index) in parSpokeCIDRPrefixArray: {
    name  : '${varModuleDeploymentNames.modNetworkingSpoke}-${index}'
    scope : resResourceGroup
    params: {
      parLocation                 : parLocation
      parSpokeNetworkAddressPrefix: spokeCIDR
      parSpokeNetworkName         : '${varSpokeNetworkName}-${index}'
      parNextHopIpAddress         : parAzFirewallEnabled ? modHubNetworking.outputs.outAzFirewallPrivateIp: ''
      parDnsServerIps             : []
      parSpokeToHubRouteTableName : '${varSpokeNetworkName}-${index}-routetable'
      parTags                     : parTags
      parTelemetryOptOut          : parTelemetryOptOut

    }
}]

module modVnetPeeringHubToSpoke '../modules/vnetPeering/vnetPeering.bicep' = [for i in range(0,length(parSpokeCIDRPrefixArray)) : {
  name  : '${varModuleDeploymentNames.modSpokePeeringFromHub}-${i}'
  scope : resResourceGroup
  params: {
    parSourceVirtualNetworkName     : modHubNetworking.outputs.outHubVirtualNetworkName
    parDestinationVirtualNetworkName: modSpokeNetworking[i].outputs.outSpokeVirtualNetworkName
    parDestinationVirtualNetworkId  : modSpokeNetworking[i].outputs.outSpokeVirtualNetworkId
    parAllowVirtualNetworkAccess    : true
    parAllowForwardedTraffic        : true
    parAllowGatewayTransit          : true
    parUseRemoteGateways            : false
    parTelemetryOptOut              : parTelemetryOptOut
  }
  dependsOn:[modSubnets]
}]

module modVnetPeeringSpokeToHub '../modules/vnetPeering/vnetPeering.bicep' = [for i in range(0,length(parSpokeCIDRPrefixArray)) : {
  name  : '${varModuleDeploymentNames.modSpokePeeringToHub}-${i}'
  scope : resResourceGroup
  params: {
    parSourceVirtualNetworkName     : modSpokeNetworking[i].outputs.outSpokeVirtualNetworkName
    parDestinationVirtualNetworkName: modHubNetworking.outputs.outHubVirtualNetworkName
    parDestinationVirtualNetworkId  : modHubNetworking.outputs.outHubVirtualNetworkId
    parAllowVirtualNetworkAccess    : true
    parAllowForwardedTraffic        : true
    parAllowGatewayTransit          : true
    parUseRemoteGateways            : false
    parTelemetryOptOut              : parTelemetryOptOut
  }
  dependsOn:[modVnetPeeringHubToSpoke]
}]

module modPrivateDNSZones '../modules/privateDnsZones/privateDnsZones.bicep' = {
  name  : varModuleDeploymentNames.modPrivateDNSZones
  scope : resResourceGroup
  params: {
    parLocation              : parLocation
    parVirtualNetworkIdToLink: modHubNetworking.outputs.outHubVirtualNetworkId
    parTelemetryOptOut       : parTelemetryOptOut
  }
}

module modKeyVault  '../modules/keyVault/keyvault.bicep' = {
  name  : varModuleDeploymentNames.modKeyVault
  scope : resResourceGroup
  params: {
    parLocation                    : parLocation
    parSKU                         : 'standard'
    parObjectID                    : parKeyVaultAccessObjectID
    parRecoverMode                 : false
    parPublicNetworkAccess         : 'enabled'
    parAllowedVNETSubnets          : [ for (subnets, i) in parHubSubnets: {
      id                              : modSubnets[i].outputs.subnetID
      ignoreMissingVnetServiceEndpoint: false
    }]
    parAzureServicesBypass         : true
    parNetworkDefaultAction        : 'Deny'
    parVNETName                    : modHubNetworking.outputs.outHubVirtualNetworkName
    parEnabledForDeployment        : true
    parEnabledForDiskEncryption    : true
    parEnabledForTemplateDeployment: true
    parEnablePurgeProtection       : true
    parEnableRbacAuthorization     : true
    parEnableSoftDelete            : true
    parSoftDeleteRetentionInDays   : 7
    parTags                        : parTags
  }
  dependsOn: []
}

//TODO: Az CLI Create Role Assignment to single subscription
