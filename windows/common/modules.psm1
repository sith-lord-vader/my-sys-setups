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
        if (!(Test-Path "$UserInstalledFonts\$Name")){
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
    param(
    [String]$ArchiveFile,
    [String]$OutputDirectory
    )

    Reset-Env -Add "C:\Program Files\7-Zip"
    7z x $ArchiveFile -o"$OutputDirectory"
}

function Show-Menu (){
    
    Param(
        [Parameter(Mandatory=$True)][String]$MenuTitle,
        [Parameter(Mandatory=$True)][System.Collections.Specialized.OrderedDictionary]$MenuOptionsTable
    )

    $MenuOptions = [String[]] $MenuOptionsTable.Values

    $MaxValue = $MenuOptions.count-1
    $Selection = 0
    $EnterPressed = $False
    
    Clear-Host

    While($EnterPressed -eq $False){
        
        Write-Host "$MenuTitle"

        For ($i=0; $i -le $MaxValue; $i++){
            
            If ($i -eq $Selection){
                Write-Host -BackgroundColor Cyan -ForegroundColor Black "[ $($MenuOptions[$i]) ]"
            } Else {
                Write-Host "  $($MenuOptions[$i])  "
            }

        }

        $KeyInput = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown").virtualkeycode

        Switch($KeyInput){
            13{
                $EnterPressed = $True
                Clear-Host
                Return $MenuOptionsTable[$Selection]
                break
            }

            38{
                If ($Selection -eq 0){
                    $Selection = $MaxValue
                } Else {
                    $Selection -= 1
                }
                Clear-Host
                break
            }

            40{
                If ($Selection -eq $MaxValue){
                    $Selection = 0
                } Else {
                    $Selection +=1
                }
                Clear-Host
                break
            }
            Default{
                Clear-Host
            }
        }
    }
}

function Get-Fonts {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    $objFonts = New-Object System.Drawing.Text.InstalledFontCollection
    $colFonts = $objFonts.Families

    return $colFonts
}

function Test-Font {
    param(
    [String]$Font
    )

    $AllFonts = Get-Fonts
    
    for ($i = 1; $i -le $AllFonts.Count; $i++) {
        if ($AllFonts[$i] -contains $Font) {
            return $true
        }
    }
    
    return $false
}

Export-ModuleMember -Function Reset-Env
Export-ModuleMember -Function Install-Winget
Export-ModuleMember -Function Install-Fonts
Export-ModuleMember -Function Write-Pretty
Export-ModuleMember -Function Expand-7Zip
Export-ModuleMember -Function Show-Menu
Export-ModuleMember -Function Test-Font
