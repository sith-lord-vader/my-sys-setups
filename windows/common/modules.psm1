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

Export-ModuleMember -Function Reset-Env