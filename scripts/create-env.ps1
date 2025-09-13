Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-EnvFile {
    if (-not (Test-Path ".env")) {
        if (-not (Test-Path ".env.example")) {
            Write-Error "Missing .env.example file. Cannot create .env."
            exit 1
        }

        Write-Host "Creating .env file from .env.example..."
        Copy-Item ".env.example" ".env"
    } else {
        Write-Host ".env already exists. Skipping copy..."
    }
}

function Get-LocalIPv4 {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object {
            $_.InterfaceAlias -notlike "*Virtual*" -and
            $_.IPAddress -notlike "169.*" -and
            $_.IPAddress -ne "127.0.0.1"
        } |
        Select-Object -First 1).IPAddress

    if (-not $ip) {
        Write-Error "Could not determine local IPv4 address."
        exit 1
    }

    return $ip
}

function Update-EnvHost($ip) {
    Write-Host "Setting HOST=$ip in .env..."

    $content = Get-Content ".env"

    if ($content -match '^HOST=') {
        $content = $content -replace '^HOST=.*', "HOST=$ip"
    } else {
        $content += "HOST=$ip"
    }

    $content | Set-Content ".env"
}

Ensure-EnvFile

$localIp = Get-LocalIPv4
Update-EnvHost $localIp

Write-Host "🌙 Setup completed!"
