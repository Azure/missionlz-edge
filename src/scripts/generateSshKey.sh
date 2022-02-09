#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

echo -e \'y\' | ssh-keygen -f scratch -N "" 
privateKey=$(cat scratch) 
publicKey=$(cat scratch.pub) 
json="{\"keyinfo\":{\"privateKey\":\"$privateKey\",\"publicKey\":\"$publicKey\"}}" 
echo "$json" > sshkeys.json