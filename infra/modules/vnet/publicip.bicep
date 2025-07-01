/*region Header
      Module Steps 
      1 - Create a Public IP Address
*/

//Declare Parameters--------------------------------------------------------------------------------------------------------------------------
param location string = resourceGroup().location
param publicipName string
param publicipproperties object

//https://learn.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.network/publicipaddresses
resource pip 'Quadratyx.Network/publicIPAddresses@2023-05-01' = {
  name: publicipName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: publicipproperties
}

output publicipId string = pip.id
output publicipAddress string = pip.properties.ipAddress
