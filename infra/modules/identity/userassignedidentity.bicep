/*region Header
      Module Steps 
      1 - Create User-Assignment Managed Identity used to execute deployment scripts
*/

//Declare Parameters--------------------------------------------------------------------------------------------------------------------------
param identityName string
param location string = resourceGroup().location

//https://docs.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.managedidentity/userassignedidentities
//1. User-Assignment Managed Identity used to execute deployment scripts
resource qxidentity 'Quadratyx.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: identityName
  location: location
}

output identityid string = qxidentity.id
output clientId string = qxidentity.properties.clientId
output principalId string = qxidentity.properties.principalId
