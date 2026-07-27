[CmdletBinding()]
param(
    [string]$ComposeFile = "$PSScriptRoot\compose.production.yml",
    [string]$EnvFile = "$PSScriptRoot\.env.production",
    [string]$HealthUrl = "http://127.0.0.1:8080/healthcheck",
    [ValidateRange(30, 900)]
    [int]$TimeoutSeconds = 180,
    [switch]$SkipPull
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-DockerCompose {
    param(
        [Parameter(Mandatory)]
        [string[]]$CommandArguments
    )

    & docker compose --env-file $EnvFile -f $ComposeFile @CommandArguments

    if ($LASTEXITCODE -ne 0) {
        throw "docker compose failed: $($CommandArguments -join ' ')"
    }
}

function Show-Diagnostics {
    Write-Host "Compose status:"
    & docker compose --env-file $EnvFile -f $ComposeFile ps

    Write-Host "Recent application logs:"
    & docker compose --env-file $EnvFile -f $ComposeFile logs --tail 200 jojo
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker is not installed or is not available on PATH."
}

if (-not (Test-Path -LiteralPath $ComposeFile -PathType Leaf)) {
    throw "Compose file not found: $ComposeFile"
}

if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) {
    throw "Environment file not found: $EnvFile. Copy deploy/.env.production.example first."
}

& docker info *> $null

if ($LASTEXITCODE -ne 0) {
    throw "The Docker daemon is not reachable."
}

Invoke-DockerCompose -CommandArguments @("config", "--quiet")

if (-not $SkipPull) {
    Invoke-DockerCompose -CommandArguments @("pull", "jojo")
}

Invoke-DockerCompose -CommandArguments @("up", "-d", "--remove-orphans", "jojo")

$containerId = (& docker compose --env-file $EnvFile -f $ComposeFile ps --quiet jojo).Trim()

if (-not $containerId) {
    Show-Diagnostics
    throw "Compose did not return a Jojo container ID."
}

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$containerState = ""

while ((Get-Date) -lt $deadline) {
    $containerState = (& docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' $containerId).Trim()

    if ($containerState -eq "healthy" -or $containerState -eq "running") {
        break
    }

    if ($containerState -eq "unhealthy" -or $containerState -eq "exited" -or $containerState -eq "dead") {
        Show-Diagnostics
        throw "Jojo entered container state '$containerState'."
    }

    Start-Sleep -Seconds 3
}

if ($containerState -ne "healthy" -and $containerState -ne "running") {
    Show-Diagnostics
    throw "Jojo did not become runnable within $TimeoutSeconds seconds."
}

try {
    $response = Invoke-WebRequest -UseBasicParsing -Uri $HealthUrl -TimeoutSec 10

    if ($response.StatusCode -ne 200 -or $response.Content.Trim() -ne "Ok!") {
        throw "Unexpected health response: HTTP $($response.StatusCode) '$($response.Content.Trim())'"
    }
} catch {
    Show-Diagnostics
    throw
}

Write-Host "Jojo is healthy at $HealthUrl using image configured in $EnvFile."
