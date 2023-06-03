Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sith-lord-vader/my-sys-setups/main/windows/setup-2.ps1" -o "setup-2.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sith-lord-vader/my-sys-setups/main/windows/setup.bat" -o "setup.bat"
cmd.exe /c 'setup.bat'