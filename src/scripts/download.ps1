<#
.SYNOPSIS 
    Pre-process for Azure Stack Hub market place items related to Mission Landing Zone Edge.

.DESCRIPTION 
    This script takes in the registration name for the Azure Stack Hub and will reach out and pre-process a 
    standard set of items required by Mission Landing Zone Edge. The script will use a custom version of 
    Azs.Syndication.Admin which will be setup using the setup PowerShell script.

.PARAMETER registrationName
    The registration name where the Azure Stack Hub is located. REQUIRED

.PARAMETER environment
    The cloud environment that you are needing to analyze. Default is AzureCloud
    Available clouds: AzureChinaCloud, AzureCloud,AzureGermanCloud,AzureUSGovernment

.PARAMETER repositoryDir
    Location where syndication tool will crate artifact folders and download items.
    This will then be used when running the upload/import process.

.PARAMETER marketPlaceItemsPath
    Location of text file which hosts the default list of items to process. This list
    be added to if new items are desired to be include. Format euqals 1 per line.
    Example: /subscriptions/<subscription>/resourceGroups/<resourcegroup>/providers/Microsoft.AzureStack/registrations/<registration>/products/microsoft.vmaccessagent-2.4.9

.PARAMETER UseDeviceAuthentication
    Switch used to change Azure login from credential based to Web based authentication.

.PARAMETER skipprecheck
    Switch used to skip pre-check of items. Default to False.
    When not used the script will call the registration subscription to see if the market place items in the list are available for download.
    Skipping can speed the process up slightly.

.PARAMETER subscriptionId
    The subscription Id of the registration subscription. Adding it in as a parameter speeds up processesing since the subscription will not
    to be checked.

.PARAMETER resourceGroup
    The resource group hosting the registration. Default is 'Azurestack'

#>

param
(
    [Parameter(Mandatory = $true)]
    [string]$registrationName , # example = 'CPEC-3173R03B'

    [Parameter(Mandatory = $false)]
    [ValidateSet('AzureChinaCloud','AzureCloud','AzureGermanCloud','AzureUSGovernment')]
    [string]$environment = 'AzureCloud',   # Environment defines what cloud you are useing for registration subscription (defaults to AzureCloud)

    [Parameter(Mandatory = $false)]
    [string]$repositoryDir = $PWD.Path + '/src/artifacts', # where download script stored artifacts 

    [Parameter(Mandatory = $false)]
    [string]$marketPlaceItemsPath = $PWD.Path + '/src/artifacts/defaultMlzMarketPlaceItems.txt', 

    [Parameter(Mandatory = $false)]
    [switch] $UseDeviceAuthentication,

    [Parameter(Mandatory = $false)]
    [switch] $skipprecheck = $false,

    [Parameter(Mandatory = $false)]
    [string] $subscriptionId,

    [Parameter(Mandatory = $false)]
    [string] $resourceGroup = 'Azurestack',

    [Parameter(Mandatory = $false)]
    $modulePath = $HOME + '/.local/share/powershell/Modules/Azs.Syndication.Admin/0.1.157'
)

$null = Disable-AzContextAutosave

[array]$products = @()
[array]$productDetails = @()

$exportModulePath = $modulePath+'/Export.psm1'
Import-Module $exportModulePath -Force

function Add-IndexNumberToArray (
    [Parameter(Mandatory=$True)]
    [array]$array
    )
{
    for($i=0; $i -lt $array.Count; $i++) 
    { 
        Add-Member -InputObject $array[$i] -Name "#" -Value ($i+1) -MemberType NoteProperty 
    }
    $array
}

# MAIN #
Write-Host "Authenticating to Azure... Note: Be sure to fully exit PowerShell session to prevent caching of Azure context." -ForegroundColor Cyan
try {
    $subscription = Get-AzSubscription -WarningAction Ignore
    $currentContext = Get-AzContext
} catch {
    try {
        if($UseDeviceAuthentication.ToBool()) {
            $null = Connect-AzAccount -UseDeviceAuthentication -Environment $environment -ea Stop # Add Tenant plus Environment for ASH? Also since interactive is not supported will this break for MFA?
            $subscription = Get-AzSubscription -WarningAction Ignore
            $currentContext = Get-AzContext
        } else {
            $registrationSub = Get-Credential -Message "Please enter user name and password for ASH registration subscription."
            $null = Connect-AzAccount -Credential $registrationSub -Environment $environment -ea Stop # Add Tenant plus Environment for ASH? Also since interactive is not supported will this break for MFA?
            $subscription = Get-AzSubscription -WarningAction Ignore
            $currentContext = Get-AzContext
        }
    } catch {
        if($PSItem.Exception.InnerException.ErrorCode -eq 'invalid_grant')
        { 
            Write-Host "Your organization requires interactive login or MFA, please run script with '-UseDeviceAuthentication'" -ForegroundColor Red
        } else {
            Write-Error "Unknown error please try again or run script with '-UseDeviceAuthentication'" -Category SecurityError
        }
        break
    }
}

# Ensure this is the subscription where your Azure Resources are you want to send diagnostic data from
If($currentContext -and !($subscriptionID))
{
    [array]$subscriptionArray = Add-IndexNumberToArray (Get-AzSubscription -WarningAction Ignore) 
    [int]$selectedSub = 0

    # use the current subscription if there is only one subscription available
    if ($subscriptionArray.Count -eq 1) 
    {
        $selectedSub = 1
    }
    # Get subscriptionID if one isn't provided
    while($selectedSub -gt $subscriptionArray.Count -or $selectedSub -lt 1)
    {
        Write-host "Please select a subscription from the list below"
        $subscriptionArray | Select-Object "#", Id, Name | Format-Table
        try
        {
            $selectedSub = Read-Host "Please enter a selection from 1 to $($subscriptionArray.count)"
        }
        catch
        {
            Write-Warning -Message 'Invalid option, please try again.'
        }
    }
    if($($subscriptionArray[$selectedSub - 1].Name))
    {
        $subscriptionName = $($subscriptionArray[$selectedSub - 1].Name)
    }
    elseif($($subscriptionArray[$selectedSub - 1].SubscriptionName))
    {
        $subscriptionName = $($subscriptionArray[$selectedSub - 1].SubscriptionName)
    }
    write-verbose "You Selected Azure Subscription: $subscriptionName"
    
    if($($subscriptionArray[$selectedSub - 1].SubscriptionID))
    {
        [guid]$subscriptionID = $($subscriptionArray[$selectedSub - 1].SubscriptionID)
    }
    if($($SubscriptionArray[$SelectedSub - 1].ID))
    {
        [guid]$subscriptionID = $($subscriptionArray[$selectedSub - 1].ID)
    }
}
if($subscriptionId)
{
    try{
        $subscriptionToUse = Select-AzSubscription -Subscription $subscriptionId -WarningAction Ignore -ea Stop
        Write-Host "Selecting Azure Subscription: $($subscriptionToUse.Subscription.Name) ..." -ForegroundColor Cyan
    }
    catch{
        write-host "Something went wrong trying to select subscription - please check subscriptionId and try again" -ForegroundColor Red
        break
    }
}

foreach($line in [System.IO.File]::ReadLines("$marketPlaceItemsPath"))
{
    $product = (($line.replace('<subscription>', $subscription[0].Id)).replace('<registration>', $registrationName)).replace('<resourcegroup>', $resourceGroup)
    $products += $product
}

if(!$skipprecheck){
    Write-Host "Retrieving product details ... " -ForegroundColor Cyan
    foreach($product in $products)
    {
        $productName = ($product -Split "/")[10]
        Write-Host "Checking for product : $productName" -ForegroundColor Cyan
        try {
            $resourceDefinition = Get-AzResource -ResourceId $product -ApiVersion 2016-01-01 -ea Stop
            $productDetails += $resourceDefinition
        } catch {
            Write-Error $PSItem.Exception.Message
            if($product -like '*windowsserver2019*' -or $product -like '*f5-networks.f5-big-ip*' -or $product -like '*ubuntuserver1804lts*') {
                Write-Error "Missing $productName is a deal breaker since it is required for the landing zone."
                break
            }
            Write-Warning "Product : $productName is not listed in registration subscription for download."
        }
    }
} else { write-warning "Precheck of items has been skipped."}

$products | Export-AzsMarketplaceItem  -RepositoryDir $repositoryDir -AcceptLegalTerms -SleepInterval 10

# Clear Azure credentials to ensure they are not cached in conjunction with above 'Disable-AzContextAutosave' command
Disconnect-AzAccount
Get-AzContext | Remove-AzContext