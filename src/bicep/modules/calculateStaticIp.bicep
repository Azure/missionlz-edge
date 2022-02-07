// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// scope
targetScope = 'subscription'

param cidr string = '10.90.0.0/24'
param offset int

var delimiters = [
  '.'
  '/'
]

output static_ip_1 string = '${split(cidr, delimiters)[0]}.${split(cidr, delimiters)[1]}.${split(cidr, delimiters)[2]}.${string(int(split(cidr, delimiters)[3]) + offset)}'
