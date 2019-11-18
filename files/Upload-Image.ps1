$ErrorActionPreference = "Stop"

#Login-AzAccount

#Provide the subscription Id where image is created
$subscriptionId="c4fd644c-22da-4e2e-8c6c-86dfa6a28964"
Select-AzureRmSubscription -SubscriptionId $subscriptionId

#Provide the name of your resource group where managed disk is created
$resourceGroupName="QACA"

#Provide the image path 
$image="D:/Downloads/Cloud Academy Command Line Fundamentals - Kali-002.ova"
$item=Get-Item $image

#Provide storage account name where you want to copy the underlying VHD file of the managed disk. 
$storageAccountName="techvetsdisks1"

#Name of the storage container where the downloaded VHD will be stored
$storageContainerName="nested-images"

$storageContext=(Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context
Set-AzureStorageBlobContent -File $image -Container $storageContainerName -Context $storageContext -Blob $item.Name
