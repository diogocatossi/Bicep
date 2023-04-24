targetScope = 'resourceGroup'

@description('Domain Name')
param parDomainName string

@description('Location for all resources.')
param parLocation string = resourceGroup().location

@allowed([
  'Standard'
  'Enterprise'
  'Premium'
])
@description('SKU of the AD Domain Service.')
param parSKU string = 'Standard'

@allowed([
  'FullySynced'
  'ResourceTrusting'
])
@description('Domain Configuration Type. DEFAULT: FullySynced')
param parDomainConfigurationType string = 'FullySynced'

@allowed([
  'Enabled'
  'Disabled'
])
@description('Enabled or Disabled flag to turn on Group-based filtered sync')
param parFilteredSync string = 'Disabled'

@allowed([
  'Enabled'
  'Disabled'
])
@description('A flag to determine whether or not NtlmV1 is enabled or disabled. DEFAULT: Disabled')
param parNTLMV1 string = 'Disabled'


@allowed([
  'Enabled'
  'Disabled'
])
@description('A flag to determine whether or not TlsV1 is enabled or disabled. DEFAULT: Disabled')
param parTLSV1 string = 'Disabled'

@allowed([
  'Enabled'
  'Disabled'
])
@description('A  flag to determine whether or not KerberosRc4Encryption is enabled or disabled. DEFAULT: Enabled')
param parKerberosRC4 string = 'Enabled'

@allowed([
  'All'
  'CloudOnly'
])
@description('All or CloudOnly, All users in AAD are synced to AAD DS domain or only users actively syncing in the cloud')
param parSyncScope string = 'All'

@allowed([
  'Enabled'
  'Disabled'
])
@description('A flag to determine whether or not Secure LDAP is enabled or disabled. DEFAULT: Disabled')
param parSecureLDAPEnable string = 'Disabled'

@secure()
@description('The certificate required to configure Secure LDAP. The parameter passed here should be a base64encoded representation of the certificate pfx file.')
param parSecureLDAPCert string = ''

@secure()
@description('The password to decrypt the provided Secure LDAP certificate pfx file.')
param parSecureLDAPCertPwd string = ''

@description('Virtual Network Name')
param parVirtualNetworkName string

@description('AD DS Subnet Name')
param parSubnetName string 

@description('Array of Tags to be applied to all resources in module. Default: empty array')
param parTags object = {}

resource resDomainServices 'Microsoft.AAD/domainServices@2022-12-01' = {
  name      : parDomainName
  location  : parLocation
  properties: {
    domainName             : parDomainName
    filteredSync           : parFilteredSync
    domainConfigurationType: parDomainConfigurationType
    syncScope              : parSyncScope
    domainSecuritySettings : {
                              ntlmV1               : parNTLMV1
                              tlsV1                : parTLSV1
                              kerberosRc4Encryption: parKerberosRC4
                            }
    notificationSettings   : {
      notifyDcAdmins    : 'Enabled'
      notifyGlobalAdmins: 'Enabled'
    }
    ldapsSettings: {
      externalAccess        : 'Disabled'
      ldaps                 : parSecureLDAPEnable
      pfxCertificate        : parSecureLDAPEnable == 'Enabled' ? parSecureLDAPCert   : null
      pfxCertificatePassword: parSecureLDAPEnable == 'Enabled' ? parSecureLDAPCertPwd: null
    }
    replicaSets : [
      {
        subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', parVirtualNetworkName, parSubnetName)
        location: parLocation
      }
    ]
    sku: parSKU
  }
  tags: parTags
}

output outADDSid string = resDomainServices.id
