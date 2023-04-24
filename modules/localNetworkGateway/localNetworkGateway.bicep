targetScope = 'resourceGroup'

@description('Local Network Gateway Name')
param parLocalNetworkGatewayName string

@description('Resource location.')
param parLocation string = resourceGroup().location

@description('IP address of local (remote) network gateway.')
param parGatewayIpAddress string

@description('An aarray with list of address blocks reserved for this virtual network in CIDR notation.')
param parAddressPrefixes array = []

@description('Object with Tags to be applied to all resources in module. Default: empty array')
param parTags object = {}

resource resLocalNetworkGateway 'Microsoft.Network/localNetworkGateways@2022-07-01' = {
  name      : parLocalNetworkGatewayName
  location  : parLocation
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: parAddressPrefixes
    }
    gatewayIpAddress: parGatewayIpAddress
  }
  tags: parTags
}

output lngid string = resLocalNetworkGateway.id

  
