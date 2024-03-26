targetScope = 'resourceGroup'

@description('This module deploys a NAT Gateway in a Virtual Network. The NAT Gateway provides outbound connectivity for virtual networks.')
param parName string

@description('The location of the resource. This value is optional if the resource group is provided.')
param parLocation string          = resourceGroup().location

@description('The idle timeout of the NAT gateway in minutes. The value can be set between 4 and 120 minutes. The default value is 4 minutes.')
param parIdleTimeoutInMinutes int = 4

@description('An array of objects containing the resource Id of Public IP addresses of the NAT gateway. You can specify up to 16 public IP addresses for the NAT gateway. If it is not specified, the NAT gateway will be created without any public IP addresses and outbound connectivity will not work until one is added.')
param parPublicIpAddresses array  = []

@description('An array of objects containing the resource Id of the public IP prefixes of the NAT gateway. You can specify up to 16 public IP prefixes for the NAT gateway. If it is not specified, the NAT gateway will be created without any public IP prefixes and outbound connectivity will not work until one is added.')
param parPublicIpPrefixes array    = []

@description('The SKU of the NAT gateway. The default value is Standard.')
param parSkuName string = 'Standard'

@description('An array of availability zones denoting the zone in which the NAT gateway should be created. If it is not specified, the NAT gateway will be created in the default zone.')
param parZones array = []

@description('''Object with Tags key pairs to be applied to all resources in module. Default: empty array. Format: 
{
  Environment      : 'string'
  SLA              : 'string'
  CustomerName     : 'string'
  CustomerShortCode: 'string'
  Service          : 'string'
  Tier             : 'coreinfra'
}
''')
param parTags object = {}

resource resNATGateway 'Microsoft.Network/natGateways@2023-09-01' = {
  name      : parName
  location  : parLocation
  tags      : parTags
  properties: {
    idleTimeoutInMinutes: parIdleTimeoutInMinutes
    publicIpAddresses   : [for ip in parPublicIpAddresses: {
                            id: resourceId('Microsoft.Network/publicIPAddresses', ip)
                          }]
    publicIpPrefixes: [for prefix in parPublicIpPrefixes: {
                        id: resourceId('Microsoft.Network/publicIPPrefixes', prefix)
                      }]
  }
  sku: {
    name: parSkuName
  }
  zones: parZones
}

output id string   = resNATGateway.id
output name string = resNATGateway.name
