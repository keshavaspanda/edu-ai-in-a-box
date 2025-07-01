param vnetName string
param subnetName string
param properties object

resource vnet 'Quadratyx.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource subnet 'Quadratyx.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: vnet
  name: subnetName
   properties: properties
}

output subnetId string = subnet.id
