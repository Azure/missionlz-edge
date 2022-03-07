# Post-deployment F5 BIG-IP configuration

## Table of Contents

1. [Introduction](#introduction)
1. [Prerequisites](#prerequisites)
1. [Accessing the F5](#accessing-the-f5)
1. [Configuring the F5 BIG-IP](#configuring-the-f5-big-ip)
1. [Applying Network and STIG Configurations to F5](#applying-network-and-stig-configurations-to-f5)

## Introduction

This guide will walk the MLZ-Edge deployer thru the steps to configure the F5 BIG-IP with the base configurations that will implement the following functionalities:

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
- Select `Specify Range` in the `SSH IP Allow` section and then enter the CIDR information for the management subnet (default is 10.90.0.0/24)

On the `Network` page, click `Finished` under `Advanced Network Configuration`.

## Applying Network and STIG Configurations to F5

When the F5 was deployed as part of the MLZ - Edge deployment, the scripts needed to configure the F5 were copied to the F5. If the MLZ - Edge deployment was done with the `stig` parameter set to `true`, the STIG settings script was run against the F5 during the deployment and now it just needs to be configured. Follow the steps below to run the configuration script:

- From the Windows 2019 management VM, SSH into the F5 BIG-IP using the `f5admin` account by running the command: `ssh f5admin@<mgmt-ip-of-f5>`
- Once on the BIG-IP, ensure the prompt is `f5admin@(localhost)(cfg-sync Standalone)(Active)(/Common)(tmos)#`
- At the prompt, enter the command `bash` to change to the bash shell
- Execute the configuratiuon bash script using the command below:
  - `/var/lib/waagent/custom-script/download/0/mlzash_f5_cfg.sh`
- Once the script completes, reboot the F5 BIG-IP by entering the command `reboot`

>**NOTE**: If the MLZ - Edge deployment was done without setting the `stig` parameter to `true` and post deployment the F5 needs to have STIG settings applied, run the script below from the bash shell prompt:

- `/var/lib/waagent/custom-script/download/0/mlzash_f5_stig.sh`
