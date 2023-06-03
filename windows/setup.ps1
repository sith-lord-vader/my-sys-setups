function ResetPath {
    # ? Inspiration taken from https://stackoverflow.com/a/56033268

    $env:Path=(
        [System.Environment]::GetEnvironmentVariable("Path","Machine"),
        [System.Environment]::GetEnvironmentVariable("Path","User")
    ) -match '.' -join ';'
}

winget install Microsoft.Powershell --silent
ResetPath

# ? Elevate the script to Admin
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process pwsh.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}
'running with full privileges'
# ? ------------------------------

# ? Actual script

# ! Setup Git
winget install Git.Git --silent
ResetPath

# ! Cloning the repo
Set-Location -Path $HOME
$RepoLocation = "$HOME\my-sys-setups"

if (Test-Path $RepoLocation) {
    Set-Location -Path $RepoLocation
    Git pull
}
else {
    Git clone https://github.com/sith-lord-vader/my-sys-setups.git 
}

# ! Import Common-Modules
Import-Module $RepoLocation\windows\common\modules.psm1 -Force

# ! Setup Temp directory
$TempDir = "$env:TEMP\my-sys-setups"

if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse
    New-Item $TempDir -ItemType Directory
}
else {
    New-Item $TempDir -ItemType Directory
}

# ! Installing Windows Terminal and 7zip
Install-Winget Microsoft.WindowsTerminal
Install-Winget 7zip.7zip
Reset-Env -Add "C:\Program Files\7-Zip"

# ! Installing Fonts
Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/Meslo.zip" -OutFile "$TempDir\Meslo.zip"
Invoke-WebRequest -Uri "https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip" -OutFile "$TempDir\CascadiaCode.zip"

7z x "$TempDir\Meslo.zip" -o"$TempDir\Meslo"
7z x "$TempDir\CascadiaCode.zip" -o"$TempDir\CascadiaCode"
Remove-Item "$TempDir\CascadiaCode\ttf\static" -Recurse

Install-Fonts -SourceDir "$TempDir\Meslo" -FileRegex "MesloLGLNerd*.ttf"
Install-Fonts -SourceDir "$TempDir\CascadiaCode\ttf" -FileRegex "Cascadia*.ttf"

Pause
Stop-Process -Id $PID