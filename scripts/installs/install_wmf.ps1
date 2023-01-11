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
} catch {
    LogWrite $_.Exception | Format-List -force
    LogWrite "Failed to download file."
}

LogWrite "Starting installation process..."
try {
    Start-Process -FilePath "wusa.exe" -ArgumentList "C:\Windows\Temp\wmf.msu /quiet /norestart" -Wait -PassThru
} catch {
    LogWrite $_.Exception | Format-List -force
    LogWrite "Exception during install process."
}
