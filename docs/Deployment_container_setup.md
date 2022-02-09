# Azure Stack Hub Syndication and setup

Prior to any deployments with a new install of Azure Stack Hub (ASH) the mission landing zone edge will require certain marketplace items be made available. These marketplace items exist in your "registration" subscription in a publicly available cloud.
The following allows for this specific list of required items to be downloaded into a container then saved and moved into the environment which has access to ASH. The following process is designed for environments where the ASH stamp is in a isolated network without connectivity to public clouds.

![Basic process flow of syndication in highly secure scenarios.](../images/workflow.png)

>**NOTE**: In the above scenario the container is created in a publicly accessible location, this means access to the Azure portal, either commercial or government where the subscription that hosts the ASH registration is. The container can then be moved to the private location where the ASH stamp lives and connected to a network that has access to the stamps admin portal management API.
The only requirements for both environments, is that Docker containers can run and connect to the proper network and that the Docker containers available space has been expanded using the process documented below in troubleshooting.
For example, a single laptop can run the create and download process in a public network and then be moved to the private network and run import and eventually azure deploy of mission landing zone.
>
>**NOTE**: This process will also bring with it, in the container, all files needed to STIG VMs during or after deployment. These will be located in the artifacts folder inside the container as well as a script in the scripts folder to upload them into a storage account of the ASH’s operator portal for access to deployment resources.

## From main source repo directory run the following

### Requirements

Currently this process is developed running Docker for Windows desktop with WSL enabled. While other setups may/should support running this same process certain commands might be slightly different to what is listed here.

Tested environments: 2 Options

- New container built from repo's container file - Following all steps below. **Please expand your virtual disk size for Docker by following the trouble shooting guide below**
- Windows 10 & 11 running WSL with PowerShell core installed - Outside a container requires running setup.ps1 in PWSH which installs modified version of Syndication Tool and then following running download and import PowerShell scripts.

## Container \<create\>

Clone the repo and run the following from a command prompt in which Docker client is installed and has access to Docker service. Also run from repo's root directory.

- Create new container from Dockerfile:

  ```bash
  docker build -t <image_name> .
  ```

- Run new container in interactive mode

  ```bash
  docker run -it <image_name>
  ```

## Inside container \<download\>

>**NOTE**: The download process will include complete packages which may or may not include required VMs making this process time consuming and result in a large container to transport.
>
>**NOTE****: To modify the default list of items that gets downloaded, edit the `artifacts/defaultMarketPlaceItems.txt` file.
>
>**NOTE**: The value for `<registration_name>` can be found from the admin portal of the stamp. In the admin portal, click on the `Dashboard` blade, click on the `Region management` tile, click on the `Properties` blade and observe the value in the `Registration name` field.

- Run download script as first step of syndication. This will also upload the required resources needed to STIG VMs into a storage account unless you add the parameter `-uploadStigReq $false`.

  ```bash
  pwsh ./src/scripts/download.ps1 –registrationName <registration_name> [-UseDeviceAuthentication]
  ```

`download.ps1` Availalbe Parameters:
**Parameter Name**          | **Default value** | **Description**
------------------------| --------------| -----------
registrationName  | None  | Required. The name of registration in which the Azure Stack Hub is added.
environment | AzureCloud  | Environment defines what cloud you are useing for registration subscription, use AzureUSGovernment for Government cloud.
UseDeviceAuthentication | not set | Switch used to have Azure Login use device authentication capabilities. This is ussually needed when using ADFS.
skipprecheck  | False | Set to true if you do not want script to run chaeck against products in registration versus whats in default text file.

A few other parameters exist in the script file but do not require changing.

>**NOTE**: You will be prompted for username and password for a user that has access to the subscription where the registration exists. To find your registration name you can log into the Admin portal and on the dashboard select the region inside the 'region management' widget and then select properties.*

## Save container – commit changes in new container

- If not already out of container either exit or open new command prompt
- View running or previously run containers

  ```bash
  docker ps -a
  ```

- Depending on your use of Docker locally you may see 1 or more containers listed. Observe the container that was create previously and copy its "CONTAINER ID" (example "72118659ddcf")
- Commit its changes to new container

  ```bash
  docker commit <id> <new name>
  ```

- View images to ensure the image was created by running:

  ```bash
  docker images
  ```

- If wanting to use a different system than one used to create the container and transport a tar file you can save this image to compressed tar file by running:

>**NOTE**: Essentially, we want to run 'docker save -o \<container name\>.tar' to create a tar of the container image and then compress/zip the file for transport. On Windows we simply save the tar file and open explorer then right click on tar file and zip/compress.*

  Linux \<create new container\>:

  ```bash
  docker save <container name> | gzip > <container name>.tar.gz
  ```

  This container is now ready to transport.

## Container \<Import\>

>**NOTE**: This is also a time consuming process depending on the size of the packages selected and network bandwidth.*

- If on a new system with the compressed file available run:

  Linux \<run import machine\>

  ```bash
  gunzip -c <container name>.tar.gz | docker load
  ```

- Once extracted run:

  ```bash
  docker run -it <container name>
  ```

- Now inside the container run:

  ```bash
  pwsh ./src/scripts/import.ps1 -hubDomain <local ASH domain> [-UseDeviceAuthentication]
  ```

  >**NOTE**: Import will use the default value of AzureStackAdmin for adding an environment into the containers local Azure environment files. This will be based on the hubDomain value you enter which is basically the same portal domain you use to access the stamp minus the ‘portal’ or ‘adminportal’ part. Example: ‘region.localstamp.com’* .

## Using this container model to transport other market place items

At a few different stages in the process it can be modified to download an external set of market place items beyond those set by default that are required by Mission Landing Zone - Edge.

- The easiest way to accomplish this task would be use the Azure Stack Hub syndication tool which runs on Windows to select items you want to move into ASH and can download then import. This is the same tool, although slightly modified to run on Linux that is used in this container process except it doesn't allow you to run the 'Select items' capability.

- `./artifacts/defaultMlzMarketPlaceItems.txt` contains the list of Marketplace items required to deploy MLZ on Azure Stack Hub. Modify this list either in the source repo which then requires a new container to be built or inside the container using `vi ./artifacts/defaultMlzMarketPlaceItems.txt`.

  >**NOTE**: Each item in the `./artifacts/defaultMlzMarketPlaceItems.txt` file is separated by new line and is in the resource ID format `/subscriptions/<subscription>/resourceGroups/<resourcegroup>/providers/Microsoft.AzureStack/registrations/<registration>/products/f5-networks.f5-big-ip-bestf5-bigip-virtual-edition-best-byol-13.1.100000`.
  >
  >**NOTE**: Do not edit the variables for \<subscription\> and \<registration\> because the script replaces them with values at execution time.

- An additional model to undertake would be combine both efforts, the easy method using the windows tooling to create a directory of items and then move that directory into the artifacts folder prior to building the container. At this point the 'download' process would not need to be run since it is already completed so only the 'import' process should run to move into ASH.

## Trouble shooting this process

- Error downloading marketplace items due to size limits.
Run `df -h` in WSL to see  current directory sizes and usage. The docker directory `/mnt/wsl/docker-desktop-data/isocache` can be maxed out either due to caching a failed effort or other cause. Running `docker system prune` may clear enough resources to download items.

### Changing default Docker size limits may also alleviate the issue. To resize

- Stop WSL by running `wsl --shutdown`
- Stop Docker For Windows by right clicking DFW in status bar and selecting quit.
- Open command prompt and start disk partition by running `diskpart`
- In diskpart command line select the correct VHD file by running `Select vdisk file=<path to VHD>` - where path to VHD is most likely %LOCALAPPDATA%\Docker\wsl\data\ext4.vhdx
- Confirm the correct VDisk is selected by running `detail vdisk`
- Now expand the disk by running  `expand vdisk maximum=<sizeInMegaBytes>` where sizeInMegaBytes is something like 512000. ~Note: 512000 may not be enough since it typically is double the default size, this depends on additions to Market Place items you may have added and the current size of them as of today.
- Exit diskpart and restart WSL by typing `wsl` at command prompt.
- Start Docker For Windows
- Double check size by running `df -Th` at command prompt and look for `/mnt/wsl/docker-desktop-data/isocache` "Mounted on" and copy the Filesytem, ie: /dev/sde
- If not already installed in WSL, install resize2fs by running with sudo apt install resize2fs
- Expand the corresponding Docker desktop iso cache mount with `sudo resize2fs /dev/<mount> <sizeInMegabytes>M` where \<mount\> is the filesystem from the earlier `df -Th` command.
