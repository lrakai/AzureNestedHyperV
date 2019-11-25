# Run in an admin PowerShell

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Install-Module AzureRm.Storage,AzureRm.Compute -Force

function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

function Set-AzureVHD {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Vhd,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $ResourceGroup,
        [Parameter(Mandatory = $true, Position = 2)]
        [string] $StorageAccount,
        [Parameter(Mandatory = $true, Position = 3)]
        [string] $ContainerName
    )
    $item = (Get-Item $Vhd)
    $blobName = $item.Name

    try {
        $container = Get-AzureRmStorageContainer -ResourceGroupName $ResourceGroup -StorageAccountName $storageAccount -Name $ContainerName 
    }
    catch {
        New-AzureRmStorageContainer -ResourceGroupName $ResourceGroup -AccountName $StorageAccount -ContainerName $ContainerName -PublicAccess Blob | Out-Null
    }
    Add-AzureRmVhd -ResourceGroupName $ResourceGroup -Destination "https://$StorageAccount.blob.core.windows.net/$ContainerName/$blobName" -LocalFilePath $Vhd -NumberOfUploaderThreads 32 | Out-Null
    $blobName
}

function Copy-AzureVHD {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $SrcSubscription,
        [Parameter(Mandatory = $true, Position = 2)]
        [string] $SrcStorageAccount,
        [Parameter(Mandatory = $true, Position = 3)]
        [string] $ResourceGroup,
        [Parameter(Mandatory = $true, Position = 4)]
        [string] $ContainerName,
        [Parameter(Mandatory = $true, Position = 5)]
        [string] $BlobName,
        [Parameter(Mandatory = $true, Position = 6)]
        [string] $DestSubscription,
        [Parameter(Mandatory = $true, Position = 7)]
        [string] $DestStorageAccount
    )

    Set-AzureRmContext -SubscriptionId $DestSubscription
    try {
        $container = Get-AzureRmStorageContainer -ResourceGroupName $ResourceGroup -StorageAccountName $DestStorageAccount -Name $ContainerName 
    }
    catch {
        New-AzureRmStorageContainer -ResourceGroupName $ResourceGroup -AccountName $DestStorageAccount -ContainerName $ContainerName -PublicAccess Blob
    }
    
    $destContext = (Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $copyStorageAccount).Context
    Set-AzureRmContext -SubscriptionId $subscription
    $srcContext = (Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount).Context
    Start-AzureStorageBlobCopy -Context $srcContext -SrcContainer $containerName -SrcBlob $blobName -DestContext $destContext -DestContainer $containerName -DestBlob $blobName

    Set-AzureRmContext -SubscriptionId $DestSubscription
    do {
        Start-Sleep -Seconds 30
        $copyState = Get-AzureStorageBlobCopyState -Context $destContext -Container $ContainerName -Blob $BlobName 
        Write-Host Copy is $copyState.Status "("($copyState.BytesCopied)B / ($copyState.TotalBytes)B = ($copyState.BytesCopied/$copyState.TotalBytes*100)"%)"
    } while ($copyState.Status -eq "Pending")
}

$vhd = "C:\Images\Cloud Academy Command Line Fundamentals - Kali-002.vhd"

$subscription = "c4fd644c-22da-4e2e-8c6c-86dfa6a28964"
$copySubscription = "c460cd3f-7c2a-48cc-9f5d-b62d6083ec23"
$resourceGroup = "QACA"
$containerName = "qavhd"
$storageAccount = "techvetsdisks1"
$copyStorageAccount = "techvetsdisks2"

Disable-InternetExplorerESC
Connect-AzureRmAccount
Set-AzureRmContext -SubscriptionId $subscription
$blobName = Set-AzureVHD -Vhd $vhd -ResourceGroup $resourceGroup -StorageAccount $storageAccount -containerName $containerName

Copy-AzureVHD -SrcSubscription $subscription -SrcStorageAccount $storageAccount -ResourceGroup $resourceGroup -ContainerName $containerName -BlobName $blobName -DestSubscription $copySubscription -DestStorageAccount $copyStorageAccount