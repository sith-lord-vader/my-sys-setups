function Write-Pretty {
    # TODO: Add a pretty console Output
}

function Reset-Env {
    # ? Inspiration taken from https://stackoverflow.com/a/56033268

    param(
    [String]$Key = "Path",
    [String]$Add = ""
    )

    Set-Item `
        -Path (('Env:', $Key) -join '') `
        -Value ((
            [System.Environment]::GetEnvironmentVariable($Key, "Machine"),
            [System.Environment]::GetEnvironmentVariable($Key, "User"),
            $Add
        ) -match '.' -join ';')
}

function Install-Winget {
    Write-Host "Checking $args"
    winget install $args --silent
    Write-Host "$args is now ready!"
}

function Install-Fonts {
    # ? This part of code is taken from https://witit.blog/font-installer-script-powershell/
    param(
    [String]$SourceDir = "Path",
    [String]$FileRegex = ""
    )
    $ShellObject = New-Object -ComObject shell.application
    $Fonts = $ShellObject.NameSpace(0x14)
    $FontsToInstallDirectory = $SourceDir
    $FontsToInstall = Get-ChildItem $FontsToInstallDirectory -Recurse -Include $FileRegex
    $Ctr = 1
    $Total = $FontsToInstall.Count
    ForEach ($F in $FontsToInstall){
        $FullPath = $F.FullName
        $Name = $F.Name
        $UserInstalledFonts = "$ENV:USERPROFILE\AppData\Local\Microsoft\Windows\Fonts"
        If (!(Test-Path "$UserInstalledFonts\$Name")){
            $Fonts.CopyHere($FullPath)
            Write-Host "[$Ctr of $Total] || Installed Font $Name...moving on!" -ForegroundColor Cyan
        }
        else{
            Write-Host "[$Ctr of $Total] || Font $Name is already installed bro..." -ForegroundColor Green
        }
        $Ctr++
    }
}

function Expand-7Zip {
    Write-Host $args
    Write-Host $args[0]
    7z x $args[0] -o$args[1]
}

Export-ModuleMember -Function Reset-Env
Export-ModuleMember -Function Install-Winget
Export-ModuleMember -Function Install-Fonts
Export-ModuleMember -Function Write-Pretty
Export-ModuleMember -Function Expand-7Zip
