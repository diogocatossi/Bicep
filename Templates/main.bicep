targetScope = 'subscription'

// ################# Parameters #####################################################################################################################################################################################################
@description('Target Subscription Name')
param parSubscriptionName string = subscription().displayName

@description('The region to deploy all resources into. DEFAULTS TO deployment().location')
param parLocation string = deployment().location

@description('3 letter customer code')
param parCustomerCode string

@description('3 letter License Model. ex.:CSP')
param parLicenseModel string

@description('Customer defined name.')
param parCustomerName string

@allowed([
  'ACC'
  'ASR'
  'BLD'
  'CFG'
  'CRP'
  'CUS'
  'DEV'
  'DMO'
  'DTA'
  'FCT'
  'GLD'
  'ITG'
  'PRD'
  'QAT'
  'RND'
  'SBX'
  'STG'
  'TRN'
  'TST'
  'UAT'
])
@description('3 Letter code from the Naming Convention 4.3 describing the environment. Ex.: Research & Development - RND. Default: PRD')
param parEnvironment string = 'PRD'

@description('Short code that would describe the product/technology/identifier that this environment. Ex.: ITWOFM, PDM')
param parProductCode string

@description('Defines if Azure Firewall should be deployed: DEFAULT: false')
param parAzFirewallEnabled bool = false

@description('Azure AD Domain Services domain name')
param parDomainName string 

@allowed([
  'Enabled'
  'Disabled'
])
@description('A flag to determine whether or not Secure LDAP is enabled or disabled. DEFAULT: Disabled')
param parSecureLDAPEnable string = 'Disabled'

@description('The certificate required to configure Secure LDAP. The parameter passed here should be a base64encoded representation of the certificate pfx file.')
param parSecureLDAPCert string = ''

@secure()
@description('The password to decrypt the provided Secure LDAP certificate pfx file.')
param parSecureLDAPCertPwd string = ''

@description('Domain user name that has permission to join VM. eg: Domain Admin')
param parDomainUserName string 

@secure()
@description('Domain user password that has permission to join VM')
param parDomainUserPassword string 

@description('Local VM admin user name')
param parVMAdminUserName string 

@secure()
@description('Local VM admin user name password')
param parVMAdminUserNamePassword string 

@description('List of email address(es) which will get email alerts from Log Analytics.')
param parActionGroupNotificationEmail string = ''

@description('List of email addresses which will get notifications from Microsoft Defender for Cloud by the configurations defined in this security contact. Separated by comma')
param parSecurityContacts string = ''

@description('The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies.')
param parKeyVaultAccessObjectID string = ''

@description('Object with Tags key pairs to be applied to all resources in module. Default: empty array')
param parTags object = {
  Environment      : parEnvironment
  SLA              : 'N/A'
  CustomerName     : parCustomerName
  CustomerShortCode: parCustomerCode
  Service          : parProductCode
  Tier             : 'coreinfra'
}

@allowed([
  true
  false
])
@description('Set Parameter to true to Opt-out of deployment telemetry DEFAULTS TO = true')
param parTelemetryOptOut bool = true


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ VARIABLES @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//################################### Global VARIABLES #################################################################################################################################
//3 Letter code from the Naming Convention describing the location. Ex.: Azure West Europe. Default: AWE
var varAzureRegion = {
  australiacentral  : 'AAC'
  australiacentral2 : 'AA2'
  australiaeast     : 'AAE'
  australiasoutheast: 'AAS'
  brazilsouth       : 'ABS'
  brazilsoutheast   : 'ABE'
  canadacentral     : 'ACT'
  canadaeast        : 'ACQ'
  eastasia          : 'AEA'
  francecentral     : 'AFC'
  francesouth       : 'AFS'
  germanynorth      : 'AGN'
  centralindia      : 'ACI'
  southindia        : 'ASI'
  westindia         : 'AWI'
  northeurope       : 'ANE'
  japaneast         : 'AJE'
  japanwest         : 'AJW'
  westeurope        : 'AWE'
  norwayeast        : 'AYE'
  norwaywest        : 'AYW'
  polandcentral     : 'APC'
  qatarcentral      : 'AQC'
  southeastasia     : 'ASA'
  southafricanorth  : 'AAN'
  southafricawest   : 'AAW'
  koreacentral      : 'AKC'
  koreasouth        : 'AKS'
  switzerlandnorth  : 'ASN'
  switzerlandwest   : 'ASW'
  uaecentral        : 'AEC'
  uaenorth          : 'AEN'
  uksouth           : 'AUS'
  ukwest            : 'AUW'
  centralus         : 'ACU'
  eastus            : 'AEU'
  eastus2           : 'AE2'
  northcentralus    : 'ANC'
  southcentralus    : 'ASU'
  westcentralus     : 'AWC'
  westus            : 'AWU'
  westus2           : 'AW2'
  westus3           : 'AW3'
  swedencentral     : 'AS?'
}

//################################### Landing Zone VARIABLES #################################################################################################################################
var varRGLandingZoneName         = 'RG-${parCustomerCode}-${parLicenseModel}-SCC-${varAzureRegion[parLocation]}-001'
var varKeyvaultName              = 'KV-${parCustomerCode}-${parLicenseModel}-${parEnvironment}-${varAzureRegion[parLocation]}-01'
var varLogAnalyticsName          = 'WS-${parCustomerCode}-${parLicenseModel}-${parEnvironment}-${varAzureRegion[parLocation]}-01'
var varHubNetworkName            = 'VNET-${parCustomerCode}-${parLicenseModel}-SCC-${varAzureRegion[parLocation]}-001'
var varHubRouteTableName         = 'RTB-${varHubNetworkName}'
var varAADDSSubnet               = 'AADNET'
var varAzBastionName             = 'BAS-${parCustomerCode}-${parLicenseModel}-${parEnvironment}-${varAzureRegion[parLocation]}-001'
var varVirtualNetworkGatewayName = 'VNG-${varHubNetworkName}'
var varAzFirewallName            = 'AFW-${parCustomerCode}-${parLicenseModel}-${parEnvironment}-${varAzureRegion[parLocation]}-001'
var varAzFirewallPoliciesName    = 'AFWP-${varAzFirewallName}'
var varRecoveryServicesVaultName = 'RV-${parCustomerCode}-${parLicenseModel}-${varAzureRegion[parLocation]}-${parEnvironment}-001'
var varAutomationAccount         = 'AUT-${parCustomerCode}-${varAzureRegion[parLocation]}-${parEnvironment}-001'
//var varBackupPolicyNameStorage   = 'ABP-${parCustomerCode}-${parLicenseModel}-${varAzureRegion[parLocation]}-${parEnvironment}-STO-01'
var varBackupPolicyNameVM        = 'ABP-${parCustomerCode}-${parLicenseModel}-${varAzureRegion[parLocation]}-${parEnvironment}-VML-01'
var varBackupPolicyNameSQL       = 'ABP-${parCustomerCode}-${parLicenseModel}-${varAzureRegion[parLocation]}-${parEnvironment}-SQL-01'
var varLogRetentionDays          = 365
var varStorageAccountSCC         = replace('sto${toLower(parCustomerCode)}${toLower(varAzureRegion[parLocation])}sccdtzrs001', '-', '')
var varStorageAccountSCCSubnets  = ['MGTNET']
var varDNSIPs                    = ['10.50.3.68','10.50.3.69']

//################################### PDM PRD VARIABLES ######################################################################################################################################
var varRGPRD                 = 'RG-${parCustomerCode}-${parLicenseModel}-${parProductCode}-${parEnvironment}-${varAzureRegion[parLocation]}-001'
var varVNETSpokePRD          = 'VNET-${parCustomerCode}-${parLicenseModel}-${parEnvironment}-${varAzureRegion[parLocation]}-001'
var varStorageAccountPRD     = replace('sto${toLower(parCustomerCode)}${toLower(varAzureRegion[parLocation])}${toLower(parEnvironment)}dtzrs001', '-', '')
var varStorageSubnets        = ['${parProductCode}NET']
var varStorageFileShareList  = ['${parProductCode}']
var varStorageFileShareQuota = 5120
//var varSQLServerName         = 'SQL-${parCustomerCode}-${parProductCode}-${varAzureRegion[parLocation]}-001'
//var varSQLSubnets            = ['${parProductCode}NET']

var varVirtualMachines = [
  {
    // Management VM
    parVirtualMachineName        : '${parCustomerCode}MGT${parEnvironment}${varAzureRegion[parLocation]}001'
    parResourceGroup             : varRGLandingZoneName
    parLocation                  : parLocation
    parVMSize                    : 'Standard_B2ms'
    parVirtualNetworkName        : varHubNetworkName
    parSubnetName                : 'MGTNET'
    parDomainToJoin              : parDomainName
    parDomainUsername            : parDomainUserName
    parDomainUserPassword        : parDomainUserPassword
    parOUPath                    : ''
    parBootDiagStorageAccountName: varStorageAccountSCC
    parAdminUsername             : parVMAdminUserName
    parAdminPassword             : parVMAdminUserNamePassword
    parDeployPublicIP            : false
    parDataDisks                 : [500]
    parImagePublisher            : 'MicrosoftWindowsServer'
    parImageOffer                : 'WindowsServer'
    parSKU                       : '2022-Datacenter'
    parZones                     : [1]
    parRecoveryServicesVaultName : varRecoveryServicesVaultName
    parBackupPolicyName          : varBackupPolicyNameVM
    parLogAnalyticsWorkspaceName : varLogAnalyticsName
    parTags                      : parTags
  }
  {
    //PDM PRD Server
    parVirtualMachineName        : '${parCustomerCode}${parProductCode}${parEnvironment}${varAzureRegion[parLocation]}001'
    parResourceGroup             : varRGPRD
    parLocation                  : parLocation
    parVMSize                    : 'Standard_D4s_v5'
    parVirtualNetworkName        : varVNETSpokePRD
    parSubnetName                : '${parProductCode}NET'
    parDomainToJoin              : parDomainName
    parDomainUsername            : parDomainUserName
    parDomainUserPassword        : parDomainUserPassword
    parOUPath                    : ''
    parBootDiagStorageAccountName: varStorageAccountPRD
    parAdminUsername             : parVMAdminUserName
    parAdminPassword             : parVMAdminUserNamePassword
    parDeployPublicIP            : false
    parDataDisks                 : [500]
    parImagePublisher            : 'MicrosoftWindowsServer'
    parImageOffer                : 'WindowsServer'
    parSKU                       : '2022-Datacenter'
    parZones                     : [1]
    parRecoveryServicesVaultName : varRecoveryServicesVaultName
    parBackupPolicyName          : varBackupPolicyNameVM
    parLogAnalyticsWorkspaceName : varLogAnalyticsName
    parTags                      : parTags
  }
  {
    //PDM SQL Server
    parVirtualMachineName        : '${parCustomerCode}SQL${parEnvironment}${varAzureRegion[parLocation]}001'
    parResourceGroup             : varRGPRD
    parLocation                  : parLocation
    parVMSize                    : 'Standard_D4s_v5'
    parVirtualNetworkName        : varVNETSpokePRD
    parSubnetName                : 'CDTNET'
    parDomainToJoin              : parDomainName
    parDomainUsername            : parDomainUserName
    parDomainUserPassword        : parDomainUserPassword
    parOUPath                    : ''
    parBootDiagStorageAccountName: varStorageAccountPRD
    parAdminUsername             : parVMAdminUserName
    parAdminPassword             : parVMAdminUserNamePassword
    parDeployPublicIP            : false
    parDataDisks                 : [200]
    parImagePublisher            : 'MicrosoftSQLServer'
    parImageOffer                : 'SQL2019-WS2022'
    parSKU                       : 'Standard'
    parZones                     : [1]
    parRecoveryServicesVaultName : varRecoveryServicesVaultName
    parBackupPolicyName          : varBackupPolicyNameVM
    parLogAnalyticsWorkspaceName : varLogAnalyticsName
    parTags                      : parTags
  }
]

var varLocalNetworksArray = [
  {
    LNGName         : 'LNG-OnPrem-JouleIreland'
    connectionName  : 'CON-LNG-OnPrem-JouleHQ'
    addressPrefixes : ['192.168.16.0/23']
    gatewayIpAddress: '185.32.152.147'
    location        : parLocation
    preSharedKey    : 'pLRa0AW52YBPWuduDtqi2gqOGeqBs8bLbp8INlP4urwBTTHZA1ZjXNdChGVmKBNy'
    IPSecPolicies   : {}
  }
  {
    LNGName         : 'LNG-OnPrem-Inventum'
    connectionName  : 'CON-LNG-OnPrem-Inventum'
    addressPrefixes : ['10.10.8.0/22','10.20.0.0/16']
    gatewayIpAddress: '159.100.64.100'
    location        : parLocation
    preSharedKey    : 'XlpwJxo0s594WSnvf9eDhAGOuYvxhQ0Os9fOp4F6xcu4klgjdLH45U2583yTogMg'
    IPSecPolicies   : {
      dhGroup            : 'DHGroup14'
      ikeEncryption      : 'AES256'
      ikeIntegrity       : 'SHA256'
      ipsecEncryption    : 'AES256'
      ipsecIntegrity     : 'SHA256'
      saDataSizeKilobytes: 102400000
      saLifeTimeSeconds  : 27000
    }
  }
]


//Hub network CIDR address space in the format N.N.N.0/NN
//Used also in NSGs:
var varHubCIDR                   = '10.50.0.0/22'
var varHubCIDRprefix             = '${split(varHubCIDR,'.')[0]}.${split(varHubCIDR,'.')[1]}'
var varHubCIDRAADNET             = '${varHubCIDRprefix}.3.64/26'
var varHubCIDRAzureBastionSubnet = '${varHubCIDRprefix}.3.128/26'
var varHubCIDRGatewaySubnet      = '${varHubCIDRprefix}.3.224/27'

//Array of objects containing the subnets that will be deployed to the Hub/Landing Zone VNET
/* Service Endpoint list: https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview */
var varHubSubnets = [
  {
    name            : 'AADNET'
    ipAddressRange  : varHubCIDRAADNET
    serviceEndpoints: [
      {
        service  : 'Microsoft.AzureActiveDirectory'
        locations: [parLocation]
      }
      {
        service  : 'Microsoft.KeyVault'
        locations: [parLocation]
      }
    ]
    networkSecurityGroup: 'NSG-${parCustomerCode}-${varAzureRegion[parLocation]}-AADNET-${parEnvironment}-001'
  }
  {
    name            : 'AzureBastionSubnet'
    ipAddressRange  : varHubCIDRAzureBastionSubnet
    serviceEndpoints: [
      {
        service  : 'Microsoft.KeyVault'
        locations: [parLocation]
      }
    ]
    networkSecurityGroup: 'NSG-${parCustomerCode}-${varAzureRegion[parLocation]}-BASTION-${parEnvironment}-001'
  }
  {
    name            : 'MGTNET'
    ipAddressRange  : '${varHubCIDRprefix}.3.192/27'
    serviceEndpoints: [
      {
        service  : 'Microsoft.Storage'
        locations: [parLocation]
      }
      {
        service  : 'Microsoft.AzureActiveDirectory'
        locations: [parLocation]
      }
      {
        service  : 'Microsoft.KeyVault'
        locations: [parLocation]
      }
    ]
    networkSecurityGroup: {}
  }
  {
    name                : 'GatewaySubnet'
    ipAddressRange      : varHubCIDRGatewaySubnet
    serviceEndpoints    : [
      {
        service  : 'Microsoft.KeyVault'
        locations: [parLocation]
      }
    ]
    networkSecurityGroup: {}
  }
]

//Used also in NSGs:
var varSpokePRDCIDR       = '10.50.4.0/22'
var varSpokePRDPrefix     = '${split(varSpokePRDCIDR,'.')[0]}.${split(varSpokePRDCIDR,'.')[1]}'
var varSpokePRDCIDRPDMNET = '${varSpokePRDPrefix}.4.0/24'
var varSpokePRDCIDRCDTNET = '${varSpokePRDPrefix}.7.192/26'

//Array of objects containing the Spoke VNETs and their definitions
/* Service Endpoint list: https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview */
var varSpokeVNETS     = [
  {
    resourceGroupName       : varRGPRD
    networkAddressPrefix    : varSpokePRDCIDR
    networkName             : varVNETSpokePRD
    nextHopIpAddress        : '' //modHubNetworking.outputs.outAzFirewallPrivateIp
    dnsServerIps            : varDNSIPs
    spokeToHubRouteTableName: 'RTB-${varVNETSpokePRD}'
    subnets                 : [
      {
        name                : 'PDMNET'
        ipAddressRange      : varSpokePRDCIDRPDMNET
        networkSecurityGroup: 'NSG-${parCustomerCode}-${varAzureRegion[parLocation]}-PDMNET-${parEnvironment}-001'
        serviceEndpoints    : [
          {
            service  : 'Microsoft.Storage'
            locations: [parLocation]
          }
          {
            service  : 'Microsoft.Sql'
            locations: [parLocation]
          }
          {
            service  : 'Microsoft.KeyVault'
            locations: [parLocation]
          }
        ]
      }
      {
        //Client Data Layer (SQL, Databases, etc.)
        name                : 'CDTNET'
        ipAddressRange      : varSpokePRDCIDRCDTNET
        networkSecurityGroup: 'NSG-${parCustomerCode}-${varAzureRegion[parLocation]}-CDTNET-${parEnvironment}-001'
        serviceEndpoints    : [
          {
            service  : 'Microsoft.Storage'
            locations: [parLocation]
          }
          {
            service  : 'Microsoft.KeyVault'
            locations: [parLocation]
          }
        ]
      }
    ]
  }
]

var varNetworkSecurityGroups =  [
  {
    name         : 'NSG-${parCustomerCode}-${varAzureRegion[parLocation]}-PDMNET-${parEnvironment}-001'
    resourceGroup: varRGPRD
    location     : parLocation
    tags         : parTags
    securityRules: [
      //############################### INBOUND Rules ######################################################################################################################
      {
        name      : 'Inbound_Archive_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Solidworks Archive server access'
          direction               : 'Inbound'
          priority                : 100
          sourceAddressPrefix     : 'VirtualNetwork'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '3030'
        }
      }
      {
        name      : 'Inbound_SQL_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'SQL Database traffic'
          direction               : 'Inbound'
          priority                : 200
          sourceAddressPrefix     : 'VirtualNetwork'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRanges   : ['1433','1434']
        }
      }
      {
        name      : 'Inbound_License_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Solidworks Licensing access'
          direction               : 'Inbound'
          priority                : 300
          sourceAddressPrefix     : 'VirtualNetwork'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRanges   : ['25734','25735']
        }
      }
      {
        name      : 'Inbound_VirtualNetwork_ADDS_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Ports required by Active Directory Domain Services'
          direction               : 'Inbound'
          priority                : 400
          sourceAddressPrefix     : varHubCIDRAADNET
          destinationAddressPrefix: '*'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRanges   : ['53','88','135','389','445','464','500','636','3268-3269','4500','49152-65535']
        }
        
      }
      {
        name      : 'Inbound_Bastion_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Bastion RDP'
          direction               : 'Inbound'
          priority                : 500
          sourceAddressPrefix     : varHubCIDRAzureBastionSubnet
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRanges   : ['3389']
        }
        
      }
      {
        name      : 'Inbound_All_Deny'
        properties: {
          access                  : 'Deny'
          description             : 'Inbound_All_Deny'
          direction               : 'Inbound'
          priority                : 4095
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: '*'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRange    : '*'
        }
      }
      //############################### OUTBOUND Rules ####################################################################################################################
      {
        name      : 'Outbound_Archive_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Solidworks Archive server access'
          direction               : 'Outbound'
          priority                : 100
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '3030'
        }
      }
      {
        name      : 'Outbound_SQL_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'SQL Database traffic'
          direction               : 'Outbound'
          priority                : 200
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRanges   : ['1433','1434']
        }
      }
      {
        name      : 'Outbound_License_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Solidwork Licensing access'
          direction               : 'Outbound'
          priority                : 300
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRanges   : ['25734','25735']
        }
      }
      {
        name      : 'Outbound_VirtualNetwork_ADDS_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Ports required by Active Directory Domain Services'
          direction               : 'Outbound'
          priority                : 400
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: varHubCIDRAADNET
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRanges   : ['53','88','135','389','445','464','500','636','3268-3269','4500','49152-65535']
        }
      }
      {
        name      : 'Outbound_All_Deny'
        properties: {
          access                  : 'Deny'
          description             : 'Outbound_All_Deny'
          direction               : 'Outbound'
          priority                : 4095
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: '*'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRange    : '*'
        }
      }
    ]
  }
  {
    name         : 'NSG-${parCustomerCode}-${varAzureRegion[parLocation]}-CDTNET-${parEnvironment}-001'
    resourceGroup: varRGPRD
    location     : parLocation
    tags         : parTags
    securityRules: [
      //############################### INBOUND Rules ######################################################################################################################
      {
        name      : 'Inbound_SQL_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'SQL Database traffic'
          direction               : 'Inbound'
          priority                : 100
          sourceAddressPrefix     : 'VirtualNetwork'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRanges   : ['1433','1434']
        }
      }
      {
        name      : 'Inbound_VirtualNetwork_ADDS_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Ports required by Active Directory Domain Services'
          direction               : 'Inbound'
          priority                : 200
          sourceAddressPrefix     : varHubCIDRAADNET
          destinationAddressPrefix: '*'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRanges   : ['53','88','135','389','445','464','500','636','3268-3269','4500','49152-65535']
        }
        
      }
      {
        name      : 'Inbound_Bastion_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Bastion RDP'
          direction               : 'Inbound'
          priority                : 300
          sourceAddressPrefix     : varHubCIDRAzureBastionSubnet
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRanges   : ['3389']
        }
        
      }
      {
        name      : 'Inbound_All_Deny'
        properties: {
          access                  : 'Deny'
          description             : 'Inbound_All_Deny'
          direction               : 'Inbound'
          priority                : 4095
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: '*'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRange    : '*'
        }
      }
      //############################### OUTBOUND Rules ####################################################################################################################
      {
        name      : 'Outbound_SQL_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'SQL Database traffic'
          direction               : 'Outbound'
          priority                : 100
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRanges   : ['1433','1434']
        }
      }
      {
        name      : 'Outbound_VirtualNetwork_ADDS_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Ports required by Active Directory Domain Services'
          direction               : 'Outbound'
          priority                : 200
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: varHubCIDRAADNET
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRanges   : ['53','88','135','389','445','464','500','636','3268-3269','4500','49152-65535']
        }
      }
      {
        name      : 'Outbound_All_Deny'
        properties: {
          access                  : 'Deny'
          description             : 'Outbound_All_Deny'
          direction               : 'Outbound'
          priority                : 4095
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: '*'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRange    : '*'
        }
      }
    ]
  }
  {
    name         : 'NSG-${parCustomerCode}-${varAzureRegion[parLocation]}-AADNET-${parEnvironment}-001'
    resourceGroup: varRGLandingZoneName
    location     : parLocation
    tags         : parTags
    securityRules: [
      //############################### INBOUND Rules ##############################
      {
        name      : 'Inbound_AAD_HTTPS_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Application traffic'
          direction               : 'Inbound'
          priority                : 100
          sourceAddressPrefix     : 'AzureActiveDirectoryDomainServices'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '443'
        }
      } 
      {
        name      : 'Inbound_AAD_WinRM_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Management traffic'
          direction               : 'Inbound'
          priority                : 200
          sourceAddressPrefix     : 'AzureActiveDirectoryDomainServices'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRanges   : ['5985','5986']
        }
      } 
      {
        name      : 'Inbound_AAD_RDP_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Remote Desktop Access from MS Secure network'
          direction               : 'Inbound'
          priority                : 300
          sourceAddressPrefix     : 'CorpNetSaw'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '3389'
        }
      } 
      {
        name      : 'Inbound_VirtualNetwork_ADDS_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Ports required by Active Directory Domain Services'
          direction               : 'Inbound'
          priority                : 400
          sourceAddressPrefix     : 'VirtualNetwork'
          destinationAddressPrefix: '*'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRanges   : ['53','88','135','389','445','464','500','636','3268-3269','4500','49152-65535']
        }
      }
      {
        name      : 'Inbound_AzureLoadBalancer_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Required for AD Load Balancer'
          direction               : 'Inbound'
          priority                : 500
          sourceAddressPrefix     : 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '*'
        }
      }
      {
        name      : 'Inbound_All_Deny'
        properties: {
          access                  : 'Deny'
          description             : 'Deny_All_Inbound'
          direction               : 'Inbound'
          priority                : 4095
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: '*'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRange    : '*'
        }
      }
      //############################### OUTBOUND Rules ##############################
      {
        name      : 'Outbound_AAD_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Allow_AzAADDS_Outbound'
          direction               : 'Outbound'
          priority                : 100
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: 'AzureActiveDirectoryDomainServices'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '*'
        }
      }
      {
        name      : 'Outbound_Storage_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Allow_AzStorage_Outbound'
          direction               : 'Outbound'
          priority                : 200
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: 'Storage'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '*'
        }
      }
      {
        name      : 'Outbound_VirtualNetwork_ADDS_Allow'
        properties: {
          access                  : 'Allow'
          description             : 'Ports required by Active Directory Domain Services'
          direction               : 'Outbound'
          priority                : 300
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRanges   : ['53','88','135','389','445','464','500','636','3268-3269','4500','49152-65535']
        }
      }
    ]
  }
  {
    name         : 'NSG-${parCustomerCode}-${varAzureRegion[parLocation]}-BASTION-${parEnvironment}-001'
    resourceGroup: varRGLandingZoneName
    location     : parLocation
    tags         : parTags
    securityRules: [
      //############################### INBOUND Rules ##############################
      {
        name      : 'AllowHttpsInbound'
        properties: {
          access                  : 'Allow'
          direction               : 'Inbound'
          priority                : 100
          sourceAddressPrefix     : 'Internet'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '443'
        }
      }
      {
        name      : 'AllowGatewayManagerInbound'
        properties: {
          access                  : 'Allow'
          direction               : 'Inbound'
          priority                : 200
          sourceAddressPrefix     : 'GatewayManager'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '443'
        }
      }
      {
        name      : 'AllowAzureLoadBalancerInbound'
        properties: {
          access                  : 'Allow'
          direction               : 'Inbound'
          priority                : 300
          sourceAddressPrefix     : 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '443'
        }
      }
      {
        name      : 'AllowBastionHostCommunication'
        properties: {
          access                  : 'Allow'
          direction               : 'Inbound'
          priority                : 400
          sourceAddressPrefix     : 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRanges   : ['8080','5701']
        }
      }
      {
        name      : 'Inbound_All_Deny'
        properties: {
          access                  : 'Deny'
          description             : 'Deny_All_Inbound'
          direction               : 'Inbound'
          priority                : 4095
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: '*'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRange    : '*'
        }
      }
      //############################### OUTBOUND Rules ##############################
      {
        name      : 'AllowSshRDPOutbound'
        properties: {
          access                  : 'Allow'
          direction               : 'Outbound'
          priority                : 100
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRanges   : ['22','3389']
        }
      }
      {
        name      : 'AllowAzureCloudOutbound'
        properties: {
          access                  : 'Allow'
          direction               : 'Outbound'
          priority                : 200
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: 'AzureCloud'
          protocol                : 'Tcp'
          sourcePortRange         : '*'
          destinationPortRange    : '443'
        }
      }
      {
        name      : 'AllowBastionCommunication'
        properties: {
          access                  : 'Allow'
          direction               : 'Outbound'
          priority                : 300
          sourceAddressPrefix     : 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRanges    : ['8080','5701']
        }
      }
      {
        name      : 'AllowGetSessionInformation'
        properties: {
          access                  : 'Allow'
          direction               : 'Outbound'
          priority                : 400
          sourceAddressPrefix     : '*'
          destinationAddressPrefix: 'Internet'
          protocol                : '*'
          sourcePortRange         : '*'
          destinationPortRange    : '80'
        }
      }
    ]
  }
  
]

var varAlertRules = [
  {
    parAlertRuleName            : 'Antimalware Alert'
    parAlertRuleDisplayName     : 'Antimalware Alert'
    parAlertRuleDescription     : 'The Antimalware has detected something, please investigate'
    parAlertRuleSeverity        : 0
    parEvaluationFrequencyMin   : 5
    parWindowSize               : 5
    parQuery                    : 'ProtectionStatus\n| where ThreatStatusRank  in("550","350","370","330")\n'
    parAgregation               : 'Count'
    parMetricMeasureColumn      : ''
    parDimensions               : []
    parOperator                 : 'GreaterThan'
    parThreshold                : 0
    parNumberOfEvaluationPeriods: 1
    parMinFailingPeriodsToAlert : 1
    parMuteActionsDurationHours : 0
  }
  {
    parAlertRuleName            : 'Antimalware signatures out of date'
    parAlertRuleDisplayName     : 'Antimalware signatures out of date'
    parAlertRuleDescription     : 'Please update the Antimalware signature'
    parAlertRuleSeverity        : 1
    parEvaluationFrequencyMin   : 5
    parWindowSize               : 5
    parQuery                    : 'ProtectionStatus\n| summarize Rank = max(ProtectionStatusRank) by Computer\n| where Rank == "250"\n\n'
    parAgregation               : 'Count'
    parMetricMeasureColumn      : ''
    parDimensions               : []
    parOperator                 : 'GreaterThan'
    parThreshold                : 0
    parNumberOfEvaluationPeriods: 1
    parMinFailingPeriodsToAlert : 1
    parMuteActionsDurationHours : 0
  }
  {
    parAlertRuleName            : 'CPU Alert'
    parAlertRuleDisplayName     : 'CPU Alert'
    parAlertRuleDescription     : 'Alert is fired when CPU is over 90%'
    parAlertRuleSeverity        : 1
    parEvaluationFrequencyMin   : 5
    parWindowSize               : 0
    parQuery                    : 'Perf | where ObjectName == "Processor" or ObjectName == "Processor Information" and CounterName == "% Processor Time" and InstanceName == "_Total" | summarize AggregatedValue = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)'
    parAgregation               : 'Average'
    parMetricMeasureColumn      : 'AggregatedValue'
    parDimensions               : []
    parOperator                 : 'GreaterThan'
    parThreshold                : 90
    parNumberOfEvaluationPeriods: 2
    parMinFailingPeriodsToAlert : 2
    parMuteActionsDurationHours : 1
  }
  {
    parAlertRuleName            : 'Heartbeat Alert'
    parAlertRuleDisplayName     : 'Heartbeat Alert'
    parAlertRuleDescription     : 'Alert is fired when Heartbeat is missed for more than 10 mins'
    parAlertRuleSeverity        : 0
    parEvaluationFrequencyMin   : 5
    parWindowSize               : 60
    parQuery                    : 'Perf | where ObjectName == "Processor" or ObjectName == "Processor Information" and CounterName == "% Processor Time" and InstanceName == "_Total" | summarize AggregatedValue = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)'
    parAgregation               : 'Average'
    parMetricMeasureColumn      : 'AggregatedValue'
    parDimensions               : []
    parOperator                 : 'GreaterThan'
    parThreshold                : 90
    parNumberOfEvaluationPeriods: 2
    parMinFailingPeriodsToAlert : 2
    parMuteActionsDurationHours : 1
  }
  {
    parAlertRuleName            : 'LogicalDisk Free Space Alert'
    parAlertRuleDisplayName     : 'LogicalDisk Free Space Alert'
    parAlertRuleDescription     : 'Alert is fired when LogicalDisk free space is below 10%'
    parAlertRuleSeverity        : 1
    parEvaluationFrequencyMin   : 5
    parWindowSize               : 0
    parQuery                    : 'Perf | where ObjectName == "LogicalDisk" or ObjectName == "Logical Disk" | where CounterName == "% Free Space" | where InstanceName <> "_Total" and InstanceName  !contains "HarddiskVolume" and InstanceName != "//mnt" and InstanceName !contains "//boot"| extend ComputerDrive = strcat(Computer, \' - \',InstanceName) | summarize AggregatedValue = avg(CounterValue) by ComputerDrive, bin(TimeGenerated, 15m)'
    parAgregation               : 'Average'
    parMetricMeasureColumn      : 'AggregatedValue'
    parDimensions               : [
                                    {
                                      name    : 'ComputerDrive'
                                      operator: 'Include'
                                      values  : ['*']
                                    }
                                  ]
    parOperator                 : 'LessThan'
    parThreshold                : 10
    parNumberOfEvaluationPeriods: 3
    parMinFailingPeriodsToAlert : 3
    parMuteActionsDurationHours : 1
  }
  {
    parAlertRuleName            : 'Memory Alert'
    parAlertRuleDisplayName     : 'Memory Alert'
    parAlertRuleDescription     : 'Memory over 90%'
    parAlertRuleSeverity        : 1
    parEvaluationFrequencyMin   : 5
    parWindowSize               : 0
    parQuery                    : 'Perf | where ObjectName == "Memory" and CounterName == "% Committed Bytes In Use" or CounterName == "% Used Memory"  | summarize AggregatedValue = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)'
    parAgregation               : 'Average'
    parMetricMeasureColumn      : 'AggregatedValue'
    parDimensions               : []
    parOperator                 : 'GreaterThan'
    parThreshold                : 90
    parNumberOfEvaluationPeriods: 2
    parMinFailingPeriodsToAlert : 2
    parMuteActionsDurationHours : 1
  }
]


//################################### Orchestration Module Variables##########################################################################################################################
var varDeploymentNameWrappers = {
  basePrefix               : '${parCustomerCode}-${parProductCode}'
  baseSuffixManagementGroup: 'MG-${uniqueString(parCustomerCode,parLicenseModel,parEnvironment,varAzureRegion[parLocation])}'
  baseSuffixSubscription   : 'SUB-${uniqueString(parCustomerCode,parLicenseModel,parEnvironment,varAzureRegion[parLocation])}'
  baseSuffixResourceGroup  : 'RG-${uniqueString(parCustomerCode,parLicenseModel,parEnvironment,varAzureRegion[parLocation])}'
}

var varModuleDeploymentNames = {
  modAADDS                : take('${varDeploymentNameWrappers.basePrefix}-modAADDS-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modConnection           : take('${varDeploymentNameWrappers.basePrefix}-modConneciton-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modBackupPolicyVM       : take('${varDeploymentNameWrappers.basePrefix}-modBackupPolicyVM-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modBackupPolicySQL      : take('${varDeploymentNameWrappers.basePrefix}-modBackupPolicySQL-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modCustomPolicy         : take('${varDeploymentNameWrappers.basePrefix}-modCustomPolicy-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modKeyVault             : take('${varDeploymentNameWrappers.basePrefix}-modKeyvault-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modLogAnalytics         : take('${varDeploymentNameWrappers.basePrefix}-modLogAnalytics-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modLocalNetworkGateway  : take('${varDeploymentNameWrappers.basePrefix}-modLocalNetworkGateway-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modNetworkSecurityGroup : take('${varDeploymentNameWrappers.basePrefix}-modNetworkSecurityGroup-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modNetworkingHub        : take('${varDeploymentNameWrappers.basePrefix}-modNetworkingHub-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modNetworkingHubSubnets : take('${varDeploymentNameWrappers.basePrefix}-modNetworkingHubSubnets-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modNetworkingSpoke      : take('${varDeploymentNameWrappers.basePrefix}-modNetworkingSpoke-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modPolicyAssignments    : take('${varDeploymentNameWrappers.basePrefix}-modPolicyAssignments-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modPrivateDNSZones      : take('${varDeploymentNameWrappers.basePrefix}-modPrivateDNSZones-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modRecoveryServicesVault: take('${varDeploymentNameWrappers.basePrefix}-modRecoveryServicesVault-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modResourceGroup        : take('${varDeploymentNameWrappers.basePrefix}-modResourceGroup-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modSecurityCenter       : take('${varDeploymentNameWrappers.basePrefix}-modSecurityCenter-${varDeploymentNameWrappers.baseSuffixSubscription}', 64)
  modSQL                  : take('${varDeploymentNameWrappers.basePrefix}-modSQL-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modSpokePeeringToHub    : take('${varDeploymentNameWrappers.basePrefix}-modVnetPeering-ToHub-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modSpokePeeringFromHub  : take('${varDeploymentNameWrappers.basePrefix}-modVnetPeering-FromHub-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modStorageAccount       : take('${varDeploymentNameWrappers.basePrefix}-modStorageAccount-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
  modVirtualMachine       : take('${varDeploymentNameWrappers.basePrefix}-modVirtualMachine-${varDeploymentNameWrappers.baseSuffixResourceGroup}', 64)
}


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ RESOURCES @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//The recommendation is to create the raw ResourceGroup in the "main" bicep so it can be used as scope for the modules and allowing it to create the dependency
resource resALZResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: parLocation
  name    : varRGLandingZoneName
  tags    : parTags
}

resource resRGPRD 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: parLocation
  name    : varRGPRD
  tags    : parTags
}



  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ MODULES @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  /* module modCustomPolicyDefinitions 'modules/policySubscription/definitions/customPolicyDefinitions.bicep' = {
  name  : varModuleDeploymentNames.modCustomPolicy
  scope : subscription()
  params: {
    parTargetSubscriptionId: subscription().id
  }
} */

module modLogAnalytics 'modules/logging/logging.bicep' = {
  name  : varModuleDeploymentNames.modLogAnalytics
  scope : resALZResourceGroup
  params: {
    parLogAnalyticsWorkspaceName              : varLogAnalyticsName
    parLogAnalyticsWorkspaceLocation          : parLocation
    parLogAnalyticsWorkspaceLogRetentionInDays: varLogRetentionDays
    parLogAnalyticsWorkspaceSkuName           : 'PerGB2018'
    parLogAnalyticsWorkspaceTags              : parTags
    parAutomationAccountName                  : varAutomationAccount
    parAutomationAccountLocation              : parLocation
    parTelemetryOptOut                        : parTelemetryOptOut
    parActionGroupNotificationEmail           : parActionGroupNotificationEmail
    parAlertRules                             : varAlertRules 
  }
}


//################################### NETWORKING ###################################################
module modNSG 'modules/networkSecurityGroup/networkSecurityGroup.bicep' = [for (nsg, i) in varNetworkSecurityGroups:  {
  name  : '${varModuleDeploymentNames.modNetworkSecurityGroup}-${padLeft(i,2,'0')}'
  scope : resourceGroup(nsg.resourceGroup)
  params: {
    parNSGName      : nsg.name
    parLocation     : nsg.location
    parSecurityRules: nsg.securityRules
    parTags         : nsg.tags
  }
  dependsOn:[resRGPRD,resALZResourceGroup]
}]

module modHubNetworking 'modules/virtualNetworks/hubNetworking.bicep' = {
  name  : varModuleDeploymentNames.modNetworkingHub
  scope : resALZResourceGroup
  params: {
    parLocation              : parLocation
    parCompanyPrefix         : parSubscriptionName
    parHubNetworkName        : varHubNetworkName
    parAzBastionEnabled      : true
    parAzBastionName         : varAzBastionName
    parAzBastionSku          : 'Basic'
    parPublicIpSku           : 'Standard'
    parDdosEnabled           : false
    parAzFirewallEnabled     : parAzFirewallEnabled
    parAzFirewallName        : varAzFirewallName
    parAzFirewallPoliciesName: varAzFirewallPoliciesName
    parAzFirewallTier        : 'Standard'
    parHubRouteTableName     : varHubRouteTableName
    parDnsServerIps          : varDNSIPs
    parVpnGatewayConfig      : {
                                  name                           : varVirtualNetworkGatewayName
                                  gatewayType                    : 'Vpn'
                                  sku                            : 'VpnGw1'
                                  vpnType                        : 'RouteBased'
                                  generation                     : 'Generation1'
                                  enableBgp                      : false
                                  activeActive                   : false
                                  enableBgpRouteTranslationForNat: false
                                  enableDnsForwarding            : false
                                  asn                            : 65515
                                  bgpPeeringAddress              : ''
                                  bgpsettings                    : {
                                    asn              : 65515
                                    bgpPeeringAddress: ''
                                    peerWeight       : 5
                                  }
                                }
    parExpressRouteGatewayConfig: {}
    parTags                     : parTags
    parTelemetryOptOut          : parTelemetryOptOut
    parHubNetworkAddressPrefix  : varHubCIDR
    parSubnets                  : varHubSubnets
  }
  dependsOn: [modNSG]
}

module modlocalNetworkGateway 'modules/localNetworkGateway/localNetworkGateway.bicep' = [for (localNetwork, index) in varLocalNetworksArray: {
    name  : '${varModuleDeploymentNames.modLocalNetworkGateway}-${index}'
    scope : resALZResourceGroup
    params: {
      parLocalNetworkGatewayName: localNetwork.LNGName
      parAddressPrefixes        : localNetwork.addressPrefixes
      parGatewayIpAddress       : localNetwork.gatewayIpAddress
      parLocation               : localNetwork.location
      parTags                   : parTags
    }
    dependsOn:[modHubNetworking]
}]


module modConnection 'modules/localNetworkGateway/connection.bicep' = [for (localNetwork, index) in varLocalNetworksArray: {
  name  : '${varModuleDeploymentNames.modConnection}-${index}'
  scope : resALZResourceGroup
  params: {
    parConnectionName           : localNetwork.connectionName
    parConnectionType           : 'IPsec'
    parConnectionProtocol       : 'IKEv2'
    parEnableBgp                : false
    parLocalNetworkGatewayName  : localNetwork.LNGName
    parLocation                 : localNetwork.location
    parSharedKey                : localNetwork.preSharedKey
    parVirtualNetworkGatewayName: varVirtualNetworkGatewayName
    parIPSecPolicies            : localNetwork.IPSecPolicies
    parTags                     : parTags
  }
  dependsOn: [modlocalNetworkGateway]
}]


module modSpokeNetworking 'modules/spokeNetworking/spokeNetworking.bicep' = [for (spoke, index) in varSpokeVNETS : {
  name  : '${varModuleDeploymentNames.modNetworkingSpoke}-${index}'
  scope : resourceGroup(spoke.resourceGroupName)
  params: {
    parLocation                 : parLocation
    parSpokeNetworkName         : spoke.networkName
    parSpokeNetworkAddressPrefix: spoke.networkAddressPrefix
    parNextHopIpAddress         : parAzFirewallEnabled ? modHubNetworking.outputs.outAzFirewallPrivateIp: ''
    parDnsServerIps             : spoke.dnsServerIps
    parSpokeToHubRouteTableName : spoke.spokeToHubRouteTableName
    parSpokeSubnets             : spoke.subnets
    parTags                     : parTags
    parTelemetryOptOut          : parTelemetryOptOut
  }
  dependsOn: [modNSG]
}]

module modVnetPeeringHubToSpoke 'modules/vnetPeering/vnetPeering.bicep' = [for i in range(0,length(varSpokeVNETS)) : {
  name  : '${varModuleDeploymentNames.modSpokePeeringFromHub}-${padLeft(i,2,'0')}'
  scope : resALZResourceGroup
  params: {
    parSourceVirtualNetworkName     : modHubNetworking.outputs.outHubVirtualNetworkName
    parDestinationVirtualNetworkName: modSpokeNetworking[i].outputs.outSpokeVirtualNetworkName
    parDestinationVirtualNetworkId  : modSpokeNetworking[i].outputs.outSpokeVirtualNetworkId
    parAllowVirtualNetworkAccess    : true
    parAllowForwardedTraffic        : true
    parAllowGatewayTransit          : true
    parUseRemoteGateways            : false
    parTelemetryOptOut              : parTelemetryOptOut
  }
}]

module modVnetPeeringSpokeToHub 'modules/vnetPeering/vnetPeering.bicep' = [for i in range(0,length(varSpokeVNETS)) : {
  name  : '${varModuleDeploymentNames.modSpokePeeringToHub}-${padLeft(i,2,'0')}'
  scope : resourceGroup(varSpokeVNETS[i].resourceGroupName)
  params: {
    parSourceVirtualNetworkName     : modSpokeNetworking[i].outputs.outSpokeVirtualNetworkName
    parDestinationVirtualNetworkName: modHubNetworking.outputs.outHubVirtualNetworkName
    parDestinationVirtualNetworkId  : modHubNetworking.outputs.outHubVirtualNetworkId
    parAllowVirtualNetworkAccess    : true
    parAllowForwardedTraffic        : true
    parAllowGatewayTransit          : true
    parUseRemoteGateways            : true //allow on-premisses network access
    parTelemetryOptOut              : parTelemetryOptOut
  }
}]

module modPrivateDNSZones 'modules/privateDnsZones/privateDnsZones.bicep' = {
  name  : varModuleDeploymentNames.modPrivateDNSZones
  scope : resALZResourceGroup
  params: {
    parLocation              : parLocation
    parVirtualNetworkIdToLink: modHubNetworking.outputs.outHubVirtualNetworkId
    parTelemetryOptOut       : parTelemetryOptOut
  }
}

module modKeyVault  'modules/keyVault/keyvault.bicep' = {
  name  : varModuleDeploymentNames.modKeyVault
  scope : resALZResourceGroup
  params: {
    parName                        : varKeyvaultName
    parLocation                    : parLocation
    parSKU                         : 'standard'
    parObjectID                    : parKeyVaultAccessObjectID
    parRecoverMode                 : false
    parPublicNetworkAccess         : 'enabled'
    parAzureServicesBypass         : true
    parNetworkDefaultAction        : 'Deny'
    parVNETName                    : modHubNetworking.outputs.outHubVirtualNetworkName
    parAllowedVNETSubnets          : modHubNetworking.outputs.outSubnets
    parAllowedIPRange              : [
      '40.74.28.0/23' //Azure Devops West Europe
      '4.233.0.0/16' //Azure DevOps Agent Pool - Azure France
      '108.142.0.0/15' //Azure DevOps Agent Pool - West Europe
      '13.94.64.0/18' //Azure DevOps Agent Pool - AzureCloud.northeurope 
    ]
    parEnabledForDeployment        : true
    parEnabledForDiskEncryption    : true
    parEnabledForTemplateDeployment: true
    parEnablePurgeProtection       : true
    parEnableRbacAuthorization     : true
    parEnableSoftDelete            : true
    parSoftDeleteRetentionInDays   : 7
    parTags                        : parTags
    parTelemetryOptOut             : true
  }
  dependsOn: []
}

//################################### STORAGE ACCOUNT ###################################################
module modStorageAccountSCC 'modules/storageAccount/storageAccount.bicep' = {
  name  : '${varModuleDeploymentNames.modStorageAccount}-SCC'
  scope : resALZResourceGroup
  params: {
    parStorageName        : varStorageAccountSCC
    parLocation           : parLocation
    parStorageSkuName     : 'Standard_LRS'
    parStorageKind        : 'StorageV2'
    parAccessTier         : 'Hot'
    parPublicNetworkAccess: 'Enabled'
    parVirtualNetworkName : varHubNetworkName
    parSubnetNames        : varStorageAccountSCCSubnets
    parTags               : parTags
  }
  dependsOn: [
    modSpokeNetworking
  ]
}

//TODO: Move module to PRD Resource Group Bicep
module modStorageAccountPRD 'modules/storageAccount/storageAccount.bicep' = {
  name  : '${varModuleDeploymentNames.modStorageAccount}-PRD'
  scope : resRGPRD
  params: {
    parStorageName        : varStorageAccountPRD
    parLocation           : parLocation
    parStorageSkuName     : 'Standard_GRS'
    parStorageKind        : 'StorageV2'
    parAccessTier         : 'Hot'
    parPublicNetworkAccess: 'Enabled'
    parVirtualNetworkName : varVNETSpokePRD
    parSubnetNames        : varStorageSubnets
    parFileShareList      : varStorageFileShareList
    parFileAccessTier     : 'TransactionOptimized'
    parFileShareQuota     : varStorageFileShareQuota
    parTags               : parTags
  }
  dependsOn: [
    modSpokeNetworking
  ]
}

//################################### Azure AD DS ###################################################
module modAzureADDS 'modules/azureADDS/azureADDomainServices.bicep' = {
  name  : varModuleDeploymentNames.modAADDS
  scope : resALZResourceGroup
  params: {
    parDomainName             : parDomainName
    parLocation               : parLocation
    parDomainConfigurationType: 'FullySynced'
    parFilteredSync           : 'Disabled'
    parSyncScope              : 'All'
    parSKU                    : 'Standard'
    parNTLMV1                 : 'Disabled'
    parTLSV1                  : 'Disabled'
    parKerberosRC4            : 'Enabled'
    parVirtualNetworkName     : modHubNetworking.outputs.outHubVirtualNetworkName
    parSubnetName             : varAADDSSubnet
    parSecureLDAPEnable       : parSecureLDAPEnable
    parSecureLDAPCert         : parSecureLDAPCert
    parSecureLDAPCertPwd      : parSecureLDAPCertPwd
    parTags                   : parTags
  }
}

//################################### BACKUP / RECOVERY SERVICES ###################################################
module modRSV 'modules/backup/recoveryservicesvault.bicep' = {
  name  : varModuleDeploymentNames.modRecoveryServicesVault
  scope : resALZResourceGroup
  params: {
    parVaultName                   : varRecoveryServicesVaultName
    parLocation                    : parLocation
    parDataDeduplication           : 'Enabled'
    parDiagnosticStorageAccountName: modStorageAccountSCC.outputs.storageName
    parEnableDiagnostics           : true
    parEnableCrossRegionRestore    : true
    parLogAnalyticsWorkspaceName   : modLogAnalytics.outputs.outLogAnalyticsWorkspaceName
    parVaultStorageType            : 'ZoneRedundant'
    parAlertsForAllJobFailures     : 'Enabled'
    parPublicNetworkAccess         : 'Enabled'
    parTags                        : parTags
  }
}

module modBackupPolicyVM 'modules/backup/backupPolicies-AzureIaasVM.bicep' = {
  name  : varModuleDeploymentNames.modBackupPolicyVM
  scope : resALZResourceGroup
  params: {
    parBackupPolicyName                : varBackupPolicyNameVM
    parRSVaultName                     : modRSV.outputs.name
    parBackupTime                      : '03:00:00'
    parDailyBackupPointRetentionDays   : 30
    parInstantRestorePointRetentionDays: 2
    parTimeZone                        : 'W. Europe Standard Time'
    parLocation                        : parLocation
    parTags                            : parTags
  }
  
}

module modBackupPolicySQL 'modules/backup/backupPolicies-AzureSql.bicep' = {
  name  : varModuleDeploymentNames.modBackupPolicySQL
  scope : resALZResourceGroup
  params: {
    parBackupPolicyName                : varBackupPolicyNameSQL
    parRSVaultName                     : modRSV.outputs.name
    parDailyBackupPointRetentionDays   : 30
    parLogBackupPointRetentionDays     : 15
    parBackupTime                      : '03:00'
    parTimeZone                        : 'W. Europe Standard Time'
    parLocation                        : parLocation
    parTags                            : parTags
  }
}


//################################### SECURITY ###################################################
module modSecurityCenter 'modules/security/securityCenter.bicep' = {
  name  : varModuleDeploymentNames.modSecurityCenter
  scope : subscription()
  params: {
    parEnableSecurityCenterFor: [
      'Dns'
      'KeyVaults'
      'SqlServerVirtualMachines'
      'SqlServers'
      'StorageAccounts'
      'VirtualMachines'
    ]
    parMinimalSeverity : 'Low'
    parSecurityContacts: parSecurityContacts
    parTier            : 'Free'
  }
}


//TODO: Move to sub-module that will deploy resources for each Resource Group
//################################### Virtual Machines ###################################################
module modVirtualMachine 'modules/virtualMachine/virtualMachine.bicep' = [for (vm, i) in varVirtualMachines : {
  name  : '${varModuleDeploymentNames.modVirtualMachine}-${padLeft(i,2,'0')}'
  scope : resourceGroup(vm.parResourceGroup)
  params: {
    parVirtualMachineName        : vm.parVirtualMachineName
    parLocation                  : vm.parLocation
    parVMSize                    : vm.parVMSize
    parVirtualNetworkName        : vm.parVirtualNetworkName
    parSubnetName                : vm.parSubnetName
    parDomainToJoin              : vm.parDomainToJoin
    parDomainUsername            : vm.parDomainUsername
    parDomainPassword            : vm.parDomainUserPassword
    parOUPath                    : vm.parOUPath
    parBootDiagStorageAccountName: vm.parBootDiagStorageAccountName
    parAdminUsername             : vm.parAdminUsername
    parAdminPassword             : vm.parAdminPassword
    parDeployPublicIP            : vm.parDeployPublicIP
    parDataDisks                 : vm.parDataDisks
    parImageOffer                : vm.parImageOffer
    parImagePublisher            : vm.parImagePublisher
    parSKU                       : vm.parSKU
    parZones                     : vm.parZones
    parRecoveryServicesVaultName : modRSV.outputs.name
    parRecoveryServicesVaultRG   : resALZResourceGroup.name
    parBackupPolicyName          : vm.parBackupPolicyName
    parLogAnalyticsWorkspaceId   : modLogAnalytics.outputs.outLogAnalyticsCustomerId
    parTags                      : vm.parTags
    parTelemetryOptOut           : true
  }
  dependsOn: [
    modSpokeNetworking
  ]
}]

//################################### DATABASE ###################################################
// Removed per client request on 2023-03-10 and converted to SQL on a VM as product didn't support Azure SQL PaaS

