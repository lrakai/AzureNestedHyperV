#Provide the subscription Id where managed disk is created
# subscriptionId=yourSubscriptionId # omit for use in Azure Cloud Shell
# az account set --subscription $subscriptionId

#Provide the name of your resource group where managed disk is created
resourceGroupName=QACA

#Provide the managed disk name 
diskName=ca-lab-vm_OsDisk_1_b5b39d9313ec4ce3aa8ace3889dcce9b

#Provide Shared Access Signature (SAS) expiry duration in seconds e.g. 3600.
#Know more about SAS here: https://docs.microsoft.com/en-us/azure/storage/storage-dotnet-shared-access-signature-part-1
sasExpiryDuration=3600

#Provide storage account name where you want to copy the underlying VHD file of the managed disk. 
storageAccountName=techvetsdisks

#Name of the storage container where the downloaded VHD will be stored
storageContainerName=hyperv-cpsa

#Provide the key of the storage account where you want to copy the VHD 
storageAccountKey=<INSERT_STORAGE_ACCOUNT_KEY>

#Provide the name of the destination VHD file to which the VHD of the managed disk will be copied.
destinationVHDFileName=cpsa.vhd

sas=$(az disk grant-access --resource-group $resourceGroupName --name $diskName --duration-in-seconds $sasExpiryDuration --query [accessSas] -o tsv)

az storage blob copy start --destination-blob $destinationVHDFileName --destination-container $storageContainerName --account-name $storageAccountName --account-key $storageAccountKey --source-uri $sas

# Watch copy progress
# watch az storage blob show --container-name $storageContainerName --account-name $storageAccountName --name $destinationVHDFileName --query "properties.copy"

# Copy across subscriptions with azcopy (Disk can only be used in the same subscription)
# azcopy --source "https://acct1.blob.core.windows.net/hyperv-cpsa/cpsa.vhd" --destination "https://acct2.blob.core.windows.net/hyperv-cpsa/cpsa.vhd" --dest-key '...'