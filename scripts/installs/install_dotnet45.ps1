$Logfile = "C:\Windows\Temp\dotnet-install.log"
function LogWrite {
   Param ([string]$logstring)
   $now = Get-Date -format s
   Add-Content $Logfile -value "$now $logstring"
   Write-Host $logstring
}
 
LogWrite "Downloading dotNet 4.5.1"
try {
    (New-Object System.Net.WebClient).DownloadFile('http://files.network-pro.de/metasploitable3/NDP451-KB2858728-x86-x64-AllOS-ENU.exe', 'C:\Windows\Temp\dotnet.exe')
} catch {
    LogWrite $_.Exception | Format-List -force
    LogWrite "Failed to download file."
}

LogWrite "Starting installation process..."
try {
    Start-Process -FilePath "C:\Windows\Temp\dotnet.exe" -ArgumentList "/I /q /norestart" -Wait -PassThru
} catch {
    LogWrite $_.Exception | Format-List -force
    LogWrite "Exception during install process."
}
