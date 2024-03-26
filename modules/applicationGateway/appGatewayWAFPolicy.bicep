targetScope = 'resourceGroup'

@description('The name of the WAF Policy. DEFAULTS TO appGatewayWAFPolicy')
param parPolicyName string = 'appGatewayWAFPolicy'

@description('The region to deploy all resources into. DEFAULTS TO deployment().location')
param parLocation string = resourceGroup().location

@description('Object with Tags key pairs to be applied to all resources in module. Default: empty array')
param parTags object = {}

@description('Whether to allow WAF to check request Body. Default: true')
param parRequestBodyCheck bool = true

@description('The maximum request body size in kilobytes. Max 2000. Default: 1024')
@minValue(8)
@maxValue(2000)
param parMaxRequestBodySizeInKb int = 1024

@description('The maximum file upload size in megabytes. Max 4000. Default: 100')
@minValue(1)
@maxValue(4000)
param parFileUploadLimitInMb int = 100

@description('The state of the policy. Default: Enabled')
@allowed([
  'Enabled'
  'Disabled'
])
param parPolicyState string = 'Enabled'

@description('The mode of the policy. Default: Detection')
@allowed([
  'Prevention'
  'Detection'
])
param parPolicyMode string = 'Detection'

@description('The type of the managed rule set. Default: OWASP_3.2')
@allowed([
  'OWASP-3.2'
  'OWASP-3.1'
  'OWASP-3.0'
  'Microsoft_DefaultRuleSet-2.1'
])
param parManagedRuleSetType string = 'OWASP-3.2'

@description('The type of the additional managed rule set. Default: Microsoft_BotManagerRuleSet-1.0')
@allowed([
  'Microsoft_BotManagerRuleSet-1.0'
  'Microsoft_BotManagerRuleSet-0.1'
])
param parAdditionalManagedRuleSetType string = 'Microsoft_BotManagerRuleSet-1.0'

@description('The custom rules to apply to the WAF Policy. Default: empty array' )
param parCustomRules array = []

resource resAppGatewayWAFPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-09-01' = {
  name    : parPolicyName
  location: parLocation
  tags    : parTags
  properties: {
    policySettings: {
      requestBodyCheck           : parRequestBodyCheck
      maxRequestBodySizeInKb     : parMaxRequestBodySizeInKb
      fileUploadLimitInMb        : parFileUploadLimitInMb
      state                      : parPolicyState
      mode                       : parPolicyMode 
      requestBodyInspectLimitInKB: parMaxRequestBodySizeInKb
      fileUploadEnforcement      : true
      requestBodyEnforcement     : true
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType       : split(parManagedRuleSetType, '-')[0]
          ruleSetVersion    : split(parManagedRuleSetType, '-')[1]
          ruleGroupOverrides: []
        }
        {
          ruleSetType       : split(parAdditionalManagedRuleSetType, '-')[0]
          ruleSetVersion    : split(parAdditionalManagedRuleSetType, '-')[1]
          ruleGroupOverrides: []
        }
      ]
      exclusions: []
    }
    customRules   : parCustomRules
  }
}

output id string   = resAppGatewayWAFPolicy.id
output name string = resAppGatewayWAFPolicy.name
output state string = resAppGatewayWAFPolicy.properties.provisioningState
