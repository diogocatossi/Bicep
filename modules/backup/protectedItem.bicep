targetScope = 'resourceGroup'

@description('Virtual Server Name')
@minLength(1)
@maxLength(15)
param parVirtualMachineName string

@description('Recovery Services Vault name. If not provided Backup is disabled')
param parRecoveryServicesVaultName string = ''

@description('Recovery Services Vault RG. If not provided Backup is disabled')
param parRecoveryServicesVaultRG string = ''

@description('Backup policy name if parRecoveryServicesVaultName is provided')
param parBackupPolicyName string = ''

@description('Object with Tags to be applied to all resources in module. Default: empty array')
param parTags object = {}

var varBackupFabric        = 'Azure'
var varProtectionContainer = 'IaasVMContainer;iaasvmcontainerv2;${parRecoveryServicesVaultRG};${parVirtualMachineName}'
var varProtectedItem       = 'VM;iaasvmcontainerv2;${parRecoveryServicesVaultRG};${parVirtualMachineName}'

resource resVirtualMachine 'Microsoft.Compute/virtualMachines@2022-11-01' existing =  {
  name      : parVirtualMachineName
}

resource resBackupProtectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2023-01-01' = if (!empty(parRecoveryServicesVaultName)) {
    name      : '${parRecoveryServicesVaultName}/${varBackupFabric}/${varProtectionContainer}/${varProtectedItem}'
    properties: {
      protectedItemType: 'Microsoft.Compute/virtualMachines'
      policyId         : '${resourceId('Microsoft.RecoveryServices/vaults', parRecoveryServicesVaultName)}/backupPolicies/${parBackupPolicyName}'
      sourceResourceId : resVirtualMachine.id
    }
    tags: parTags
}

output id string   = resBackupProtectedItem.id
output name string = resBackupProtectedItem.name

