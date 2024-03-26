targetScope = 'resourceGroup'

@description('The Azure Region to deploy the resources into. Default: resourceGroup().location')
param parLocation string = resourceGroup().location

@description('Prefix value which will be prepended to all resource names. Default: alz')
param parCompanyPrefix string = 'IN2'

@description('Prefix Used for Virtual Network. Default: VNET-{parCompanyPrefix}-{parLocation}')
param parVirtualNetworkName string = 'VNET-${parCompanyPrefix}-${parLocation}-01'

@description('The IP address range for all virtual networks to use. Default: 10.10.0.0/16')
param parVirtualNetworkAddressPrefixes array = ['10.10.0.0/16']

@description('The name and IP address range for each subnet in the virtual networks. Default: AzureBastionSubnet, GatewaySubnet, AzureFirewall Subnet')
param parSubnets array = [
  {
    name          : 'AzureBastionSubnet'
    ipAddressRange: '10.0.0.0/26'
  }
  {
    name          : 'GatewaySubnet'
    ipAddressRange: '10.0.0.64/27'
  }
  {
    name          : 'AzureFirewallSubnet'
    ipAddressRange: '10.0.0.96/27'
  }
]

@description('Array of DNS Server IP addresses for VNet. Default: Empty Array')
param parDnsServerIps array = []

@description('Switch to enable/disable Private DNS Zones deployment. Default: true')
param parPrivateDnsZonesEnabled bool = false

@description('Resource Group Name for Private DNS Zones. Default: same resource group')
param parPrivateDnsZonesResourceGroup string = resourceGroup().name

@description('Array of DNS Zones to provision in Hub Virtual Network. Default: All known Azure Private DNS Zones')
param parPrivateDnsZones array = []

@description('Switch to enable/disable DDoS Standard deployment. Default: true')
param parDdosEnabled bool = false

@description('DDoS Plan Name. Default: {parCompanyPrefix}-ddos-plan')
param parDdosPlanName string = 'DDOS-${parCompanyPrefix}-plan-01'

@description('Tags you would like to be applied to all resources in this module. Default: empty array')
param parTags object = {}

//DDos Protection plan will only be enabled if parDdosEnabled is true.  
resource resDdosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2023-06-01' = if (parDdosEnabled) {
  name    : parDdosPlanName
  location: parLocation
  tags    : parTags
}

resource resVnet 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name      : parVirtualNetworkName
  location  : parLocation
  tags      : parTags
  properties: {
    addressSpace: {
      addressPrefixes: parVirtualNetworkAddressPrefixes
    }
    dhcpOptions: {
      dnsServers: parDnsServerIps
    }
    subnets : [for subnet in parSubnets: {
      name      : subnet.name
      properties: {
        addressPrefix       : subnet.ipAddressRange
        networkSecurityGroup: empty(subnet.networkSecurityGroup) ? null : {
                              id: resourceId('Microsoft.Network/networkSecurityGroups', subnet.networkSecurityGroup )
                            }
        serviceEndpoints    : empty(subnet.serviceEndpoints) ? null : subnet.serviceEndpoints
      }
    }]
    enableDdosProtection: parDdosEnabled
    ddosProtectionPlan  : (parDdosEnabled) ? { id: resDdosProtectionPlan.id } : null
  }
}

module modPrivateDnsZones '../privateDNSZones/privateDnsZones.bicep' = if (parPrivateDnsZonesEnabled) {
  name  : 'deploy-Private-DNS-Zones'
  scope : resourceGroup(parPrivateDnsZonesResourceGroup)
  params: {
    parLocation              : parLocation
    parTags                  : parTags
    parVirtualNetworkIdToLink: resVnet.id
    parPrivateDnsZones       : parPrivateDnsZones
  }
}

output outDdosPlanResourceId string    = resDdosProtectionPlan.id
output outHubVirtualNetworkName string = resVnet.name
output outHubVirtualNetworkId string   = resVnet.id
output outSubnets array                = resVnet.properties.subnets

