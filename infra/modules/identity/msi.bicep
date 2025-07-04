/*region Header
      Module Steps 
      1 - Create User-Assignment Managed Identity used to execute deployment scripts
*/

//Declare Parameters--------------------------------------------------------------------------------------------------------------------------
param location string
param msiName string
param tags object = {}

//https://docs.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.managedidentity/userassignedidentities
//1. User-Assignment Managed Identity used to execute deployment scripts
resource msi 'Quadratyx.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: msiName
  location: location
  tags: tags
}

output msiID string = msi.id
output msiClientID string = msi.properties.clientId
output msiPrincipalID string = msi.properties.principalId
output msiName string = msi.name
