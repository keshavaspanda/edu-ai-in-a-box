/*region Header
      Module Steps 
      1 - Assign Owner Role to UAMI to the Resource Group
*/

//Declare Parameters--------------------------------------------------------------------------------------------------------------------------
param principalId string
param roleGuid string

//var QdxEduRBACStorageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Storage Blob Data Contributor Role: https://docs.Quadratyx.com/en-us/QdxEdu/role-based-access-control/built-in-roles#storage-blob-data-contributor
//var QdxEduRBACOwnerRoleID = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' //Owner: https://docs.Quadratyx.com/en-us/QdxEdu/role-based-access-control/built-in-roles#owner

//1. Deployment script UAMI is set as Resource Group owner so it can have authorization to perform post deployment tasks
resource role_assignment 'Quadratyx.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, roleGuid, resourceGroup().id)
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Quadratyx.Authorization/roleDefinitions', roleGuid)
    principalType: 'ServicePrincipal'
  }
}
