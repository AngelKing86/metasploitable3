$Logfile = "C:\Windows\Temp\wmf-install.log"
function LogWrite {
   Param ([string]$logstring)
   $now = Get-Date -format s
   Add-Content $Logfile -value "$now $logstring"
   Write-Host $logstring
}
 
LogWrite "Downloading Windows Management Framework 5.0"
try {
    #(New-Object System.Net.WebClient).DownloadFile('http://files.network-pro.de/metasploitable3/Win7AndW2K8R2-KB3134760-x64.msu', 'C:\Windows\Temp\wmf.msu')

    #Download from HTTP works, but the ENV Vars are not in the vm, so ip and port is hardcoded
    #(New-Object System.Net.WebClient).DownloadFile('http://{{ .HTTPIP }}:{{ .HTTPPort }}/Win7AndW2K8R2-KB3134760-x64.msu', 'C:\Windows\Temp\wmf.msu')
    try { (New-Object System.Net.WebClient).DownloadFile('http://10.0.2.2:9001/Win7AndW2K8R2-KB3134760-x64.msu', 'C:\Windows\Temp\wmf.msu') }catch {echo $_.Exception }
    try { (New-Object System.Net.WebClient).DownloadFile('http://10.0.2.3:9001/Win7AndW2K8R2-KB3134760-x64.msu', 'C:\Windows\Temp\wmf.msu') }catch {echo $_.Exception }

} catch {
    LogWrite $_.Exception | Format-List -force
    LogWrite "Failed to download file."
    Write-Host "Failed to download file."
}

LogWrite "Starting installation process..."
try {
    Start-Process -FilePath "wusa.exe" -ArgumentList "C:\Windows\Temp\wmf.msu /quiet /norestart" -Wait -PassThru
} catch {
    LogWrite $_.Exception | Format-List -force
    LogWrite "Exception during install process."
}
