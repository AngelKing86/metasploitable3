function Invoke-CLR4PowerShellCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ScriptBlock]
        $ScriptBlock,
        
        [Parameter(ValueFromRemainingArguments=$true)]
        [Alias('Args')]
        [object[]]
        $ArgumentList
    )
    
    if ($PSVersionTable.CLRVersion.Major -eq 4) {
        Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList
        return
    }

    $RunActivationConfigPath = $Env:TEMP | Join-Path -ChildPath ([Guid]::NewGuid())
    New-Item -Path $RunActivationConfigPath -ItemType Container | Out-Null
@"
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <startup useLegacyV2RuntimeActivationPolicy="true">
    <supportedRuntime version="v4.0"/>
  </startup>
</configuration>
"@ | Set-Content -Path $RunActivationConfigPath\powershell.exe.activation_config -Encoding UTF8

    $EnvVarName = 'COMPLUS_ApplicationMigrationRuntimeActivationConfigPath'
    $EnvVarOld = [Environment]::GetEnvironmentVariable($EnvVarName)
    [Environment]::SetEnvironmentVariable($EnvVarName, $RunActivationConfigPath)

    try {
        & powershell.exe -inputformat text -command $ScriptBlock -args $ArgumentList
    } finally {
        [Environment]::SetEnvironmentVariable($EnvVarName, $EnvVarOld)
        $RunActivationConfigPath | Remove-Item -Recurse
    }

}

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$isWin8 = wmic os get caption | find /i '" 8 "'
$isWin2012 = wmic os get caption | find /i '" 2012 "'

# skip wrapping for 8 or 2012?
if ($isWin8 -or $isWin2012){
   $env:chocolateyVersion = '0.10.8';
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
   iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
   #iex ((New-Object System.Net.WebClient).DownloadString('http://files.network-pro.de/metasploitable3/install.ps1'))
}else{
    Invoke-CLR4PowerShellCommand -ScriptBlock {
       $env:chocolateyVersion = '0.10.8';
       [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
       iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
       #iex ((New-Object System.Net.WebClient).DownloadString('http://files.network-pro.de/metasploitable3/install.ps1'))
    }
}

# cribbed from https://gist.github.com/jstangroome/882528
