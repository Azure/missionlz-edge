# Mission LZ Edge Bicep

## Deployment

### **Prerequisistes**

The Mission LZ - Edge solution was designed to be deployed utilizing a deployment container built from an image defined in this repo.

1. An Azure Stack Hub (ASH) stamp where you or an identity you manage has `Owner` [RBAC permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)
1. A workload subscription on the ASH stamp provisioned using an offering/plan that contains the following providers:
    - Microsoft.Subscriptions
    - Microsoft.Storage
    - Microsoft.KeyVault
    - Microsoft.Compute
    - Microsoft.Network
1. A system separate from the ASH stamp that has the ability to run containers. An example would be a laptop running Windows 10 that has Docker Desktop installed. This system will be referred to in the remainder of this document as the MLZ deployment system
1. Determine version of ASH on target stamp. The version of APIs supported on Azure Stack Hub always trails behind what is currently available in hyperscale Azure. Review the article [Azure Stack Profiles](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-profiles-azure-resource-manager-versions) to determine the profile to be used for the target stamp.
1. The code in this repo has been developed and tested with the ASH versions listed below:

    **Azure Stack Hub Version** | **API Profile Version**
    ------------------------| --------------
    2102 | 2020-09-01-hybrid

### **Common Deployment Parameters**

Below is a table of parameters that should be reviewed before deployment. While not an exhaust list of all parameters, these parameters either do not have default values or have defaults that customers may want to modify:

**Parameter Name**          | **Default value** | **Description**
------------------------| --------------| -----------
resourcePrefix | None | A prefix, 3-10 alphanumeric characters without whitespace, used to prefix resources and generate uniqueness for resources with globally unique naming requirements like Storage Accounts
tenantId | Subscription().tenantId | Required for f5VmAuthenticationType=sshPublicKey. Specifies the tenant ID of the subscription
keyVaultAccessPolicyObjectId | None | Required for f5VmAuthenticationType=sshPublicKey. Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.
f5VmAdminPasswordOrKey | new Guid value | Required for f5VmAuthenticationType=Password.
resourceSuffix | mlz | A suffix, 3 to 6 characters in length, to append to resource names (e.g. "dev", "test", "prod", "mlz"). It defaults to "mlz"
hubVirtualNetworkAddressPrefix | 10.90.0.0/16 | Address space used for the Hub virtual network
mgmtSubnetAddressPrefix | 10.90.0.0/24 | Address space used for the Management subnet
extSubnetAddressPrefix | 10.90.1.0/24 | Address space used for the External subnet
intSubnetAddressPrefix | 10.90.2.0/24 | Address space used for the Internal subnet
vdmsSubnetAddressPrefix | 10.90.3.0/24 | Address space used for the VDMS subnet
operationsVirtualNetworkAddressPrefix | 10.91.0.0/16 | The CIDR Virtual Network Address Prefix for the Operations Virtual Network
operationsSubnetAddressPrefix | 10.91.0.0/24 | The CIDR Subnet Address Prefix for the default Operations subnet. It must be in the Operations Virtual Network space
identityVirtualNetworkAddressPrefix | 10.92.0.0/16 | The CIDR Virtual Network Address Prefix for the Identity Virtual Network
identitySubnetAddressPrefix | 10.92.0.0/24 | The CIDR Subnet Address Prefix for the default Identity subnet. It must be in the Identity Virtual Network space
sharedServicesVirtualNetworkAddressPrefix | 10.93.0.0/16 | The CIDR Virtual Network Address Prefix for the Shared Services Virtual Network
sharedServicesSubnetAddressPrefix | 10.93.0.0/24 | The CIDR Subnet Address Prefix for the default Shared Services subnet. It must be in the Shared Services Virtual Network space
f5VmAuthenticationType | sshPublicKey | Allowed values are {password, sshPublicKey} with a minimum length of 14 characters with atleast 1 uppercase, 1 lowercase, 1 alphnumeric, 1 special character
f5VmAdminUsername | f5admin | Administrator account on the F5 NVAs that get deployed
f5VmSize | Standard_DS3_v2 | The size of the F5 firewall appliance. It defaults to "Standard_DS3_v2"

### **Setup Deployment Container**

The deployment container can be created using the container image generated from the dockerfile in this repo. Transfer the image to the MLZ deployment system. Once the image is on the MLZ deployment system and imported into the local docker repository, perform the steps below to create and configure the deployment container:

1. Execute **docker ...**
1. Execute **docker run ...**
1. From the docker deployment container prompt, register the ASH stamp environment by executing the block of code below, edited for the specific target stamp:

    ```plaintext
    az cloud register /
      --name <environmentname> /
      --endpoint-resource-manager "https://management.<region>.<fqdn>" /
      --suffix-storage-endpoint "<fqdn>" /
      --suffix-keyvault-dns ".vault.<fqdn>" /
      --endpoint-active-directory-graph-resource-id "https://graph.windows.net/"
    ```

1. After registering the stamp, run the command below to make it the active environment:

    ```plaintext
    az cloud set --name <environmentname>
    ```

1. Run the command below to set the API profile for the Azure CLI session:

    ```plaintext
    az cloud update --profile 2020-09-01-hybrid
    ```

1. Authenticate to the stamp by performing an `az login`

### **Azure CLI**

Use `az deployment sub` to deploy MLZ to the subscription set as **isDefault** for the logged on account (and `az deployment sub create --help` for more information).

**Note:** When deploying from a container that does not have access to the Internet, replace the `mlz-ash.bicep` template file in the deployment command with the `mlz-ash.json` file.

#### **Default MLZ Instance deployment**

To deploy Mission LZ with all of the parameter defaults, provide values for the --name and --location parameters (by default, location will be "local" unless that stamp has a custom domain name) and specify the `./mlz-ash.bicep` template file:

Step 1: cd src/bicep

Step 2: Run the bashscript /scripts/generateSshKey.sh to generate new ssh keypair to configure SSH Key-Based Authentication on a Linux VM

Step 3: Run the deployment script below with defaults by providing required parameter values for resourcePrefix and keyVaultAccessPolicyObjectId

```plaintext
az deployment sub create \
  --name myMlzDeployment \
  --location <location> \
  --template-file ./mlz-ash.bicep
```

#### **Custom MLZ Instance deployment**

To deploy an instance of MLZ with customized parameters, utilize the `--parameters` parameter and specify the parameter/value paris to be overriden. The example below is a customer deployment that overrides the `f5VmAuthenticationType` default of `sshPublicKey` with `password`:

```plaintext
az deployment sub create \
  --name myMlzDeployment \
  --location <location> \
  --template-file ./mlz-ash.bicep \
  --parameters \
      f5VmAuthenticationType=password \
```   f5VmAdminPasswordOrKey =<minimum length of 14 characters>
