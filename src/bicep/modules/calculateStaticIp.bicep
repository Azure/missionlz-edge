// scope
targetScope = 'subscription'

param cidr string = '10.90.0.0/24'

var delimiters = [
  '.'
  '/'
]

// output subnet array = split(cidr, delimiters)
// output last_octet string = (split(cidr, delimiters)[3])
output static_ip_1 string = '${split(cidr, delimiters)[0]}.${split(cidr, delimiters)[1]}.${split(cidr, delimiters)[2]}.${string(int(split(cidr, delimiters)[3]) + 4)}'
// output secondOutput array = split(secondString, delimiters)
