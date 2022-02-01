# Post-deployment F5 BIG-IP configuration

## Introduction

This guide will walk the MLZ-Edge deployer thru the steps to manually configure the F5 BIG-IP with the base configurations that will implement the following functionalities:

- Spoke-to-Spoke (East-West) traffic routing
- Spoke-to-Platform (North-South) traffic routing
- Allow Inbound RDP traffic to the Windows management VM
- Apply applicable DoD compliance related configurations

## Prerequisites

- F5 BIG-IP license key
- Deployment system must have an Azure supported browser (Edge, Chrome)
- IP assigned to the network interface card of the F5 BIG-IP attached to the `mgmt` subnet (This is normally `.4` of the subnet assigned to the `mgmt` subnet. The default is `10.90.0.4`)
- Password for Windows 2019 management server which is stored in the Key Vault secret named ``
- Password or SSH private key for `f5admin` account. Password will be stored in the Key Vault secret named `f5Vm01Password`. SSH private will be stored in the repo of the system used to deploy the MLZ instance
- Public IP address of the Windows 2019 management VM deployed as part of the MLZ solution

## Accessing the F5

When the MLZ-Edge instance was deployed, a Windows 2019 management VM was deployed with a public IP address. From the system used to deploy the instance, open a browser and access the Azure Stack stamp portal, authenticating with credentials that has access to the subscription the instance was deployed into.

From the system used to deploy the instance, RDP into the Windows 2019 management VM using the public IP. The credentials to use to authenticate to the VM are `azureuser` along with the `` secret value retrieved from the Key Vault.

Once logged onto the Windows 2019 VM, the administrator will be presented with the Server Manager application. On the left hand side of the `Server Manager` application, click on the `Local Server` blade. In the `PROPERTIES` pane for the `Local Server`, click the `IE Enhanced Security Configuration` setting and select `Off` for both `Administrators` and `Users`. Close the `Server Manager` application.

From the Windows 2019 management VM, open Internet Explorer and enter the URL `https://<private_management_ip_of_the_F5_BIG-IP>`. The URL for a default deployment would be (https://10.90.0.4). A page stating `This site is not secure` should appear. Click the `More information` drop down on the page and then click on `Go on to the webpage (not recommended)` link.

The `F5 BIG-IP Configuration Utility` page should appear. Login to the page with `f5admin` along with the `f5Vm01Password` secret value retrieved from the Key Vault.

## Configuring the F5 BIG-IP

### Setup Utility

Once logged into the F5 BIG-IP, the screen displayed will be the `Welcome` page of the `Setup Utility`. Click `Next` on the page.

On the `General Properties`, click `Activate` to enter the license key. Enter the license key into the `Base Registration Key` field, select `Manual` in the `Activation Method` field and then clcik the `Next` button.

On the next screen, select `Download/Upload File` and then click the `Click Here To Download Dossier File`. Transfer the `dossier.do` file downloaded to the `Downloads` folder to a system that has Internet connectivity.

From a system that has Internet connectivity, using a browser...navigate to the [F5 License Activation site](https://activate.f5.com/license)

On the `Activate F5 Product` webpage, click on `Choose File`, select the `dossier.do` file transferred from the BIG-IP and then click `Next`.

On the `End User Legal Agreement` page, check the box next to `I have read and agree to the terms of this license` near the bottom of the page and then click `Next`.

Click the button `Download license` to download the license file. Transfer the `License.txt` file back to the Windows 2019 management VM.

Back on the Windows 2019 management VM on the `Setup Utility >> License` page, click the Browse button to select the license file to upload. In the browser window that opens, navigate to and select the `License.txt` file downloaded from the F5 activation site and then click `Next` to upload the file to the F5 BIG-IP.

The F5 BIG-IP should now be licensed and activated and the `Resource Provisioning` page should be displayed. NOTE: The BIG-IP may log the user out before presenting the `Resource Provisioning` page. If this happens, re-authenticate anc continue the setup process.

On the `Resource Provisioning` page, leave all default settings as configured and click on the `Next` button at the bottom of the page.

On the `Device Certificates` page, import a customer cert if desired or to just proceed with the self-signed cert for testing purposes click `Next`.

On the `Platform` page, make the following configurations and then click `Next`:

- Enter a desired hostname for the F5 (example: `mlzashf5.local`)
- Select the desired time zone
- Select `Specify Range` in the `SSH IP Allow` section and then enter the CIDR information for the management subnet (default is 10.90.0.0/24)

On the `Network` page, click `Finished` under `Advanced Network Configuration`.

## Applying Network and STIG Configurations to F5

### Enabling the root account

In-order to scp a bash script over to the F5 and then execute the script, the root account must be enabled.

Perform the steps below from the Windows 2019 management VM:

- Open a `CMD` window
- SSH into the F5 BIG-IP as the f5admin account by running the command: `ssh f5admin@<mgmt-ip-of-f5>`. If using SSH keys, add `-i <path/name of private key>`. Default management IP for F5 BIG-IP is `10.90.0.4`
- Once on the BIG-IP, ensure the prompt si `(tmos)#`
- From the `(tmos)#` prompt, enter the command `modify auth password root`. Enter a new password once prompted and save password to Key Vault.
- From the `(tmos)#` prompt, enter the command `modify /sys db systemauth.disablerootlogin value false`. Reboot the F5 BIG-IP by entering the command `reboot`

### Executing bash configuration script

The MLZ repo that is part of the deployment container image contains the bash script called `<script_name>` that will be used to apply STIG and network settings to the BIG-IP. The script is located in the `/src/scripts/f5config` folder. Copy the script over to the Windows 2019 management VM.

From the Windows 2019 management VM, copy the bash script over to the F5 BIG-IP by running the command below:

- `scp <path_to_script>\<script_name> root@<mgmt-ip-of-f5>:/var/config/rest/downloads/<script_name>`

SSH into the F5 BIG-IP as the root account by running the command: `ssh root@<mgmt-ip-of-f5>`.

Navigate to the `/var/config/rest/downloads/` folder

Execute the bash script using the command: 
