# Mission LZ Edge Bicep Usage Guide

## Table of Contents

1. [Introduction](#introduction)
1. [Deploying into Hyperscale](#deploying-into-hyperscale)
1. [Deploying into ASH](#deploying-into-ash)
1. [Remote Access](#remote-access)
1. [Deployment Examples](#deployment-examples)

## **Introduction**

While MLZ-Edge is designed for use on Azure Stack Hub (ASH), the solution can be deployed into Azure Commercial or Azure Government hyperscale instances for testing or evaluation purposes. When deploying into hyperscale, it is not necessary to use the Marketplace Syndication tool for exporting/importing Marketplace items.

## **Deploying into Hyperscale**

When deploying into hyperscale, it is not required to use the deployment container. The deployment can be done by cloning the repo down to a system that has the following prerequisites. For consistency across ASH and hyperscale deployments, the example deployments provided later in this guide are formatted for deploying from a Linux system.

### **Prerequisites for Hyperscale Deployment**

Deploying to hyperscale requires the following prerequisites:

1. The deployment must be run from a system that has the prerequisites listed below:
    - PowerShell
    - Az PowerShell module
    - Azure CLI
    - Bicep
1. The account used to perform the deployment into hyperscale must have the Owner role on the target subscription

### **Hyperscale Deployment**

1. Connect to the target environment using the PowerShell command `Connect-AzAccount`
1. Populate the target environment with the files necessary for applying STIG configurations by running the PowerShell script detailed below. The script create a storage account in the Resource Group specified and then upload the STIG'ing components to the storage account. The script will also output the URL to the storage account that will be used when executing the deployment of MLZ-Edge:

    ```plaintext
    ./src/scripts/stig/publish-to-blob.ps1 -location <region_to_deploy_into> -resourceGroupName <resource_group_name> -storageAccountPrefix <string_used_in_storage_account_name>
    ```

1. Login to the target environment using Azure CLI
1. Run the deployment using one of the examples in the [Deployment Examples](#deployment-examples) section below. For a list of common parameters that can be modified at deployment time, see the document [Common Parameters](./Common_Parameters.md).
1. From the deployment system, remote (RDP) into the Windows 2019 management VM using the Public IP attached to the VM
1. Configure the F5 BIG-IP using the appropriate guide ([Partially Scripted](./F5_manual_cfg.md) or [Fully Scripted](./F5_scripted_config.md)) for the deployment scenario
1. Test remote (RDP) connectivity to the F5 BIG-IP using the `Inbound` public IP of the F5
1. If the test in the previouis step is successful, disassociate the public IP attached to the Windows 2019 management VM NIC and delete the public IP resource

## **Deploying into ASH**

### **Prerequisites for ASH Deployment**

Deploying to an ASH stamp requires the following prerequisites:

1. A workload subscription on the ASH stamp provisioned using an offering/plan that contains the following providers:
    - Microsoft.Subscriptions
    - Microsoft.Storage
    - Microsoft.KeyVault
    - Microsoft.Compute
    - Microsoft.Network
1. The account used to perform the deployment must have the Owner role on the target subscription
1. The deployment is done using the [Deployment Container](./Deployment_container_setup.md). The system used to run the container needs to have the dependencies below:
    - Modern browser (Edge, Chrome)
    - GIT
    - WSL
    - Docker Desktop

### **ASH Deployment**

>**NOTE**: Prior to deploying Mission LZ - Edge to an ASH stamp, it is required that the necessary Marketplace items are available in the target ASH Marketplace. Follow the steps outlined in the [Deployment Container Setup README](./Deployment_container_setup.md) to populate the ASH Marketplace with the required SKUs.
>
>**NOTE**: The required Marketplace items and specific versions can be found in the text file used by the container to download. The file is located [here](../src/artifacts/defaultMlzMarketPlaceItems.txt).
>
>**NOTE**: The version of APIs supported on Azure Stack Hub always trails behind what is currently available in hyperscale Azure. Review the article [Azure Stack Profiles](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-profiles-azure-resource-manager-versions) to determine the profile to be used for the target stamp.
>
>**NOTE**: The code in this repo has been developed and tested with the ASH versions listed below:
>
>**Azure Stack Hub Version** | **API Profile Version**
>------------------------| --------------
>2102 | 2020-09-01-hybrid

1. Follow the steps outlined in the [Deployment Container Setup README](./Deployment_container_setup.md) to download the required Marketplace items from a hyperscale environment
1. Transfer the container image created in the previous step to the deployment system that is connected to the same network as the ASH stamp
1. Follow the steps outlined in the [Deployment Container Setup README](./Deployment_container_setup.md) to upload Marketplace items and scripts to the ASH stamp
1. Determine version of ASH on target stamp
1. From the bash prompt in the Docker container, register the ASH stamp environment by executing the block of code below, edited for the specific target stamp:

    ```plaintext
    az cloud register /
      --name <environmentname> /
      --endpoint-resource-manager "https://management.<region>.<fqdn>" /
      --suffix-storage-endpoint "<fqdn>" /
      --suffix-keyvault-dns ".vault.<fqdn>" /
      --endpoint-active-directory-graph-resource-id "https://graph.windows.net/"
    ```

1. After registering the stamp, execute the command below to set the stamp as the active environment:

    ```plaintext
    az cloud set --name <environmentname>
    ```

1. Execute the command below to set the API profile for the Azure CLI session:

    ```plaintext
    az cloud update --profile 2020-09-01-hybrid
    ```

1. Authenticate to the stamp by executing the command `az login`
1. Run the deployment using one of the examples in the [Deployment Examples](#deployment-examples) section below. For a list of common parameters that can be modified at deployment time, see the document [Common Parameters](./Common_Parameters.md).
1. From the deployment system, remote (RDP) into the Windows 2019 management VM using the Public IP attached to the VM
1. Configure the F5 BIG-IP using the appropriate guide ([Partially Scripted](./F5_manual_cfg.md) or [Fully Scripted](./F5_scripted_config.md)) for the deployment scenario
1. Test remote (RDP) connectivity to the F5 BIG-IP using the `Inbound` public IP of the F5
1. If the test in the previouis step is successful, disassociate the public IP attached to the Windows 2019 management VM NIC and delete the public IP resource

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

The example below is for `password` auth and [applies STIG settings](./STIG_Guide.md) in Azure Government:
>**Note:** In commercial or Government cloud the artifacts required to configure and STIG VMs need to be uploaded using `./src/scripts/stig/publish-to-blob.ps1`. The url output from the script is the value used in the `storageUrl` parameter

```plaintext
resourcePrefix="<value>"
f5VmImageVersion="15.1.400000"
keyVaultAccessPolicyObjectId="<value>"
region=<value>
storageUrl="<value_output_from_publish-to-blob_script>"

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      stig="true" \
      resourcePrefix=${resourcePrefix} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
      storageUrl=${storageUrl}
```

The example below is for `password` auth on an Azure Stack Hub registered in Azure Government:

```plaintext
resourcePrefix="<value>"
keyVaultAccessPolicyObjectId="<value>"
region=<value>

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      stig="true" \
      resourcePrefix=${resourcePrefix} \
      f5VmAuthenticationType=${f5AuthType} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
```

The example below is for `sshPublicKey` auth and [applies STIG settings](./STIG_Guide.md) in Azure Government:
>**Note:** In commercial or Government cloud the artifacts required to configure and STIG VMs need to be uploaded using `./src/scripts/stig/publish-to-blob.ps1`. The url output from the script is the value used in the `storageUrl` parameter
>
>**Note:** Before doing a deployment using `sshPublicKey`, the `./src/scripts/generateSshKey.sh` script must be run from the `./src/bicep` folder.

```plaintext
resourcePrefix="<value>"
f5AuthType="sshPublicKey"
f5VmImageVersion="15.1.400000"
keyVaultAccessPolicyObjectId="<value>"
region="<value>"
storageUrl="<value_output_from_publish-to-blob_script>"

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      stig="true" \
      resourcePrefix=${resourcePrefix} \
      f5VmAuthenticationType=${f5AuthType} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId} \
      storageUrl=${storageUrl}
```

The example below uses `sshPublicKey` auth and [applies STIG settings](./STIG_Guide.md) on an Azure Stack Hub registered in Azure US Government.

>**Note:** Before doing a deployment using `sshPublicKey`, the `./src/scripts/generateSshKey.sh` script must be run from the `./src/bicep` folder.

```plaintext
resourcePrefix="<value>"
f5AuthType="sshPublicKey"
keyVaultAccessPolicyObjectId="<value>"
region="<value>"

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      stig="true" \
      resourcePrefix=${resourcePrefix} \
      f5VmAuthenticationType=${f5AuthType} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
```

The example below uses `password` auth and [applies STIG settings](./STIG_Guide.md) in Azure Commercial (or an Azure Stack Hub registered in Azure Commercial).

```plaintext
resourcePrefix="<value>"
f5VmImageVersion="16.0.101000"
keyVaultAccessPolicyObjectId="<value>"
region=<value>
storageUrl="<value_output_from_publish-to-blob_script>"

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      stig="true" \
      resourcePrefix=${resourcePrefix} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId} \
      storageUrl=${storageUrl}
```

The example below is for `sshPublicKey` auth in Azure Commercial.

>**Note:** Before doing a deployment using `sshPublicKey`, the `./src/scripts/generateSshKey.sh` script must be run from the `./src/bicep` folder.

```plaintext
resourcePrefix="<value>"
f5AuthType="sshPublicKey"
f5VmImageVersion="16.0.101000"
keyVaultAccessPolicyObjectId="<value>"
region=<value>
storageUrl="<value_output_from_publish-to-blob_script>"

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      stig="true" \
      resourcePrefix=${resourcePrefix} \
      f5VmAuthenticationType=${f5AuthType} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
      storageUrl=${storageUrl}
```

The example below is for `sshPublicKey` auth on an Azure Stack Hub registered in Azure Commercial.

>**Note:** Before doing a deployment using `sshPublicKey`, the `./src/scripts/generateSshKey.sh` script must be run from the `./src/bicep` folder.

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
      stig="true" \
      resourcePrefix=${resourcePrefix} \
      f5VmAuthenticationType=${f5AuthType} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId}
```

The example is for `sshPublicKey` auth in Azure Commercial and includes the Linux VM option:

>**Note:** Before doing a deployment using `sshPublicKey`, the `./src/scripts/generateSshKey.sh` script must be run from the `./src/bicep` folder.

```plaintext
resourcePrefix="<value>"
f5AuthType="sshPublicKey"
f5VmImageVersion="16.0.101000"
keyVaultAccessPolicyObjectId="<value>"
region=<value>
storageUrl="<value_output_from_publish-to-blob_script>"

az deployment sub create \
  --name "deploy-mlz-${resourcePrefix}" \
  --location ${region} \
  --template-file ./mlz-ash.bicep \
  --parameters \
      resourcePrefix=${resourcePrefix} \
      deployLinux=true
      f5VmAuthenticationType=${f5AuthType} \
      f5VmImageVersion=${f5VmImageVersion} \
      keyVaultAccessPolicyObjectId=${keyVaultAccessPolicyObjectId} \
      storageUrl=${storageUrl}
```
