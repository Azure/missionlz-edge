# Post-deployment F5 BIG-IP configuration

## Table of Contents

1. [Introduction](#introduction)
1. [Prerequisites](#prerequisites)
1. [Accessing the F5](#accessing-the-f5)
1. [Configuring the F5 BIG-IP](#configuring-the-f5-big-ip)
    - [Setup Utility](#setup-utility)
    - [Network Configuration](#network-configuration)
    - [Routes](#routes)
    - [Local Traffic](#local-traffic)
    - [Virtual Servers](#virtual-servers)
1. [Applying Network and STIG Configurations to F5](#applying-stig-configurations-to-f5)

## Introduction

This guide will walk the MLZ-Edge deployer thru the steps to manually configure the F5 BIG-IP with the base configurations that will implement the following functionalities:

- Spoke-to-Spoke (East-West) traffic routing
- Spoke-to-Platform (North-South) traffic routing
- Allow Inbound RDP traffic to the Windows management VM
- Apply applicable DoD compliance related configurations

## Prerequisites

- Public IP address of the Windows 2019 management VM deployed as part of the MLZ solution.
- Password of `azureuser` account created on Windows 2019 management VM (created and stored in Key Vault at deployment time).
- IP assigned to the network interface card of the F5 BIG-IP attached to the `mgmt` subnet (This is normally `.4` of the subnet assigned to the `mgmt` subnet. The default is `10.90.0.4`). This value is referred to as `<mgmt-ip-of-f5>` in the documentation sections below.
- F5 BIG-IP license key.
- Password or SSH private key for `f5admin` account. When deploying using `password` for the value of the `f5VmAuthenticationType` parameter, the password gets created and stored in Key Vault at deployment time. When using `sshPublicKey` for the value of the `f5VmAuthenticationType` parameter, the SSH private key will be stored in the repo of the system used to deploy the MLZ instance.

## Accessing the F5

From the system used to deploy the instance, RDP into the Windows 2019 management VM using the public IP. The credentials to use to authenticate to the VM are `azureuser` along with the password retrieved from the Key Vault.

Once logged onto the Windows 2019 VM, right-click on the Internet Explorer icon on the Taskbar, right-click on `Internet Explorer` from the menu that opens and then select `Run as administrator`. Click `Yes` on the UAC dialog box that pops up.

In the address bar of Internet Explorer, enter the URL `https://<private_management_ip_of_the_F5_BIG-IP>`. The URL for a default deployment would be (<https://10.90.0.4>). In the Security Alert popup that opens, check the box next to `In the future, do not show this warning` and then click `OK`.
A page stating `This site is not secure` should appear. Click the `More information` drop down on the page and then click on `Go on to the webpage (not recommended)` link.

The `F5 BIG-IP Configuration Utility` page should appear. Login to the page with `f5admin` along with the password retrieved from the Key Vault.

## Configuring the F5 BIG-IP

### Setup Utility

Once logged into the F5 BIG-IP, the screen displayed will be the `Welcome` page of the `Setup Utility`. Click `Next` on the page.

On the `General Properties`, click `Activate` to enter the license key. Enter the license key into the `Base Registration Key` field, select `Manual` in the `Activation Method` field and then click the `Next` button.

On the next screen, select `Download/Upload File` and then click the `Click Here To Download Dossier File`. Transfer the `dossier.do` file downloaded to the `Downloads` folder to a system that has Internet connectivity.

From a system that has Internet connectivity, using a browser...navigate to the [F5 License Activation site](https://activate.f5.com/license)

On the `Activate F5 Product` webpage, click on `Choose File`, select the `dossier.do` file transferred from the BIG-IP and then click `Next`.

On the `End User Legal Agreement` page, check the box next to `I have read and agree to the terms of this license` near the bottom of the page and then click `Next`.

Click the button `Download license` to download the license file. Transfer the `License.txt` file back to the Windows 2019 management VM.

Back on the Windows 2019 management VM on the `Setup Utility >> License` page, click the Browse button to select the license file to upload. In the browser window that opens, navigate to and select the `License.txt` file downloaded from the F5 activation site and then click `Next` to upload the file to the F5 BIG-IP.

The F5 BIG-IP should now be licensed and activated and the `Resource Provisioning` page should be displayed.

>**NOTE**: The BIG-IP may log the user out before presenting the `Resource Provisioning` page. If this happens, re-authenticate and continue the setup process.

On the `Resource Provisioning` page, leave all default settings as configured and click on the `Next` button at the bottom of the page.

On the `Device Certificates` page, import a customer cert if desired or to proceed with the self-signed cert for testing purposes click `Next`.

On the `Platform` page, make the following configurations and then click `Next`:

- Enter a desired hostname for the F5 (example: `mlzashf5.local`)
- Select the desired time zone
- Uncheck the box next to `Disable login` for the Root Account field
- Enter a secure password for the Root account
- Select `Specify Range` in the `SSH IP Allow` section and then enter the CIDR information for the management subnet (default is 10.90.0.0/24)

On the `Network` page, click `Finished` under `Advanced Network Configuration`.

### Network Configuration

#### Interfaces

In the `Network > Interfaces` section click on each discovered interface and enter a description (labels such as `External, Internal, VDMS`) for the interface. To understand which interface is connected to which subnet, it can be helpful to view the interfaces via the Azure Stack portal and observe the MAC address of the interface

#### VLANs

In the `Network > VLANs > VLAN List` section, create a VLAN for each of the interfaces (`External, Internal, VDMS`) by clicking the `Create...` button and entering in the information listed below:

- Enter a name and description for the VLAN (example: `External_Interface`)
- Select the interface that will be attached to the VLAN in the `Interface` dropdown, select `untagged` in the `Tagging` dropdown and then click the `Add` button
- Leave all other fields with the default settings and click the `Finished` button at the bottom of the page

#### Self IPs

Using the Azure Stack portal, note the IP address that was assigned to each of the F5 interfaces (`External, Internal, VDMS`). The default IPs are `10.90.1.4, 10.90.2.4, 10.90.3.4` respectfully. In the `Network > Self IPs` section, create a new IP for each interface by clicking the `Create...` button and entering in the information listed below:

- Enter a name for the Self IP (Example: ``)
- Enter the `IP Address` of the F5 interface associated with the Self IP being created
- Enter the `Netmask` of the F5 interface associated with the Self IP being created
- Select the `VLAN/Tunnel` of the F5 interface associated with the Self IP being created
- Leave all other fields with the default settings and click the `Finished` button at the bottom of the page

### Routes

#### Default Route

In the `Network > Routes` section, create the default route by clicking the `Add` button and entering in the information listed below:

- Enter a `Name` for the Route (Example: `Default_Route`)
- Enter a `Description` for the Route (Example: `External`)
- Enter `0.0.0.0` for the `Destination` and `Netmask` fields
- In the `Resource` field, select `Gateway` from the dropdown
- In the `Gateway Address` field, enter in the IP address of the gateway for the `External` subnet. The default value is `10.90.1.1`
- Click the `Finished` button at the bottom of the page

#### Spoke-to-Spoke (East-West) Routes

The MLZ architecture has 3 spokes (`Identity, Operations,` and `SharedServices`) each of which are peered with the `Hub` but are not peered with one another. In-order for the spokes to be able to talk with one another, a route must be added to the F5 that will pass traffic between the spokes.

Depending on the IP scheme used when the MLZ instance was deployed, the `Spoke-to-Spoke` traffic can be summarized into a single route by super-netting the IP address spaces of each spoke virtual networkinto a single CIDR block. The steps below add a single route by super-netting the default address space.

In the `Network > Routes` section, create the spoke-to-spoke route by clicking the `Add` button and entering in the information listed below:

- Enter a `Name` for the Route (Example: `Traffic_between_MLZ_Tiers`)
- Enter a `Description` for the Route (Example: `Spoke-to-Spoke Traffic`)
- Enter `10.88.0.0` for the `Destination` field
- Enter `255.248.0.0` for the `Netmask` field
- In the `Resource` field, select `Gateway` from the dropdown
- In the `Gateway Address` field, enter in the IP address of the gateway for the `Internal` subnet. The default value is `10.90.2.1`
- Click the `Finished` button at the bottom of the page

### Local Traffic

#### Pools & Nodes

Pools can be defined to group 1 to many servers that host the same services. Create a pool for the Windows remote access server using the steps below:

In the `Local Traffic > Pools > Pool List` section, click the `Create...` button and enter the information below:

- Enter a name and description for the Pool (example: `RemoteAccess_Windows`)
- In the `New Members` field, add the information below for the Windows 2019 management VM and then click the `Add` button
  - Node Name: `RemoteAccess_Windows_VM_1`
  - Address: `<private_mgmt_IP_address_of_Windows_VM>` (Default: 10.90.0.5)
  - Service Port: `3389`
- Click the `Finished` button to create the node and the pool

### Virtual Servers

#### Inbound RDP Traffic

At deployment time, the Windows 2019 management server was deployed with a Public IP Address to enable the configuration of the F5. This was only meant to be a temporary configuration so the F5 needs to be configured to allow inbound RDP traffic to the server so that the Public IP Address can be removed from the management server.

In-order to complete the configuration below, collect the private IP of the F5. Using the Azure Stack portal, navigating to the `<resourcePrefix>-nic-f5vm01-ext-mlz` resource in the `Hub` resource group, selecting the `IP configurations` blade and then noting the private IP assigned to the configuraiton name `<resourcePrefix>-ipconf-f5vm01-ext2-mlz`. The default value is `10.90.1.5`

In the `Local Traffic > Virtual Servers > Virtual Server List` section, click the `Create...` button and enter the information below:

- Enter a name and description for the Virtual Server (example: `Allow_RDP_to_MGMT`)
- In the `Type` dropdown, select `Standard`
- In the `Source Address` field, enter `0.0.0.0/0`. If it is known that external (inbound) RDP will only be performed from a set of know IPs or address range, that IP/range can be entered here instead of `0.0.0.0/0`
- In the `Destination Address/Mask` field, enter the private IP address assigned to the F5's external interface as noted above (default value: `10.90.1.5`).
- In the `Service Port` field, select `Other` in the dropdown and then enter `3389`.
- In the `VLAN and Tunnel Traffic` field, select `Enabled on...` from the dropdown.
- In the `VLANS and Tunnels` field, select the VLAN that is associated with the external subnet (example: `External_Interface`).
- In the `Source Address Translation` field, select `Auto Map` from the dropdown.
- Leave all other fields with the default settings and click the `Finished` button at the bottom of the page

#### Outbound Traffic

In-order for resources deployed inside of the MLZ instance to be able to reach platform endpoints (such as for storage), a virtual server needs to be created to allow outbound HTTPS traffic.

The example below is based on the default IP scheme and achieves outbound flow for each of the MLZ spokes using super-netting. The same flow could be affected by creating a virtual server for each spoke in the case where super-neeting can not be used.

In the `Local Traffic > Virtual Servers > Virtual Server List` section, click the `Create...` button and enter the information below:

- Enter a name and description for the Virtual Server (example: `MLZ_to_External`)
- In the `Type` dropdown, select `Forwarding (IP)`
- In the `Source Address` field, enter `10.88.0.0/13`.
- In the `Destination Address/Mask` field, enter `0.0.0.0/0`.
- In the `Service Port` field, select `HTTPS`.
- In the `VLAN and Tunnel Traffic` field, select `Enabled on...` from the dropdown.
- In the `VLANS and Tunnels` field, select the VLAN that is associated with the internal subnet (example: `Internal_Interface`).
- In the `Source Address Translation` field, select `Auto Map` from the dropdown.
- Leave all other fields with the default settings and click the `Finished` button at the bottom of the page

#### Spoke-to-Spoke Traffic

In-order for traffic to go between spokes, a virtual server needs to be created to allow East-West traffic between the spokes.

The example below is based on the default IP scheme and achieves outbound flow for each of the MLZ spokes using super-netting. The same flow could be affected by creating a matrix of virtual servers in the case where super-neeting can not be used.

In the `Local Traffic > Virtual Servers > Virtual Server List` section, click the `Create...` button and enter the information below:

- Enter a name and description for the Virtual Server (example: `Spoke_to_Spoke_Traffic`)
- In the `Type` dropdown, select `Forwarding (IP)`
- In the `Source Address` field, enter `10.88.0.0/13`.
- In the `Destination Address/Mask` field, enter `10.88.0.0/13`.
- In the `Service Port` field, select `All Ports`.
- In the `VLAN and Tunnel Traffic` field, select `Enabled on...` from the dropdown.
- In the `VLANS and Tunnels` field, select the VLAN that is associated with the internal subnet (example: `Internal_Interface`).
- In the `Source Address Translation` field, select `Auto Map` from the dropdown.
- Leave all other fields with the default settings and click the `Finished` button at the bottom of the page

## Applying STIG Configurations to F5

The MLZ repo that is part of the deployment container image contains the bash script called `mlzash_f5_stig_only.sh` that will be used to apply STIG and network settings to the BIG-IP. The script is located in the `/src/scripts/f5config` folder. Copy the script over to the Windows 2019 management VM and apply to the F5 BIG-IP using the steps below:

- From the Windows 2019 management VM, copy the bash script over to the F5 BIG-IP by running the command below:
  - `scp <path_to_script>\mlzash_f5_stig_only.sh root@<mgmt-ip-of-f5>:/var/config/rest/downloads/mlzash_f5_stig_only.sh`
- SSH into the F5 BIG-IP as the root account by running the command: `ssh root@<mgmt-ip-of-f5>`.
- Once on the BIG-IP, ensure the prompt is `config #`
- Apply the execute flag to the `mlzash_f5_stig_only.sh` script by execute the command below:
  - `chmod +x /var/config/rest/downloads/mlzash_f5_stig_only.sh`
- Execute the bash script using the command below:
  - `sh /var/config/rest/downloads/mlzash_f5_stig_only.sh`
- Once the script completes, reboot the F5 BIG-IP by entering the command `reboot`
