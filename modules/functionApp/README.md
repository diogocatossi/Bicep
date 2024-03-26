# FunctionApp.bicep

This Bicep file is used to define and manage an Azure Function App resource. Azure Function Apps are a serverless compute service that enables you to run code on-demand without having to explicitly provision or manage infrastructure. This Bicep file allows you to customize the Function App according to your needs by setting various parameters.

# Bicep Template Parameters

## Required Parameters
- `parName`: `string`
  - Function App Name

- `parAppType`: `string`
  - The type of the App Service.
  - Allowed Values: Code, Container
  - Defaults To: Code

- `parStorageAccountName`: `string`
  - Azure Storage account name for logs, code, and bindings

## Optional Parameters
- `parAppRuntime`: `string`
  - Code runtime stack of the App Service
  - Allowed Values: dotnet-isolated, dotnet-inprocess, node, java, powershell, python, custom
  - Defaults To: dotnet

- `parNetFrameworkVersion`: `string`
  - The .NET Framework version. This parameter is used when the `parAppRuntime` is set to a .NET runtime. More information [here](https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions?pivots=programming-language-csharp).
  - Allowed Values: 4.8, 6.0, 7.0, 8.0
  - Defaults To: 8.0

- `parJavaVersion`: `string`
  - The Java version.  This parameter is used when the `parAppRuntime` is set to the Java runtime. More information [here](https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions?pivots=programming-language-java).
  - Allowed Values: 8, 11, 17, 21
  - Defaults To: 17

- `parNodeVersion`: `string`
  - The Node.js version. This parameter is used when the `parAppRuntime` is set to the Node.js runtime. More information [here](https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions?pivots=programming-language-javascript).
  - Allowed Values: 14, 16, 18, 20
  - Defaults To: 14

- `parPowerShellVersion`: `string`
  - The PowerShell version. This parameter is used when the `parAppRuntime` is set to the PowerShell runtime. More information [here](https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions?pivots=programming-language-powershell).
  - Allowed Values: 7.2
  - Defaults To: 7.2

- `parPythonVersion`: `string`
  - The Python version. This parameter is used when the `parAppRuntime` is set to the Python runtime. More information [here](https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions?pivots=programming-language-python).
  - Allowed Values: 3.8, 3.9, 3.10, 3.11
  - Defaults To: 3.11

- `parLocation`: `string`
  - The region to deploy resources into
  - Defaults To: resourceGroup().location

- `parEnabled`: `bool`
  - If the app is enabled
  - Defaults To: true

- `parOS`: `string`
  - The operating system
  - Allowed Values: Windows, Linux
  - Defaults To: Linux

- `parReserved`: `bool`
  - Determines if the OS instance is fully reserved
  - Defaults To: false

- `parIsSpot`: `bool`
  - If the app is running as a spot instance
  - Defaults To: false

- `parPerSiteScaling`: `bool`
  - If enabled, apps can be scaled independently
  - Defaults To: false

- `parHyperVSandbox`: `bool`
  - If the app is running in a Hyper-V container
  - Defaults To: false

- `parVnetRouteAllEnabled`: `bool`
  - Virtual Network Route All enabled
  - Defaults To: false

- `parVnetImagePullEnabled`: `bool`
  - To enable pulling image over Virtual Network
  - Defaults To: false

- `parVnetContentShareEnabled`: `bool`
  - To enable accessing content over virtual network
  - Defaults To: false

- `parNumberOfWorkers`: `int`
  - Number of workers
  - Defaults To: 1

- `parZoneRedundant`: `bool`
  - Sets App Service Plan to perform availability zone balancing
  - Defaults To: false

- `parElasticScaleEnabled`: `bool`
  - ServerFarm supports ElasticScale
  - Defaults To: true

- `parNumberOfWorkersMax`: `int`
  - Maximum number of workers to scale out when ElasticScale is enabled
  - Defaults To: 5

- `parFtpsState`: `string`
  - The FTPS state of the Function App
  - Allowed Values: AllAllowed, Disabled, FtpsOnly
  - Defaults To: Disabled

- `parAppServicePlanSKU`: `string`
  - The SKU of the App Service Plan
  - Allowed Values: Serverless, FunctionsPremium, AppServicePlanBasic, AppServicePlanStandard, AppServicePlanPremiumV2, AppServicePlanPremiumV3, AppServicePlanPremiumV3Mem
  - Defaults To: Serverless

- `parAppServicePlanTier`: `int`
  - The tier of the App Service Plan
  - Allowed Values: 0, 1, 2, 3, 4, 5
  - Defaults To: 1

- `parPublicNetworkAccess`: `string`
  - Property to allow or block all public traffic
  - Allowed Values: Enabled, Disabled, ''
  - Defaults To: Enabled

- `parIdentityType`: `string`
  - The User Assigned Managed Identity type
  - Allowed Values: UserAssigned, SystemAssigned, SystemAssigned, UserAssigned, None
  - Defaults To: None

- `parUserAssignedManagedIdentityNameRG`: `string`
  - RG of User Assigned Managed Identity
  - Defaults To: ''

- `parUserAssignedManagedIdentityName`: `string`
  - User Assigned Managed Identity name
  - Defaults To: ''

- `parAcrUseManagedIdentityCreds`: `bool`
  - Flag to use Managed Identity Creds for ACR pull
  - Defaults To: false

- `parSiteAlwaysOn`: `bool`
  - If the app is always on
  - Defaults To: false

- `parHttp2Enabled`: `bool`
  - If the app is enabled for HTTP/2
  - Defaults To: true

- `parFunctionAppScaleLimit`: `int`
  - Maximum number of workers for site scaling
  - Defaults To: 200

- `parClientAffinityEnabled`: `bool`
  - Enable client affinity
  - Defaults To: false

- `parClientCertEnabled`: `bool`
  - Enable client certificate authentication
  - Defaults To: true

- `parClientCertMode`: `string`
  - Client certificate mode
  - Allowed Values: Optional, OptionalInteractiveUser, Required
  - Defaults To: Optional

- `parHostNamesDisabled`: `bool`
  - Disable public hostnames of the app
  - Defaults To: false

- `parHTTPSOnly`: `bool`
  - If the app is only accessible via HTTPS
  - Defaults To: true

- `parRedundancyMode`: `string`
  - The redundancy mode of the app
  - Allowed Values: ActiveActive, Failover, GeoRedundant, Manual, None
  - Defaults To: None

- `parApplicationInsightsEnable`: `string`
  - Enable Application Insights for the Function App
  - Defaults To: false

- `parApplicationInsightsName`: `string`
  - Name of the Application Insights
  - Defaults To: empty string

- `parLogAnalyticsWorkspaceName`: `string`
  - Log Analytics Workspace Resource Group
  - Defaults To: empty string

- `parLogAnalyticsWorkspaceRG`: `string`
  - Log Analytics Workspace Name RG
  - Defaults To: empty string

- `parTags`: `object`
  - Object with Tags key pairs to be applied to all resources
  - Default: empty array
  - Format: 
    ```json
    {
      "Environment": "string",
      "SLA": "string",
      "CustomerName": "string",
      "CustomerShortCode": "string",
      "Service": "string",
      "Tier": "coreinfra"
    }
    ```

