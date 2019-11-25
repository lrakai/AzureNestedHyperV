
function Get-FtpDir {
    param (
        [Parameter(Mandatory = $true)]
        [string] $url, 
        [Parameter(Mandatory = $true)]
        [System.Net.NetworkCredential] $credentials
    ) 
    $request = [Net.WebRequest]::Create($url)
    $request.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory
    if ($credentials) { $request.Credentials = $credentials }
    $response = $request.GetResponse()
    $reader = New-Object IO.StreamReader $response.GetResponseStream() 
    while (-not $reader.EndOfStream) {
        $reader.ReadLine()
    }
    $reader.Close()
    $response.Close()
}

    
function Get-ImageFromFTP {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Image,
        [Parameter(Mandatory = $true)]
        [string] $DownloadPath
    )
    
    . ./Secrets.ps1 # defines $ftp, $user, $password, $ftpDirectory
    
    $credentials = new-object System.Net.NetworkCredential($user, $password)
    
    #SET FOLDER PATH
    $url = $ftp + $ftpDirectory + "/"
    
    $files = Get-FtpDir -url $url -credentials $credentials
    
    Write-Host "Found the following files via ftp"
    $files 
    
    $webclient = New-Object System.Net.WebClient 
    $webclient.Credentials = New-Object System.Net.NetworkCredential($user, $pass) 
    foreach ($file in ($files | Where-Object { $_ -like "*$Image*" })) {
        $source = $url + $file  
        $target = $DownloadPath + "/" + $file
        Write-Host "Downloading $source to $target"
        $webclient.DownloadFile($source, $target)
        Write-Host "Completed download of $target"
    }
}

