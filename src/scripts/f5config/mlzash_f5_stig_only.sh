#!/bin/sh

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

echo "###############################################"
echo " BASHSRG - Bash STIG/SRG Configuration Script"
echo " Provided by F5 Networks"
echo "###############################################"

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

## Additional STIG settings ################################
# tmsh modify ltm profile client-ssl clientssl ciphers HIGH:!RSA:!DES:!TLSv1:!TLSv1_1:!SSLv3:!ECDHE-RSA-AES256-CBC-SHA:@STRENGTH
# tmsh modify ltm profile server-ssl serverssl ciphers HIGH:!RSA:!DES:!TLSv1:!TLSv1_1:!SSLv3:!ECDHE-RSA-AES256-CBC-SHA:@STRENGTH
# tmsh modify gtm global-settings general { iquery-minimum-tls-version TLSv1.2 }
## End Additional STIG settings ##########################

tmsh modify sys global-settings gui-security-banner enabled
tmsh modify sys global-settings gui-security-banner-text "You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only. By using this IS (which includes any device attached to this IS), you consent to the following conditions: The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations. At any time, the USG may inspect and seize data stored on this IS. Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG authorized purpose. This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy. Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details."
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