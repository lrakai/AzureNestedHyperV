#!/bin/bash

#Provide the subscription Id where image is created
subscriptionId="c4fd644c-22da-4e2e-8c6c-86dfa6a28964" # omit for use in Azure Cloud Shell
az account set --subscription $subscriptionId

#Provide the name of your resource group where managed disk is created
resourceGroupName=QACA

#Provide the image path 
image="D:/Downloads/Cloud Academy Command Line Fundamentals - Kali-002.ova"

#Provide Shared Access Signature (SAS) expiry duration in seconds e.g. 3600.
#Know more about SAS here: https://docs.microsoft.com/en-us/azure/storage/storage-dotnet-shared-access-signature-part-1
sasExpiryDuration=14400

#Provide storage account name where you want to copy the underlying VHD file of the managed disk. 
storageAccountName=techvetsdisks1

#Name of the storage container where the downloaded VHD will be stored
storageContainerName=nested-images

#Provide the key of the storage account where you want to copy the VHD 
storageAccountKey=<INSERT_STORAGE_ACCOUNT_KEY>

sas=$(az disk grant-access --resource-group $resourceGroupName --name $diskName --duration-in-seconds $sasExpiryDuration --query [accessSas] -o tsv)

az storage blob upload start --file $image --container-name $storageContainerName --account-name $storageAccountName #--account-key $storageAccountKey

# Watch copy progress
# watch az storage blob show --container-name $storageContainerName --account-name $storageAccountName --name $destinationVHDFileName --query "properties.copy"
