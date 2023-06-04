# ! Run using Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sith-lord-vader/my-sys-setups/main/windows/setup-1.ps1" | iex

function ResetPath {
    # ? Inspiration taken from https://stackoverflow.com/a/56033268

    $env:Path=(
        [System.Environment]::GetEnvironmentVariable("Path","Machine"),
        [System.Environment]::GetEnvironmentVariable("Path","User")
    ) -match '.' -join ';'
}

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
# TODO: Check if fonts already present, then skip this step
Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/Meslo.zip" -OutFile "$TempDir\Meslo.zip"
Invoke-WebRequest -Uri "https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip" -OutFile "$TempDir\CascadiaCode.zip"

# TODO: Make a wrapper function for 7z to add 7z in PATH
7z x "$TempDir\Meslo.zip" -o"$TempDir\Meslo"
7z x "$TempDir\CascadiaCode.zip" -o"$TempDir\CascadiaCode"
Remove-Item "$TempDir\CascadiaCode\ttf\static" -Recurse

Install-Fonts -SourceDir "$TempDir\Meslo" -FileRegex "MesloLGLNerd*.ttf"
Install-Fonts -SourceDir "$TempDir\CascadiaCode\ttf" -FileRegex "Cascadia*.ttf"

# ! Install Oh-My-Posh
Install-Winget JanDeDobbeleer.OhMyPosh
Reset-Env

# ! Setting up Powershell User Profile
$UserProfileDir = "$HOME\Documents\PowerShell"
$UserProfileDirOneDrive = "$HOME\OneDrive\Documents\PowerShell"
if (Test-Path $UserProfileDir) {
    if (Test-Path "$UserProfileDir\Microsoft.PowerShell_profile.ps1") {
        Remove-Item "$UserProfileDir\Microsoft.PowerShell_profile.ps1"
    }
}
else {
    New-Item $UserProfileDir -ItemType Directory
}

if (Test-Path $UserProfileDirOneDrive) {
    if (Test-Path "$UserProfileDirOneDrive\Microsoft.PowerShell_profile.ps1") {
        Remove-Item "$UserProfileDirOneDrive\Microsoft.PowerShell_profile.ps1"
    }
}
else {
    New-Item $UserProfileDirOneDrive -ItemType Directory
}


Install-Module PowerType -AllowPrerelease
New-Item -ItemType SymbolicLink -Path "$UserProfileDir\Microsoft.PowerShell_profile.ps1" -Target "$RepoLocation\windows\common\profile.ps1"
New-Item -ItemType SymbolicLink -Path "$UserProfileDirOneDrive\Microsoft.PowerShell_profile.ps1" -Target "$RepoLocation\windows\common\profile.ps1"

# ! Configure Windows Terminal
$WTProfileLocation = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $WTProfileLocation) {
}
else {
    New-Item $WTProfileLocation -ItemType Directory
}

$WTProfileLocation = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $WTProfileLocation) {
    Remove-Item $WTProfileLocation
}
else {
}
New-Item -ItemType SymbolicLink -Path $WTProfileLocation -Target "$RepoLocation\windows\common\wt.json"


# TODO: multiple setup profiles for machines (eg. minimal, default). Choose at beginning of this script

Pause
Stop-Process -Id $PID