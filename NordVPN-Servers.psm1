#Requires -Module @{ ModuleName = 'Microsoft.PowerShell.Archive'; ModuleVersion = '1.0' }

New-Variable -Option Constant -Scope Script TechnologyURL 'https://api.nordvpn.com/v1/technologies'
New-Variable -Option Constant -Scope Script GroupURL 'https://api.nordvpn.com/v1/servers/groups'
New-Variable -Option Constant -Scope Script CountryURL 'https://api.nordvpn.com/v1/servers/countries'
New-Variable -Option Constant -Scope Script ServerURL 'https://api.nordvpn.com/v1/servers?limit={0}'
New-Variable -Option Constant -Scope Script RecommendedURL `
    'https://api.nordvpn.com/v1/servers/recommendations?limit={0}'
New-Variable -Option Constant -Scope Script SettingsFile (Join-Path $PSScriptRoot 'NordVPN-Servers.settings.json')
New-Variable -Option Constant -Scope Script TechnologyFallback (Join-Path $PSScriptRoot 'NordVPN_Technologies.xml')
New-Variable -Option Constant -Scope Script GroupFallback (Join-Path $PSScriptRoot 'NordVPN_Groups.xml')
New-Variable -Option Constant -Scope Script CountryFallback (Join-Path $PSScriptRoot 'NordVPN_Countries.xml')
New-Variable -Option Constant -Scope Script ServerFallback (Join-Path $PSScriptRoot 'NordVPN_Servers.xml')
New-Variable -Option Constant -Scope Script ServersCompressed ($ServerFallback, '.zip' -join '')
New-Variable -Option Constant -Scope Script FailedList 'Unable to retrieve server list from NordVPN API'
New-Variable -Option Constant -Scope Script FailedConv 'Unable to process server list!'
New-Variable -Option Constant -Scope Script DefaultSettings @{
    CountryCacheLifetime         = @([UInt32], 600)
    GroupCacheLifetime           = @([UInt32], 600)
    TechnologyCacheLifetime      = @([UInt32], 600)
    OfflineMode                  = @([Boolean], $false)
    DeleteServerFallbackAfterUse = @([Boolean], $false)
}
New-Variable -Option Constant -Scope Script KnownCountries @(
    'AL', 'AR', 'AU', 'AT', 'BE', 'BA', 'BR', 'BG', 'CA', 'CL', 'CR', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI',
    'FR', 'GE', 'DE', 'GR', 'HK', 'HU', 'IS', 'IN', 'ID', 'IE', 'IL', 'IT', 'JP', 'LV', 'LU', 'MY', 'MX',
    'MD', 'NL', 'NZ', 'MK', 'NO', 'PL', 'PT', 'RO', 'RS', 'SG', 'SK', 'SI', 'ZA', 'KR', 'ES', 'SE', 'CH',
    'TW', 'TH', 'TR', 'UA', 'AE', 'GB', 'US', 'VN'
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
    Write-Debug "Loading in settings from '$SettingsFile'"
    $SettingsIn = Get-Content $SettingsFile -ErrorAction SilentlyContinue | ConvertFrom-Json
    $script:SETTINGS = @{ }
    if ($null -eq $SettingsIn) {
        Write-Verbose "No settings file or invalid, resetting..."
        foreach ($key in $DefaultSettings.Keys) {
            $SETTINGS.$key = $DefaultSettings.$key[1]
        }
        $SETTINGS | ConvertTo-Json | Set-Content $SettingsFile -Force
        Write-Debug "Wrote default settings to '$SettingsFile'"
    }
    else {
        foreach ($entry in $SettingsIn.PSObject.Properties) {
            if ($DefaultSettings.ContainsKey($entry.Name)) {
                $SETTINGS[$entry.Name] = $entry.Value -as $DefaultSettings[$entry.Name][0]
            }
            else {
                Write-Verbose "Invalid setting $($entry.Name) not loaded"
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
        Write-Debug "Set-NordVPNModuleSetting: Param set = $($PSCmdlet.ParameterSetName)"
        $Name = $PSBoundParameters.Name
        if ($PSCmdlet.ParameterSetName -eq 'SetDefault') {
            Write-Debug "Request to set $Name to default value"
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
        Write-Debug "Request to set $Name to $Value"
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
            Write-Debug "Attempting to write $SettingsFile"
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
        Write-Debug "Request to reset all module settings"
        if ($Force -or $PSCmdlet.ShouldContinue(
                "This will reset all NordVPN-Servers module settings to default and clear the cache." +
                " Are you sure?",
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
            Write-Debug "Attempting to write $SettingsFile"
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
        Write-Debug 'Dynamic setting name parameter requested.'
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
        'e.g GB (run Get-NordVPNCountryList for reference)'
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
        '(run Get-NordVPNGroupList for reference)'
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
        '(run Get-NordVPNTechnologyList for reference)'
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
        if ($SETTINGS.OfflineMode) {
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
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]
        $Servers
    )
    begin {
        Clear-Variable GroupList, CountryList, NewList -ErrorAction SilentlyContinue
        $Count = $Servers.Count
        Write-Debug "Request to convert server entries"
        Write-Verbose "Processing $($Count) server entries"
        Write-Progress -Activity "Processing server entries" -CurrentOperation "Getting group definitions" -Id 2
        Write-Debug "Attempting to get group list"
        $GroupList = Get-GroupList
        Write-Progress -Activity "Processing server entries" -CurrentOperation "Getting country definitions" -Id 2
        Write-Debug "Attempting to get countries list"
        $CountryList = Get-CountryList
        $k = 0
        $kMax = [Math]::Max($Count, 1)
        $kInterval = [Math]::Max([Math]::Floor(($Count / 100)), 10)
        Write-Debug "Will update progress every $kInterval servers"
        $ServersList = [NordVPNServerList]::new()
    }
    process {
        foreach ($Server in $Servers) {

            if ($k % $kInterval -eq 0) {
                Write-Debug "Server entry $k`: ID = $($Server.id)"
                $pcc = [Math]::Floor(($k / $kMax) * 100)
                Write-Progress -Activity "Processing server entries" -Id 2 `
                    -PercentComplete $pcc `
                    -CurrentOperation ("Server {0}/{1} ({2}%)" -f $k, $Count, $pcc)
            }

            $services = [NordVPNServiceList]::new()
            foreach ($svc in $Server.services) {
                $services.Add(
                    [NordVPNService]::new(
                        $svc.id,
                        $svc.name,
                        $svc.identifier,
                        $svc.created_at,
                        $svc.updated_at
                    )
                )
            }

            $locations = [NordVPNLocationList]::new()
            foreach ($loc in $Server.locations) {
                $locations.Add(
                    [NordVPNLocation]::new(
                        $loc.id,
                        $loc.created_at,
                        $loc.updated_at,
                        $loc.country.code,
                        $loc.country.city.dns_name,
                        $loc.latitude,
                        $loc.longitude
                    )
                )
            }

            $technologies = [NordVPNTechnologyList]::new()
            foreach ($tech in $Server.technologies) {
                $technologies.Add(
                    [NordVPNTechnology]::new(
                        $tech.id,
                        $tech.name,
                        $tech.identifier,
                        $tech.created_at,
                        $tech.updated_at,
                        $tech.pivot.status
                    )
                )
            }

            $groups = [NordVPNGroupList]::new()
            foreach ($grp in $Server.groups) {
                $grpCode = ($GroupList | Where-Object Id -eq $grp.id).Code
                $groups.Add(
                    [NordVPNGroup]::new(
                        $grp.id,
                        $grp.title,
                        $grpCode,
                        $grp.created_at,
                        $grp.updated_at,
                        $grp.type.id,
                        $grp.type.title,
                        $grp.type.identifier,
                        $grp.type.created_at,
                        $grp.type.updated_at
                    )
                )
            }

            $specs = [NordVPNSpecificationList]::new()
            foreach ($spec in $Server.specifications) {
                $specs.Add(
                    [NordVPNSpecification]::new(
                        $spec.id,
                        $spec.title,
                        $spec.identifier,
                        $spec.values
                    )
                )
            }

            $ipaddresses = [NordVPNIPAddressList]::new()
            foreach ($ip in $Server.ips) {
                $ipaddresses.Add(
                    [NordVPNIPAddress]::new(
                        $ip.ip.id,
                        $ip.created_at,
                        $ip.updated_at,
                        $ip.ip.version,
                        $ip.ip.ip,
                        $ip.id
                    )
                )
            }

            $curCountry = $CountryList | Where-Object Id -eq $Server.locations[0].country.id
            $svrCountry = [NordVPNCountry]::new(
                $curCountry.Id, $curCountry.FriendlyName, $curCountry.Code
            )
            $curCity = $curCountry.Cities | Where-Object Id -eq `
                $Server.locations[0].country.city.id
            $svrCity = [NordVPNCity]::new(
                $curCity.Id, $curCity.FriendlyName, $curCity.Code,
                $curCity.Latitude, $curCity.Longitude, $curCity.HubScore,
                $curCountry.Code
            )

            $k++

            $ServersList.Add(
                [NordVPNServer]::new(
                    $Server.id,
                    $Server.name,
                    $Server.created_at,
                    $Server.updated_at,
                    $Server.station,
                    $Server.hostname,
                    $Server.Load,
                    $Server.status,
                    $svrCountry,
                    $svrCity,
                    $Server.locations[0].longitude,
                    $Server.locations[0].latitude,
                    $locations,
                    $services,
                    $technologies,
                    $specs,
                    $ipaddresses,
                    $groups
                )
            )

        }
        ,$ServersList
    }
    end {
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
        if ($SETTINGS.OfflineMode -or $Offline) {
            Write-Debug "Get-NordVPNCountryList in Offline mode"
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
            $NewList = [NordVPNCountryList]::new()
            $i = 0
            foreach ($ctry in $CountryList) {
                Write-Progress -Activity "Building list" -CurrentOperation "Filling country list" -Id 1 `
                    -PercentComplete (($i / $CountryList.Count) * 100)
                Write-Debug "Processing entry $i`: Country code = $($ctry.code)"
                $NewList.Add(
                    [NordVPNCountry]::new(
                        $ctry.id, $ctry.name, $ctry.code, $ctry.cities
                    )
                )
                $i++
            }
            Write-Progress -Activity "Building list" -Id 1 -Completed
            Set-Variable -Scope Script -Force CountryCache $NewList
            Set-Variable -Scope Script -Force CountryCacheDate (Get-Date)
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $NewList | Export-Clixml -Path $CountryFallback -Encoding UTF8 -Force
                Write-Verbose "Exported downloaded country list to fallback: $CountryFallback"
            }
            , $NewList
        }
        elseif ($CountryCache -is [NordVPNCountryList]) {
            Write-Verbose "Used Country cache"
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $CountryCache | Export-Clixml -Path $CountryFallback -Encoding UTF8 -Force
                Write-Verbose "Exported country cache to fallback: $CountryFallback"
            }
            , $CountryCache.Clone()
        }
    }
    end {
        if (!$SUCCESS) {
            if (!($SETTINGS.OfflineMode -or $Offline)) {
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
        if ($SETTINGS.OfflineMode -or $Offline) {
            Write-Debug "Get-NordVPNGroupList in Offline mode"
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
            $NewList = [NordVPNGroupList]::new()
            $i = 0
            foreach ($grp in $GroupList) {
                Write-Progress -Activity "Building list" -CurrentOperation "Filling group list" -Id 1 `
                    -PercentComplete (($i / $GroupList.Count) * 100)
                Write-Debug "Processing entry $i`: Group code = $($grp.identifier)"
                $NewList.Add(
                    [NordVPNGroup]::new(
                        $grp.id, $grp.title, $grp.identifier, $grp.created_at, $grp.updated_at,
                        $grp.type.id, $grp.type.title, $grp.type.identifier, $grp.type.created_at,
                        $grp.type.updated_at
                    )
                )
                $i++
            }
            Write-Progress -Activity "Building list" -Id 1 -Completed
            Set-Variable -Scope Script -Force GroupCache $NewList
            Set-Variable -Scope Script -Force GroupCacheDate (Get-Date)
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $NewList | Export-Clixml -Path $GroupFallback -Encoding UTF8 -Force
                Write-Verbose "Exported downloaded group list to fallback: $GroupFallback"
            }
            , $NewList
        }
        elseif ($GroupCache -is [NordVPNGroupList]) {
            Write-Verbose "Used Group cache"
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $GroupCache | Export-Clixml -Path $GroupFallback -Encoding UTF8 -Force
                Write-Verbose "Exported group cache to fallback: $GroupFallback"
            }
            , $GroupCache.Clone()
        }
    }
    end {
        if (!$SUCCESS) {
            if (!($SETTINGS.OfflineMode -or $Offline)) {
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
        if ($SETTINGS.OfflineMode -or $Offline) {
            Write-Debug "Get-NordVPNTechnologyList in Offline mode"
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
            $NewList = [NordVPNTechnologyList]::new()
            $i = 0
            foreach ($tech in $TechnologyList) {
                Write-Progress -Activity "Building list" -CurrentOperation "Filling technology list" -Id 1 `
                    -PercentComplete (($i / $TechnologyList.Count) * 100)
                Write-Debug "Processing entry $i`: Technology code = $($tech.identifier)"
                $NewList.Add(
                    [NordVPNTechnology]::new(
                        $tech.id, $tech.name, $tech.identifier, $tech.created_at, $tech.updated_at
                    )
                )
                $i++
            }
            Write-Progress -Activity "Building list" -Id 1 -Completed
            Set-Variable -Scope Script -Force TechnologyCache $NewList
            Set-Variable -Scope Script -Force TechnologyCacheDate (Get-Date)
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $NewList | Export-Clixml -Path $TechnologyFallback -Encoding UTF8 -Force
                Write-Verbose "Exported downloaded technology list to fallback: $TechnologyFallback"
            }
            , $NewList
        }
        elseif ($TechnologyCache -is [NordVPNTechnologyList]) {
            Write-Verbose "Used Technology cache"
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $TechnologyCache | Export-Clixml -Path $TechnologyFallback -Encoding UTF8 -Force
                Write-Verbose "Exported technology cache to fallback: $TechnologyFallback"
            }
            , $TechnologyCache.Clone()
        }
    }
    end {
        if (!$SUCCESS) {
            if (!($SETTINGS.OfflineMode -or $Offline)) {
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
            $CityList = [System.Collections.ArrayList]::new()
        }
        else {
            $Countries = Get-CountryList
            $CityList = [NordVPNCityList]::new()
        }
        if ($PSBoundParameters.Country) {
            $Countries = $Countries | Where-Object { $PSBoundParameters.Country -eq $_.Code }
        }

        foreach ($ctry in $Countries) {
            foreach ($city in $ctry.Cities) {
                Write-Debug "Processing entry: City code = $($city.Code)"
                [void]$CityList.Add($city)
            }
        }
        , $CityList
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
        if ($SETTINGS.OfflineMode) {
            throw 'Cannot use recommendations API when offline mode is enabled!'
        }
        $ServerList = $null
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
        $URL = $RecommendedURL -f $Limit
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
        if ($null -eq $ServerList) { throw $FailedList }
        if ($Raw) {
            return , $ServerList
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
            , (ConvertFrom-ServerEntry $ServerList)
        }
    }
}

function Get-ServerList {
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = "DefaultOperation")]
    [OutputType('System.Array')]
    param (
        [Parameter(
            Position = 0,
            ParameterSetName = "DefaultOperation"
        )]
        [Parameter(
            Position = 0,
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
    begin {
        if (($SETTINGS.OfflineMode -or $UpdateFallback) -and $Raw) {
            throw ("You cannot use the -Raw switch in offline mode, or" +
                " with -UpdateFallback.")
        }
        if ($SETTINGS.OfflineMode -and $UpdateFallback) {
            throw ("You cannot use the -UpdateFallback switch in offline mode")
        }

        $AllServersList = $null
        if ($SETTINGS.OfflineMode -or $Offline) {
            if (!(Test-Path $ServerFallback -PathType Leaf)) {
                if (Test-Path $ServersCompressed -PathType Leaf) {
                    Write-Verbose "Importing server list"
                    Write-Progress -Activity "Setting up" -Id 3 -CurrentOperation `
                        'Expanding offline servers list: NordVPN_Servers.xml.zip => NordVPN_Servers.xml'
                    $ServersCompressed | Expand-Archive -DestinationPath $PSScriptRoot -Force
                    if (!(Test-Path $ServerFallback -PathType Leaf)) {
                        throw "Unable to expand server fallback archive '$ServersCompressed'"
                    }
                }
                else {
                    throw ("Server fallback archive '$ServersCompressed' not found!" +
                        ' Cannot create fallback file.')
                }
            }
            else {
                Write-Verbose "Located server fallback '$ServerFallback'"
            }
        }
    }
    process {
        if ($SETTINGS.OfflineMode -or $Offline) {
            Write-Progress -Activity "Importing server list" -Id 3 -CurrentOperation "Parsing $ServerFallback"
            $AllServersList = Import-Clixml -Path $ServerFallback
            if ($AllServersList.Count -lt 1) {
                throw "Unable to import server fallback list from $ServerFallback!"
            }
            Write-Progress -Activity "Importing server list" -Id 3 -Completed
        }
        else {
            $RawList = (Get-List -URL ($ServerURL -f $First))
            if ($null -eq $RawList) { throw $FailedList }
            if ($PSCmdlet.ParameterSetName -eq 'RawData' -and $Raw) {
                return , $RawList
            }

            [NordVPNServerList]$AllServersList = ConvertFrom-ServerEntry $RawList
        }
        if ($null -eq $AllServersList) { throw $FailedConv }
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

        , $AllServersList
    }
    end {
        if ($SETTINGS.DeleteServerFallbackAfterUse -and (Test-Path $ServerFallback -PathType Leaf)) {
            Remove-Item $ServerFallback -Force
        }
    }
}
