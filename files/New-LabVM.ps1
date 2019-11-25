$image = 'Cloud Academy Command Line Fundamentals - Kali-002.ova'
$vmName = 'Kali'
$vboxVersion = '6.0.8'
$vboxInstaller = "VirtualBox-$vboxVersion-130520-Win.exe"
$vboxExtensionPack = "Oracle_VM_VirtualBox_Extension_Pack-$vboxVersion.vbox-extpack"

$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -OutFile virtualbox.exe https://download.virtualbox.org/virtualbox/$vboxVersion/$vboxInstaller
Invoke-WebRequest -Outfile $vboxExtensionPack https://download.virtualbox.org/virtualbox/$vboxVersion/$vboxExtensionPack
Invoke-WebRequest -OutFile 7zip.exe https://www.7-zip.org/a/7z1900.exe

#. .\FtpHelpers.ps1
#Get-ImageFromFtp -Image "QACDADS" -DownloadPath "D:"

##Install virtual box, 7-zip

Write-Output y | & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" extpack install --replace $vboxExtensionPack

Remove-Item virtualbox.exe 
Remove-Item virtualbox.vbox-extpack
Remove-Item 7zip.exe

#Download Kali Linux

mkdir D:\VMs
Set-Location D:\VMs
Invoke-WebRequest -OutFile $image "https://techvetsdisks1.blob.core.windows.net/nested-images/$image"
& 'C:\Program Files (x86)\7-Zip\7z.exe' x "D:\VMs\$image"
$vmdk = (Get-Childitem –Path D:\VMs -Include *vmdk -File -Recurse -ErrorAction SilentlyContinue)[0].FullName
$imageItem = (Get-Item $image)
$vhdDir = "C:\Images\"
mkdir $vhdDir
$vhd = ($vhdDir + $imageItem.BaseName + ".vhd")
& 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe' clonehd --format vhd $vmdk $vhd


New-VM -Name $vmName -MemoryStartupBytes 1GB -BootDevice VHD -VHDPath $vhd -Generation 1 -Switch "NAT Switch"
#Remove-VMNetworkAdapter -VMName $vmName -Name "Network Adapter"
#Add-VMNetworkAdapter -VMName $vmName -IsLegacy $true -Name "Legacy Network Adapter" -SwitchName "NAT Switch"
Get-VM –VMname $vmName | Set-VM –AutomaticStartAction Start
Start-VM -Name $vmName

#auto eth0
#iface eth0 inet static
#    address 192.168.0.101
#    netmask 255.255.255.0
#    network 192.168.0.0
#    broadcast 192.168.0.255
#    gateway 192.168.0.1
#    dns-nameservers 192.168.0.1 8.8.8.8
#    dns-domain acme.com
#    dns-search acme.com


# Set the following in /etc/resolv.conf
#nameserver 192.168.0.1
#nameserver 8.8.8.8
#nameserver 8.8.4.4