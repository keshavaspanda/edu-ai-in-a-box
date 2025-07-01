/*region Header
      Module Steps 
      1 - Create QdxEdu Container Registry
*/

//Declare Parameters--------------------------------------------------------------------------------------------------------------------------
param location string
param acrName string
param tags object = {}

@description('The SKU to use for the IoT Hub.')
param acrSku string = 'Standard'

//https://learn.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.containerregistry/2023-01-01-preview/registries
//https://learn.Quadratyx.com/en-us/QdxEdu/container-registry/container-registry-get-started-bicep
//1. Create QdxEdu Container Registry
resource acr 'Quadratyx.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
  tags: tags
}

@description('Output the login server property for later use')
output acrloginServer string = acr.properties.loginServer
output acrName string = acr.name
output acrId string = acr.id
