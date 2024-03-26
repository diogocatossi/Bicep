using './applicationGateway.bicep'

param parAppGatewayName           = 'AAG-JGR-CSP-PRD-ANE-001'
param parLocation                 = 'northeurope'
param parSkuName                  = 'WAF_v2'
param parSkuTier                  = 'WAF_v2'
param parMinCapacity              = 1
param parMaxCapacity              = 10
param parSubnetId                 = '/subscriptions/aefc5ded-4369-4728-bed5-713c879f77f3/resourceGroups/RG-JGR-CSP-SCC-ANE-001/providers/Microsoft.Network/virtualNetworks/VNET-JGR-CSP-SCC-ANE-001/subnets/AAGNET'
param parPublicIPEnabled          = true
param parPublicIPAllocatonMethod  = 'Static'
param parPublicIPSkuName          = 'Standard'
param parPublicDDOSEnabled        = false
param parUserAssignedIdentityName = 'MID-AAG-JGR-CSP-PRD-ANE-001'
param parFrontendPorts            = [ 80, 443 ]
param parBackendAddressPools      = [
                                      {
                                        name: 'BEP-ActInTime'
                                        backendAddresses: [
                                          {
                                              ipAddress : '10.50.8.4'
                                          }
                                        ] 
                                      }
                                    ]
//NOTE: ParLiteners order will be used to define the requestRoutingRules priority
param parListeners             = [
                                  {
                                    name               : 'ActInTime-80'
                                    port               : 80
                                    protocol           : 'Http'
                                    sslCertificateName : ''
                                    hostNames          : ['actintime.joulegroupltd.com']
                                    backendPoolName    : 'BEP-ActInTime'
                                    backendHttpSettings: 'HTTPSettings-80'
                                    redirectConfig     : 'Redirect-ActInTime-80'
                                  }
                                  {
                                    name              : 'ActInTime-443'
                                    port              : 443
                                    protocol          : 'Https'
                                    sslCertificateName: 'STAR-JouleGroupLtd-com'
                                    hostNames         : ['actintime.joulegroupltd.com']
                                    backendPoolName   : 'BEP-ActInTime'
                                    backendHttpSettings: 'HTTPSettings-443'
                                    redirectConfig    : ''                                    
                                  }
                                ]
param parRedirectConfigurations = [
                                    {
                                      name              : 'Redirect-ActInTime-80'
                                      includePath       : true
                                      includeQueryString: true
                                      redirectType      : 'Permanent'
                                      targetListenerName: 'ActInTime-443'
                                    }
                                  ]
param parBackendHttpSettingsCollection =  [
                                            {
                                              name                          : 'HTTPSettings-80'
                                              port                          : 80
                                              protocol                      : 'Http'
                                              CookieBasedAffinity           : 'Enabled'
                                              CookieName                    : 'ApplicationGatewayAffinity'
                                              requestTimeout                : 20
                                              pickHostNameFromBackendAddress: false
                                              probeName                     : 'Probe-80'
                                            }
                                            {
                                              name                          : 'HTTPSettings-443'
                                              port                          : 443
                                              protocol                      : 'Https'
                                              CookieBasedAffinity           : 'Enabled'
                                              CookieName                    : 'ApplicationGatewayAffinity'
                                              requestTimeout                : 20
                                              pickHostNameFromBackendAddress: false
                                              probeName                     : 'Probe-443'
                                            }
                                          ]
param parProbes             = [
                                {
                                  name                               : 'Probe-80'
                                  protocol                           : 'Http'
                                  port                               : 80
                                  host                               : 'actintime.joulegroupltd.com'
                                  path                               : '/'
                                  interval                           : 5
                                  timeout                            : 30
                                  unhealthyThreshold                 : 3
                                  pickHostNameFromBackendHttpSettings: false
                                  minServers                         : 0
                                  statusCodes                        : [ '200-399' ]
                                }
                                {
                                  name                               : 'Probe-443'
                                  protocol                           : 'Https'
                                  port                               : 443
                                  host                               : 'actintime.joulegroupltd.com'
                                  path                               : '/'
                                  interval                           : 5
                                  timeout                            : 30
                                  unhealthyThreshold                 : 3
                                  pickHostNameFromBackendHttpSettings: false
                                  minServers                         : 0
                                  statusCodes                        : [ '200-399' ]
                                }
                              ]
param parSSLPolicyType         = 'Predefined'
param parSSLPolicyName         = 'AppGwSslPolicy20220101S'
param parKeyVaultName          = 'KV-JGR-CSP-PRD-ANE-01'
param parKeyVaultResourceGroup = 'RG-JGR-CSP-SCC-ANE-001'
param parCerficicateNames      = ['STAR-JouleGroupLtd-com']
param parEnableHTTP2           = true
param parTags                  = {
  Environment      : 'PRD'
  SLA              : 'N/A'
  CustomerName     : 'Joule Group Ltd'
  CustomerShortCode: 'JGR'
  Service          : 'Landing Zone'
  Tier             : 'coreinfra'
}

