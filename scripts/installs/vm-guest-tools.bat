if not exist "C:\Program Files\7-Zip\7z.exe" (
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://www.7-zip.org/a/7z1604-x64.msi', 'C:\Windows\Temp\7zInstaller-x64.msi')" <NUL
    msiexec /qb /i C:\Windows\Temp\7zInstaller-x64.msi
)

if "%PACKER_BUILDER_TYPE%" equ "vmware-iso" goto :vmware
if "%PACKER_BUILDER_TYPE%" equ "virtualbox-iso" goto :virtualbox
if "%PACKER_BUILDER_TYPE%" equ "parallels-iso" goto :parallels
goto :done

:vmware

echo Installing VMWare GuestAddition...
if not exist "C:\Windows\Temp\windows.iso" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('http://softwareupdate.vmware.com/cds/vmw-desktop/ws/12.0.0/2985596/windows/packages/tools-windows.tar', 'C:\Windows\Temp\vmware-tools.tar')" <NUL
    cmd /c ""C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\vmware-tools.tar -oC:\Windows\Temp"
    FOR /r "C:\Windows\Temp" %%a in (VMware-tools-windows-*.iso) DO REN "%%~a" "windows.iso"
    rd /S /Q "C:\Program Files (x86)\VMWare"
)

cmd /c ""C:\Program Files\7-Zip\7z.exe" x "C:\Windows\Temp\windows.iso" -oC:\Windows\Temp\VMWare"
cmd /c C:\Windows\Temp\VMWare\setup.exe /S /v"/qn REBOOT=R\"
echo Installing Parallels GuestAddition... finish
goto :done

:virtualbox

echo Installing VirtualBox GuestAddition...
move /Y C:\Users\vagrant\VBoxGuestAdditions.iso C:\Windows\Temp
cmd /c ""C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\VBoxGuestAdditions.iso -oC:\Windows\Temp\virtualbox"

:: There needs to be Oracle CA (Certificate Authority) certificates installed in order
:: to prevent user intervention popups which will undermine a silent installation.
if exist "C:\Windows\Temp\virtualbox\cert\vbox-sha1.cer" cmd /c certutil -addstore -f "TrustedPublisher" C:\Windows\Temp\virtualbox\cert\vbox-sha1.cer
cmd /c C:\Windows\Temp\virtualbox\cert\VBoxCertUtil.exe add-trusted-publisher vbox*.cer --root vbox*.cer

cmd /c C:\Windows\Temp\virtualbox\VBoxWindowsAdditions.exe /S
echo Installing VirtualBox GuestAddition... finish
goto :done

:parallels
echo Installing Parallels GuestAddition...
if exist "C:\Users\vagrant\prl-tools-win.iso" (
	move /Y C:\Users\vagrant\prl-tools-win.iso C:\Windows\Temp
	cmd /C "C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\prl-tools-win.iso -oC:\Windows\Temp\parallels
	cmd /C C:\Windows\Temp\parallels\PTAgent.exe /install_silent
	rd /S /Q "c:\Windows\Temp\parallels"
)
echo Installing Parallels GuestAddition... finish
:done
if exist "C:\Windows\Temp\7zInstaller-x64.msi" (
    msiexec /qb /x C:\Windows\Temp\7zInstaller-x64.msi
)
