# ConnRep
PowerShell module and helper scripts to collect active remote connections and check IP reputation using the AbuseIPDB API.

This repository contains:

- `ThreatIntel.psm1` - a small module exposing `Get-ThreatIntel` to query AbuseIPDB for an IP address.
- `Get-Connections.ps1` - enumerates active TCP connections, accumulates remote IPs and occurrence counts, and saves them to `IP_Data_File.txt`.
- `Check-IPAddresses.ps1` - loads `IP_Data_File.txt`, calls `Get-ThreatIntel` for each unflagged IP, and updates the file with flagged status.

## Requirements

- Windows with PowerShell (PowerShell 5.1 or newer recommended).
- Network privileges to list TCP connections (`Get-NetTCPConnection`). Running in an elevated session may be required to see all connections.
- An AbuseIPDB API key. See https://www.abuseipdb.com for details.

## Setup

1. Create a `.env` file in the repository root (same folder as the scripts) with your API key:

```
API_KEY=your_abuseipdb_api_key_here
```

2. (Optional) Unblock the files if you downloaded them from the internet:

PowerShell example:

```powershell
Unblock-File .\*.ps1, .\*.psm1
```

## Usage

1. Enumerate active remote connections and build/update the IP list:

```powershell
.\Get-Connections.ps1
```

This creates/updates `IP_Data_File.txt`. Each line has the format:

```
<IP Address>, <Occurrences>, <Flagged>
```

2. Check the IP list against AbuseIPDB and mark flagged addresses:

```powershell
.\Check-IPAddresses.ps1
```

`Check-IPAddresses.ps1` imports the local module with `Import-Module .\ThreatIntel.psm1`. If you prefer, you can import the module manually first:

```powershell
Import-Module .\ThreatIntel.psm1
Get-ThreatIntel -IP_Address 8.8.8.8 -Verbose
```

## What the scripts do

- `Get-Connections.ps1` reads current `IP_Data_File.txt` (if present), enumerates established TCP connections via `Get-NetTCPConnection`, updates occurrence counts, and saves the file.
- `Check-IPAddresses.ps1` reads `IP_Data_File.txt`, calls `Get-ThreatIntel` for each IP that isn't already flagged, and sets `Flagged` to `True` when the AbuseIPDB confidence score meets the script's threshold (the script checks for a score >= 50).

## Notes & Troubleshooting

- Ensure the `.env` file is present and contains `API_KEY`. The module reads this file and sets a process environment variable.
- The AbuseIPDB API may enforce rate limits and usage policies — consult their docs if you see errors or empty responses.
- If `Get-NetTCPConnection` returns few or no results, try running PowerShell as Administrator.
- If you get "API key not found" from the module, verify the `.env` file is in the same folder and has the correct key name (`API_KEY`).

## License

See the `LICENSE` file in this repository.

---

Enjoy — and use responsibly. This tool is intended for defensive/administrative purposes only.
