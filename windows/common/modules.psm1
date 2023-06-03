function Reset-Env {
    param(
    [String]$Key = "Path"
    )

    Set-Item `
        -Path (('Env:', $Key) -join '') `
        -Value ((
            [System.Environment]::GetEnvironmentVariable($Key, "Machine"),
            [System.Environment]::GetEnvironmentVariable($Key, "User")
        ) -match '.' -join ';')
}

function Install-Winget {
    Write-Host "$args"
    winget install $args[0] --silent
    Write-Host "$args is now ready!"
}

Export-ModuleMember -Function Reset-Env
Export-ModuleMember -Function Install-Winget