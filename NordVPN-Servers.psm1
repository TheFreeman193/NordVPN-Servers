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
    OfflineMode                  = @([boolean], $false)
    DeleteServerFallbackAfterUse = @([boolean], $false)
}

$SettingsIn = Get-Content $SettingsFile -ea:si | ConvertFrom-Json
$SETTINGS = @{ }
if ($null -eq $SettingsIn) {
    foreach ($key in $DefaultSettings.Keys) {
        $SETTINGS.$key = $DefaultSettings.$key[1]
    }
    $SETTINGS | ConvertTo-Json | Set-Content $SettingsFile -Force
    Write-Verbose "Wrote default settings to '$SettingsFile'"
}
else {
    foreach ($entry in $SettingsIn.PSObject.Properties) {
        $SETTINGS[$entry.Name] = $entry.Value -as $DefaultSettings[$entry.Name][0]
    }
    Write-Verbose "Loaded persistent settings from '$SettingsFile'"
}

[datetime]$script:CountryCacheDate = [datetime]::MinValue
[datetime]$script:TechnologyCacheDate = [datetime]::MinValue
[datetime]$script:GroupCacheDate = [datetime]::MinValue
New-Variable -Scope Script CountryCache $null
New-Variable -Scope Script TechnologyCache $null
New-Variable -Scope Script GroupCache $null

<# ##### Settings access #####
    Functions to modify and read config
#>
function Set-ModuleSetting {
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'SetDefault')]
    [OutputType("System.Void")]
    param (
        [switch]
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
        Write-Debug ("Parameter set name: {0}" -f $PSCmdlet.ParameterSetName)
        if ($null -ne $SETTINGS[$PSBoundParameters.Name]) {
            $Name = $PSBoundParameters.Name
            if ($PSCmdlet.ParameterSetName -eq 'SetDefault') {
                $defaultValue = $DefaultSettings[$Name][1]
                if ($PSCmdlet.ShouldContinue(
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
                Write-Error ("The type of value '{0}' does not match required type: {1}" -f
                    $PSBoundParameters.Value, $targetType
                ) -Category InvalidType
            }
        }
        else {
            Write-Error "No setting $Name exists!" -Category InvalidArgument
        }
    }
    end {
        if ($SettingsChanged) {
            $SETTINGS | ConvertTo-Json | Set-Content $SettingsFile
            Write-Verbose "Settings changed: Updated settings file '$SettingsFile'"
        }
    }
}


function Get-ModuleSetting {
    [CmdletBinding(DefaultParameterSetName = 'GetAll')]
    [OutputType("System.Object")]
    param (
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'GetDefault'
        )]
        [Switch]
        $Default,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'GetType'
        )]
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
        if ($PSCmdlet.ParameterSetName -eq 'GetAll') {
            return $SETTINGS.Clone()
        }
        if ($null -ne $SETTINGS[$PSBoundParameters.Name]) {
            if ($PSCmdlet.ParameterSetName -eq 'GetDefault') {
                $DefaultSettings[$PSBoundParameters.Name][1]
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'GetType') {
                $DefaultSettings[$PSBoundParameters.Name][0]
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'GetValue') {
                $SETTINGS[$PSBoundParameters.Name]
            }
            else {
                Write-Error "Invalid parameter set" -Category:InvalidArgument
            }
        }
        else {
            Write-Error "No setting $Name exists!" -Category:InvalidArgument
        }
    }
}


function Reset-ModuleSettings {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType('System.Void')]
    param (
        [switch]
        $Force
    )
    process {
        if ($PSCmdlet.ShouldContinue(
                "This will reset all NordVPN-Servers module settings to their defaults. Are you sure?",
                "Reset settings to default"
            )
        ) {
            if ($PSCmdlet.ShouldProcess('All settings', 'Reset defaults')) {
                $SETTINGS.Clear()
                foreach ($key in $DefaultSettings.Keys) {
                    $SETTINGS.$key = $DefaultSettings.$key[1]
                }
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
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string[]]
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
        $paramVals = [array]$SETTINGS.Keys
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
        [parameter(Mandatory = $true, Position = 0)]
        [UInt16]
        $pos,

        [Parameter(Mandatory = $true, Position = 1)]
        [string[]]
        $SetNames
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
        'e.g GB (run Show-NordVPNCountries for reference)'
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

        # $ctryAttribCol.Add($ctryAttrib)
        $ctryVals = (Get-Countries).Code
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
        [parameter(Mandatory = $true, Position = 0)]
        [UInt16]
        $pos,

        [Parameter(Mandatory = $true, Position = 1)]
        [string[]]
        $SetNames
    )
    begin {
        $oldProgressPreference = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
    }
    process {
        Write-Debug 'Dynamic Group parameter requested.'
        $mand = $false
        $help = 'Please enter a group code e.g. legacy_standard ' +
        '(run Show-NordVPNGroups for reference)'
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
        $grpVals = (Get-Groups).Code
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
        [parameter(Mandatory = $true, Position = 0)]
        [UInt16]
        $pos,

        [Parameter(Mandatory = $true, Position = 1)]
        [string[]]
        $SetNames
    )
    begin {
        $oldProgressPreference = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
    }
    process {
        Write-Debug 'Dynamic Technology parameter requested.'
        $mand = $false
        $help = 'Please enter a technology code e.g. openvpn_udp ' +
        '(run Show-NordVPNTechnologies for reference)'
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
        $techVals = (Get-Technologies).Code
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
    affect Get-NordVPNRecommendedServers which will always result in API calls.
#>

function Clear-CountryCache {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType('System.Void')]
    param()
    process {
        Write-Debug "Request to clear the country cache"
        $script:CountryCacheDate = [datetime]::MinValue
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
        $script:GroupCacheDate = [datetime]::MinValue
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
        $script:TechnologyCacheDate = [datetime]::MinValue
        Clear-Variable -Force -Scope Script TechnologyCache
        Write-Verbose "Cleared the NordVPN technology cache."
    }
}


function Clear-Caches {
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
            Write-Debug "Attempting HTTPS request to API"
            # $data = (Invoke-WebRequest -Uri $URL).Content
            # if ($data.Length -le 2) {
            #     Write-Debug "Received empty data from the API"
            #     return $true
            # }
            $data = Invoke-RestMethod -Uri $URL
            if ($data.Count -lt 1) {
                Write-Debug "Received no data from the API"
                return $true
            }
            $data
            # Write-Progress -Activity "Processing lists" -CurrentOperation "Parsing JSON data" -Id 1
            # Write-Debug "Attempting to parse downloaded JSON data"
            # ConvertFrom-Json -InputObject $data
            Write-Progress -Activity "Processing lists" -Id 1 -Completed
        }
        catch [System.Net.WebException] {
            Write-Warning "A web exception occurred: $($_.Exception.Message)"
        }
        catch {
            Write-Error "A general exception occurred: $($_.Exception.Message)"
        }
        if ($RawList -isnot [object]) {
            Write-Warning "Failed to parse JSON correctly."
            return
        }

        $RawList
    }
}


function ConvertFrom-ServerEntries {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [pscustomobject]
        $Entries
    )
    process {
        Write-Debug "Request to convert server entries"
        Write-Verbose "Processing $($Entries.Count) server entries"
        Write-Progress -Activity "Processing server entries" -CurrentOperation "Getting group definitions" -Id 2
        Write-Debug "Attempting to get group list"
        $GroupList = Get-Groups
        Write-Progress -Activity "Processing server entries" -CurrentOperation "Getting country definitions" -Id 2
        Write-Debug "Attempting to get countries list"
        $CountryList = Get-Countries
        [System.Collections.ArrayList]$NewList = @()
        Write-Debug "Calculating number of cycles"
        $k = 0
        $kMax = [Math]::Max($Entries.Count, 1)
        :serverloop foreach ($svr in $Entries) {
            if ($k % 100 -eq 0) {
                Write-Debug "Server entry $k`: ID = $($svr.id)"
            }
            $pcc = [math]::Floor(($k / $kMax) * 100)
            Write-Progress -Activity "Processing server entries" -Id 2 `
                -PercentComplete $pcc `
                -CurrentOperation ("Server {0}/{1} ({2}%)" -f $k, $Entries.Count, $pcc)
            [System.Collections.ArrayList]$services = @()
            Write-Information ".. services"
            foreach ($svc in $svr.services) {
                Write-Progress -Activity 'Populating List' -CurrentOperation "Services" -Id 20 -ParentId 2
                [void]$services.Add(
                    [pscustomobject]@{
                        Id           = $svc.id
                        FriendlyName = $svc.name
                        Code         = $svc.identifier
                        Created      = [datetime]$svc.created_at
                        Updated      = [datetime]$svc.updated_at
                    }
                )
            }
            [System.Collections.ArrayList]$locations = @()
            Write-Information ".. locations"
            foreach ($loc in $svr.locations) {
                Write-Progress -Activity 'Populating List' -CurrentOperation "Locations" -Id 20 -ParentId 2
                [void]$locations.Add(
                    [pscustomobject]@{
                        Id          = $loc.id
                        Latitude    = $loc.latitude
                        Longitude   = $loc.longitude
                        CountryCode = $loc.country.code
                        CityCode    = $loc.country.city.dns_name
                        Created     = [datetime]$loc.created_at
                        Updated     = [datetime]$loc.updated_at
                    }
                )
            }
            [System.Collections.ArrayList]$technologies = @()
            Write-Information ".. technologies"
            :techloop foreach ($tech in $svr.technologies) {
                Write-Progress -Activity 'Populating List' -CurrentOperation "Technologies" -Id 20 -ParentId 2
                if ($tech.pivot.status -ne "online") { continue techloop }
                [void]$technologies.Add(
                [pscustomobject]@{
                    Id           = $tech.id
                    FriendlyName = $tech.name
                    Code         = $tech.identifier
                    Created      = [datetime]$tech.created_at
                    Updated      = [datetime]$tech.updated_at
                    Available    = [boolean]($tech.pivot.status -eq "online")
                    Status       = $tech.pivot.status
                }
                )
            }
            [System.Collections.ArrayList]$groups = @()
            Write-Information ".. groups"
            foreach ($grp in $svr.groups) {
                Write-Progress -Activity 'Populating List' -CurrentOperation "Groups" -Id 20 -ParentId 2
                [void]$groups.Add(
                    [pscustomobject]@{
                        Id           = $grp.id
                        Code         = ($GroupList | Where-Object Id -eq $grp.id).Code
                        FriendlyName = $grp.title
                        Created      = [datetime]$grp.created_at
                        Updated      = [datetime]$grp.updated_at
                        Type         = [pscustomobject]@{
                            Id           = $grp.type.id
                            Created      = [datetime]$grp.type.created_at
                            Updated      = [datetime]$grp.type.updated_at
                            FriendlyName = $grp.type.title
                            Code         = $grp.type.identifier
                        }
                    }
                )
            }
            [System.Collections.ArrayList]$specs = @()
            Write-Information ".. specifications"
            foreach ($spec in $svr.specifications) {
                Write-Progress -Activity 'Populating List' -CurrentOperation "Specifications" -Id 20 -ParentId 2
                [void]$specs.Add(
                    [pscustomobject]@{
                        Id           = $spec.id
                        FriendlyName = $spec.title
                        Code         = $spec.identifier
                        Values       = @(
                            $spec.values | ForEach-Object {
                                [pscustomobject]@{
                                    Id    = $_.id
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
                Write-Progress -Activity 'Populating List' -CurrentOperation "IPs" -Id 20 -ParentId 2
                [void]$ipaddresses.Add(
                    [pscustomobject]@{
                        Id      = $ip.ip.id
                        Version = [UInt16]$ip.ip.version
                        Address = $ip.ip.ip
                        EntryId = $ip.id
                        Created = $ip.created_at
                        Updated = $ip.ipdated_at
                    }
                )
            }
            Write-Progress -Activity 'Populating List' -CurrentOperation "Building server entry" -Id 20 -ParentId 2
            Write-Information ".. Building final structure"
            [void]$NewList.Add(
                [pscustomobject]@{
                    Id             = [UInt64]$svr.id
                    Created        = [datetime]$svr.created_at
                    Updated        = [datetime]$svr.updated_at
                    Hostname       = [String]$svr.hostname
                    Load           = [UInt16]$svr.Load
                    Status         = [String]$svr.status
                    PrimaryIP      = [String]$svr.station
                    Country        = $CountryList | Where-Object Id -eq $svr.locations[0].country.id
                    CountryCode    = [String]$svr.locations[0].country.code
                    City           = $CountryList.Cities | Where-Object Id -eq $svr.locations[0].country.city.id
                    CityCode       = [String]$svr.locations[0].country.city.dns_name
                    Longitude      = [Double]$svr.locations[0].longitude
                    Latitude       = [Double]$svr.locations[0].latitude
                    Locations      = $locations
                    Services       = $services
                    Technologies   = $technologies
                    Specifications = $specs
                    IPs            = $ipaddresses
                    Groups         = $groups
                }
            )
            $k++
        }
        $NewList
        Write-Verbose "Finished processing entries"
        Write-Progress -Activity 'Populating List' -Id 20 -Completed `
            -CurrentOperation "Finished." -ParentId 2
        Write-Progress -Activity 'Processing server entries' -Id 2 -Completed `
            -CurrentOperation "Finished."
    }
}


<# ##### Accessory Functions #####
    These are used to obtain the lists of groups, countries and technologies needed
    to support the dynamic parameters for Get-NordVPN(Recommended)Servers.
    They have been exposed as they are useful in and of themselves.
#>

function Get-Countries {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    [OutputType('System.Array')]
    param (
        [parameter(ParameterSetName = 'DefaultOperation')]
        [switch]
        $UpdateFallback,

        [parameter(ParameterSetName = 'Offline')]
        [switch]
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
            if ($null -eq $CountryList) { return }
            Write-Verbose "Downloaded latest Country list"
            [System.Collections.ArrayList]$NewList = @()
            $i = 0
            foreach ($ctry in $CountryList) {
                Write-Progress -Activity "Building list" -CurrentOperation "Filling hashtable" -Id 1 `
                    -PercentComplete (($i / $CountryList.Count) * 100)
                Write-Debug "Processing entry $i`: Country code = $($ctry.code)"
                [void]$NewList.Add(
                    @{
                        Id           = [UInt64]$ctry.id
                        FriendlyName = [String]$ctry.name
                        Code         = [String]$ctry.code
                        Cities       = @(
                            $ctry.cities | ForEach-Object {
                                @{
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
                $NewList.ToArray() | Export-Clixml -Path $CountryFallback -Force
                Write-Verbose "Exported downloaded country list to fallback: $CountryFallback"
            }
            $NewList.ToArray()
        }
        elseif ($CountryCache -is [System.Collections.ArrayList]) {
            Write-Verbose "Used Country cache"
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                Write-Verbose "Exported technology cache to fallback: $CountryFallback"
                $CountryCache.ToArray() | Export-Clixml -Path $CountryFallback -Force
            }
            $CountryCache.ToArray()
        }
    }
    end {
        if (!$SUCCESS) {
            if (!($Settings.OfflineMode -or $Offline)) {
                Write-Warning "Used Country fallback file '$CountryFallback'"
            }
            Import-Clixml -Path $CountryFallback
        }
    }
}


function Get-Groups {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    [OutputType('System.Array')]
    param (
        [parameter(ParameterSetName = 'DefaultOperation')]
        [switch]
        $UpdateFallback,

        [parameter(ParameterSetName = 'Offline')]
        [switch]
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
            if ($null -eq $GroupList) { return }
            Write-Verbose "Downloaded latest group list"
            [System.Collections.ArrayList]$NewList = @()
            $i = 0
            foreach ($grp in $GroupList) {
                Write-Progress -Activity "Building list" -CurrentOperation "Filling hashtable" -Id 1 `
                    -PercentComplete (($i / $GroupList.Count) * 100)
                Write-Debug "Processing entry $i`: Group code = $($grp.identifier)"
                [void]$NewList.Add(
                    @{
                        Id           = [UInt64]$grp.id
                        FriendlyName = [String]$grp.title
                        Code         = [String]$grp.identifier
                        Type         = @{
                            Id           = [UInt64]$grp.type.id
                            FriendlyName = [String]$grp.type.title
                            Code         = [String]$grp.type.identifier
                            Created      = [datetime]$grp.type.created_at
                            Updated      = [datetime]$grp.type.updated_at
                        }
                        Created      = [datetime]$grp.created_at
                        Updated      = [datetime]$grp.updated_at
                    }
                )
                $i++
            }
            Write-Progress -Activity "Building list" -Id 1 -Completed
            Set-Variable -Scope Script -Force GroupCache $NewList
            Set-Variable -Scope Script -Force GroupCacheDate (Get-Date)
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $NewList.ToArray() | Export-Clixml -Path $GroupFallback -Force
                Write-Verbose "Exported downloaded group list to fallback: $GroupFallback"
            }
            $NewList.ToArray()
        }
        elseif ($GroupCache -is [System.Collections.ArrayList]) {
            Write-Verbose "Used Group cache"
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                Write-Verbose "Exported technology cache to fallback: $GroupFallback"
                $GroupCache.ToArray() | Export-Clixml -Path $GroupFallback -Force
            }
            $GroupCache.ToArray()
        }
    }
    end {
        if (!$SUCCESS) {
            if (!($Settings.OfflineMode -or $Offline)) {
                Write-Warning "Used group fallback file '$GroupFallback'"
            }
            Import-Clixml -Path $GroupFallback
        }
    }
}


function Get-Technologies {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    [OutputType('System.Array')]
    param (
        [parameter(ParameterSetName = 'DefaultOperation')]
        [switch]
        $UpdateFallback,

        [parameter(ParameterSetName = 'Offline')]
        [switch]
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
            if ($null -eq $TechnologyList) { return }
            Write-Verbose "Downloaded latest Technology list"
            [System.Collections.ArrayList]$NewList = @()
            $i = 0
            foreach ($tech in $TechnologyList) {
                Write-Progress -Activity "Building list" -CurrentOperation "Filling hashtable" -Id 1 `
                    -PercentComplete (($i / $TechnologyList.Count) * 100)
                Write-Debug "Processing entry $i`: Technology code = $($tech.identifier)"
                [void]$NewList.Add(
                    @{
                        Id           = [UInt64]$tech.id
                        FriendlyName = [String]$tech.name
                        Code         = [String]$tech.identifier
                        Created      = [datetime]$tech.created_at
                        Updated      = [datetime]$tech.updated_at
                    }
                )
                $i++
            }
            Write-Progress -Activity "Building list" -Id 1 -Completed
            Set-Variable -Scope Script -Force TechnologyCache $NewList
            Set-Variable -Scope Script -Force TechnologyCacheDate (Get-Date)
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                Write-Verbose "Exported downloaded technology list to fallback: $TechnologyFallback"
                $NewList.ToArray() | Export-Clixml -Path $TechnologyFallback -Force
            }
            $NewList.ToArray()
        }
        elseif ($TechnologyCache -is [System.Collections.ArrayList]) {
            Write-Verbose "Used Technology cache"
            $SUCCESS = $true
            if ($UpdateFallback -and !$SETTINGS.OfflineMode) {
                $TechnologyCache.ToArray() | Export-Clixml -Path $TechnologyFallback -Force
                Write-Verbose "Exported technology cache to fallback: $TechnologyFallback"
            }
            $TechnologyCache.ToArray()
        }
    }
    end {
        if (!$SUCCESS) {
            if (!($Settings.OfflineMode -or $Offline)) {
                Write-Warning "Used technology fallback file '$TechnologyFallback'"
            }
            Import-Clixml -Path $TechnologyFallback
        }
    }
}


function Get-Cities {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    [OutputType('System.Array')]
    param ()
    dynamicparam {
        $ParamDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParamDict.Add('Country', (Get-CountryDynamicParam 0 'DefaultOperation'))

        $ParamDict
    }
    process {
        Write-Debug "Cities list requested"
        $Countries = Get-Countries
        if ($PSBoundParameters.Country) {
            $Countries = $Countries | Where-Object { $PSBoundParameters.Country -eq $_.Code }
        }
        [System.Collections.ArrayList]$OutList = @()
        foreach ($ctry in $Countries) {
            foreach ($city in $ctry.Cities) {
                Write-Debug "Processing entry: City code = $($city.Code)"
                [void]$OutList.Add($city)
            }
        }

        $OutList
    }
}


<# ##### Convenience Functions #####
    These produce pretty output for quick visual reference, as opposed to raw data
    for integration into other processes.
#>

function Show-Countries {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    param ()
    begin {
        Write-Host -fo Green "`n`nServer Countries:"
    }
    process {
        Get-Countries | Sort-Object -Property Id | `
            Select-Object Id, FriendlyName, Code, Cities | Format-Table -AutoSize `
            Id, FriendlyName, Code, @{Label = "Cities"; Expression = { $_.Cities.FriendlyName -join '/' } }
    }
}


function Show-Groups {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    param ()
    begin {
        Write-Host -fo Green "`n`nServer Groups:"
    }
    process {
        Get-Groups | Sort-Object -Property Id | `
            Select-Object Id, FriendlyName, Code, Type, Created, Updated | Format-Table -AutoSize `
            Id, FriendlyName, Code, @{Label = "Type"; Expression = { $_.Type.FriendlyName } }, Created, Updated
    }
}


function Show-Technologies {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    param ()
    begin {
        Write-Host -fo Green "`n`nServer Technologies:"
    }
    process {
        Get-Technologies | Sort-Object -Property Id | `
            Select-Object Id, FriendlyName, Code, Created, Updated | Format-Table -AutoSize
    }
}


function Show-Cities {
    [CmdletBinding(DefaultParameterSetName = 'DefaultOperation')]
    param ()
    dynamicparam {
        $ParamDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParamDict.Add('Country', (Get-CountryDynamicParam 0 'DefaultOperation'))

        $ParamDict
    }
    begin {
        Write-Host -fo Green "`n`nServer Cities:"
    }
    process {
        if ($PSBoundParameters.Country) {
            $CityList = Get-Cities -Country:$PSBoundParameters.Country
        }
        else {
            $CityList = Get-Cities
        }
        $Countries = Get-NordVPNCountries
        $CityList.GetEnumerator() | Sort-Object { $_.CountryCode }, { $_.FriendlyName } | Select-Object -Property `
        @{Label = 'ID'; Expression = { $_.Id } },
        @{Label = 'Country'; Expression = {
                $ctry = $_.CountryCode; ($Countries | Where-Object { $_.Code -eq $ctry }).FriendlyName }
        },
        @{Label = 'City'; Expression = { $_.FriendlyName } },
        @{Label = 'City Code'; Expression = { $_.Code } },
        @{Label = 'Latitude'; Expression = { $_.Latitude } },
        @{Label = 'Longitude'; Expression = { $_.Longitude } },
        @{Label = 'HubScore'; Expression = { $_.HubScore } } | `
            Format-Table -AutoSize
    }
}


<# ##### Primary Functions #####
    These are the main functions for retrieving server lists from the NordVPN API.
    -Get-NordVPNRecommendedServers allows direct filtering and is ordered by recommendation.
    -Get-NordVPNSevers uses the raw API and only allows limiting results. This is useful
    for statistical collection of server details. In order to use the filters effectively,
    you should not limit the number of entries unlike with the Get..Recommended.. function.
#>

function Get-RecommendedServers {

    [CmdletBinding(DefaultParameterSetName = "DefaultOperation")]
    [OutputType('System.Array')]
    # Static params
    param (
        [Parameter(
            Position = 0,
            HelpMessage = 'Please enter the maximum number of servers to return (1-65535, default: 5)',
            ParameterSetName = "DefaultOperation"
        )]
        [ValidateRange(1, 65535)]
        [UInt16]
        $Limit = 5,

        [parameter(ParameterSetName = 'DefaultOperation')]
        [switch]
        $Raw
    )
    # Dynamic countries, technologies and groups direct from server or cache
    dynamicparam {
        $ParamDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParamDict.Add('Country', (Get-CountryDynamicParam 0 @('DefaultOperation')))
        $ParamDict.Add('Group', (Get-GroupDynamicParam 1 @('DefaultOperation')))
        $ParamDict.Add('Technology', (Get-TechnologyDynamicParam 2 @('DefaultOperation')))

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
            return
        }
    }
    process {
        if ($Settings.OfflineMode) {
            Write-Warning ("The recommended functionality does not work in offline mode.`n" +
                "Use Set-NordVPNModuleSetting OfflineMode 0 first."
            )
            return
        }
        # Get country no. from ISO code
        $CountryId = $null
        if ($null -ne $PSBoundParameters.Country) {
            $CountryId = (
                (Get-Countries) | Where-Object {
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
        }
        if (($ServerList -is [boolean] -and $true -eq $ServerList) -or ($ServerList.Count -eq 0)) {
            Write-Warning ("No results found for search with filters:" +
                $(if ($PSBoundParameters.Country) { "`n  Country: {0}" -f $PSBoundParameters.Country }) +
                $(if ($PSBoundParameters.Group) { "`n  Group: {0}" -f $PSBoundParameters.Group }) +
                $(if ($PSBoundParameters.Technology) { "`n  Technology: {0}" -f $PSBoundParameters.Technology }) +
                "`nTry adjusting the filters."
            )
        }
        else {
            Write-Verbose "Finished downloading server list. Count: $($ServerList.Count)"
            ConvertFrom-ServerEntries $ServerList
        }
    }
}

function Get-Servers {

    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = "DefaultOperation")]
    [OutputType('System.Array')]
    # Static params
    param (
        [Parameter(
            Position = 0,
            HelpMessage = {$GetServersLimitParamHelp},
            ParameterSetName = "WithFirst"
        )]
        [Parameter(
            Position = 0,
            HelpMessage = {$GetServersLimitParamHelp},
            ParameterSetName = "RawData"
        )]
        [ValidateRange(1, 65535)]
        [UInt16]
        $First = 8192,

        [parameter(ParameterSetName = 'DefaultOperation')]
        [switch]
        $UpdateFallback,

        [parameter(ParameterSetName = 'Offline')]
        [switch]
        $Offline,

        [parameter(ParameterSetName = 'RawData')]
        [switch]
        $Raw
    )
    # Dynamic countries, technologies and groups direct from server or cache
    dynamicparam {
        $ParamDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $allowedParamSets = @('DefaultOperation', 'Offline', 'WithFirst')
        $ParamDict.Add('Country', (Get-CountryDynamicParam 0 $allowedParamSets))
        $ParamDict.Add('Group', (Get-GroupDynamicParam 1 $allowedParamSets))
        $ParamDict.Add('Technology', (Get-TechnologyDynamicParam 2 $allowedParamSets))

        $ParamDict
    }
    begin {
        if (($Settings.OfflineMode -or $Offline -or $UpdateFallback -and $Raw)) {
            Write-Error ("You cannot use the -Raw switch in offline mode, or" +
            " with -UpdateFallback.")
        }
        $ServersCompressed = $ServerFallback, '.zip' -join ''
        if ($Settings.OfflineMode -or $Offline) {
            if (!(Test-Path $ServerFallback -PathType Leaf)) {
                if (Test-Path $ServersCompressed -PathType Leaf) {
                    Write-Verbose "Importing server list"
                    Write-Progress -Activity "Setting up" -Id 3 -CurrentOperation `
                        'Expanding offline servers list: NordVPN_Servers.xml.zip => NordVPN_Servers.xml'
                    Expand-Archive $ServersCompressed $PSScriptRoot -Force
                }
                else {
                    $nofileErr = @{
                        Message           = 'No NordVPN_Servers.xml.zip or NordVPN_Servers.xml file found!' +
                        ' Cannot create fallback file.'
                        Category          = [System.Management.Automation.ErrorCategory]::ResourceUnavailable
                        RecommendedAction = 'Run Get-NordVPNServers -UpdateFallback with offline mode disabled.'
                        CategoryActivity  = 'Expand server list archive'
                        CategoryReason    = 'Server list archive not available'
                    }
                    Write-Error @nofileErr
                }
            }
            Write-Progress -Activity "Importing server list" -Id 3 -CurrentOperation "Parsing $ServerFallback"
            $AllServersList = Import-Clixml -Path $ServerFallback
            Write-Progress -Activity "Importing server list" -Id 3 -Completed
        }
        else {
            $RawList = (Get-List -URL ($API_ALL_URL -f $First))
            if ($PSCmdlet.ParameterSetName -eq 'RawData' -and $Raw) {
                return $RawList
            }
            $AllServersList = ConvertFrom-ServerEntries $RawList
            if ($UpdateFallback) {
                Write-Progress -Activity "Exporting server list" -Id 3 -CurrentOperation `
                    'Writing XML => NordVPN_Servers.xml'
                $AllServersList | Export-Clixml -Path $ServerFallback -Force
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
        if ($PSCmdlet.ParameterSetName -eq 'RawData' -and $Raw) {return}
        if ($null -eq $AllServersList) {
            Write-Error @FailedList
            return
        }
        if ($AllServersList -is [boolean] -and $true -eq $AllServersList) {
            Write-Warning "No values returned from {0}!" -f `
            $(if ($Settings.OfflineMode) { 'the fallback file' } else { 'the API' })
            return
        }
        $ServerList = $AllServersList.Clone()
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
            Write-Verbose "Building structures for list with $($ServerList.Count) entries"
            $ServerList
        }
        else {
            Write-Warning ("No servers in the first $([math]::min($First,$RawList.Count)) results matched the filters! Filters:" +
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
