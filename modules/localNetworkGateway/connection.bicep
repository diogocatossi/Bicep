targetScope = 'resourceGroup'

@description('Connection Name')
param parConnectionName string

@description('')
param parLocation string = resourceGroup().location

@allowed([
  'ExpressRoute'
  'IPsec'
  'VPNClient'
  'Vnet2Vnet'
])
@description('Gateway connection type.')
param parConnectionType string

@metadata({
  dhGroup            : 'DHGroup14'
  ikeEncryption      : 'AES256' 
  ikeIntegrity       : 'SHA256'
  ipsecEncryption    : 'AES256'
  ipsecIntegrity     : 'SHA256'
  pfsGroup           : ''
  saDataSizeKilobytes: 102400000
  saLifeTimeSeconds  : 27000
})
@description('The custom IPSec Policies to be considered by this connection.')
param parIPSecPolicies object = {}

@description('The reference to virtual network gateway resource.')
param parVirtualNetworkGatewayName string

@description('EnableBgp flag.')
param parEnableBgp bool

@description('The 128-character long ASCII IPSec shared key that will be used for the S2S VPN')
param parSharedKey string

@description('The reference to local network gateway resource.')
param parLocalNetworkGatewayName string

@allowed([
  'IKEv1'
  'IKEv2'
])
@description('DEFAULT: false')
param parConnectionProtocol string = 'IKEv2'

@description('Object with Tags to be applied to all resources in module. Default: empty array')
param parTags object = {}

resource resConnection 'Microsoft.Network/connections@2022-07-01' = {
  name      : parConnectionName
  location  : parLocation
  properties: {
    connectionType        : parConnectionType
    connectionProtocol    : parConnectionProtocol
    enableBgp             : parEnableBgp
    sharedKey             : parSharedKey
    ipsecPolicies         : empty(parIPSecPolicies) ? null : [
      {
        dhGroup            : parIPSecPolicies.dhGroup
        ikeEncryption      : parIPSecPolicies.ikeEncryption
        ikeIntegrity       : parIPSecPolicies.ikeIntegrity
        ipsecEncryption    : parIPSecPolicies.ipsecEncryption
        ipsecIntegrity     : parIPSecPolicies.ipsecIntegrity
        saDataSizeKilobytes: parIPSecPolicies.saDataSizeKilobytes
        saLifeTimeSeconds  : parIPSecPolicies.saLifeTimeSeconds
      }
    ]
    virtualNetworkGateway1: {
      id        : resourceId('Microsoft.Network/virtualNetworkGateways', parVirtualNetworkGatewayName)
    }
    localNetworkGateway2: {
      id        : resourceId('Microsoft.Network/localNetworkGateways', parLocalNetworkGatewayName)
    }

  }
  tags: parTags
}

output id string = resConnection.id
