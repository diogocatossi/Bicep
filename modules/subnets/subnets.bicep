@description('The Azure Region to deploy the resources into. Default: resourceGroup().location')
param parLocation string = resourceGroup().location

@description('Virtual Network name where the subnets will be provisioned')
param parVirtualNetworkName string

@description('Subnet name')
param parSubnetName string 

@description('Array containing the subnet prefixes in CIDR format')
param parSubnetCIDR string = ''

@description('Array of service endpoints that should be added to the subnet')
param parServiceEndpoints array = []

@description('Network Security Group object for the subnet.')
param parNetworkSecurityGroup object = {}

@description('Set Parameter to true to Opt-out of deployment telemetry. Default: false')
param parTelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaid = '0c428583-f2a1-4448-975c-2d6262fd193a'

resource resHubNetworking 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name : parVirtualNetworkName
}

//Configure subnets with Service Endpoints to allow Keyvault setup
resource resSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
    name      : parSubnetName
    parent    : resHubNetworking
    properties: {
      addressPrefix   : parSubnetCIDR
      serviceEndpoints: [for (endpointName, index) in parServiceEndpoints: {
          locations: [parLocation]
          service  : endpointName
      }]
      networkSecurityGroup: parNetworkSecurityGroup
    }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut) {
  name  : 'pid-${varCuaid}-${uniqueString(resourceGroup().id)}'
  params: {}
}

output subnetName string = resSubnet.name
output subnetID string   = resSubnet.id
