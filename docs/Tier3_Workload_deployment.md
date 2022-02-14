# Mission LZ Edge Bicep - Tier 3 workload

## Table of Contents

1. [Deployment Prerequisites](#deployment-prerequisistes)
1. [Deployment Parameters](#workload-tier3-deployment-parameters)
1. [Deploy with default parameters](#default-mlz-workload-tier3-instance-deployment)
1. [Deploy with custom parameters](#custom-mlz-workload-tier3-instance-deployment)
1. [Post Deployment F5 Configuration](#post-deployment-f5-configuration)

## **Deployment Prerequisistes**

Existing MLZ-Edge instance

## **Workload (Tier3) Deployment Parameters**

Below is a table of parameters that should be reviewed before deployment. While not an exhaustive list of all parameters, these parameters either do not have default values or have defaults that customers may want to modify:

**Parameter Name**          | **Default value** | **Description**
------------------------| --------------| -----------
addSpokeRules | false | Boolen value that is used to enable or disable the addition of NSG rules to the MLZ spoke NSGs to allow traffic to flow from the workload to the Identity, Operations, and ShareServices spoke
rulePriority | 100 | Integer value that denotes the priority to assign to a rule
resourcePrefix | None | A prefix, 3-10 alphanumeric characters without whitespace, used to prefix resources and generate uniqueness for resources with globally unique naming requirements like Storage Accounts & key Vaults
hubDeploymentName | None | Required to extract MLZ-ASH deployment values
hubSubscriptionId | None | Required to extract MLZ-ASH deployment values
hubResourceGroupName | None | Required to extract MLZ-ASH deployment values
workloadVirtualNetworkAddressPrefix | 10.100.0.0/16 | The CIDR Virtual Network Address Prefix for the Workload Virtual Network
workloadsSubnetAddressPrefix | 10.100.0.0/24 | The CIDR Subnet Address Prefix for the default Workload subnet. It must be in the Workload Virtual Network space

## **Default MLZ Workload (Tier3) Instance deployment**

To deploy workload to an existing MLZ-ASH instance with default values for the virtual network and subnet, provide values for the `resourcePrefix, region, hubDeploymentName, hubSubscriptionId,` and `hubResourceGroupName` parameters and specify the `./workloadSpoke.bicep` template file. The deployment will extract values from the hub deployment to be used to deploy the workload Tier3.
Using the default deployment example below, the workload will be deployed but will NOT be able to communicate with resources deployed in the MLZ spokes (Identity, Operations, Shared Services)

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

## **Custom MLZ Workload (Tier3) Instance deployment**

To deploy a workload to an existing MLZ-ASH instance with custom values for other parameters, provide values for the `resourcePrefix, region, hubDeploymentName, hubSubscriptionId,` and `hubResourceGroupName` parameters, specify the `./workloadSpoke.bicep` template file then add the additional parameters to be changed.
The deployment will extract values from the hub deployment to be used to deploy the workload Tier3.
The deployment below enables rules being added to the Network Security Groups (NSGs) of the MLZ spokes (Identity, Operations, Shared Services).
Using the example below would add an NSG rule to each of the spoke NSGs aloowing traffic from the workload to flow into the spoke. If using this example, make sure to also follow the steps outline in optional [section](#optional---post-deployment-f5-configuration) below to configure the fire wall for the traffic flow.

Step 1: cd src/bicep/tier3WorkloadSpoke

Step 2: Run the deployment script below:

```plaintext
resourcePrefix="<value>"
region="<value>"
hubDeploymentName="<value>"
hubSubscriptionId="<value>"
hubResourceGroupName="<value>"
addSpokeRules="true"
rulePriority="<value>"

az deployment sub create \
  --name "deploy-tier3-${resourcePrefix}" \
  --location ${region} \
  --template-file ./workloadSpoke.bicep \
  --parameters \
      resourcePrefix=${resourcePrefix}
      hubDeploymentName=${hubDeploymentName} \
      hubSubscriptionId=${hubSubscriptionId} \
      hubResourceGroupName=${hubResourceGroupName} \
      addSpokeRules=${addSpokeRules} \
      rulePriority=${rulePriority}
```

## **Post Deployment F5 Configuration**

Once a workload (Tier 3) is deployed, configurations need to be made to the F5 to enable traffic flows out of the new workload. The steps that follow will detail the configurations to make that will enable flows initiated from within the workload virtual network.

The configurations need to be made on the F5 in the MLZ-Edge hub. Access to the F5 portal is done from the Windows 2019 management VM deployed in the hub attached to the `MGMT` subnet.

Remote Access into the workload (Tier 3) virtual network will only be possible from the Windows 2019 VM deployed in the hub. This traffic is allowed via the virtual network peering that is established between the workload virtual network and the hub virtual network as part of the workload deployment.

### **OPTIONAL - Workload to MLZ Tiers Flow**

The steps below should only be performed if the workload was deployed setting the `addSpokeRules` parameter to `true`. The steps below will allow traffic initiated in the workload with a destination for one of the MLZ-Edge tiers (Identity, Shared Services, Operations):

In the `Local Traffic > Virtual Servers > Virtual Server List` section, click the `Create...` button and enter the information below:

- Enter a name and description for the Virtual Server (example: `<name_for_workload>_to_MLZ-Spokes`)
- In the `Type` dropdown, select `Forwarding (IP)`
- In the `Source Address` field, enter `<workload_address_space/mask>`. Using deployment defaults, value would be `10.100.0.0/16`
- In the `Destination Address/Mask` field, enter `10.88.0.0/13`. This is the default value which is a supernet of the MLZ spoke virtual networks
- In the `Service Port` field, select `* All Ports`.
- In the `VLAN and Tunnel Traffic` field, select `Enabled on...` from the dropdown.
- In the `VLANS and Tunnels` field, select the VLAN that is associated with the internal subnet (example: `Internal_Interface`).
- In the `Source Address Translation` field, select `Auto Map` from the dropdown.
- Leave all other fields with the default settings and click the `Finished` button at the bottom of the page

### **Workload to External Flow**

The steps below will allow traffic initiated in the workload with a destination external to the MLZ-Edge instance:

- Enter a name and description for the Virtual Server (example: `<name_for_workload>_to_External`)
- In the `Type` dropdown, select `Forwarding (IP)`
- In the `Source Address` field, enter `<workload_address_space/mask>`. Using deployment defaults, value would be `10.100.0.0/16`
- In the `Destination Address/Mask` field, enter `0.0.0.0/0`. This can be further restricted down depending on the desired traffic flow.
- In the `Service Port` field, select `HTTPS`.
- In the `VLAN and Tunnel Traffic` field, select `Enabled on...` from the dropdown.
- In the `VLANS and Tunnels` field, select the VLAN that is associated with the internal subnet (example: `Internal_Interface`).
- In the `Source Address Translation` field, select `Auto Map` from the dropdown.
- Leave all other fields with the default settings and click the `Finished` button at the bottom of the page
