[CmdletBinding()]
param(
    [string]$ResourceGroup = "jojo-production",
    [string]$Location = "centralus",
    [string]$ContainerAppName = "jojo",
    [string]$EnvironmentName = "jojo-environment",
    [string]$Image = "ghcr.io/jhocali/aiseries:main",
    [ValidateRange(60, 900)]
    [int]$HealthTimeoutSeconds = 300
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required. Install it, run 'az login', and retry."
}

if ([string]::IsNullOrWhiteSpace($env:MONGODB_URI)) {
    throw "Set MONGODB_URI in this process before deploying. The script never writes or prints it."
}

& az account show --output none

if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI is not signed in. Run 'az login' and select the intended subscription."
}

& az group create --name $ResourceGroup --location $Location --output none

if ($LASTEXITCODE -ne 0) {
    throw "Unable to create or update resource group '$ResourceGroup'."
}

& az provider register --namespace Microsoft.App --wait --output none

if ($LASTEXITCODE -ne 0) {
    throw "Unable to register the Microsoft.App resource provider."
}

$applicationUrl = (& az deployment group create `
    --name "jojo-$([DateTime]::UtcNow.ToString('yyyyMMddHHmmss'))" `
    --resource-group $ResourceGroup `
    --template-file "$PSScriptRoot\main.bicep" `
    --parameters `
        location=$Location `
        containerAppName=$ContainerAppName `
        environmentName=$EnvironmentName `
        image=$Image `
        mongodbUri=$env:MONGODB_URI `
    --query "properties.outputs.applicationUrl.value" `
    --output tsv).Trim()

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($applicationUrl)) {
    throw "Azure deployment failed or did not return the application URL."
}

$healthUrl = "$applicationUrl/healthcheck"
$deadline = (Get-Date).AddSeconds($HealthTimeoutSeconds)

while ((Get-Date) -lt $deadline) {
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $healthUrl -TimeoutSec 10

        if ($response.StatusCode -eq 200 -and $response.Content.Trim() -eq "Ok!") {
            Write-Host "Jojo is healthy at $healthUrl using image $Image."
            exit 0
        }
    } catch {
        Write-Verbose "Waiting for the Container Apps revision: $($_.Exception.Message)"
    }

    Start-Sleep -Seconds 10
}

throw "Jojo did not return the expected health response from $healthUrl within $HealthTimeoutSeconds seconds."
