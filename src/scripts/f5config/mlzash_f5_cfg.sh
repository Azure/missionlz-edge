#!/bin/sh

#####################################################
## BashSRG - Bash STIG/SRG configuration Script
## Michael Coleman.  M.Coleman@F5.com
## Modified by r.eastman@f5.com
## Last Update M.Coleman@f5.com July 2020
#####################################################
echo
echo "###############################################"
echo " BASHSRG - Bash STIG/SRG Configuration Script"
echo " Developed by F5 Networks"
echo "###############################################"
## Replicated in DO Example #########################

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
# tmsh create /ltm node 10.90.1.5 address 10.90.1.5
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

## STIG Configurations ##############################
tmsh modify sys sshd inactivity-timeout 900
tmsh modify sys sshd banner enabled
tmsh modify sys sshd banner-text "You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only. By using this IS (which includes any device attached to this IS), you consent to the following conditions: The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations. At any time, the USG may inspect and seize data stored on this IS. Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG authorized purpose. This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy. Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details."
tmsh modify sys sshd include '"Protocol 2
MaxAuthTries 3
Ciphers aes128-ctr,aes192-ctr,aes256-ctr
MACs hmac-sha1
KexAlgorithms ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha256
LoginGraceTime 60
MaxStartups 5"'
tmsh modify sys ntp timezone UTC
tmsh modify sys db ui.advisory.enabled value true
tmsh modify sys db ui.advisory.color value green
tmsh modify sys db ui.advisory.text value "//UNCLASSIFIED//"
tmsh modify sys db ui.system.preferences.advancedselection value advanced
tmsh modify sys db ui.system.preferences.recordsperscreen value 100
tmsh modify sys db ui.system.preferences.startscreen value network_map
tmsh modify sys db ui.users.redirectsuperuserstoauthsummary value true
tmsh modify sys db dns.cache value enable
tmsh modify sys db big3d.minimum.tls.version value TLSV1.2
tmsh modify sys db liveinstall.checksig value "enable"
tmsh modify sys httpd auth-pam-dashboard-timeout on
tmsh modify sys httpd max-clients 10
tmsh modify sys httpd auth-pam-idle-timeout 600
tmsh modify sys httpd ssl-ciphersuite 'FIPS:!RSA:!SSLv3:!TLSv1:!3DES:!ADH'
tmsh modify sys httpd ssl-protocol 'all -SSLv2 -SSLv3 -TLSv1'
tmsh modify sys httpd redirect-http-to-https enabled
tmsh modify cli global-settings idle-timeout 10
tmsh modify sys global-settings console-inactivity-timeout 600
tmsh modify sys software update auto-check disabled
tmsh modify sys software update auto-phonehome disabled
tmsh modify sys daemon-log-settings mcpd audit enabled
tmsh modify sys daemon-log-settings mcpd log-level notice

## Optional settings ################################
# tmsh modify sys dns name-servers add { x.x.x.x x.x.x.x }
# tmsh modify sys ntp servers add { x.x.x.x x.x.x.x }
# tmsh modify sys dns search add { demo.local demo.f5demo.local }
# tmsh create sys management-route ntpservers network x.x.x.x/255.255.0.0 gateway x.x.x.x
## End Replicated Settings ##########################

# tmsh modify ltm profile client-ssl clientssl ciphers HIGH:!RSA:!DES:!TLSv1:!TLSv1_1:!SSLv3:!ECDHE-RSA-AES256-CBC-SHA:@STRENGTH
# tmsh modify ltm profile server-ssl serverssl ciphers HIGH:!RSA:!DES:!TLSv1:!TLSv1_1:!SSLv3:!ECDHE-RSA-AES256-CBC-SHA:@STRENGTH
tmsh modify sys global-settings gui-security-banner enabled
tmsh modify sys global-settings gui-security-banner-text "You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only. By using this IS (which includes any device attached to this IS), you consent to the following conditions: The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations. At any time, the USG may inspect and seize data stored on this IS. Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG authorized purpose. This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy. Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details."
# tmsh modify gtm global-settings general { iquery-minimum-tls-version TLSv1.2 }
tmsh modify sys snmp communities delete { comm-public }
tmsh modify sys daemon-log-settings tmm os-log-level informational
tmsh modify sys daemon-log-settings tmm ssl-log-level informational
tmsh modify auth password-policy expiration-warning 7
tmsh modify auth password-policy max-duration 60
tmsh modify auth password-policy max-login-failures 3
tmsh modify auth password-policy min-duration 1
tmsh modify auth password-policy minimum-length 15
tmsh modify auth password-policy password-memory 5
tmsh modify auth password-policy policy-enforcement enabled
tmsh modify auth password-policy required-lowercase 2
tmsh modify auth password-policy required-numeric 2
tmsh modify auth password-policy required-special 2
tmsh modify auth password-policy required-uppercase 2
tmsh modify sys httpd include '"
# File ETAG CVE
FileETag MTime Size

# CVE-2020-5902
<LocationMatch ";">
	Redirect 404 /
</LocationMatch>
<LocationMatch "hsqldb">
	Redirect 404 /
</LocationMatch>"'
tmsh save sys config
bigstart restart httpd
echo "Configuration Complete"