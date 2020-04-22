[CmdletBinding()]
param (
    [Switch]
    $Force
)

$SampleServers = 50

$CountryURL = 'https://api.nordvpn.com/v1/servers/countries'
$GroupURL = 'https://api.nordvpn.com/v1/servers/groups'
$TechnologyURL = 'https://api.nordvpn.com/v1/technologies'
$ServerURL = "https://api.nordvpn.com/v1/servers?limit=$SampleServers"

# Filter for test files
function GetTestData {
    $prefixes = @(
        'cities_*'
        'countries_*'
        'groups_*'
        'technologies_*'
        'servers_*'
        'recommended_*'
    )
    $list = @()
    $list += Get-ChildItem .\tests\*_raw.xml -File -Include $prefixes
    $list += Get-ChildItem .\tests\*_proc.xml -File -Include $prefixes

    $list
}

# Ensure we're in the right place
$ModulePath = Resolve-Path (Split-Path $PSScriptRoot)
if ((Split-Path $ModulePath -Leaf) -match '\d+\.\d+\.\d+') {
    $ModuleName = Split-Path (Split-Path $ModulePath) -Leaf
} else {
    $ModuleName = Split-Path $ModulePath -Leaf
}
Push-Location $ModulePath

if (!((Test-Path NordVPN-Servers.psm1 -PathType Leaf) -and (Test-Path .\tests\ -PathType Container))) {
    throw ("Couldn't find the NordVPN-Servers module. This script" +
        " must be run from the /tests directory in the module root!")
}

# Confirm
if (
    !($Force -or $PSCmdlet.ShouldContinue(
            "This will produce new test data using the module functions in their current state.`n" +
            "If the functions have been modified then the data will reflect those changes.`n" +
            "NOTE: YOU NEED TO BE CONNECTED TO THE INTERNET FOR THIS TO WORK.`n" +
            "Are you sure you want to continue?", "Regnerate all test data"
        )
    )
) { return }

# Get some early data to ensure we can access the API
$CountryRaw = Invoke-RestMethod -Uri $CountryURL
$GroupRaw = Invoke-RestMethod -Uri $GroupURL
$TechnologyRaw = Invoke-RestMethod -Uri $TechnologyURL
$ServerRaw = Invoke-RestMethod -Uri $ServerURL
if (
    ($CountryRaw.Count -lt 40) -or
    ($GroupRaw.Count -lt 4) -or
    ($TechnologyRaw.Count -lt 12) -or
    ($ServerRaw).Count -lt $SampleServers
) {
    throw 'Cannot access API or data is wildly different than expected.'
}

# Force latest module state
Get-Module $ModuleName -All | Remove-Module -Force -ErrorAction Stop
Import-Module -Name "$ModulePath\$ModuleName.psd1" -Force -ErrorAction Stop

$curOfflineMode = Get-NordVPNModuleSetting OfflineMode
Set-NordVPNModuleSetting OfflineMode $false -ErrorAction Stop

# Force latest data from online API
Clear-NordVPNCache

# Delete old test files
GetTestData | Remove-Item -Force -ErrorAction Stop
if (Test-Path .\tests\testdata.zip) {
    Remove-Item .\tests\testdata.zip -Force -ErrorAction Stop
}

# Save raw data from the API for simulations
$CountryRaw | Export-Clixml .\tests\countries_raw.xml -Encoding UTF8
$GroupRaw | Export-Clixml .\tests\groups_raw.xml -Encoding UTF8
$TechnologyRaw | Export-Clixml .\tests\technologies_raw.xml -Encoding UTF8
$ServerRaw | Export-Clixml .\tests\servers_raw.xml -Encoding UTF8

# Save latest full country, group, and technology lists
Get-NordVPNCountryList | Export-Clixml .\tests\countries_proc.xml -Encoding UTF8
Get-NordVPNGroupList | Export-Clixml .\tests\groups_proc.xml -Encoding UTF8
Get-NordVPNTechnologyList | Export-Clixml .\tests\technologies_proc.xml -Encoding UTF8
Get-NordVPNCityList | Export-Clixml .\tests\cities_proc.xml -Encoding UTF8

# 5% sample of all/recommended servers lists
Get-NordVPNServerList -First $SampleServers | Export-Clixml .\tests\servers_proc.xml -Encoding UTF8
Get-NordVPNRecommendedList -Limit $SampleServers -Country US -Group legacy_standard -Technology ikev2 `
| Export-Clixml .\tests\recommended_proc.xml -Encoding UTF8

# Compress test data
Compress-Archive (GetTestData) .\tests\testdata.zip -CompressionLevel Optimal -Force
GetTestData | Remove-Item -Force

# Return to previous mode
Set-NordVPNModuleSetting OfflineMode $curOfflineMode

Write-Output "`n`nDone. Please check that the data is valid with '.\tests\Run-Tests.ps1'"

Pop-Location
