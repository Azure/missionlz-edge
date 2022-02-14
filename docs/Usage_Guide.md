# Mission LZ Edge Bicep Usage Guide

## Table of Contents

1. [Deployment Prerequisites](#prerequisistes)
1. [Deployment Parameters](#common-deployment-parameters)
1. [Setup Deployment Container](#setup-deployment-container)
1. [Remote Access](#remote-access)
1. [Deployment Examples](#deployment-examples)
1. [Deployment Process](#deployment-process)
1. [Workload Deployment](#workload-deployment)

## **Prerequisistes**

The Mission LZ - Edge solution was designed to be deployed utilizing a deployment container built from an image defined in this repo.

>**NOTE**: Prior to deploying Mission LZ - Edge it is required that the necessary Marketplace items are available in the target ASH Marketplace. Follow the steps outlined in the [Deployment Container Setup README](./Deployment_container_setup.md) to populate the ASH Marketplace with the required SKUs.

The required Marketplace items and specific versions can be found in the text file used by the container to download. The file is located [here](../src/artifacts/defaultMlzMarketPlaceItems.txt).

1. An Azure Stack Hub (ASH) stamp where you or an identity you manage has `Owner` [RBAC permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)
1. A workload subscription on the ASH stamp provisioned using an offering/plan that contains the following providers:
    - Microsoft.Subscriptions
    - Microsoft.Storage
    - Microsoft.KeyVault
    - Microsoft.Compute
    - Microsoft.Network
1. A system separate from the ASH stamp that has the ability to run containers and has a browser supported by the Azure portal (Edge, Chrome, etc.). An example would be a laptop running Windows 10 that has Docker Desktop installed. This system will be referred to in the remainder of this document as the MLZ deployment system
1. Determine version of ASH on target stamp. The version of APIs supported on Azure Stack Hub always trails behind what is currently available in hyperscale Azure. Review the article [Azure Stack Profiles](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-profiles-azure-resource-manager-versions) to determine the profile to be used for the target stamp.
1. The code in this repo has been developed and tested with the ASH versions listed below:

    **Azure Stack Hub Version** | **API Profile Version**
    ------------------------| --------------
    2102 | 2020-09-01-hybrid

## **Common Deployment Parameters**

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
f5VmImageVersion | 15.1.004000 | Version of F5 BIG-IP sku being deployed
[artifactsUrl](./STIG_Guide.md) | None | Setting to the storage suffix will allow Desired State Configuration on Windows remote access host to set STIG related controls. ie: location.azurestack.local
deployLinux | false | Setting to true deploys a Ubuntu 180.04 management VM alongside the Windows 2019 management VM using the same credentials

>**NOTE** The `artifactsUrl` parameter is reliant on the existance of a storage account that has been populated with source files using the deployment container. If deploying MLZ-Edge into Azure Commercial or Azure Government hyper-scale, do not include the `artifactsUrl` in the deployment command.

## **Setup Deployment Container**

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

## **Remote Access**

The default MLZ-Edge deployment includes a Windows 2019 management VM that is deployed with a public IP address. This VM is used to access the F5 BIG-IP to complete the configurations.

Once the F5 BIG-IP is completely configured, test accessing the Windows 2019 management VM by RDP'ing to the Public IP address of the `Secondary` IP Configuration of the external F5 network interface card. If the RDP is successful, the Public IP associated with the network interface card of the Windows 2019 management VM can be deleted.

The deployment code has a parameter called `deployLinux` that when set to `true`, deploys a Ubuntu 18.04 management VM alongside the Windows 2019 management VM. The Ubuntu VM is not deployed with a Public IP and will need to be accessed via the Windows 2019 maangement VM.

>**NOTE**: When a linux VM is deployed as part the initial MLZ-Edge deployment, the credentials (admin username/password) are the same for both the Windows and Linux VMs.
Should the Linux VM be deployed after the initial deployment, the deployer has the option to use the password as before or to use a different password.

## **Deployment Examples**

Use `az deployment sub` to deploy MLZ to the subscription set as **isDefault** for the logged on account (run `az deployment sub create --help` for additional information).

>**NOTE**: When deploying from a container that does not have access to the Internet, replace the `mlz-ash.bicep` template file in the deployment command with the `mlz-ash.json` file.
>
>**NOTE**: To deploy Mission LZ with all of the parameter defaults, provide values for the `--name` and `--location` parameters (by default, location will be "local" unless that stamp has a custom domain name) and specify the `./mlz-ash.bicep` template file.

To deploy an instance of MLZ with customized parameters, utilize the `--parameters` parameter and specify the parameter/value paris to be overriden.

The example below is for "password" auth in Azure Government:

```plaintext
resourcePrefix="<value>"
f5VmImageVersion="15.1.400000"
keyVaultAccessPolicyObjectId="<value>"
region=<value>

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      resourcePrefix=${resourcePrefix} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
```

The example below is for "password" auth on an Azure Stack Hub registered in Azure Government:

```plaintext
resourcePrefix="<value>"
f5AuthType="password"
keyVaultAccessPolicyObjectId="<value>"
region=<value>

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      resourcePrefix=${resourcePrefix} \
      f5VmAuthenticationType=${f5AuthType} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
```

The example below is a custom deployment in Azure Government that overrides the `f5VmAuthenticationType` default of `password` with `sshPublicKey`:

```plaintext
resourcePrefix="<value>"
f5AuthType="sshPublicKey"
f5VmImageVersion="15.1.400000"
keyVaultAccessPolicyObjectId="<value>"
region="<value>"

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      resourcePrefix=${resourcePrefix} \
      f5VmAuthenticationType=${f5AuthType} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
```

The example below is a custom deployment on and Azure Stack Hub registered in Azure Government that overrides the `f5VmAuthenticationType` default of `password` with `sshPublicKey` and [allows setting STIG controls on the Windows machine](./STIG_Guide.md) by setting `artifactsUrl` to the storage accounts suffix, ie; local.azurestack.external:

```plaintext
resourcePrefix="<value>"
f5AuthType="sshPublicKey"
keyVaultAccessPolicyObjectId="<value>"
region="<value>"
artifactsUrl="<value>"

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      artifactsUrl=${artifactsUrl} \
      resourcePrefix=${resourcePrefix} \
      f5VmAuthenticationType=${f5AuthType} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
```

The example below is for `password` auth in Azure Commercial (or an Azure Stack Hub registered in Azure Commercial).

>**NOTE**: Setting STIG to true is currently not available in Commercial:

```plaintext
resourcePrefix="<value>"
f5VmImageVersion="16.0.101000"
keyVaultAccessPolicyObjectId="<value>"
region=<value>

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      resourcePrefix=${resourcePrefix} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
```

The example below is for `sshPublicKey` auth in Azure Commercial (or an Azure Stack Hub registered in Azure Commercial).

>**NOTE**: Setting STIG to true is currently not available in Commercial:

```plaintext
resourcePrefix="<value>"
f5AuthType="sshPublicKey"
f5VmImageVersion="16.0.101000"
keyVaultAccessPolicyObjectId="<value>"
region=<value>

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      resourcePrefix=${resourcePrefix} \
      f5VmAuthenticationType=${f5AuthType} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
```

The example is for `sshPublicKey` auth in Azure Commercial (or an Azure Stack Hub registered in Azure Commercial) and includes the Linux VM option:

>**NOTE**: Setting STIG to true is currently not available in Commercial:

```plaintext
resourcePrefix="<value>"
f5AuthType="sshPublicKey"
f5VmImageVersion="16.0.101000"
keyVaultAccessPolicyObjectId="<value>"
region=<value>

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      resourcePrefix=${resourcePrefix} \
      deployLinux=true
      f5VmAuthenticationType=${f5AuthType} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
```

## **Deployment Process**

To deploy an initial instance of MLZ onto an Azure Stack Hub stamp that has been previously setup with at least one plan and one offering, follow the steps below. After deploying the initial instance on a stamp, additional instances can be deployed by just repeating steps X thru Y:

1. Clone this repo to an Internet connected system that is running `Windows Subsystem for Linux (WSL)` and `Docker Desktop`
1. Follow the steps outlined in the document [Deployment Container Setup](./Deployment_container_setup.md) to complete the following steps:
    - Prepare a container image to used to perform the deployment
    - Save image and transfer to deployment system running `Windows Subsystem for Linux (WSL)` and `Docker Desktop` on disconnected network
    - Create deployment container using image transferred from connected environment
    - From deployment container, populate the Marketplace of the target Azure Stack Hub stamp
1. From within the deployment container, deploy the MLZ-Edge instance using Azure CLI ([examples](#deployment-examples))
    >**NOTE**: Execute deployment from the `src/bicep` folder
    >
    >**NOTE**: If using SSH keys for auth to the F5, run the script `generateSshKey.sh` to generate a new ssh keypair. Execute the script from the `src/bicep` folder by executing `../scripts/generateSshKey.sh`
1. From the deployment system, remote (RDP) into the Windows 2019 management VM using the Public IP attached to the VM
1. Configure the F5 BIG-IP using the appropriate guide ([Partially Scripted](./F5_manual_cfg.md) or [Fully Scripted](./F5_scripted_config.md)) for the deployment scenario
1. Test remote (RDP) connectivity to the F5 BIG-IP using the `Inbound` public IP of the F5
1. If the test in the previouis step is successful, disassociate the public IP attached to the Windows 2019 management VM NIC and delete the public IP resource

## **Workload Deployment**

Once the MLZ-Edge instance is deployed and functional as outlined in the [Deployment Process](#deployment-process) section, `N` number of Tier 3 deployments can be performed to integrate workloads with the MLZ-Edge instance. Refer to the [Tier 3 Workload Deployment Guide](./Tier3_Workload_deployment.md) for details on deploying workloads.
