$ErrorActionPreference = "Stop"

#Login-AzAccount

#Provide the path to image(s) 
$images = @(
    "D:/Downloads/Cyber OWASP/Hydra.vhd", 
    "D:/Downloads/Cyber OWASP/Kali.vhd", 
    "D:/Downloads/Cyber OWASP/Metasploitable.vhd", 
    "D:/Downloads/Cyber OWASP/Heartbleed.vhd"
)

$blobPrefix = "owasp/"

#Provide the subscription Id where image is created
$subscriptionId = "c4fd644c-22da-4e2e-8c6c-86dfa6a28964"
Select-AzureRmSubscription -SubscriptionId $subscriptionId

#Provide the name of your resource group where managed disk is created
$resourceGroupName = "QACA"

#Provide storage account name where you want to copy the underlying VHD file of the managed disk. 
$storageAccountName = "techvetsdisks1"

#Name of the storage container where the downloaded VHD will be stored
$storageContainerName = "nested-images"

try {
    $container = Get-AzureRmStorageContainer -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -Name $storageContainerName -ErrorAction Continue
}
catch {
    New-AzureRmStorageContainer -ResourceGroupName $resourceGroupName -AccountName $storageAccountName -ContainerName $storageContainerName -PublicAccess Blob
}

$storageContext = (Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context

foreach ($image in $images) {
    $item = Get-Item $image
    $blob = $blobPrefix + $item.Name
    Write-Host "Uploading $image to blob $subscriptionId/$resourceGroupName/$storageAccountName/$storageContainerName/$blob"
    Set-AzureStorageBlobContent -File $image -Container $storageContainerName -Context $storageContext -Blob $blob
}