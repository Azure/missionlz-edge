# Mission LZ Edge Bicep - Tier 3 workload

## Table of Contents

1. [Deployment Prerequisites](#deployment-prerequisistes)
1. [Deployment Parameters](#workload-tier3-deployment-parameters)
1. [Deploy with default parameters](#default-mlz-workload-tier3-instance-deployment)
1. [Post Deployment F5 Configuration](#post-deployment-f5-configuration)

## **Deployment Prerequisistes**

Existing MLZ-Edge instance

## **Workload (Tier3) Deployment Parameters**

Below is a table of parameters that should be reviewed before deployment. While not an exhaustive list of all parameters, these parameters either do not have default values or have defaults that customers may want to modify:

**Parameter Name**          | **Default value** | **Description**
------------------------| --------------| -----------
resourcePrefix | None | A prefix, 3-10 alphanumeric characters without whitespace, used to prefix resources and generate uniqueness for resources with globally unique naming requirements like Storage Accounts & key Vaults
hubDeploymentName | None | Required to extract MLZ-ASH deployment values
hubSubscriptionId | None | Required to extract MLZ-ASH deployment values
hubResourceGroupName | None | Required to extract MLZ-ASH deployment values
workloadVirtualNetworkAddressPrefix | 10.94.0.0/16 | The CIDR Virtual Network Address Prefix for the Workload Virtual Network
workloadsSubnetAddressPrefix | 10.94.0.0/24 | The CIDR Subnet Address Prefix for the default Workload subnet. It must be in the Workload Virtual Network space

## **Default MLZ Workload (Tier3) Instance deployment**

To deploy workload to an existing MLZ-ASH instance with default values for the virtual network and subnet, provide values for the `resourcePrefix, region, hubDeploymentName, hubSubscriptionId,` and `hubResourceGroupName` parameters and specify the `./workloadSpoke.bicep` template file. The deployment will extract values from the hub deployment to be used to deploy the workload Tier3.

Step 1: cd src/bicep/tier3WorkloadSpoke

Step 2: Run the deployment script below:

```plaintext
resourcePrefix="<value>"
region="<value>"
hubDeploymentName="<value>"
hubSubscriptionId="<value>"
hubResourceGroupName="<value>"

az deployment sub create \
  --name "deploy-tier3-${resourcePrefix}" \
  --location ${region} \
  --template-file ./workloadSpoke.bicep \
  --parameters \
      resourcePrefix=${resourcePrefix}
      hubDeploymentName=${hubDeploymentName} \
      hubSubscriptionId=${hubSubscriptionId} \
      hubResourceGroupName=${hubResourceGroupName}
```

## **Post Deployment F5 Configuration**

Once a workload (Tier 3) is deployed, configurations need to be made to the F5 to enable traffic flows out of the new workload. The steps that follow will detail the configurations to make that will enable flows initiated from within the workload virtual network.

The configurations need to be made on the F5 in the MLZ-Edge hub. Access to the F5 portal is done from the Windows 2019 management VM deployed in the hub attached to the `MGMT` subnet.

Remote Access into the virtual network will only be possible from the Windows 2019 VM deployed in the hub. This traffic is allowed via the virtual networking peering that is established between the workload vnet and the hub vnet as part of the workload deployment.

### **Workload to MLZ Tiers Flow**

The steps below will allow traffic initiated in the workload with a destination for one of the MLZ-Edge tiers (Identity, ShareServices, Operations):

In the `Local Traffic > Virtual Servers > Virtual Server List` section, click the `Create...` button and enter the information below:

- Enter a name and description for the Virtual Server (example: `<name_for_workload>_to_MLZ-Spokes`)
- In the `Type` dropdown, select `Forwarding (IP)`
- In the `Source Address` field, enter `<workload_address_space/mask>`. Using deployment defaults, value would be `10.94.0.0/16`
- In the `Destination Address/Mask` field, enter `10.88.0.0/13`. This is the default value which is supernet of the MLZ spoke vnets
- In the `Service Port` field, select `HTTPS`.
- In the `VLAN and Tunnel Traffic` field, select `Enabled on...` from the dropdown.
- In the `VLANS and Tunnels` field, select the VLAN that is associated with the internal subnet (example: `Internal_Interface`).
- In the `Source Address Translation` field, select `Auto Map` from the dropdown.
- Leave all other fields with the default settings and click the `Finished` button at the bottom of the page

### **Workload to External Flow**

The steps below will allow traffic initiated in the workload with a destination external to the MLZ-Edge instance:

- Enter a name and description for the Virtual Server (example: `<name_for_workload>_to_External`)
- In the `Type` dropdown, select `Forwarding (IP)`
- In the `Source Address` field, enter `<workload_address_space/mask>`. Using deployment defaults, value would be `10.94.0.0/16`
- In the `Destination Address/Mask` field, enter `0.0.0.0/0`. This can be further restricted down depending on the desired traffic flow.
- In the `Service Port` field, select `HTTPS`.
- In the `VLAN and Tunnel Traffic` field, select `Enabled on...` from the dropdown.
- In the `VLANS and Tunnels` field, select the VLAN that is associated with the internal subnet (example: `Internal_Interface`).
- In the `Source Address Translation` field, select `Auto Map` from the dropdown.
- Leave all other fields with the default settings and click the `Finished` button at the bottom of the page
