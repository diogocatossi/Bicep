targetScope = 'resourceGroup'

@description('Function App Name')
param parName string

@description('The type of the App Service. Possible values are Code and Container. DEFAULTS TO: Code.')
@allowed([
  'Code'
  'Container'
])
param parAppType string

@description('When creating a function app, you must create or link to a general-purpose Azure Storage account that supports Blobs, Queue, and Table storage. This is used to store the execution logs, function code, and bindings.')
param parStorageAccountName string

@description('The Code runtime stack of the App Service. Possible values are dotnet, node, java, powershell, python, custom. DEFAULTS TO: dotnet.')
@allowed([
  'dotnet-isolated'
  'dotnet-inprocess'
  'node'
  'java'
  'powershell'
  'python'
  'custom'
])
param parAppRuntime string = 'dotnet-isolated'

@description('The .NET Framework version. https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions?pivots=programming-language-csharp. DEFAULTS TO: v6.0.')
@allowed([
  '4.8'
  '6.0'
  '7.0'
  '8.0'
])
param parNetFrameworkVersion string = '8.0'


@description('The Java version. https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions?pivots=programming-language-java. DEFAULTS TO: 17.')
@allowed([
  '8'
  '11'
  '17'
  '21'
])
param parJavaVersion string = '17'

@description('The Node.js version. https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions?pivots=programming-language-javascript. DEFAULTS TO: 14.')
@allowed([
  '14'
  '16'
  '18'
  '20'
])
param parNodeVersion string = '14'

@description('The PowerShell version. https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions?pivots=programming-language-powershell. DEFAULTS TO: 7.2.')
@allowed([
  '7.2'
])
param parPowerShellVersion string = '7.2'

@description('The Python version. https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions?pivots=programming-language-python. DEFAULTS TO: 3.11.')
@allowed([
  '3.8'
  '3.9'
  '3.10'
  '3.11'
])
param parPythonVersion string = '3.11'

@description('The region to deploy all resources into. DEFAULTS TO: deployment().location')
param parLocation string = resourceGroup().location

@description('If the app is enabled. Setting this value to false disables the app (takes the app offline). DEFAULTS TO: true.')
param parEnabled bool = true

@description('The operating system. Possible values are Windows and Linux. DEFAULTS TO: Linux.')
@allowed([
  'Windows'
  'Linux'
])
param parOS string = 'Linux'

@description('Determines if the OS instance will fully reserved. Setting this value to false will make a Windows App service to be created. DEFAULTS TO: false.')
param parReserved bool = true

@description('If the app is running as a spot instance. DEFAULTS TO: false.')
param parIsSpot bool = false

@description('If enabled apps assigned to this App Service plan can be scaled independently. DEFAULTS TO: false.')
param parPerSiteScaling bool = false

@description('If the app is running in a Hyper-V container; otherwise, false. DEFAULTS TO: false.')
param parHyperVSandbox bool = false

@description('Virtual Network Route All enabled. This causes all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied. DEFAULTS TO: false.')
param parVnetRouteAllEnabled bool = false

@description('To enable pulling image over Virtual Network. DEFAULTS TO: false.')
param parVnetImagePullEnabled bool = false

@description('To enable accessing content over virtual network. DEFAULTS TO: false.')
param parVnetContentShareEnabled bool = false

@description('The Resource Group containing Virtual Network for the ContentShare/Integration. DEFAULTS TO: empty string.')
param parVnetContentShareVNetRG string = ''

@description('The Virtual Network Name for the ContentShare/Integration. DEFAULTS TO: empty string.')
param parVnetContentShareVNetName string = ''

@description('The Subnet Name for the ContentShare/Integration. DEFAULTS TO: empty string.')
param parVnetContentShareSubnetName string = ''

@description('Number of workers. DEFAULTS TO: 1.')
param parNumberOfWorkers int = 1

@description('Sets App Service Plan to perform availability zone balancing. DEFAULTS TO: false.')
param parZoneRedundant bool = false

@description('ServerFarm supports ElasticScale. Apps in this plan will scale as if the ServerFarm was FunctionsPremium(ElasticPremium) sku. DEFAULTS TO: false.')
param parElasticScaleEnabled bool = true

@description('Maximum number of workers to scale out in when ElasticScale is enabled. DEFAULTS TO: 5.')
param parNumberOfWorkersMax int = 5

@description('The FTPS state of the Function App. The allowed values are AllAllowed, Disabled, FtpsOnly. DEFAULTS TO: Disabled.')
@allowed([
  'AllAllowed'
  'Disabled'
  'FtpsOnly'
])
param parFtpsState string = 'Disabled'

@description('The SKU of the App Service Plan to be used by the Function App. The allowed values are the same as the Azure Portal and which are converted into the Template internal names. DEFAULTS TO: Serverless.')
@allowed([
  'Serverless'
  'FunctionsPremium'
  'AppServicePlanBasic'
  'AppServicePlanStandard'
  'AppServicePlanPremiumV2'
  'AppServicePlanPremiumV3'
  'AppServicePlanPremiumV3Mem'
])
param parAppServicePlanSKU string = 'Serverless'

@description('The tier of the App Service Plan to be used by the Function App. https://azure.microsoft.com/en-us/pricing/details/app-service/windows/. DEFAULTS TO: 1')
@allowed([0, 1, 2, 3, 4, 5])
param parAppServicePlanTier int = 1

@description('Property to allow or block all public traffic. Allowed Values: Enabled, Disabled or an empty string. DEFAULTS TO: Enabled')
@allowed([
  'Enabled'
  'Disabled'
  ''
])
param parPublicNetworkAccess string = 'Enabled'

@description('The User Assigned Managed Identity to be used by the Function App. DEFAULTS TO: None')
@allowed([
  'UserAssigned'
  'SystemAssigned'
  'SystemAssigned, UserAssigned'
  'None'
])
param parIdentityType string = 'None'

@description('The Resource Group of the User Assigned Managed Identity to be used by the Function App. Only required if parIdentityType is UserAssigned. DEFAULTS TO: empty string.')
param parUserAssignedManagedIdentityNameRG string = ''

@description('The User Assigned Managed Identity to be used by the Function App. Only required if parIdentityType is UserAssigned.')
param parUserAssignedManagedIdentityName string = ''

@description('Flag to use Managed Identity Creds for ACR pull. DEFAULTS TO: false.')
param parAcrUseManagedIdentityCreds bool = false

@description('If the app is always on. Setting this value to true keeps the app always on. DEFAULTS TO: false.')
param parSiteAlwaysOn bool = true

@description('If the app is enabled for HTTP/2. DEFAULTS TO: true.')
param parHttp2Enabled bool = true

@description('Maximum number of workers that a site can scale out to. This setting only applies to the Consumption and Elastic Premium Plans. DEFAULTS TO: 200.')
param parFunctionAppScaleLimit int = 200

@description('Enable client affinity, which route client requests in the same session to the same instance. DEFAULTS TO: true.')
param parClientAffinityEnabled bool = false

@description('Enable client certificate authentication (TLS mutual authentication). False means ClientCert is ignored. DEFAULTS TO: true')
param parClientCertEnabled bool = true

@description('This composes with ClientCertEnabled setting. Required means ClientCert is required. Optional means ClientCert is optional or accepted. DEFAULTS TO: Optional')
@allowed([
  'Optional'
  'OptionalInteractiveUser'
  'Required'
])
param parClientCertMode string = 'Optional'

@description('Disable the public hostnames of the app. The app would be only accessible via API management process')
param parHostNamesDisabled bool = false

@description('If the app is only accessible via HTTPS. DEFAULTS TO: true.')
param parHTTPSOnly bool = true

@description('The redundancy mode of the app. DEFAULTS TO: None')
@allowed([
  'ActiveActive'
  'Failover' 
  'GeoRedundant'
  'Manual'
  'None'
])
param parRedundancyMode string = 'None'

@description('Enable Application Insights for the Function App. DEFAULTS TO: false.')
param parApplicationInsightsEnable string = 'false'

@description('The name of the Application Insights to be used by the Function App. DEFAULTS TO: empty string.')
param parApplicationInsightsName string = '${parName}-AppInsights'

@description('The Log Analytics Workspace Resource Group to be used by the Application Insights. DEFAULTS TO: empty string.')
param parLogAnalyticsWorkspaceName string = ''

@description('The Log Analytics Workspace Name RG. DEFAULTS TO: empty string.')
param parLogAnalyticsWorkspaceRG string = ''

@description('The Key Vault to be used by the Function App. DEFAULTS TO: empty string.')
param parKeyvaultName string = ''

@description('The Key Vault Secret to be used by the Function App. DEFAULTS TO: empty string.')
param parCertificateName string = ''

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

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ VARIABLES @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//Convert the SKU to the internal name
var varAppServicePlanSKUDefinition = {
  Serverless                : 'Dynamic'
  FunctionsPremium          : 'ElasticPremium'
  AppServicePlanBasic       : 'Basic'
  AppServicePlanStandard    : 'Standard'
  AppServicePlanPremiumV2   : 'PremiumV2'
  AppServicePlanPremiumV3   : 'PremiumV3'
  AppServicePlanPremiumV3Mem: 'PremiumMV3'
}
var varSKUTierTemp = varAppServicePlanSKUDefinition[parAppServicePlanSKU]
//Special case for PremiumV3 with Tier 0
var varSKUTier = (varSKUTierTemp == 'PremiumV3') && (parAppServicePlanTier == 0) ? 'Premium0V3' : varSKUTierTemp

//Selects the Tier Code Letter based on the SKU
var varAppServicePlanTierCodeLetter = {
  Serverless                : 'Y'
  FunctionsPremium          : 'EP'
  AppServicePlanBasic       : 'B'
  AppServicePlanStandard    : 'S'
  AppServicePlanPremiumV2   : 'P'
  AppServicePlanPremiumV3   : 'P'
  AppServicePlanPremiumV3Mem: 'P'
}
//Composes the Tier Code based on the SKU and the Tier'. The Tier is adjusted to the maximum allowed for the SKU
var varAppServicePlanTier       = (varSKUTier == 'Dynamic') ? 1
                                  : ((varSKUTier == 'Basic') || (varSKUTier == 'Standard') || (varSKUTier == 'PremiumV2') || (varSKUTier == 'PremiumV3')) && (parAppServicePlanTier > 3) ? 3 //Only PremiumMV3 has Tier 4 and 5
                                  : !((varSKUTier == 'PremiumV3') || (varSKUTier == 'Premium0V3')) && (parAppServicePlanTier == 0) ? 1 //Only PremiumV3 can have Tier 0
                                  : parAppServicePlanTier
var varAppServicePlanTierSuffix = contains(varSKUTier, 'PremiumV2') ? 'v2'
                                  : contains(varSKUTier, 'PremiumV3') ? 'V3'
                                  : contains(varSKUTier, 'Premium0V3') ? 'V3'
                                  : contains(varSKUTier, 'PremiumMV3') ? 'MV3' 
                                  : ''
var varAppServicePlanTierCode = '${varAppServicePlanTierCodeLetter[parAppServicePlanSKU]}${varAppServicePlanTier}${varAppServicePlanTierSuffix}'

//Selects the Worker Size based on the SKU and the Tier.
var varWorkerSizeId = {
  Y1  : 0
  B1  : 0
  B2  : 1
  B3  : 2
  S1  : 0
  S2  : 1
  S3  : 2
  EP1 : 3
  EP2 : 4
  EP3 : 5
  P1V2: 3
  P2V2: 4
  P3V2: 5
  P0V3: 18
  P1V3: 6
  P2V3: 7
  P3V3: 8
  P1MV3: 13
  P2MV3: 14
  P3MV3: 15
  P4MV3: 16
  P5MV3: 17
}

//Maps the runtime versions based on the runtime selected
var varAppRuntimeVersion = contains(parAppRuntime, 'dotnet') ? parNetFrameworkVersion
                            : parAppRuntime == 'java'       ? parJavaVersion
                            : parAppRuntime == 'node'       ? parNodeVersion
                            : parAppRuntime == 'powershell' ? parPowerShellVersion
                            : parAppRuntime == 'python'     ? parPythonVersion
                            : ''

// Only Dotnet 6.0 can be inprocess, all other runtimes are isolated
var varAppRuntime = contains(parAppRuntime, 'dotnet') && parNetFrameworkVersion != '6.0' ? 'dotnet-isolated' : parAppRuntime

var varLinuxFxVersion    = contains(varAppRuntime,'dotnet') ? 'DOTNETCORE|${parNetFrameworkVersion}' //Old: '${toUpper(varAppRuntime)}|${parNetFrameworkVersion}' //https://medium.com/medialesson/solved-the-parameter-linuxfxversion-has-an-invalid-value-net6-linux-533c759456cd
                            : varAppRuntime == 'java'       ? 'Java|${varAppRuntimeVersion}'
                            : varAppRuntime == 'node'       ? 'Node|${varAppRuntimeVersion}'
                            : varAppRuntime == 'powershell' ? 'PowerShell|${varAppRuntimeVersion}'
                            : varAppRuntime == 'python'     ? 'Python|${varAppRuntimeVersion}'
                            : ''


//.NET 4.8 is only available on Windows
var varOS = parNetFrameworkVersion == '4.8' ? 'Windows' : parOS


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ RESOURCES @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

resource resAppInsights 'Microsoft.Insights/components@2020-02-02' = if (toLower(parApplicationInsightsEnable) == 'true') {
  name      : parApplicationInsightsName
  location  : parLocation
  kind      : 'web'
  properties: {
    Application_Type   : 'web'
    Flow_Type          : 'Redfield'
    WorkspaceResourceId: resourceId(parLogAnalyticsWorkspaceRG, 'Microsoft.OperationalInsights/workspaces', parLogAnalyticsWorkspaceName)
  }
}

resource resAppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name      : '${parName}-ASP'
  kind      : varOS == 'Windows' ? '' : toLower(varOS)
  location  : parLocation
  properties: {
    perSiteScaling           : parPerSiteScaling
    elasticScaleEnabled      : ((parAppServicePlanSKU == 'AppServicePlanBasic') || (parAppServicePlanSKU == 'Serverless')) ? false : parElasticScaleEnabled
    maximumElasticWorkerCount: parNumberOfWorkersMax
    isSpot                   : parIsSpot
    reserved                 : parReserved
    targetWorkerSizeId       : varWorkerSizeId[varAppServicePlanTierCode]
    targetWorkerCount        : (parNumberOfWorkers < 3 && parZoneRedundant) ? 3 : parNumberOfWorkers //Zone Redundant requires at least 3 workers
    zoneRedundant            : !contains(varSKUTier, 'Premium') ? false : parZoneRedundant //Only Premium SKUs can be Zone Redundant
  }
  sku: {
    name    : varAppServicePlanTierCode
    tier    : varSKUTier
  }
}

resource resCertificate 'Microsoft.Web/certificates@2023-01-01' = if (parCertificateName != '') {
  name      : parCertificateName
  location  : parLocation
  properties: {
    keyVaultId        : resourceId('Microsoft.KeyVault/vaults', parKeyvaultName)
    keyVaultSecretName: parCertificateName
    serverFarmId      : resAppServicePlan.id
  }
}

resource resFunctionApp 'Microsoft.Web/sites@2023-01-01' = {
  name      : parName
  kind      : varOS == 'Windows' ? 'functionapp' : 'functionapp,linux'
  location  : parLocation
  tags      : parTags
  properties: {
    hostNameSslStates: parCertificateName != ''? [
      {
        name      : resCertificate.properties.hostNames[0]
        sslState  : 'SniEnabled'
        hostType  : 'Standard'
        thumbprint: resCertificate.properties.thumbprint
      }
    ] : null
    enabled                : parEnabled
    reserved               : parReserved
    hyperV                 : parHyperVSandbox
    vnetRouteAllEnabled    : parVnetRouteAllEnabled
    vnetImagePullEnabled   : parVnetImagePullEnabled
    vnetContentShareEnabled: parVnetContentShareEnabled
    virtualNetworkSubnetId : parVnetContentShareEnabled  ? resourceId(parVnetContentShareVNetRG, 'Microsoft.Network/virtualNetworks/subnets', parVnetContentShareVNetName, parVnetContentShareSubnetName) : null
    siteConfig             : {
      acrUseManagedIdentityCreds : parAcrUseManagedIdentityCreds
      alwaysOn                   : parSiteAlwaysOn
      ftpsState                  : parFtpsState
      functionAppScaleLimit      : parFunctionAppScaleLimit
      http20Enabled              : parHttp2Enabled
      javaVersion                : parAppRuntime == 'java' ? varAppRuntimeVersion  : null
      linuxFxVersion             : varOS == 'Linux' ? varLinuxFxVersion : null
      minimumElasticInstanceCount: 1
      netFrameworkVersion        : 'v${parNetFrameworkVersion}'
      numberOfWorkers            : (parNumberOfWorkers < 3 && parZoneRedundant) ? 3: parNumberOfWorkers  //Zone Redundant requires at least 3 workers
      use32BitWorkerProcess      : varAppRuntime == 'core-inprocess' ? true : false
      appSettings                : [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: parAppRuntime
        }
        {
          name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
          value: parAppRuntime == 'dotnet-isolated' ? '1' : '0'
        }
        {
          name: 'APPLICATIONINSIGHTS_ENABLE_AGENT'
          value: parApplicationInsightsEnable
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: parApplicationInsightsEnable == 'true' ? resAppInsights.properties.ConnectionString : ''
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${parStorageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts',parStorageAccountName),'2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${parStorageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts',parStorageAccountName),'2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(parName)
        }

      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
    }
    clientAffinityEnabled    : parClientAffinityEnabled
    clientCertEnabled        : parClientCertEnabled
    clientCertMode           : parClientCertMode
    hostNamesDisabled        : parHostNamesDisabled
    httpsOnly                : parHTTPSOnly
    redundancyMode           : parRedundancyMode
    publicNetworkAccess      : parPublicNetworkAccess
    serverFarmId             : resAppServicePlan.id
    // keyVaultReferenceIdentity: parIdentityType == 'SystemAssigned' ? parIdentityType 
    //                             : resourceId(parUserAssignedManagedIdentityNameRG ,'Microsoft.ManagedIdentity/userAssignedIdentities', parUserAssignedManagedIdentityName)
    // Via template this fails, so we use a deployment script (below)  to set the KeyVaultReferenceIdentity
    // --> https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?tabs=azure-powershell#access-vaults-with-a-user-assigned-identity
  }
  identity: {
    type: parIdentityType
    userAssignedIdentities: parIdentityType == 'UserAssigned' ? {
      '${resourceId(parUserAssignedManagedIdentityNameRG, 'Microsoft.ManagedIdentity/userAssignedIdentities', parUserAssignedManagedIdentityName)}': {}
    } : null
  }
}

//Sets the KeyVaultReferenceIdentity propertyto the User Assigned Managed Identity because via template it fails
resource resDeploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = if (parIdentityType == 'UserAssigned') {
  name: 'Set-keyVaultReferenceIdentity'
  location: parLocation
  kind: 'AzurePowerShell'
  // identity: {
  //   type: 'UserAssigned'
  //   userAssignedIdentities: {
  //     '${resourceId(parUserAssignedManagedIdentityNameRG, 'Microsoft.ManagedIdentity/userAssignedIdentities', parUserAssignedManagedIdentityName)}' : {}
  //   }
  // }
  properties: {
    azPowerShellVersion: '11.2'
    retentionInterval: 'P1D'
    arguments: '-FunctionAppName ${parName} -RG ${parUserAssignedManagedIdentityNameRG} -IDName ${parUserAssignedManagedIdentityName} -IDRG ${parUserAssignedManagedIdentityNameRG}' 
    scriptContent: '''
    param(
      [string]$FunctionAppName,
      [string]$RG,
      [string]$IDName
    )
    $identityResourceId = Get-AzUserAssignedIdentity -ResourceGroupName $IDRG -Name $IDName | Select-Object -ExpandProperty Id
    $appResourceId = Get-AzFunctionApp -ResourceGroupName $RG -Name $FunctionAppName  | Select-Object -ExpandProperty Id
    $Path = "{0}?api-version=2021-01-01" -f $appResourceId
    Invoke-AzRestMethod -Method PATCH -Path $Path -Payload "{'properties':{'keyVaultReferenceIdentity':'$identityResourceId'}}"    
    '''
  }
}



output FunctionAppName string  = resFunctionApp.name
output appServicePlanId string = resAppServicePlan.id
output AppInsightsId string    = resAppInsights.id

