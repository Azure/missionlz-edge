#!/bin/sh

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

echo "###############################################"
echo " BASHSRG - Bash STIG/SRG Configuration Script"
echo " Provided by F5 Networks"
echo "###############################################"

## Routing Configurations ###########################
tmsh modify /net interface 1.1 description External_Interface 
tmsh modify /net interface 1.2 description Internal_Interface
tmsh modify /net interface 1.3 description VDMS_Interface
tmsh create /net vlan External_VLAN
tmsh create /net vlan Internal_VLAN
tmsh create /net vlan VDMS_VLAN
tmsh modify /net vlan External_VLAN interfaces add { 1.1 }
tmsh modify /net vlan Internal_VLAN interfaces add { 1.2 }
tmsh modify /net vlan VDMS_VLAN interfaces add { 1.3 }
tmsh create /net self VDMS_IP address 10.90.3.4/24 vlan VDMS_VLAN
tmsh create /net self External_IP address 10.90.1.4/24 vlan External_VLAN
tmsh create /net self Internal_IP address 10.90.2.4/24 vlan Internal_VLAN
tmsh create /ltm node RemoteAccess_Windows_VM_1 address 10.90.0.5
tmsh create /ltm virtual-address 10.88.0.0 mask 255.248.0.0
tmsh create /ltm pool RemoteAccess_Windows
tmsh modify /ltm pool RemoteAccess_Windows members add { RemoteAccess_Windows_VM_1:3389 }
tmsh create /ltm virtual Allow_RDP_to_MGMT description Inbound_RemoteAccess_to_MGMT_Server destination 10.90.1.5:3389 ip-protocol tcp mask 255.255.255.255 pool RemoteAccess_Windows source 0.0.0.0/0 snat automap
tmsh modify /ltm virtual Allow_RDP_to_MGMT vlans-enabled vlans add { External_VLAN }
tmsh create /ltm virtual Spoke_to_Spoke_Traffic description Spoke_to_Spoke_Traffic destination 10.88.0.0:any mask 255.248.0.0 ip-forward ip-protocol any source 10.88.0.0/13 snat automap
tmsh modify /ltm virtual Spoke_to_Spoke_Traffic profiles modify { fastL4 }
tmsh create /ltm virtual MLZ_to_External description MLZ_to_External destination 0.0.0.0:443 ip-forward ip-protocol tcp source 10.88.0.0/13 snat automap
tmsh modify /ltm virtual MLZ_to_External profiles modify { fastL4 }
tmsh save sys config
tmsh create /net route Default_Route description "Outbound_External" gw 10.90.1.1 network 0.0.0.0/0
tmsh create /net route MLZ_Tiers description "Spoke_to_Spoke Trafic" gw 10.90.2.1 network 10.88.0.0/13
tmsh save sys config
echo "Configuration Complete"