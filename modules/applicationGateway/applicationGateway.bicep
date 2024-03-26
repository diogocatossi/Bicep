targetScope = 'resourceGroup'

@description('The name of the Application Gateway.')
param parAppGatewayName string

@description('The location of the Application Gateway.')
param parLocation string = resourceGroup().location

@description('The SKU name of the Application Gateway.')
@allowed([
  'Basic' 
  'Standard_Small'
  'Standard_Medium'
  'Standard_Large'
  'Standard_v2'
  'WAF_Medium'
  'WAF_Large'
  'WAF_v2'
])
param parSkuName string = 'WAF_v2'

@description('The SKU tier of the Application Gateway.')
@allowed([
  'Basic'
  'Standard'
  'Standard_v2'
  'WAF'
  'WAF_v2'
])
param parSkuTier string = 'WAF_v2'

@description('The minimum capacity of the Application Gateway. Default: 1.')
param parMinCapacity int = 1

@description('The maximum capacity of the Application Gateway. Default: 10.')
param parMaxCapacity int = 10

@description('The ID of the subnet.')
param parSubnetId string

@description('Flag that defines is Application Gateway has public IP address.')
param parPublicIPEnabled bool = true

@description('The public IP address allocation method. Default: Static (recommended for production environments)')
@allowed([
  'Dynamic'
  'Static'
])
param parPublicIPAllocatonMethod string = 'Static'

@description('The public IP address SKU name. Default: Standard')
@allowed([
  'Basic'
  'Standard'
])
param parPublicIPSkuName string = 'Standard'

@description('The public IP address SKU tier. Default: Regional')
@allowed([
  'Global'
  'Regional'
])
param parPublicIPTier string = 'Regional'

@description('Flag that defines is DDoS protection enabled for public IP address.')
param parPublicDDOSEnabled bool = false

@description('The name of the User Assigned Identity to be used by the Application Gateway to access resources such as Key Vault. Default: empty string.')
param parUserAssignedIdentityName string = ''

@description('The list of frontend ports.')
param parFrontendPorts array = [ 80 , 443 ]

@description('''An array of objects representing the backend address pools. It should contain the following format and BackendAddresses only needs to be filled with either fdqn: or ipAddress: if it's not a VM connection. Otherwise provide a blank array:  
[ 
  {
    name            : 'string',
    backendAddresses: [ 
      {
        fqdn     : 'string',
        ipAddress: 'string'
      }
    ]
  }
]
''')
param parBackendAddressPools array = []

@description('The type of SSL policy. Default: Predefined')
@allowed([
  'Predefined'
  'Custom'
  'CustomV2'
])
param parSSLPolicyType string = 'Predefined'

@description('The name of the SSL policy. Default: empty string.')
@allowed([
  'AppGwSslPolicy20150501'
  'AppGwSslPolicy20170401'
  'AppGwSslPolicy20170401S'
  'AppGwSslPolicy20220101'
  'AppGwSslPolicy20220101S'
])
param parSSLPolicyName string = 'AppGwSslPolicy20220101S'

@description('The minimum protocol version of the SSL policy. Only required if SSLPolicyType is Custom. Default: TLSv1_2')
@allowed([
  'TLSv1_0'
  'TLSv1_1'
  'TLSv1_2'
  'TLSv1_3'
])
param parMinProtocolVersion string = 'TLSv1_2'

@description('''And array of objects representing the Listeners. NOTE: ParLiteners order will be used to define the requestRoutingRules priority. Default: empty array. Example: 
[
  {
    name              : 'string',
    port              : int,
    protocol          : 'Http' | 'Https' | 'Tls',
    sslCertificateName: 'string',
    hostNames         : [ 
      '*.domain.com'
      'test.domain.com' 
    ],
    backendPoolName : 'string',
    redirectConfig  : 'string'
  }
]''')
param parListeners array = []

@description('''An array of objects representing the RedirectConfigurations. It should contain the following format: 
{
  name              : 'string', 
  includePath       : bool, 
  includeQueryString: bool, 
  redirectType      : 'Found' | 'Permanent' | 'SeeOther' | 'Temporary', 
  targetListenerName: 'string'
}
''')
param parRedirectConfigurations array = []


@description('''An array of objects representing the BackendHttpSettingsCollection. It should contain the following format: 
[ 
  {
    name                           : 'string',
    port                           : int,
    protocol                       : 'Http' | 'Https',
    CookieBasedAffinity            : 'Enabled' | 'Disabled',
    CookieName                     : 'string',
    pickHostNameFromBackendAddress : bool,
    requestTimeout                 : int,
    probeName                      : 'string'
  }
]
''')
param parBackendHttpSettingsCollection array = []

@description('''An array of objects representing the Probes. It should contain the following format: 
[
  {
    name                           : 'string',
    protocol                       : 'Http' | 'Https',
    port                           : int,
    host                           : 'string',
    path                           : 'string',
    interval                       : int,
    timeout                        : int,
    unhealthyThreshold             : int,
    pickHostNameFromBackendHttpSettings: bool,
    statusCodes                    : [ 
      int
    ]
  }
]
''')
param parProbes array = []

@description('The Name of the Key Vault that contains the SSL certificates.')
param parKeyVaultName string = ''

@description('The Resource Group of the Key Vault that contains the SSL certificates. Default: empty string.')
param parKeyVaultResourceGroup string = ''

@description('The list of SSL certificates names to be retrieved from the Keyvault.')
param parCerficicateNames array = []

@description('The flag that defines if the Application Gateway uses HTTP2. Default: true')
@allowed([
  true
  false
])
param parEnableHTTP2 bool = true

@description('The tags of the Application Gateway.')
param parTags object = {}


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ RESOURCES @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//Create a Managed User Assigned Identity to be used by the Application Gateway to access Key Vault
resource resManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (!empty(parUserAssignedIdentityName)) {
  name: parUserAssignedIdentityName
}

resource resKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name : parKeyVaultName
  scope: resourceGroup(parKeyVaultResourceGroup)
}

resource resDDOSProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2023-09-01' = if (parPublicDDOSEnabled) {
  name    : '${parAppGatewayName}-DDOS'
  location: parLocation
  tags    : parTags
}

resource resPublicIPAddress 'Microsoft.Network/publicIPAddresses@2023-09-01' = if (parPublicIPEnabled) {
  name      : '${parAppGatewayName}-PIP'
  location  : parLocation
  sku: {
    name: parPublicIPSkuName
    tier: parPublicIPTier
  }
  properties: {
    publicIPAllocationMethod: parPublicIPAllocatonMethod
    ddosSettings            : parPublicDDOSEnabled ? {
      ddosProtectionPlan:{
        id: resDDOSProtectionPlan.id
      }
    } : null
  }
  tags: parTags
}

//TODO: Implement support for multiple WAF policies
module resAppGatewayWAFPolicy 'appGatewayWAFPolicy.bicep' = if (parSkuName == 'WAF_v2') {
  name    : 'Deploy-${parAppGatewayName}-WAFPolicy'
  params: {
    parPolicyName                  : '${parAppGatewayName}-WAFPolicy-01'
    parLocation                    : parLocation
    parTags                        : parTags
    parRequestBodyCheck            : true
    parMaxRequestBodySizeInKb      : 1024
    parFileUploadLimitInMb         : 100
    parPolicyState                 : 'Enabled'
    parPolicyMode                  : 'Prevention'
    parManagedRuleSetType          : 'OWASP-3.2'
    parAdditionalManagedRuleSetType: 'Microsoft_BotManagerRuleSet-1.0'
  }
}

resource resApplicationGateway 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name    : parAppGatewayName
  location: parLocation
  identity: empty(parUserAssignedIdentityName) ? null: {
    type                  : 'UserAssigned'
    userAssignedIdentities: {
      '${resManagedIdentity.id}': {}
    }
  }
  properties: {
    sku: {
      name: parSkuName
      tier: parSkuTier
    }
    autoscaleConfiguration: {
      minCapacity: parMinCapacity
      maxCapacity: parMaxCapacity
    }
    sslPolicy: {
      policyType        : parSSLPolicyType
      policyName        : parSSLPolicyName
      minProtocolVersion: parSSLPolicyType == 'Predefined' ? null : parMinProtocolVersion
    }
    enableHttp2: parEnableHTTP2
    gatewayIPConfigurations: [
      {
        name      : 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: parSubnetId
          }
        }
      }
    ]
    sslCertificates: [ for cert in parCerficicateNames: {
        name : cert
        properties: {
            keyVaultSecretId: '${resKeyVault.properties.vaultUri}secrets/${cert}'
        }
      }     
    ]
    frontendIPConfigurations: [
      {
        name      : 'appGatewayFrontendIp'
        properties: {
          publicIPAddress: !parPublicIPEnabled ? null : {
            id: resPublicIPAddress.id
          } 
          privateIPAllocationMethod: parPublicIPEnabled ? null: 'Dynamic'
        }
      }
    ]
    frontendPorts: [ for port in parFrontendPorts: {
        name      : 'Port_${string(port)}'
        properties: {
          port: port
        }
      }
    ]
    backendAddressPools: [for pool in parBackendAddressPools: {
        name      : pool.name
        properties: {
          backendAddresses: empty(pool.backendAddresses) ? []: pool.backendAddresses
        }
      }
    ]
    backendHttpSettingsCollection: [for setting in parBackendHttpSettingsCollection: {
        name      : setting.name
        properties: {
          port                          : setting.port
          protocol                      : setting.protocol
          //'The flag that defines if the Application Gateway uses cookie-based affinity. Default: Enabled.'
          cookieBasedAffinity           : setting.CookieBasedAffinity
          affinityCookieName            : setting.CookieBasedAffinity == 'Disabled' ? null: setting.CookieName
          pickHostNameFromBackendAddress: setting.pickHostNameFromBackendAddress
          //'Request timeout in seconds. Application Gateway will fail the request if response is not received within RequestTimeout. Acceptable values are from 1 second to 86400 seconds. Default: 20.'
          requestTimeout                : setting.requestTimeout
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', parAppGatewayName, setting.probeName)
          }
        }
      }
    ]
    httpListeners: [ for listener in parListeners: {
        name      : listener.name
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', parAppGatewayName, 'appGatewayFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', parAppGatewayName, 'Port_${string(listener.port)}')
          }
          protocol      : listener.protocol
          sslCertificate: (listener.protocol == 'Https') || (listener.protocol == 'Tls') ? {
                            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', parAppGatewayName, listener.sslCertificateName)
                          } : null
          hostNames                  : !empty(listener.hostNames) ? listener.hostNames: null
          requireServerNameIndication: listener.protocol == 'Https' ? true            : false
          //Firewall policy is only available for WAF_v2 and preferably applied to the Listeners, in case you need to have different policies per listener
          firewallPolicy: (parSkuName == 'WAF_v2') ? {
            id: resAppGatewayWAFPolicy.outputs.id
          } : null
        }
      }
    ]
    //TODO: Implement support for multiple redirects when multiple Https listeners are present
    redirectConfigurations: [for (config ,index) in parRedirectConfigurations: {
        name      : config.name
        properties: {
          includePath       : config.includePath
          includeQueryString: config.includeQueryString
          redirectType      : config.redirectType
          targetListener    : {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', parAppGatewayName, config.targetListenerName)
          }
        }
      } 
      // //TODO: Submit but bug because redirectConfiguration doesn't work with conditional inside for loop:
      // for () in zzzz : (listener.protocol == 'Https') ? {...} : {
      //   name: ''! //Stupid as it seems, because it's not a Subresource, it doesn't accept null or empty object
      //   properties: null
      // }
    ]
    requestRoutingRules: [for (listener,index) in parListeners: {
        name      : 'Rule-${listener.name}'
        properties: {
          ruleType    : 'Basic'      //TODO: Implement support for 'PathBasedRouting'
          priority    : index + 1    //TODO: Implement support for custom priority
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', parAppGatewayName, listener.name)
          }
          redirectConfiguration: listener.protocol == 'Http' ? {
            //TODO: Implement support for multiple redirects when multiple Http listeners are present. For now it's hardcoded to the first redirect, meaning -0 is the one for port 80
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', parAppGatewayName, listener.redirectConfig)
          } : null
          backendAddressPool: listener.protocol != 'Http' ? {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', parAppGatewayName, listener.backendPoolName )
          } : null
          backendHttpSettings: listener.protocol != 'Http' ? {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', parAppGatewayName, listener.backendHttpSettings)
          } : null
        }
      }
    ]
    probes: [ for probe in parProbes : empty(parProbes) ? {} :{
        name      : empty(probe.name) ? 'Probe-${string(probe.port)}' : probe.name
        properties: {
          protocol                           : probe.protocol
          port                               : probe.port
          host                               : probe.host
          path                               : probe.path
          interval                           : probe.interval
          timeout                            : probe.timeout
          unhealthyThreshold                 : probe.unhealthyThreshold
          pickHostNameFromBackendHttpSettings: probe.pickHostNameFromBackendHttpSettings
          minServers                         : 0
          match                              : {
            statusCodes: empty(probe.statusCodes) ? [] : probe.statusCodes
          }
        }
      }
    ]
  }
  tags: parTags
}

output id string   = resApplicationGateway.id
output name string = resApplicationGateway.name
output pipID string = resApplicationGateway.properties.frontendIPConfigurations[0].properties.publicIPAddress.id
