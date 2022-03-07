# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

<#
    This script publishes templates and associated scripts into your Azure Storage account, and generates Azure Portal link for deployment.
    Replace variables with your environment details.
#>

Param(
    [string]
    [Parameter(Mandatory = $false)]
    $resourceGroupName = "stig_rg",

    [string]
    [Parameter(Mandatory = $false)]
    $storageAccountNamePrefix = "stigtools",

    [string]
    [Parameter(Mandatory = $false)]
    $containerName = "artifacts",

    [bool]
    [Parameter(Mandatory = $false)]
    $uploadStigReq = $true,
    
    [string]
    [Parameter(Mandatory = $false)]
    $osBasePath = '.\src\scripts\stig\',

    [string]
    [Parameter(Mandatory = $false)]
    $location = ""
)

if(!$uploadStigReq)
{
    Write-Host "Skipping the upload of required utilities to STIG.  Quiting STIG artifact upload." -ForegroundColor Cyan
    break
}
Write-Host "Uploading required tool set for applying STIG controls to VMs."  -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
if(!$location) {
    $location = if(((Get-AzLocation).Location).count -gt 1){$location = (Get-AzLocation).Location[0]}else{$location = (Get-AzLocation).Location}
}
$resourceGroup = Get-AzResourceGroup -name $resourceGroupName -ErrorAction SilentlyContinue

$concatStName = $storageAccountNamePrefix + $location
if ($concatStName.Length -gt 24) {
$storageAccountName = (($storageAccountNamePrefix + $location).ToLower()).Substring(0,24)
} else { $storageAccountName = $concatStName }

$storageContext = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue).Context

# Create Resource Group
if(!$resourceGroup)
{
    $rg = New-AzResourceGroup -Name $resourceGroupName -Location $location
}

# Create Storage account

if(!$storageContext)
{
    Write-Host "Creating storage account." -ForegroundColor Cyan
    $storage = New-AzStorageAccount -ResourceGroupName $resourceGroupName `
                         -Name $storageAccountName `
                         -Location $location `
                         -SkuName Standard_LRS
}
$storageContext = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue).Context

$container = Get-AzStorageContainer -Context $storageContext -Prefix $containerName -ErrorAction SilentlyContinue

if (!$container) {
    Write-Host "Creating container." -ForegroundColor Cyan
    $containerContext = New-AzStorageContainer `
        -Context $storageContext `
        -Name $containerName `
        -Permission Container
}

Write-Host "Uploading required artifacts to set STIG controls on VMs. Note: This will overwrite existing files." -ForegroundColor Cyan
Get-ChildItem -Path $osBasePath -Exclude "publish-to-blob.sh","publish-to-blob.ps1","*.md" -File -Recurse | Set-AzStorageBlobContent -Context $storageContext -Container $containerName -Force
Get-ChildItem -Path $osBasePath.Replace('\stig\','\f5config\') -File -Recurse | Set-AzStorageBlobContent -Context $storageContext -Container $containerName -Force

$blobUrl = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue).Context.BlobEndpoint
Write-Host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host "Use this URL in any deployments that require links back to the files."
Write-Host ""
Write-Host $blobUrl.Substring(0,$blobUrl.Length-1)