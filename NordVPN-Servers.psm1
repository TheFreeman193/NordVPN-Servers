#Requires -Module @{ ModuleName = 'Microsoft.PowerShell.Archive'; ModuleVersion = '1.0' }

New-Variable -Option Constant -Scope Script TechnologyURL 'https://api.nordvpn.com/v1/technologies'
New-Variable -Option Constant -Scope Script GroupURL 'https://api.nordvpn.com/v1/servers/groups'
New-Variable -Option Constant -Scope Script CountryURL 'https://api.nordvpn.com/v1/servers/countries'
New-Variable -Option Constant -Scope Script API_ALL_URL 'https://api.nordvpn.com/v1/servers?limit={0}'
New-Variable -Option Constant -Scope Script API_URL_BASE `
    'https://api.nordvpn.com/v1/servers/recommendations?limit={0}'
New-Variable -Option Constant -Scope Script SettingsFile (Join-Path $PSScriptRoot 'NordVPN-Servers.settings.json')
New-Variable -Option Constant -Scope Script TechnologyFallback (Join-Path $PSScriptRoot 'NordVPN_Technologies.xml')
New-Variable -Option Constant -Scope Script GroupFallback (Join-Path $PSScriptRoot 'NordVPN_Groups.xml')
New-Variable -Option Constant -Scope Script CountryFallback (Join-Path $PSScriptRoot 'NordVPN_Countries.xml')
New-Variable -Option Constant -Scope Script ServerFallback (Join-Path $PSScriptRoot 'NordVPN_Servers.xml')
New-Variable -Option Constant -Scope Script GetServersLimitParamHelp (
    'Gets the first x number of servers specified (1-65535, default: 8192).' +
    "`nNote:Lowering this number may result in some servers matching the filters to be missed."
)
New-Variable -Option Constant -Scope Script FailedList @{
    Message           = 'Unable to retrieve server list from NordVPN API'
    Category          = [System.Management.Automation.ErrorCategory]::ResourceUnavailable
    RecommendedAction = 'Check internet connection and API server status'
    CategoryActivity  = 'Retrieve server list'
    CategoryReason    = 'Server list not available'
}
New-Variable -Option Constant -Scope Script DefaultSettings @{
    CountryCacheLifetime         = @([UInt32], 600)
    GroupCacheLifetime           = @([UInt32], 600)
    TechnologyCacheLifetime      = @([UInt32], 600)
    OfflineMode                  = @([Boolean], $false)
    DeleteServerFallbackAfterUse = @([Boolean], $false)
}
New-Variable -Option Constant -Scope Script KnownCountries @(
    'AL', 'AR', 'AU', 'AT', 'BE', 'BA', 'BR', 'BG', 'CA', 'CL', 'CR', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'GE', 'DE',
    'GR', 'HK', 'HU', 'IS', 'IN', 'ID', 'IE', 'IL', 'IT', 'JP', 'LV', 'LU', 'MY', 'MX', 'MD', 'NL', 'NZ', 'MK', 'NO', 'PL',
    'PT', 'RO', 'RS', 'SG', 'SK', 'SI', 'ZA', 'KR', 'ES', 'SE', 'CH', 'TW', 'TH', 'TR', 'UA', 'AE', 'GB', 'US', 'VN'
)
New-Variable -Option Constant -Scope Script KnownGroups @(
    'legacy_double_vpn', 'legacy_onion_over_vpn', 'legacy_ultra_fast_tv', 'legacy_anti_ddos',
    'legacy_dedicated_ip', 'legacy_standard', 'legacy_netflix_usa', 'legacy_p2p', 'legacy_obfuscated_servers',
    'europe', 'the_americas', 'asia_pacific', 'africa_the_middle_east_and_india'
)
New-Variable -Option Constant -Scope Script KnownTechnologies @(
    'ikev2', 'openvpn_udp', 'openvpn_tcp', 'socks', 'proxy', 'pptp', 'l2tp', 'openvpn_xor_udp', 'openvpn_xor_tcp',
    'proxy_cybersec', 'proxy_ssl', 'proxy_ssl_cybersec', 'ikev2_v6', 'openvpn_udp_v6', 'openvpn_tcp_v6',
    'wireguard_udp', 'openvpn_udp_tls_crypt', 'openvpn_tcp_tls_crypt', 'openvpn_dedicated_udp',
    'openvpn_dedicated_tcp', 'v2ray'
)

[DateTime]$script:CountryCacheDate = [DateTime]::MinValue
[DateTime]$script:TechnologyCacheDate = [DateTime]::MinValue
[DateTime]$script:GroupCacheDate = [DateTime]::MinValue
New-Variable -Scope Script CountryCache $null
New-Variable -Scope Script TechnologyCache $null
New-Variable -Scope Script GroupCache $null

Function LoadSettings {
    $SettingsIn = Get-Content $SettingsFile -ea:si | ConvertFrom-Json
    $script:SETTINGS = @{ }
    if ($null -eq $SettingsIn) {
        foreach ($key in $DefaultSettings.Keys) {
            $SETTINGS.$key = $DefaultSettings.$key[1]
        }
        $SETTINGS | ConvertTo-Json | Set-Content $SettingsFile -Force
        Write-Verbose "Wrote default settings to '$SettingsFile'"
    }
    else {
        foreach ($entry in $SettingsIn.PSObject.Properties) {
            if ($DefaultSettings.ContainsKey($entry.Name)) {
                $SETTINGS[$entry.Name] = $entry.Value -as $DefaultSettings[$entry.Name][0]
            }
            else {
                Write-Warning "Invalid setting $($entry.Name) not loaded"
            }
        }
        Write-Verbose "Loaded persistent settings from '$SettingsFile'"
    }
}
LoadSettings

<# ##### Settings access #####
    Functions to modify and read config
#>
function Set-ModuleSetting {
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'SetDefault')]
    [OutputType("System.Void")]
    param (
        [Switch]
        $Force
    )
    begin {
        $SettingsChanged = $false
    }
    dynamicparam {
        $paramDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDict.Add('Name', (
                Get-ModuleSettingNameDynamicParam @('SetDefault', 'SetValue')
            ))
        $paramAttribCol = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $paramAttrib = New-Object System.Management.Automation.ParameterAttribute
        $paramAttrib.Position = 1
        $paramAttrib.Mandatory = $true
        $paramAttrib.HelpMessage = 'The new value for the setting.'
        $paramAttrib.ParameterSetName = 'SetValue'
        $paramAttribCol.Add($paramAttrib)
        $paramObj = New-Object System.Management.Automation.RuntimeDefinedParameter(
            'Value', [Object], $paramAttribCol
        )
        $paramDict.Add('Value', $paramObj)
        return $paramDict
    }
    process {
        Write-Debug ("Parameter set name: $($PSCmdlet.ParameterSetName)")
        $Name = $PSBoundParameters.Name
        if ($PSCmdlet.ParameterSetName -eq 'SetDefault') {
            $defaultValue = $DefaultSettings[$Name][1]
            if ($Force -or $PSCmdlet.ShouldContinue(
                    ("This will reset '{0}' to its default of {1}. Are you sure?" -f
                        $Name, $defaultValue),
                    "Reset setting to default"
                )
            ) {
                if ($PSCmdlet.ShouldProcess("Setting: $Name", "Reset default: $defaultValue")) {
                    $SETTINGS[$Name] = $defaultValue
                }
                $SettingsChanged = $true
            }
            return
        }
        $targetType = $DefaultSettings[$Name][0]
        $Value = $PSBoundParameters.Value -as $targetType
        if ($Value -is $targetType) {
            if ($PSCmdlet.ShouldProcess("Setting: $Name", "Update value: $Value")) {
                if ($SETTINGS[$Name] -ne $Value) { $SettingsChanged = $true }
                $SETTINGS[$Name] = $Value
            }
        }
        else {
            throw ("The type of value '{0}' does not match required type: {1}" -f
                $PSBoundParameters.Value, $targetType
            )
        }
    }
    end {
        if ($SettingsChanged) {
            $SETTINGS | ConvertTo-Json | Set-Content $SettingsFile -Force
            Write-Verbose "Settings changed: Updated settings file '$SettingsFile'"
        }
    }
}


function Get-ModuleSetting {
    [CmdletBinding(DefaultParameterSetName = 'GetAll')]
    [OutputType("System.Object")]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'GetDefault')]
        [Switch]
        $Default,

        [Parameter(Mandatory = $true, ParameterSetName = 'GetType')]
        [Switch]
        $Type
    )
    dynamicparam {
        $paramDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDict.Add('Name', (
                Get-ModuleSettingNameDynamicParam @('GetDefault', 'GetType', 'GetValue')
            ))
        return $paramDict
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'GetDefault' {
                $DefaultSettings[$PSBoundParameters.Name][1]
            }
            'GetType' {
                $DefaultSettings[$PSBoundParameters.Name][0]
            }
            'GetValue' {
                $SETTINGS[$PSBoundParameters.Name]
            }
            default { $SETTINGS.Clone() }
        }
    }
}


function Reset-Module {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType('System.Void')]
    param (
        [Switch]
        $Force
    )
    process {
        if ($Force -or $PSCmdlet.ShouldContinue(
                "This will reset all NordVPN-Servers module settings to their defaults. Are you sure?",
                "Reset settings to default"
            )
        ) {
            if ($PSCmdlet.ShouldProcess('All settings', 'Reset defaults')) {
                $SETTINGS.Clear()
                foreach ($key in $DefaultSettings.Keys) {
                    $SETTINGS.$key = $DefaultSettings.$key[1]
                }
                Clear-Cache
            }
            $SETTINGS | ConvertTo-Json | Set-Content $SettingsFile
            Write-Verbose "Settings changed: Updated settings file '$SettingsFile'"
        }
    }
}

<# ##### Dymamic Parameters #####
    Some functions to build dynamic parameters for each filter type
#>

function Get-ModuleSettingNameDynamicParam {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.RuntimeDefinedParameter')]
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [String[]]
        $SetNames
    )
    process {
        $pos = 0
        $mand = $true
        $help = 'The name of the module setting'
        $paramAttribCol = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        foreach ($n in $SetNames) {
            $paramAttrib = New-Object System.Management.Automation.ParameterAttribute
            $paramAttrib.Position = $pos
            $paramAttrib.Mandatory = $mand
            $paramAttrib.HelpMessage = $help
            $paramAttrib.ParameterSetName = $n
            $paramAttribCol.Add($paramAttrib)
        }
        $paramVals = [Array]$SETTINGS.Keys
        $paramValidateSet = New-Object System.Management.Automation.ValidateSetAttribute($paramVals)
        $paramAttribCol.Add($paramValidateSet)
        New-Object System.Management.Automation.RuntimeDefinedParameter(
            'Name', [String], $paramAttribCol
        )
    }
}


function Get-CountryDynamicParam {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.RuntimeDefinedParameter')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [UInt16]
        $pos,

        [Parameter(Mandatory = $true, Position = 1)]
        [String[]]
        $SetNames,

        [Parameter(Mandatory = $false, Position = 2)]
        [Switch]
        $Offline
    )
    begin {
        $oldProgressPreference = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
    }
    process {
        Write-Debug 'Dynamic Country parameter requested.'
        $mand = $false
        $fromPipeProp = $true
        $help = 'Please enter a 2-digit ISO 3166-1 country code ' +
        'e.g GB (run Show-NordVPNCountryList for reference)'
        $ctryAttribCol = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        foreach ($n in $SetNames) {
            $paramAttrib = New-Object System.Management.Automation.ParameterAttribute
            $paramAttrib.Position = $pos
            $paramAttrib.Mandatory = $mand
            $paramAttrib.HelpMessage = $help
            $paramAttrib.ParameterSetName = $n
            $paramAttrib.ValueFromPipelineByPropertyName = $fromPipeProp
            $ctryAttribCol.Add($paramAttrib)
        }
        if ($Offline) {
            $ctryVals = (Get-CountryList -Offline).Code
        }
        else {
            $ctryVals = (Get-CountryList).Code
        }
        if ($ctryVals.Count -lt 1) { $ctryVals = $KnownCountries }
        $ctryValidateSet = New-Object System.Management.Automation.ValidateSetAttribute($ctryVals)
        $ctryAttribCol.Add($ctryValidateSet)
        New-Object System.Management.Automation.RuntimeDefinedParameter(
            'Country', [String], $ctryAttribCol
        )
    }
    end {
        $ProgressPreference = $oldProgressPreference
    }
}


function Get-GroupDynamicParam {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.RuntimeDefinedParameter')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [UInt16]
        $pos,

        [Parameter(Mandatory = $true, Position = 1)]
        [String[]]
        $SetNames,

        [Parameter(Mandatory = $false, Position = 2)]
        [Switch]
        $Offline
    )
    begin {
        $oldProgressPreference = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
    }
    process {
        Write-Debug 'Dynamic Group parameter requested.'
        $mand = $false
        $help = 'Please enter a group code e.g. legacy_standard ' +
        '(run Show-NordVPNGroupList for reference)'
        $fromPipeProp = $true
        $grpAttribCol = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        foreach ($n in $SetNames) {
            $paramAttrib = New-Object System.Management.Automation.ParameterAttribute
            $paramAttrib.Position = $pos
            $paramAttrib.Mandatory = $mand
            $paramAttrib.HelpMessage = $help
            $paramAttrib.ParameterSetName = $n
            $paramAttrib.ValueFromPipelineByPropertyName = $fromPipeProp
            $grpAttribCol.Add($paramAttrib)
        }
        if ($Offline) {
            $grpVals = (Get-GroupList -Offline).Code
        }
        else {
            $grpVals = (Get-GroupList).Code
        }
        if ($grpVals.Count -lt 1) { $grpVals = $KnownGroups }
        $grpValidateSet = New-Object System.Management.Automation.ValidateSetAttribute($grpVals)
        $grpAttribCol.Add($grpValidateSet)
        New-Object System.Management.Automation.RuntimeDefinedParameter(
            'Group', [String], $grpAttribCol
        )
    }
    end {
        $ProgressPreference = $oldProgressPreference
    }
}


function Get-TechnologyDynamicParam {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.RuntimeDefinedParameter')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [UInt16]
        $pos,

        [Parameter(Mandatory = $true, Position = 1)]
        [String[]]
        $SetNames,

        [Parameter(Mandatory = $false, Position = 2)]
        [Switch]
        $Offline
    )
    begin {
        $oldProgressPreference = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
    }
    process {
        Write-Debug 'Dynamic Technology parameter requested.'
        $mand = $false
        $help = 'Please enter a technology code e.g. openvpn_udp ' +
        '(run Show-NordVPNTechnologyList for reference)'
        $fromPipeProp = $true
        $techAttribCol = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        foreach ($n in $SetNames) {
            $paramAttrib = New-Object System.Management.Automation.ParameterAttribute
            $paramAttrib.Position = $pos
            $paramAttrib.Mandatory = $mand
            $paramAttrib.HelpMessage = $help
            $paramAttrib.ParameterSetName = $n
            $paramAttrib.ValueFromPipelineByPropertyName = $fromPipeProp
            $techAttribCol.Add($paramAttrib)
        }
        if ($Offline) {
            $techVals = (Get-TechnologyList -Offline).Code
        }
        else {
            $techVals = (Get-TechnologyList).Code
        }
        if ($techVals.Count -lt 1) { $techVals = $KnownTechnologies }
        $techValidateSet = New-Object System.Management.Automation.ValidateSetAttribute($techVals)
        $techAttribCol.Add($techValidateSet)
        New-Object System.Management.Automation.RuntimeDefinedParameter(
            'Technology', [String], $techAttribCol
        )
    }
    end {
        $ProgressPreference = $oldProgressPreference
    }
}


<# ##### Cache Functions #####
    Given the number of countries with servers, technology types and group
    definitions are unlikely to change from minute-to-minute, this
    significantly reduces web traffic and improves performace. This does not
    affect Get-NordVPNRecommendedList which will always result in API calls.
#>

function Clear-CountryCache {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType('System.Void')]
    param()
    process {
        Write-Debug "Request to clear the country cache"
        $script:CountryCacheDate = [DateTime]::MinValue
        Clear-Variable CountryCache -Force -Scope Script
        Write-Verbose "Cleared the NordVPN country cache."
    }
}


function Clear-GroupCache {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType('System.Void')]
    param()
    process {
        Write-Debug "Request to clear the group cache"
        $script:GroupCacheDate = [DateTime]::MinValue
        Clear-Variable -Force -Scope Script GroupCache
        Write-Verbose "Cleared the NordVPN group cache."
    }
}


function Clear-TechnologyCache {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType('System.Void')]
    param()
    process {
        Write-Debug "Request to clear the technology cache"
        $script:TechnologyCacheDate = [DateTime]::MinValue
        Clear-Variable -Force -Scope Script TechnologyCache
        Write-Verbose "Cleared the NordVPN technology cache."
    }
}


function Clear-Cache {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType('System.Void')]
    param()
    process {
        Write-Debug "Request to clear all caches"
        Clear-CountryCache
        Clear-GroupCache
        Clear-TechnologyCache
    }
}


<# ##### Internal Functions #####
    Internal utility functions for commonly called code.
#>

function Get-List {
    [CmdletBinding()]
    [OutputType('System.Array')]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [String]
        $URL
    )
    process {
        Write-Debug "NordVPN web API download requested"
        if ($Settings.OfflineMode) {
            Write-Warning "An attempt was made to use the web API but offline mode is enabled."
            return
        }
        $RawList = try {
            Write-Progress -Activity "Processing lists" -CurrentOperation "Downloading server data" -Id 1
            Write-Debug "Attempting HTTPS request to API: $URL"
            $data = Invoke-RestMethod -Uri $URL
            if ($data.Count -lt 1) {
                Write-Debug "Received no data from the API"
                return $true
            }
            $data
            Write-Progress -Activity "Processing lists" -Id 1 -Completed
        }
        catch [System.Net.WebException] {
            Write-Warning ("NordVPN API web exception: {0}`nResponse: {1}`nStatus: {2}" -f `
                    $_.Exception.Message, $_.Exception.Response, $_.Exception.Status)
            return $false
        }
        catch {
            Write-Warning ("An exception occurred accessing the NordVPN API: $($_.Exception.Message)")
            return $false
        }
        $RawList
    }
}


function ConvertFrom-ServerEntry {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Entries
    )
    process {
        Write-Debug "Request to convert server entries"
        Write-Verbose "Processing $($Entries.Count) server entries"
        Write-Progress -Activity "Processing server entries" -CurrentOperation "Getting group definitions" -Id 2
        Write-Debug "Attempting to get group list"
        $GroupList = Get-GroupList
        Write-Progress -Activity "Processing server entries" -CurrentOperation "Getting country definitions" -Id 2
        Write-Debug "Attempting to get countries list"
        $CountryList = Get-CountryList
        [System.Collections.ArrayList]$NewList = @()
        Write-Debug "Calculating number of cycles"
        $k = 0
        $kMax = [Math]::Max($Entries.Count, 1)
        :serverloop foreach ($svr in $Entries) {
            if ($k % 100 -eq 0) {
                Write-Debug "Server entry $k`: ID = $($svr.id)"
            }
            $pcc = [Math]::Floor(($k / $kMax) * 100)
            if ($k % 100 -eq 0) {
                Write-Progress -Activity "Processing server entries" -Id 2 `
                    -PercentComplete $pcc `
                    -CurrentOperation ("Server {0}/{1} ({2}%)" -f $k, $Entries.Count, $pcc)
            }
            [System.Collections.ArrayList]$services = @()
            Write-Information ".. services"
            foreach ($svc in $svr.services) {
                [Void]$services.Add(
                    [PSCustomObject]@{
                        Id           = [UInt64]$svc.id
                        FriendlyName = [String]$svc.name
                        Code         = [String]$svc.identifier
                        Created      = [DateTime]$svc.created_at
                        Updated      = [DateTime]$svc.updated_at
                    }
                )
            }
            [System.Collections.ArrayList]$locations = @()
            Write-Information ".. locations"
            foreach ($loc in $svr.locations) {
                [Void]$locations.Add(
                    [PSCustomObject]@{
                        Id          = [UInt64]$loc.id
                        Latitude    = [Double]$loc.latitude
                        Longitude   = [Double]$loc.longitude
                        CountryCode = [String]$loc.country.code
                        CityCode    = [String]$loc.country.city.dns_name
                        Created     = [DateTime]$loc.created_at
                        Updated     = [DateTime]$loc.updated_at
                    }
                )
            }
            [System.Collections.ArrayList]$technologies = @()
            Write-Information ".. technologies"
            :techloop foreach ($tech in $svr.technologies) {
                [Void]$technologies.Add(
                    [PSCustomObject]@{
                        Id           = [UInt64]$tech.id
                        FriendlyName = [String]$tech.name
                        Code         = [String]$tech.identifier
                        Created      = [DateTime]$tech.created_at
                        Updated      = [DateTime]$tech.updated_at
                        Available    = [Boolean]($tech.pivot.status -eq "online")
                        Status       = [String]$tech.pivot.status
                    }
                )
            }
            [System.Collections.ArrayList]$groups = @()
            Write-Information ".. groups"
            foreach ($grp in $svr.groups) {
                [Void]$groups.Add(
                    [PSCustomObject]@{
                        Id           = [UInt64]$grp.id
                        Code         = [String]($GroupList | Where-Object Id -eq $grp.id).Code
                        FriendlyName = [String]$grp.title
                        Created      = [DateTime]$grp.created_at
                        Updated      = [DateTime]$grp.updated_at
                        Type         = [PSCustomObject]@{
                            Id           = [UInt64]$grp.type.id
                            Created      = [DateTime]$grp.type.created_at
                            Updated      = [DateTime]$grp.type.updated_at
                            FriendlyName = [String]$grp.type.title
                            Code         = [String]$grp.type.identifier
                        }
                    }
                )
            }
            [System.Collections.ArrayList]$specs = @()
            Write-Information ".. specifications"
            foreach ($spec in $svr.specifications) {
                [Void]$specs.Add(
                    [PSCustomObject]@{
                        Id           = [UInt64]$spec.id
                        FriendlyName = [String]$spec.title
                        Code         = [String]$spec.identifier
                        Values       = @(
                            $spec.values | ForEach-Object {
                                [PSCustomObject]@{
                                    Id    = [UInt64]$_.id
                                    Value = $_.value
                                }
                            }
                        )
                    }
                )
            }
            [System.Collections.ArrayList]$ipaddresses = @()
            Write-Information ".. IPs"
            foreach ($ip in $svr.ips) {
                [Void]$ipaddresses.Add(
                    [PSCustomObject]@{
                        Id      = [UInt64]$ip.ip.id
                        Version = [UInt16]$ip.ip.version
                        Address = [String]$ip.ip.ip
                        EntryId = [UInt64]$ip.id
                        Created = [DateTime]$ip.created_at
                        Updated = [DateTime]$ip.updated_at
                    }
                )
            }
            Write-Information ".. Building final structure"
            [Void]$NewList.Add(
                [PSCustomObject]@{
                    Id             = [UInt64]$svr.id
                    Created        = [DateTime]$svr.created_at
                    Updated        = [DateTime]$svr.updated_at
                    Hostname       = [String]$svr.hostname
                    Load           = [UInt16]$svr.Load
                    Status         = [String]$svr.status
                    PrimaryIP      = [String]$svr.station
                    Country        = [PSCustomObject]($CountryList | `
                            Where-Object Id -eq $svr.locations[0].country.id
                    )
                    CountryCode    = [String]$svr.locations[0].country.code
                    City           = [PSCustomObject]($CountryList.Cities | `
                            Where-Object Id -eq $svr.locations[0].country.city.id
                    )
                    CityCode       = [String]$svr.locations[0].country.city.dns_name
                    Longitude      = [Double]$svr.locations[0].longitude
                    Latitude       = [Double]$svr.locations[0].latitude
                    Locations      = [PSCustomObject]$locations
                    Services       = [PSCustomObject]$services
                    Technologies   = [PSCustomObject]$technologies
                    Specifications = [PSCustomObject]$specs
                    IPs            = [PSCustomObject]$ipaddresses
                    Groups         = [PSCustomObject]$groups
                }
            )
            $k++
        }
        $NewList
        Write-Verbose "Finished processing entries"
        Write-Progress -Activity 'Processing server entries' -Id 2 -Completed `
            -CurrentOperation "Finished."
    }
}


<# ##### Accessory Functions #####
    These are used to obtain the lists of groups, countries and technologies needed
    to support the dynamic parameters for Get-NordVPN(Recommended)Servers.
    They have been exposed as they are useful in and of themselves.
#>

function Get-CountryList {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    [OutputType('System.Array')]
    param (
        [Parameter(ParameterSetName = 'DefaultOperation')]
        [Switch]
        $UpdateFallback,

        [Parameter(ParameterSetName = 'Offline')]
        [Switch]
        $Offline
    )
    process {
        Write-Debug "Countries list requested"
        if ($Settings.OfflineMode -or $Offline) {
            $SUCCESS = $false
            return
        }
        Write-Debug ('Country cache lifetime: {0}s. Country cache Age: {1:n0}s' -f `
                $SETTINGS.CountryCacheLifetime, ((Get-Date) - $CountryCacheDate).TotalSeconds
        )
        if (
            !$CountryCacheDate -or `
            ((Get-Date) -gt ($CountryCacheDate.AddSeconds($SETTINGS.CountryCacheLifetime)))
        ) {
            Write-Debug "Requesting country list from the API"
            $CountryList = Get-List $CountryURL
            if ($CountryList -isnot [Array]) {
                if ($CountryList -is [Boolean]) {
                    $SUCCESS = $false
                    return
                }
                else {
                    throw "Invalid data returned by Get-List!"
                }
            }
            Write-Verbose "Downloaded latest Country list"
            [System.Collections.ArrayList]$NewList = @()
            $i = 0
            foreach ($ctry in $CountryList) {
                Write-Progress -Activity "Building list" -CurrentOperation "Filling hashtable" -Id 1 `
                    -PercentComplete (($i / $CountryList.Count) * 100)
                Write-Debug "Processing entry $i`: Country code = $($ctry.code)"
                [Void]$NewList.Add(
                    [PSCustomObject]@{
                        Id           = [UInt64]$ctry.id
                        FriendlyName = [String]$ctry.name
                        Code         = [String]$ctry.code
                        Cities       = @(
                            $ctry.cities | ForEach-Object {
                                [PSCustomObject]@{
                                    Id           = [UInt64]$_.id
                                    FriendlyName = [String]$_.name
                                    Code         = [String]$_.dns_name
                                    Longitude    = [Double]$_.longitude
                                    Latitude     = [Double]$_.latitude
                                    HubScore     = [Int16]$_.hub_score
                                    CountryCode  = [String]$ctry.Code
                                }
                            }
                        )
                    }
                )
                $i++
            }
            Write-Progress -Activity "Building list" -Id 1 -Completed
            Set-Variable -Scope Script -Force CountryCache $NewList
            Set-Variable -Scope Script -Force CountryCacheDate (Get-Date)
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $NewList.ToArray() | Export-Clixml -Path $CountryFallback -Encoding UTF8 -Force
                Write-Verbose "Exported downloaded country list to fallback: $CountryFallback"
            }
            $NewList.ToArray()
        }
        elseif ($CountryCache -is [System.Collections.ArrayList]) {
            Write-Verbose "Used Country cache"
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $CountryCache.ToArray() | Export-Clixml -Path $CountryFallback -Encoding UTF8 -Force
                Write-Verbose "Exported country cache to fallback: $CountryFallback"
            }
            $CountryCache.ToArray()
        }
    }
    end {
        if (!$SUCCESS) {
            if (!($Settings.OfflineMode -or $Offline)) {
                Write-Verbose "Used Country fallback file '$CountryFallback'"
            }
            Import-Clixml -Path $CountryFallback
        }
    }
}


function Get-GroupList {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    [OutputType('System.Array')]
    param (
        [Parameter(ParameterSetName = 'DefaultOperation')]
        [Switch]
        $UpdateFallback,

        [Parameter(ParameterSetName = 'Offline')]
        [Switch]
        $Offline
    )
    process {
        Write-Debug "Groups list requested"
        if ($Settings.OfflineMode -or $Offline) {
            $SUCCESS = $false
            return
        }
        Write-Debug ('Group cache lifetime: {0}s. Group cache Age: {1:n0}s' -f
            $SETTINGS.GroupCacheLifetime,
            ((Get-Date) - $GroupCacheDate).TotalSeconds
        )
        if (
            !$GroupCacheDate -or `
            ((Get-Date) -gt ($GroupCacheDate.AddSeconds($SETTINGS.GroupCacheLifetime)))
        ) {
            $GroupList = Get-List $GroupURL
            if ($GroupList -isnot [Array]) {
                if ($GroupList -is [Boolean]) {
                    $SUCCESS = $false
                    return
                }
                else {
                    throw "Invalid data returned by Get-List!"
                }
            }
            Write-Verbose "Downloaded latest group list"
            [System.Collections.ArrayList]$NewList = @()
            $i = 0
            foreach ($grp in $GroupList) {
                Write-Progress -Activity "Building list" -CurrentOperation "Filling hashtable" -Id 1 `
                    -PercentComplete (($i / $GroupList.Count) * 100)
                Write-Debug "Processing entry $i`: Group code = $($grp.identifier)"
                [Void]$NewList.Add(
                    [PSCustomObject]@{
                        Id           = [UInt64]$grp.id
                        FriendlyName = [String]$grp.title
                        Code         = [String]$grp.identifier
                        Type         = [PSCustomObject]@{
                            Id           = [UInt64]$grp.type.id
                            FriendlyName = [String]$grp.type.title
                            Code         = [String]$grp.type.identifier
                            Created      = [DateTime]$grp.type.created_at
                            Updated      = [DateTime]$grp.type.updated_at
                        }
                        Created      = [DateTime]$grp.created_at
                        Updated      = [DateTime]$grp.updated_at
                    }
                )
                $i++
            }
            Write-Progress -Activity "Building list" -Id 1 -Completed
            Set-Variable -Scope Script -Force GroupCache $NewList
            Set-Variable -Scope Script -Force GroupCacheDate (Get-Date)
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $NewList.ToArray() | Export-Clixml -Path $GroupFallback -Encoding UTF8 -Force
                Write-Verbose "Exported downloaded group list to fallback: $GroupFallback"
            }
            $NewList.ToArray()
        }
        elseif ($GroupCache -is [System.Collections.ArrayList]) {
            Write-Verbose "Used Group cache"
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $GroupCache.ToArray() | Export-Clixml -Path $GroupFallback -Encoding UTF8 -Force
                Write-Verbose "Exported group cache to fallback: $GroupFallback"
            }
            $GroupCache.ToArray()
        }
    }
    end {
        if (!$SUCCESS) {
            if (!($Settings.OfflineMode -or $Offline)) {
                Write-Verbose "Used group fallback file '$GroupFallback'"
            }
            Import-Clixml -Path $GroupFallback
        }
    }
}


function Get-TechnologyList {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    [OutputType('System.Array')]
    param (
        [Parameter(ParameterSetName = 'DefaultOperation')]
        [Switch]
        $UpdateFallback,

        [Parameter(ParameterSetName = 'Offline')]
        [Switch]
        $Offline
    )
    process {
        Write-Debug "Technologies list requested"
        if ($Settings.OfflineMode -or $Offline) {
            $SUCCESS = $false
            return
        }
        Write-Debug ('Technology cache lifetime: {0}s. Technology cache Age: {1:n0}s' -f
            $SETTINGS.TechnologyCacheLifetime,
            ((Get-Date) - $TechnologyCacheDate).TotalSeconds
        )
        if (
            !$TechnologyCacheDate -or `
            ((Get-Date) -gt ($TechnologyCacheDate.AddSeconds($SETTINGS.TechnologyCacheLifetime)))
        ) {
            $TechnologyList = Get-List $TechnologyURL
            if ($TechnologyList -isnot [Array]) {
                if ($TechnologyList -is [Boolean]) {
                    $SUCCESS = $false
                    return
                }
                else {
                    throw "Invalid data returned by Get-List!"
                }
            }
            Write-Verbose "Downloaded latest Technology list"
            [System.Collections.ArrayList]$NewList = @()
            $i = 0
            foreach ($tech in $TechnologyList) {
                Write-Progress -Activity "Building list" -CurrentOperation "Filling hashtable" -Id 1 `
                    -PercentComplete (($i / $TechnologyList.Count) * 100)
                Write-Debug "Processing entry $i`: Technology code = $($tech.identifier)"
                [Void]$NewList.Add(
                    [PSCustomObject]@{
                        Id           = [UInt64]$tech.id
                        FriendlyName = [String]$tech.name
                        Code         = [String]$tech.identifier
                        Created      = [DateTime]$tech.created_at
                        Updated      = [DateTime]$tech.updated_at
                    }
                )
                $i++
            }
            Write-Progress -Activity "Building list" -Id 1 -Completed
            Set-Variable -Scope Script -Force TechnologyCache $NewList
            Set-Variable -Scope Script -Force TechnologyCacheDate (Get-Date)
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $NewList.ToArray() | Export-Clixml -Path $TechnologyFallback -Encoding UTF8 -Force
                Write-Verbose "Exported downloaded technology list to fallback: $TechnologyFallback"
            }
            $NewList.ToArray()
        }
        elseif ($TechnologyCache -is [System.Collections.ArrayList]) {
            Write-Verbose "Used Technology cache"
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $TechnologyCache.ToArray() | Export-Clixml -Path $TechnologyFallback -Encoding UTF8 -Force
                Write-Verbose "Exported technology cache to fallback: $TechnologyFallback"
            }
            $TechnologyCache.ToArray()
        }
    }
    end {
        if (!$SUCCESS) {
            if (!($Settings.OfflineMode -or $Offline)) {
                Write-Verbose "Used technology fallback file '$TechnologyFallback'"
            }
            Import-Clixml -Path $TechnologyFallback
        }
    }
}


function Get-CityList {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    [OutputType('System.Array')]
    param (
        [Parameter(ParameterSetName = 'Offline')]
        [Switch]
        $Offline
    )
    dynamicparam {
        $ParamDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParamDict.Add('Country', (Get-CountryDynamicParam 0 @('DefaultOperation', 'Offline') -Offline:$Offline))

        $ParamDict
    }
    process {
        Write-Debug "Cities list requested"
        if ($Offline) {
            $Countries = Get-CountryList -Offline
        }
        else {
            $Countries = Get-CountryList
        }
        if ($PSBoundParameters.Country) {
            $Countries = $Countries | Where-Object { $PSBoundParameters.Country -eq $_.Code }
        }
        [System.Collections.ArrayList]$OutList = @()
        foreach ($ctry in $Countries) {
            foreach ($city in $ctry.Cities) {
                Write-Debug "Processing entry: City code = $($city.Code)"
                [Void]$OutList.Add($city)
            }
        }

        $OutList
    }
}


<# ##### Convenience Functions #####
    These produce pretty output for quick visual reference, as opposed to raw data
    for integration into other processes.
#>

function Show-CountryList {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    param (
        [Parameter(ParameterSetName = 'Offline')]
        [Switch]
        $Offline
    )
    begin {
        $OldFG = $Host.UI.RawUI.ForegroundColor
        $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Cyan
        Write-Output "`n`nServer Countries:"
    }
    process {
        $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::White
        if ($Offline) {
            $CountryList = Get-CountryList -Offline
        }
        else {
            $CountryList = Get-CountryList
        }
        $CountryList | Sort-Object -Property Id | `
            Select-Object Id, FriendlyName, Code, Cities | Format-Table -AutoSize `
            Id, FriendlyName, Code, @{Label = "Cities"; Expression = { $_.Cities.FriendlyName -join '/' } }
    }
    end {
        $Host.UI.RawUI.ForegroundColor = $OldFG
    }
}


function Show-GroupList {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    param (
        [Parameter(ParameterSetName = 'Offline')]
        [Switch]
        $Offline
    )
    begin {
        $OldFG = $Host.UI.RawUI.ForegroundColor
        $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Cyan
        Write-Output "`n`nServer Groups:"
    }
    process {
        $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::White
        if ($Offline) {
            $GroupList = Get-GroupList -Offline
        }
        else {
            $GroupList = Get-GroupList
        }
        $GroupList | Sort-Object -Property Id | `
            Select-Object Id, FriendlyName, Code, Type, Created, Updated | Format-Table -AutoSize `
            Id, FriendlyName, Code, @{Label = "Type"; Expression = { $_.Type.FriendlyName } }, Created, Updated
    }
    end {
        $Host.UI.RawUI.ForegroundColor = $OldFG
    }
}


function Show-TechnologyList {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    param (
        [Parameter(ParameterSetName = 'Offline')]
        [Switch]
        $Offline
    )
    begin {
        $OldFG = $Host.UI.RawUI.ForegroundColor
        $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Cyan
        Write-Output "`n`nServer Technologies:"
    }
    process {
        $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::White
        if ($Offline) {
            $TechnologyList = Get-TechnologyList -Offline
        }
        else {
            $TechnologyList = Get-TechnologyList
        }
        $TechnologyList | Sort-Object -Property Id | `
            Select-Object Id, FriendlyName, Code, Created, Updated | Format-Table -AutoSize
    }
    end {
        $Host.UI.RawUI.ForegroundColor = $OldFG
    }
}


function Show-CityList {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    param (
        [Parameter(ParameterSetName = 'Offline')]
        [Switch]
        $Offline
    )
    dynamicparam {
        $ParamDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParamDict.Add('Country', (Get-CountryDynamicParam 0 @('DefaultOperation', 'Offline') -Offline:$Offline))

        $ParamDict
    }
    begin {
        $OldFG = $Host.UI.RawUI.ForegroundColor
        $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Cyan
        Write-Output "`n`nServer Cities:"
    }
    process {
        if ($Offline) {
            if ($PSBoundParameters.Country) {
                $CityList = Get-CityList -Country:$PSBoundParameters.Country -Offline
            }
            else {
                $CityList = Get-CityList -Offline
            }
            $Countries = Get-CountryList -Offline
        }
        else {
            if ($PSBoundParameters.Country) {
                $CityList = Get-CityList -Country:$PSBoundParameters.Country
            }
            else {
                $CityList = Get-CityList
            }
            $Countries = Get-CountryList
        }
        $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::White
        $CityList | Sort-Object -Property CountryCode, FriendlyName | `
            Select-Object -Property Id,
        @{Label = 'Country'; Expression = {
                $ctry = $_.CountryCode; ($Countries | Where-Object { $_.Code -eq $ctry }).FriendlyName }
        },
        FriendlyName, Code, Latitude, Longitude, HubScore | Format-Table -AutoSize
    }
    end {
        $Host.UI.RawUI.ForegroundColor = $OldFG
    }
}


<# ##### Primary Functions #####
    These are the main functions for retrieving server lists from the NordVPN API.
    -Get-NordVPNRecommendedList allows direct filtering and is ordered by recommendation.
    -Get-NordVPNServerList uses the raw API and only allows limiting results. This is useful
    for statistical collection of server details. In order to use the filters effectively,
    you should not limit the number of entries unlike with the Get..Recommended.. function.
#>

function Get-RecommendedList {
    [CmdletBinding(DefaultParameterSetName = "DefaultOperation")]
    [OutputType('System.Array')]
    param (
        [Parameter(
            Position = 0,
            HelpMessage = 'Please enter the maximum number of servers to return (1-65535, default: 5)',
            ParameterSetName = "DefaultOperation"
        )]
        [ValidateRange(1, 65535)]
        [UInt16]
        $Limit = 5,

        [Parameter(ParameterSetName = 'DefaultOperation')]
        [Switch]
        $Raw
    )
    dynamicparam {
        $ParamDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParamDict.Add('Country', (Get-CountryDynamicParam 0 @('DefaultOperation') -Offline:$Offline))
        $ParamDict.Add('Group', (Get-GroupDynamicParam 1 @('DefaultOperation') -Offline:$Offline))
        $ParamDict.Add('Technology', (Get-TechnologyDynamicParam 2 @('DefaultOperation') -Offline:$Offline))

        $ParamDict
    }
    begin {
        Write-Debug "Recommended servers list requested"
        if ($Settings.OfflineMode) {
            $FallbackErr = @{
                Message           = 'Cannot use recommendations API when offline mode is enabled!'
                Category          = [System.Management.Automation.ErrorCategory]::InvalidOperation
                RecommendedAction = 'Disable offline mode with Set-NordVPNModuleSetting OfflineMode 0'
                CategoryActivity  = 'Retrieve server list'
                CategoryReason    = 'Offline mode enabled'
            }
            Write-Error @FallbackErr
            throw $FallbackErr.Message
        }
    }
    process {
        $CountryId = $null
        if ($null -ne $PSBoundParameters.Country) {
            $CountryId = (
                (Get-CountryList) | Where-Object {
                    $PSBoundParameters.Country -eq $_.Code
                }
            ).Id
        }
        $URL = $API_URL_BASE -f $Limit
        foreach ($cid in $CountryId) {
            $URL += ('&filters[country_id]={0}' -f $cid)
        }
        foreach ($tech in $PSBoundParameters.Technology) {
            $URL += ('&filters[servers_technologies][identifier]={0}' -f $tech)
        }
        foreach ($grp in $PSBoundParameters.Group) {
            $URL += ('&filters[servers_groups][identifier]={0}' -f $grp)
        }
        $ServerList = Get-List -URL $URL
        if ($PSCmdlet.ParameterSetName -eq 'RawData' -and $Raw) {
            return $ServerList
        }
        if ($null -eq $ServerList) {
            Write-Error @FailedList
            throw $FailedList.Message
        }
        if (($ServerList -is [Boolean] -and $true -eq $ServerList) -or ($ServerList.Count -eq 0)) {
            Write-Warning ("No results found for search with filters:" +
                $(if ($PSBoundParameters.Country) { "`n  Country: {0}" -f $PSBoundParameters.Country }) +
                $(if ($PSBoundParameters.Group) { "`n  Group: {0}" -f $PSBoundParameters.Group }) +
                $(if ($PSBoundParameters.Technology) { "`n  Technology: {0}" -f $PSBoundParameters.Technology }) +
                "`nTry adjusting the filters."
            )
        }
        else {
            Write-Verbose "Finished downloading server list. Count: $($ServerList.Count)"
            ConvertFrom-ServerEntry $ServerList
        }
    }
}

function Get-ServerList {
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = "DefaultOperation")]
    [OutputType('System.Array')]
    param (
        [Parameter(
            Position = 0,
            HelpMessage = { $GetServersLimitParamHelp },
            ParameterSetName = "DefaultOperation"
        )]
        [Parameter(
            Position = 0,
            HelpMessage = { $GetServersLimitParamHelp },
            ParameterSetName = "RawData"
        )]
        [ValidateRange(1, 65535)]
        [UInt16]
        $First = 8192,

        [Parameter(ParameterSetName = 'DefaultOperation')]
        [Switch]
        $UpdateFallback,

        [Parameter(ParameterSetName = 'Offline')]
        [Switch]
        $Offline,

        [Parameter(ParameterSetName = 'RawData')]
        [Switch]
        $Raw
    )
    dynamicparam {
        $ParamDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $allowedParamSets = @('DefaultOperation', 'Offline')
        $ParamDict.Add('Country', (Get-CountryDynamicParam 0 $allowedParamSets $Offline))
        $ParamDict.Add('Group', (Get-GroupDynamicParam 1 $allowedParamSets $Offline))
        $ParamDict.Add('Technology', (Get-TechnologyDynamicParam 2 $allowedParamSets $Offline))

        $ParamDict
    }
    begin {
        if (($Settings.OfflineMode -or $Offline -or $UpdateFallback) -and $Raw) {
            throw ("You cannot use the -Raw switch in offline mode, or" +
                " with -UpdateFallback.")
        }
        $ServersCompressed = $ServerFallback, '.zip' -join ''
        if ($Settings.OfflineMode -or $Offline) {
            if (!(Test-Path $ServerFallback -PathType Leaf)) {
                if (Test-Path $ServersCompressed -PathType Leaf) {
                    Write-Verbose "Importing server list"
                    Write-Progress -Activity "Setting up" -Id 3 -CurrentOperation `
                        'Expanding offline servers list: NordVPN_Servers.xml.zip => NordVPN_Servers.xml'
                    $ServersCompressed | Expand-Archive -DestinationPath $PSScriptRoot -Force
                }
                else {
                    throw ("$ServersCompressed or $ServerFallback file not found!" +
                        ' Cannot create fallback file.')
                }
            }
            Write-Progress -Activity "Importing server list" -Id 3 -CurrentOperation "Parsing $ServerFallback"
            $AllServersList = Import-Clixml -Path $ServerFallback
            if ($AllServersList.Count -lt 1) {
                throw "Unable to import server fallback list from $ServerFallback!"
            }
            Write-Progress -Activity "Importing server list" -Id 3 -Completed
        }
        else {
            $RawList = (Get-List -URL ($API_ALL_URL -f $First))
            if ($PSCmdlet.ParameterSetName -eq 'RawData' -and $Raw) {
                return $RawList
            }
            $AllServersList = ConvertFrom-ServerEntry $RawList
            if ($UpdateFallback) {
                Write-Progress -Activity "Exporting server list" -Id 3 -CurrentOperation `
                    'Writing XML => NordVPN_Servers.xml'
                $AllServersList | Export-Clixml -Path $ServerFallback -Encoding UTF8 -Force
                Write-Progress -Activity "Exporting server list" -Id 3 -CurrentOperation `
                    'Compressing offline servers list: NordVPN_Servers.xml => NordVPN_Servers.xml.zip'
                Compress-Archive -Path $ServerFallback -DestinationPath $ServersCompressed -Force `
                    -CompressionLevel Optimal
                Write-Verbose "Exported downloaded server list to fallback: $ServerFallback"
                Write-Progress -Activity "Importing server list" -Id 3 -Completed
            }
        }
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'RawData' -and $Raw) { return }
        if ($null -eq $AllServersList) {
            Write-Error @FailedList
            throw $FailedList.Message
        }
        if ($AllServersList -is [Boolean] -and $true -eq $AllServersList) {
            Write-Warning "No values returned from {0}!" -f `
            $(if ($Settings.OfflineMode) { 'the fallback file' } else { 'the API' })
            return
        }
        if ($AllServersList.Count -gt 1) {
            $ServerList = $AllServersList.Clone()
        }
        else {
            $ServerList = @($AllServersList).Clone()
        }
        if ($null -ne $PSBoundParameters.Country) {
            Write-Verbose "Filtering by country: $($PSBoundParameters.Country)"
            $ServerList = $ServerList | Where-Object CountryCode -eq $PSBoundParameters.Country
        }
        if ($null -ne $PSBoundParameters.Group) {
            Write-Verbose "Filtering by group: $($PSBoundParameters.Group)"
            $ServerList = $ServerList | Where-Object {
                $_.Groups.Code -contains $PSBoundParameters.Group
            }
        }
        if ($null -ne $PSBoundParameters.Technology) {
            Write-Verbose "Filtering by technology: $($PSBoundParameters.Technology)"
            $ServerList = $ServerList | Where-Object {
                $_.Technologies.Code -contains $PSBoundParameters.Technology
            }
        }
        if ($ServerList.Count -gt 0) {
            $ServerList
        }
        else {
            Write-Warning ('No servers in the first {0} results matched the filters! Filters:' `
                    -f [Math]::min($First, $RawList.Count) +
                $(if ($PSBoundParameters.Country) { "`n  Country: {0}" -f $PSBoundParameters.Country }) +
                $(if ($PSBoundParameters.Group) { "`n  Group: {0}" -f $PSBoundParameters.Group }) +
                $(if ($PSBoundParameters.Technology) { "`n  Technology: {0}" -f $PSBoundParameters.Technology }) +
                "`nTry increasing the value of the -First parameter or adjusting the filters."
            )
            @()
        }
    }
    end {
        if ($SETTINGS.DeleteServerFallbackAfterUse -and (Test-Path $ServerFallback -PathType Leaf)) {
            Remove-Item $ServerFallback -Force
        }
    }
}
