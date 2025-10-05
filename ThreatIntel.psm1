# ThreatIntel Module
# Author: Scott Davis
# Date: 02/02/2025

# Purpose: This module is designed to provide a set of functions that can be used to interact with threat intelligence data.

# Load API key from .env file
function Get-EnvVariables {
    $envFile = ".env"  # Change path if necessary
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            if ($_ -match "^(?<key>\S+)=(?<value>.+)$") {
                [System.Environment]::SetEnvironmentVariable($matches['key'], $matches['value'], [System.EnvironmentVariableTarget]::Process)
            }
        }
    } else {
        Write-Warning ".env file not found"
    }
}

# Define function Get-ThreatIntel($IPAddress)
function Get-ThreatIntel {
    param (
        [Parameter(Mandatory = $true)]
        [ValidatePattern("^(?:\d{1,3}\.){3}\d{1,3}$")]
        [string]$IP_Address
    )

    Write-Verbose "Validating IP address: $IP_Address"

    # Load API key from environment variables
    Get-EnvVariables
    $APIKey = [System.Environment]::GetEnvironmentVariable("API_KEY", [System.EnvironmentVariableTarget]::Process)

    if (-not $APIKey) {
        Write-Error "API key not found in environment variables."
        return $null
    }

    # API Configuration
    $Url = "https://api.abuseipdb.com/api/v2/check"
    $Headers = @{
        "Key" = $APIKey
        "Accept" = "application/json"
        "Verbose" = $true
    }
    $QueryParams = @{
        "ipAddress" = $IP_Address
        "maxAgeInDays" = 30
    }

    try {
        # Perform API request
        Write-Verbose "Sending request to AbuseIPDB..."
        $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method Get -Body $QueryParams

        # Return parsed response
        return $Response.data 
    }
    catch {
        Write-Error "Failed to fetch threat intel: $_"
        return $null
    }
}
