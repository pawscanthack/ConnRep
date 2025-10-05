# Script to get remote IP addresses for any active connections and save them to a text file
# Usage: .\Get-Connections.ps1
# Output: connections.txt
# Version: 1.0
# Author: Scott Davis
# Date: 2025-10-04

# Text file format: IP Address, Occurences, Flagged (True/False)

# Define the output file path
$IPdataFile = "IP_Data_File.txt"

# Check if the output file exists, if not create it
if (-Not (Test-Path -Path $IPdataFile)) {
    New-Item -Path $IPdataFile -ItemType File -Force | Out-Null
}   

# Load existing IP data from the file into a hashtable
$IPData = @{}
if (Test-Path -Path $IPdataFile) {
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
}   

# Get active TCP connections and extract remote IP addresses
$connections = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' }
foreach ($conn in $connections) {
    $remoteIP = $conn.RemoteAddress
    if ($remoteIP -and -not ($remoteIP -like '127.*') -and $remoteIP -ne '::1') {
        if ($IPData.ContainsKey($remoteIP)) {
            $IPData[$remoteIP].Occurrences += 1
        } else {
            $IPData[$remoteIP] = @{ Occurrences = 1; Flagged = $false }
        }

        # Only display if it's not a loopback
        Write-Host "IP Address: $remoteIP, Occurrences: $($IPData[$remoteIP].Occurrences)"
    }
}
 
# Save the updated IP data back to the file
$IPData.GetEnumerator() | ForEach-Object {
    "$($_.Key), $($_.Value.Occurrences), $($_.Value.Flagged)" 
} | Set-Content -Path $IPdataFile   
Write-Host "IP data saved to $IPdataFile"
# End of script
