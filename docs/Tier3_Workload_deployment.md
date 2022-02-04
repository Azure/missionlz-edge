# Mission LZ Edge Bicep - Tier 3 workload

## Deployment

### **Prerequisistes**

The Mission LZ - Edge existing deployment to Azure Stack subscription.

### **Common Workload(tier3)Deployment Parameters**

Below is a table of parameters that should be reviewed before deployment. While not an exhaustive list of all parameters, these parameters either do not have default values or have defaults that customers may want to modify:

**Parameter Name**          | **Default value** | **Description**
------------------------| --------------| -----------
resourcePrefix | None | A prefix, 3-10 alphanumeric characters without whitespace, used to prefix resources and generate uniqueness for resources with globally unique naming requirements like Storage Accounts & key Vaults
hubDeploymentName | None | Required to extract MLZ-ASH deployment values
hubSubscriptionId | None | Required to extract MLZ-ASH deployment values
hubResourceGroupName | None | Required to extract MLZ-ASH deployment values
workloadVirtualNetworkAddressPrefix | 10.94.0.0/16 | The CIDR Virtual Network Address Prefix for the Workload Virtual Network
workloadsSubnetAddressPrefix | 10.94.0.0/24 | The CIDR Subnet Address Prefix for the default Workload subnet. It must be in the Workload Virtual Network space

#### **Default MLZ workload(tier3) Instance deployment**

To deploy workload to an existing MLZ-ASH instance with default values, provide values for the --name, --location parameters (by default, location will be "local" unless that stamp has a custom domain name) and specify the `./workloadSpoke.bicep` template file with following parameters to extract output values of existing MLZ-ASH deployment: resourcePrefix,hubDeploymentName,hubSubscriptionId, and hubResourceGroupName

Step 1: cd src/bicep/tier3WorkloadSpoke

Step 2: Run the deployment script below with defaults by providing required parameter values for resourcePrefix and keyVaultAccessPolicyObjectId

```plaintext
az deployment sub create \
  --name <t3 deployment Name> \
  --template-file workloadSpoke.bicep \
  --location 3173r03b \
  --parameters \
      resourcePrefix =<resource prefix> \
      hubDeploymentName = {Hub and Spoke Deployment Name that recently deployed} \
      hubSubscriptionId = {Hub Subscription Id} \
      hubResourceGroupName = {Hub Resource Group Name}
