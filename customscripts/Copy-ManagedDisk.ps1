#Provide the subscription Id where managed disk is created
# subscriptionId=yourSubscriptionId # omit for use in Azure Cloud Shell

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
storageContainerName=HyperV-CPSA

#Provide the key of the storage account where you want to copy the VHD 
storageAccountKey=mystorageaccountkey

#Provide the name of the destination VHD file to which the VHD of the managed disk will be copied.
destinationVHDFileName=cpsa.vhd

az account set --subscription $subscriptionId

sas=$(az disk grant-access --resource-group $resourceGroupName --name $diskName --duration-in-seconds $sasExpiryDuration --query [accessSas] -o tsv)

az storage blob copy start --destination-blob $destinationVHDFileName --destination-container $storageContainerName --account-name $storageAccountName --account-key $storageAccountKey --source-uri $sas

