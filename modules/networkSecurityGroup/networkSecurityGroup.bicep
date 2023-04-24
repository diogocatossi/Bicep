targetScope = 'resourceGroup'

@description('Network Security Group Name, starting with NSG- ')
param parNSGName string

@description('Resource Location. DEFAULT: Resource Group location')
param parLocation string = resourceGroup().location

@description('Array of objects representing the security rules that will be assigned to the NSG. DEFAULT: 443/TCP Inbound and Outbound')
param parSecurityRules array = [
  // Inbound Rules
  {
    name: 'AllowHttpsInbound'
    properties: {
      access: 'Allow'
      direction: 'Inbound'
      priority: 100
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
    }
  }
  // #################  Outbound Rules ######################
  {
    name: 'AllowHttpsInbound'
    properties: {
      access: 'Allow'
      direction: 'outbound'
      priority: 100
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
    }
  }
]

@description('Tags you would like to be applied to all resources in this module. Default: empty array')
param parTags object = {}


resource resNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' =  {
  name    : parNSGName
  location: parLocation
  tags    : parTags
  properties: {
    securityRules: parSecurityRules
  }
}

output nsgId string                = resNSG.id
output nsgProvisioningState string = resNSG.properties.provisioningState

