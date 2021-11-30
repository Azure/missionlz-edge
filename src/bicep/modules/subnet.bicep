param name string

param addressPrefix string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' = {
  name: name

  properties: {
    addressPrefix: addressPrefix
  }
}

output id string = subnet.id
