targetScope = 'resourceGroup'

@description('Usernames to be used for SFTP access in lower case - Please update as needed based on the number of user count to create (one Azure file share per user)')
param parSFTPUserNamesArray array

@description('The Container Group Name')
param parContainerGroupName string 

@description('Primary location for resources')
param parLocation string = resourceGroup().location

@description('Storage account name where the SFTP shares are hosted.')
param parStorageAccountName string

@secure()
@description('Storage account key where the SFTP shares are hosted.')
param parStorageAccountKey string

@description('Resource group name for existing storage account where nginx config resides')
param parExistingNGINXStorageAccountRGName string 

@description('The existing storage account name where the nginx config is uploaded to the file share')
param parExistingNGINXStorageAccountName string

@description('The name of the existing Azure file share where nginx.conf file is uploaded')
param parExistingNGINXFileShareName string

@description('DNS label for container group')
param parContainerGroupDNSLabel string = uniqueString(resourceGroup().id, deployment().name)

@allowed([
  'Private'
  'Public'
])
@description('Specifies if the IP is exposed to the public internet or private VNET. DEFAULT: Public')
param parIPAddressType string = 'Public'

@description('Array containing the list of ports exposed on the container group. FORMAT: [{ protocol: \'TCP\', port: 80 }]')
param parPorts array = [{ protocol: 'TCP', port: 80 }]

@description('Array of objects with The containers within the container group.')
param parContainers array 

@description('User Assigned Managed Identity that should be used if any container image is stored in a private container registry')
param parManagedIdentityId string = ''

@description('Container Registry that stores private images. Should be provided together with the managed identity name')
param parAzureContainerRegistry string = ''

@description('Tags to add to the resources')
param parTags object = {}

var varVolumesUsers = [for user in parSFTPUserNamesArray: {
  name: 'sftpvolume-${toLower(user)}'
  azureFile: {
    readOnly          : false
    shareName         : toLower(user)
    storageAccountName: parStorageAccountName
    storageAccountKey : parStorageAccountKey
  }
} ]

var varVolumesSSH = [for user in parSFTPUserNamesArray: {
  name: toLower(user)
  azureFile: {
    readOnly          : false
    shareName         : '${toLower(user)}-sshkey'
    storageAccountName: parStorageAccountName
    storageAccountKey : parStorageAccountKey
  }
} ]


var varVolumeMountsUsers = [for user in parSFTPUserNamesArray: {
  mountPath: '/home/${toLower(user)}/${toLower(user)}'
  name     : 'sftpvolume-${toLower(user)}'
  readOnly : false
}]

var varVolumeMountsSSH = [for user in parSFTPUserNamesArray: {
  mountPath: '/home/${toLower(user)}/.ssh/keys'
  name     : toLower(user)
  readOnly : true
}]


var varVolumesNGINX = [
  {
    name: 'nginxconf'
    azureFile: {
      readOnly          : false
      shareName         : parExistingNGINXFileShareName
      storageAccountName: parExistingNGINXStorageAccountName
      storageAccountKey : listKeys(resourceId(parExistingNGINXStorageAccountRGName, 'Microsoft.Storage/storageAccounts', parExistingNGINXStorageAccountName), '2022-09-01').keys[0].value
    }
  }
]

resource resSFTPContainerGroup 'Microsoft.ContainerInstance/containerGroups@2022-09-01' = {
  name      : parContainerGroupName
  location  : parLocation
  identity: (empty(parManagedIdentityId)) ? null : {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${parManagedIdentityId}' : {}
    }
  }
  properties: {
    imageRegistryCredentials: empty(parManagedIdentityId) ? null : [
      {
        server  : parAzureContainerRegistry
        identity: parManagedIdentityId
      }
    ]
    containers: [for container in parContainers: {
      name      : container.name
      properties: {
        image               : container.image
        environmentVariables: container.environmentVariables
        resources           : {
          requests: {
            cpu       : container.cpu
            memoryInGB: container.ramGB
          }
        }
        ports: container.ports
        volumeMounts: !(empty(container.volumeMounts)) ? container.volumeMounts : union(varVolumeMountsUsers,varVolumeMountsSSH)
      }
    }]
    osType: 'Linux'
    ipAddress: {
      type        : parIPAddressType
      ports       : parPorts
      dnsNameLabel: parContainerGroupDNSLabel
    }
    restartPolicy: 'OnFailure'
    volumes: union(varVolumesUsers,varVolumesSSH,varVolumesNGINX)
  }
  tags      : parTags
}

output ip string = resSFTPContainerGroup.properties.ipAddress.ip
output fqdn string = resSFTPContainerGroup.properties.ipAddress.fqdn
