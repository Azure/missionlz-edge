# Azure Stack Hub Syndication and setup
Prior to any deployments with a new install of Azure Stack Hub (ASH) the mission landing zone will require certain marketplace items be made available. These marketplace items exist in your ‘registration’ subscription in a publicly available cloud. The following allows for this specific list of required items be downloaded into a container then saved and moved into the environment which has access to ASH. The following process is design for environments where the ASH stamp is in a isolated network without connectivity to public clouds.
![](./images/workflow.png)

*Note: In the above scenario the container is created in a publicly accessible location, this means access to the Azure portal, either commercial or government where the subscription that hosts the ASH registration is. The container can then be moved to the private location where the ASH stamp lives and connected to a network that has access to its admin portal management API. The only requirement for both environments, the public and private networks will be that docker containers can run and connect to the proper network. For example, a single laptop can run the create and download process in a public network and then be moved to the private network and run import and eventually azure deploy of mission landing zone.*

*This process will also bring with it, in the container, all files needed to STIG VMs during or after deployment. These will be located in the artifacts folder inside the container as well as a script in the scripts folder to upload them into a storage account of the ASH’s operator portal for access to deployment resources.*
## From main source repo directory run the following.
### Requirements
Currently this process is developed running Docker for Windows desktop with WSL enabled. While other setups may/should support running this same process certain commands might be slightly different to what is listed here.

Tested environments:
- New container built from repo's container file
- Windows 10 & 11 running WSL with PowerShell core installed (This requires running setup.ps1 in PWSH  which installs modified version of Syndication Tool)

## Container \<create\>: 
Clone the repo and run the following from a command prompt in which docker client is installed and has access to docker service. Also run from repo's root directory.
- Create new container from dockerfile: use your own naming in place of shawngib/syndication
  ```bash
  docker build -t shawngib/syndication .
  ```
- Run new container in interactive mode
  ```bash
  docker run -it shawngib/syndication
  ```
## Inside container \<download\>:
*Note: The download process will include complete packages which may or may not include required VMs making this process time consuming and result in a large container to transport.*

- Run download script as first step of syndication. This will also upload the required resources needed to STIG VMs into a storage account unless you add the parameter `-uploadStigReq $false`. Note: if you wanted to modify marketplace items prior to this download step you can modify the artifacts/defaultMarketPlaceItems.txt file to include those.
  ```bash
  pwsh ./src/scripts/download.ps1 –registrationName <your reg. name> # example: CPEC-37173
  ```
  *Note: You will be prompted for username and password for a user that has access to the subscription where the registration exists.*
## Save container – commit changes in new container
- If not already out of container either exit or open new command prompt
- View running or previously run containers
  ```bash
  docker ps -a
  ```
- Depending on your use of docker locally you may see 1 or more containers listed, we are looking for one named the same as used in the above steps. ‘shawngib/syndication’, copy its ‘CONTAINER ID’, example ‘72118659ddcf’
- Commit its changes to new container
  ```bash
  docker commit <id> <new name>
  ```
- View images to ensure the image was created by running:
  ```bash
  docker images
  ```
- If wanting to use a different system than one used to create the container and transport a tar file you can save this image to compressed tar file by running:

*Note: Essentially, we want to run 'docker save -o \<container name\>.tar' to create a tar of the container image and then compress/zip the file for transport. On Windows we simply save the tar file and open explorer then right click on tar file and zip/compress.*

  Linux \<create new container\>:
  ```bash
  docker save <container name> | gzip > <container name>.tar.gz
  ```

  This container is now ready to transport.
## Container \<Import\>
*Note: This is also a time consuming process depending on the size of the packages selected and network bandwidth.*

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
  pwsh ./src/scripts/import.ps1 – hubDomain <local ASH domain> [-activeDirectoryEndpoint <ADFS Login>]
  ```
  *Note: Import will use the default value of AzureStackAdmin for adding an environment into the containers local Azure environment files. This will be based on the hubDomain value you enter which is basically the same portal domain you use to access the stamp minus the ‘portal’ or ‘adminportal’ part. Example: ‘region.localstamp.com’* . The activeDirectoryEndpoint parameter is defaulted to publicly accessible AAD endpoint of ‘https://login.microsoftonline.com/’ for logging into ASH, if this is different add that parameter and value.

## Using this container model to transport other market place items
At a few different stages in the process it can be modified to download an external set of market place items beyond those set by default that are required by Mission Landing Zone - Edge.

- The easiest way to accomplish this task would be use the Azure Stack Hub syndication tool which runs on Windows to select items you want to move into ASH and can download then import. This is the same tool, although slightly modified to run on Linux that is used in this container process except it doesn't allow you to run the 'Select items' capability. 

- `./artifacts/defaultMlzMarketPlaceItems.txt` host the required by MLZ list of marrkplace items. Modify this list either in the source repo which then requires a new container to be built or inside the container using `vi ./artifacts/defaultMlzMarketPlaceItems.txt`.

*Note: the items are seperated by new line and are in the resource ID format `/subscriptions/<subscription>/resourceGroups/<resourcegroup>/providers/Microsoft.AzureStack/registrations/<registration>/products/f5-networks.f5-big-ip-bestf5-bigip-virtual-edition-best-byol-13.1.100000`. Leave the variables for \<subscription\> and \<registraion\> as is since the script replaces these based on the credentials you enter.*  

- An additional model to undertake would be combine both efforts, the easy method using the windows tooling to create a diretory of items and then move that dorectory into the artifacts folder prior to building the container. At this point the 'download' process would not need to be run since it is already completed so only the 'import' process should run to move into ASH.

## Trouble shooting this process

- Error downloading marketplace items due to size limits.
Run `df -h` in WSL to see  current directory sizes and usage. The docker directory `/mnt/wsl/docker-desktop-data/isocache` can be maxed out either due to caching a failed effort or other cuase. Running `docker system prune` may clear enough resources to download items. 

### Changing default docker size limits may also eleviate the issue. To resize:
- Stop WSL by running `wsl -shutdown`
- Stop Docker For Windows by right clicking DFW in status bar and selecting quit.
- Open command prompt and start disk partition by running `diskpart`
- In diskpart command line select the correct VHD file by running `Select vdisk file=<path to VHD>` - where path to VHD is most likely %LOCALDATA%\Docker\wsl\data\ext4.vhdx
- Confirm the correct VDisk is selected by running `detail vdisk`
- Now expand the disk by running  `expand vdisk maximum=<sizeInMegaBytes>` where sizeInMegaBytes is something like 512000. ~Note: 512000 may not be enough since it typically is double the default size, this depends on additions to Market Place items you may have added and the current size of them as of today.
- Exit diskpart and restart WSL by typeing `wsl` at command prompt.
- Start Docker For Windows
- Double check size by running `df -Th` at command prompt and look for /mnt/wsl/docker-desktop-data directory