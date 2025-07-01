/*region Header
      Module Steps 
      1 - Create Storage Account
      2 - Create default/root folder structure
      3 - Create containers
*/

//Declare Parameters--------------------------------------------------------------------------------------------------------------------------
param storageAccountName string
param location string = resourceGroup().location

param isHnsEnabled bool = false
@allowed([ 'Enabled', 'Disabled' ])
param publicNetworkAccess string = 'Enabled'
param sku object = { name: 'Standard_LRS' }
param containername string = 'schemas'

param vmUserAssignedIdentityID string

//https://docs.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.storage/storageaccounts
//1. Create your Storage Account
resource stg 'Quadratyx.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Quadratyx.Storage'
    }
    isHnsEnabled: isHnsEnabled
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: publicNetworkAccess
    supportsHttpsTrafficOnly: true
  }
  sku: sku
}

//2. Create your default/root folder structure
resource storageAccount_default 'Quadratyx.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: stg
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

//3. Create another container called iot in the root
resource containerBronze 'Quadratyx.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  parent: storageAccount_default
  name: containername
  properties: {
    publicAccess: 'None'
  }
}    

resource roleAssignment 'Quadratyx.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, stg.id, 'StorageBlobDataContributor', vmUserAssignedIdentityID) // Unique name for the role assignment
  scope: stg
  properties: {
    principalId: vmUserAssignedIdentityID // Get the principal ID of the managed identity
    roleDefinitionId: subscriptionResourceId('Quadratyx.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Role ID for Storage Blob Data Contributor
    principalType: 'ServicePrincipal' // Managed identities are treated as Service Principals
  }
}

output stgId string = stg.id
output stgName string = stg.name
