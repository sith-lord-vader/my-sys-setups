function Reset-Env {
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

Export-ModuleMember -Function Reset-Env
Export-ModuleMember -Function Install-Winget