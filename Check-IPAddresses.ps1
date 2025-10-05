# Script to load IP address data from a file and use the ThreatIntel.psm1 module to check if the IPs are flagged
# Usage: .\Check-IPAddresses.ps1
# Output: Updated IP_Data_File.txt with flagged status
# Version: 1.0
# Author: Scott Davis
# Date: 2025-10-04
# Text file format: IP Address, Occurences, Flagged (True/False)

# Import the ThreatIntel module
Import-Module .\ThreatIntel.psm1

# Define the input/output file path
$IPdataFile = "IP_Data_File.txt"
if (-Not (Test-Path -Path $IPdataFile)) {
    Write-Error "IP data file not found: $IPdataFile"
    exit
}
# Load existing IP data from the file into a hashtable
$IPData = @{}
$lines = Get-Content -Path $IPdataFile
foreach ($line in $lines) {
    $parts = $line -split ","
    if ($parts.Length -eq 3) {
        $ip = $parts[0].Trim()
        $occurrences = [int]$parts[1].Trim()
        $flagged = [bool]::Parse($parts[2].Trim())
        $IPData[$ip] = @{ Occurrences = $occurrences; Flagged = $flagged }
    }
}
# Check each IP address using the ThreatIntel module
foreach ($ip in $IPData.Keys) {
    if (-not $IPData[$ip].Flagged) {
        Write-Host "Checking IP address: $ip"
        $threatInfo = Get-ThreatIntel -IP_Address $ip
        if ($threatInfo) {
            if ($threatInfo.abuseConfidenceScore -ge 50) {
                Write-Host "IP $ip is flagged with confidence score: $($threatInfo.abuseConfidenceScore)" -ForegroundColor Red
                $IPData[$ip].Flagged = $true
            } else {
                Write-Host "IP $ip is not flagged. Confidence score: $($threatInfo.abuseConfidenceScore)" -ForegroundColor Green
            }
        } else {
            Write-Warning "No threat information returned for IP: $ip"
        }
    } else {
        Write-Host "IP address $ip is already flagged." -ForegroundColor Yellow
    }
}  
# Save the updated IP data back to the file
$IPData.GetEnumerator() | ForEach-Object {
    "$($_.Key), $($_.Value.Occurrences), $($_.Value.Flagged)" 
} | Set-Content -Path $IPdataFile   
Write-Host "Updated IP data saved to $IPdataFile"
# End of script     