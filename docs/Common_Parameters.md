# **Common Deployment Parameters**

Below is a table of parameters that should be reviewed before deployment. While not an exhaust list of all parameters, these parameters either do not have default values or have defaults that customers may want to modify:

**Parameter Name**          | **Default value** | **Description**
------------------------| --------------| -----------
deployLinux | false | Setting to true deploys a Ubuntu 180.04 management VM alongside the Windows 2019 management VM using the same credentials
extSubnetAddressPrefix | 10.90.1.0/24 | Address space used for the External subnet
f5VmAdminPasswordOrKey | new Guid value | Required for f5VmAuthenticationType=Password.
f5VmAdminUsername | f5admin | Administrator account on the F5 NVAs that get deployed
f5VmAuthenticationType | sshPublicKey | Allowed values are {password, sshPublicKey} with a minimum length of 14 characters with atleast 1 uppercase, 1 lowercase, 1 alphnumeric, 1 special character
f5VmImageVersion | 15.0.100000 | Version of F5 BIG-IP sku being deployed
f5VmSize | Standard_DS3_v2 | The size of the F5 firewall appliance. It defaults to "Standard_DS3_v2"
hubVirtualNetworkAddressPrefix | 10.90.0.0/16 | Address space used for the Hub virtual network
identitySubnetAddressPrefix | 10.92.0.0/24 | The CIDR Subnet Address Prefix for the default Identity subnet. It must be in the Identity Virtual Network space
identityVirtualNetworkAddressPrefix | 10.92.0.0/16 | The CIDR Virtual Network Address Prefix for the Identity Virtual Network
intSubnetAddressPrefix | 10.90.2.0/24 | Address space used for the Internal subnet
keyVaultAccessPolicyObjectId | None | Required for f5VmAuthenticationType=sshPublicKey. Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.
mgmtSubnetAddressPrefix | 10.90.0.0/24 | Address space used for the Management subnet
operationsVirtualNetworkAddressPrefix | 10.91.0.0/16 | The CIDR Virtual Network Address Prefix for the Operations Virtual Network
operationsSubnetAddressPrefix | 10.91.0.0/24 | The CIDR Subnet Address Prefix for the default Operations subnet. It must be in the Operations Virtual Network space
resourcePrefix | None | A prefix, 3-10 alphanumeric characters without whitespace, used to prefix resources and generate uniqueness for resources with globally unique naming requirements like Storage Accounts
resourceSuffix | mlz | A suffix, 3 to 6 characters in length, to append to resource names (e.g. "dev", "test", "prod", "mlz"). It defaults to "mlz"
sharedServicesVirtualNetworkAddressPrefix | 10.93.0.0/16 | The CIDR Virtual Network Address Prefix for the Shared Services Virtual Network
sharedServicesSubnetAddressPrefix | 10.93.0.0/24 | The CIDR Subnet Address Prefix for the default Shared Services subnet. It must be in the Shared Services Virtual Network space
stig | false | Setting to true enables custom script and DSC extension to set STIG controls on Windows remote access VM.
storageUrl | None | When deploying into Hyperscale, needs to be set to the value output from the `publish-to-blob.ps1` script
tenantId | Subscription().tenantId | Required for f5VmAuthenticationType=sshPublicKey. Specifies the tenant ID of the subscription
vdmsSubnetAddressPrefix | 10.90.3.0/24 | Address space used for the VDMS subnet
