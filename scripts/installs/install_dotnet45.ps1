$Logfile = "C:\Windows\Temp\dotnet-install.log"
function LogWrite {
   Param ([string]$logstring)
   $now = Get-Date -format s
   Add-Content $Logfile -value "$now $logstring"
   Write-Host $logstring
}
 
LogWrite "Downloading dotNet 4.5.1"
try {
    #(New-Object System.Net.WebClient).DownloadFile('http://files.network-pro.de/metasploitable3/NDP451-KB2858728-x86-x64-AllOS-ENU.exe', 'C:\Windows\Temp\dotnet.exe')
    
    #Download from HTTP works, but the ENV Vars are not in the vm, so ip and port is hardcoded
    #(New-Object System.Net.WebClient).DownloadFile('http://{{ .HTTPIP }}:{{ .HTTPPort }}/NDP451-KB2858728-x86-x64-AllOS-ENU.exe', 'C:\Windows\Temp\dotnet.exe')
    try { (New-Object System.Net.WebClient).DownloadFile('http://10.0.2.2:9001/NDP451-KB2858728-x86-x64-AllOS-ENU.exe', 'C:\Windows\Temp\dotnet.exe') }catch {echo $_.Exception }
    try { (New-Object System.Net.WebClient).DownloadFile('http://10.0.2.3:9001/NDP451-KB2858728-x86-x64-AllOS-ENU.exe', 'C:\Windows\Temp\dotnet.exe') }catch {echo $_.Exception }

} catch {
    LogWrite $_.Exception | Format-List -force
    LogWrite "Failed to download file."
    Write-Host "Failed to download file."
}

LogWrite "Starting installation process..."
try {
    Start-Process -FilePath "C:\Windows\Temp\dotnet.exe" -ArgumentList "/I /q /norestart" -Wait -PassThru
} catch {
    LogWrite $_.Exception | Format-List -force
    LogWrite "Exception during install process."
}
