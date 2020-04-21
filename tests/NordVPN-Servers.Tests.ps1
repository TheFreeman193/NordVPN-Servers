#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '4.0' }

param (
    [String]
    $TestID,

    [Int64]
    $TestSamples = 5
)

if ((Get-PSCallStack).Command -notcontains 'Run-Tests.ps1') {
    throw ("Please run these tests using ./tests/Run-Tests.ps1!" +
        " It protects the module files against modification by the tests.")
}

Write-Information "Setting up test $TestID" -InformationAction Continue

$ModulePath = Resolve-Path (Split-Path $PSScriptRoot)
$ModuleName = Split-Path $ModulePath -Leaf
Push-Location $ModulePath

# Clear any existing instance
Get-Module -Name $ModuleName -All | Remove-Module -Force -ErrorAction Stop

# Enforce native archive functionality (e.g. Pscx OVR)
Import-Module -Name Microsoft.PowerShell.Archive -force

# Import latest instance
Import-Module -Name $ModuleName -Force -ErrorAction Stop

# Import custom classes
. .\NordVPN-Servers.Classes.ps1

Reset-NordVPNModule -Force

Write-Information "Running test $TestID, list samples $TestSamples" -InformationAction Continue

Describe 'Fundamental requirements' -Tag 'Offline', 'Param' {

    Context 'Exports' {

        $prefix = 'NordVPN'
        $neededFuncs = @{
            "Set-${prefix}ModuleSetting"     = 'Force', 'Name', 'Value'
            "Get-${prefix}ModuleSetting"     = 'Default', 'Type', 'Name'
            "Reset-${prefix}Module"          = 'Force'
            "Clear-${prefix}CountryCache"    = @()
            "Clear-${prefix}GroupCache"      = @()
            "Clear-${prefix}TechnologyCache" = @()
            "Clear-${prefix}Cache"           = @()
            "Get-${prefix}CountryList"       = 'UpdateFallback', 'Offline'
            "Get-${prefix}GroupList"         = 'UpdateFallback', 'Offline'
            "Get-${prefix}TechnologyList"    = 'UpdateFallback', 'Offline'
            "Get-${prefix}CityList"          = 'Country', 'Offline'
            "Get-${prefix}ServerList"        = 'First', 'Raw', 'Country', 'Group', 'Technology'
            "Get-${prefix}RecommendedList"   = `
                'Limit', 'UpdateFallback', 'Offline', 'Raw', 'Country', 'Group', 'Technology'
        }
        $actualFuncs = ((Get-Command -Module NordVPN-Servers) `
            | Where-Object CommandType -eq Function).Name

        It 'Exports only correct function members' {
            Compare-Object $neededFuncs.Keys.ForEach( { $_ } ) $actualFuncs | Should -BeNullOrEmpty
        }

        foreach ($name in $neededFuncs.Keys) {
            It "Function $name has correct parameters" {
                $func = Get-Command $name
                foreach ($param in $neededFuncs.$name.Value) {
                    $func | Should -HaveParameter $param
                }
            }
        }
    }

    Context 'Fallback files' {

        It 'Includes fallback files' {
            '.\NordVPN_Countries.xml' | Should -Exist
            '.\NordVPN_Groups.xml' | Should -Exist
            '.\NordVPN_Technologies.xml' | Should -Exist
            '.\NordVPN_Servers.xml.zip' | Should -Exist
        }

    }

    Context 'Default settings' {

        It 'Can generate default module settings file' {
            Remove-Item .\NordVPN-Servers.settings.json -Force -ErrorAction SilentlyContinue
            '.\NordVPN-Servers.settings.json' | Should -Not -Exist
            Reset-NordVPNModule -Force
            '.\NordVPN-Servers.settings.json' | Should -Exist
        }


        $expectedSettings = [PSCustomObject]@{
            CountryCacheLifetime         = 600
            GroupCacheLifetime           = 600
            TechnologyCacheLifetime      = 600
            OfflineMode                  = $false
            DeleteServerFallbackAfterUse = $false
        }
        It 'Is able to generate default settings' {
            $actualSettings = Get-Content '.\NordVPN-Servers.settings.json' | ConvertFrom-Json
            Compare-Object $actualSettings $expectedSettings | Should -BeNullOrEmpty
        }

    }

}

Describe 'Class Methods' -Tag Offline, Unit {
    Function GenID { [UInt64](Get-Random -Minimum 1 -Maximum 9e8) }
    Function GenFName { (New-Guid).Guid -replace '-', ' ' }
    Function GenCode { (New-Guid).Guid.Split('-')[-1] }
    Function GenCountryCode { [string]( -join (65..90 | Get-Random -Count 2 | ForEach-Object { [Char]$_ })) }
    Function GenLatitude { [Double]([math]::Round((Get-Random -Minimum -89.999 -Maximum 90), 6)) }
    Function GenLongitude { [Double]([math]::Round((Get-Random -Minimum -179.999 -Maximum 180), 6)) }
    Function GenDate { [DateTime]((Get-Date).AddSeconds( - (Get-Random -Minimum 0 -Maximum 1e9))) }

    Function ObjCloneTest($Obj) {
        $Clone1 = $Obj.Clone()
        Compare-Object $Clone1 $Obj | Should -BeNullOrEmpty
        $Clone2 = $Clone1.Clone()
        $Clone1.Id = 0
        $Clone1 | Add-Member -NotePropertyName Random -NotePropertyValue (New-Guid)
        Compare-Object $Obj $Clone2 | Should -BeNullOrEmpty
        Remove-Variable Clone1
        Compare-Object $Obj $Clone2 | Should -BeNullOrEmpty
        Remove-Variable Clone2
        $Obj | Should -Not -BeNullOrEmpty
    }
    Function ListCloneTest($List) {
        $Clone1 = $List.Clone()
        Compare-Object $Clone1 $List | Should -BeNullOrEmpty
        $Clone2 = $Clone1.Clone()
        $Clone1 | Add-Member -NotePropertyName Random -NotePropertyValue (New-Guid)
        Compare-Object $List $Clone2 | Should -BeNullOrEmpty
        Remove-Variable Clone1
        Compare-Object $List $Clone2 | Should -BeNullOrEmpty
        Remove-Variable Clone2
        $List | Should -Not -BeNullOrEmpty
    }

    Context 'Cities' {

        $CityList = [NordVPNCityList]::new()
        It 'Can construct new city list' {
            $CityList.GetType().FullName | Should -Be 'NordVPNCityList'
            $CityList.GetType().BaseType.FullName | Should -Be 'System.Collections.ArrayList'
        }

        $City = [NordVPNCity]::new(
            (GenID), (GenFName), (GenCode), (GenLatitude), (GenLongitude),
            (Get-Random -Minimum -100 -Maximum 100), (GenCountryCode)
        )

        It 'Can construct new city entry' {
            $City.GetType().FullName | Should -Be 'NordVPNCity'
            $City.GetType().BaseType.FullName | Should -Be 'NordVPNItem'
        }

        It 'Cities can be added to CityList' {
            { $CityList.Add($City) } | Should -Not -Throw
            $CityList[0] | Should -Be $City
        }

        It 'City can be cloned' {
            ObjCloneTest $City
        }

        It 'CityList can be cloned' {
            ListCloneTest $CityList
        }

    }

    Context 'Countries' {

        $CountryList = [NordVPNCountryList]::new()
        It 'Can construct new country list' {
            $CountryList.GetType().FullName | Should -Be 'NordVPNCountryList'
            $CountryList.GetType().BaseType.FullName | Should -Be 'System.Collections.ArrayList'
        }

        $Country = [NordVPNCountry]::new()
        $Country.Id = (GenID)
        $Country.FriendlyName = (GenFName)
        $Country.Code = (GenCountryCode)
        $City = [NordVPNCity]::new(
            (GenID), (GenFName), (GenCode), (GenLatitude), (GenLongitude),
            (Get-Random -Minimum -100 -Maximum 100), (GenCountryCode)
        )
        $Country.Cities = [NordVPNCityList]::new()
        $Country.Cities.Add($City)

        It 'Can construct new country entry' {
            $Country.GetType().FullName | Should -Be 'NordVPNCountry'
            $Country.GetType().BaseType.FullName | Should -Be 'NordVPNItem'
        }

        It 'Countries can be added to CountryList' {
            { $CountryList.Add($Country) } | Should -Not -Throw
            $CountryList[0] | Should -Be $Country
        }

        It 'Country can be cloned' {
            ObjCloneTest $Country
        }

        It 'CountryList can be cloned' {
            ListCloneTest $CountryList
        }

    }

    Context 'Groups' {

        $GroupList = [NordVPNGroupList]::new()
        It 'Can construct new group list' {
            $GroupList.GetType().FullName | Should -Be 'NordVPNGroupList'
            $GroupList.GetType().BaseType.FullName | Should -Be 'System.Collections.ArrayList'
        }

        $Group = [NordVPNGroup]::new()
        $Group.Id = (GenID)
        $Group.FriendlyName = (GenFName)
        $Group.Code = (GenCode)
        $Group.Created = (GenDate)
        $Group.Updated = (GenDate)
        $Group.Type = [NordVPNDatedItem]::new()
        $Group.Type.Id = (GenID)
        $Group.Type.FriendlyName = (GenFName)
        $Group.Type.Code = (GenCode)
        $Group.Type.Created = (GenDate)
        $Group.Type.Updated = (GenDate)

        It 'Can construct new group entry' {
            $Group.GetType().FullName | Should -Be 'NordVPNGroup'
            $Group.GetType().BaseType.FullName | Should -Be 'NordVPNDatedItem'
        }

        It 'Groups can be added to GroupList' {
            { $GroupList.Add($Group) } | Should -Not -Throw
            $GroupList[0] | Should -Be $Group
        }

        It 'Group can be cloned' {
            ObjCloneTest $Group
        }

        It 'GroupList can be cloned' {
            ListCloneTest $GroupList
        }

    }

    Context 'Technologies' {

        $TechnologyList = [NordVPNTechnologyList]::new()
        It 'Can construct new technology list' {
            $TechnologyList.GetType().FullName | Should -Be 'NordVPNTechnologyList'
            $TechnologyList.GetType().BaseType.FullName | Should -Be 'System.Collections.ArrayList'
        }

        $Technology = [NordVPNTechnology]::new()
        $Technology.Id = (GenID)
        $Technology.FriendlyName = (GenFName)
        $Technology.Code = (GenCode)
        $Technology.Created = (GenDate)
        $Technology.Updated = (GenDate)
        $Technology.Status = (GenCode)

        It 'Can construct new technology entry' {
            $Technology.GetType().FullName | Should -Be 'NordVPNTechnology'
            $Technology.GetType().BaseType.FullName | Should -Be 'NordVPNDatedItem'
        }

        It 'Technologies can be added to TechnologyList' {
            { $TechnologyList.Add($Technology) } | Should -Not -Throw
            $TechnologyList[0] | Should -Be $Technology
        }

        It 'Technology can be cloned' {
            ObjCloneTest $Technology
        }

        It 'TechnologyList can be cloned' {
            ListCloneTest $TechnologyList
        }

    }

    Context 'Services' {

        $ServiceList = [NordVPNServiceList]::new()
        It 'Can construct new service list' {
            $ServiceList.GetType().FullName | Should -Be 'NordVPNServiceList'
            $ServiceList.GetType().BaseType.FullName | Should -Be 'System.Collections.ArrayList'
        }

        $Service = [NordVPNService]::new()
        $Service.Id = (GenID)
        $Service.FriendlyName = (GenFName)
        $Service.Code = (GenCode)
        $Service.Created = (GenDate)
        $Service.Updated = (GenDate)

        It 'Can construct new service entry' {
            $Service.GetType().FullName | Should -Be 'NordVPNService'
            $Service.GetType().BaseType.FullName | Should -Be 'NordVPNDatedItem'
        }

        It 'Services can be added to ServiceList' {
            { $ServiceList.Add($Service) } | Should -Not -Throw
            $ServiceList[0] | Should -Be $Service
        }

        It 'Service can be cloned' {
            ObjCloneTest $Service
        }

        It 'ServiceList can be cloned' {
            ListCloneTest $ServiceList
        }

    }

    Context 'IPAddresses' {

        $IPAddressList = [NordVPNIPAddressList]::new()
        It 'Can construct new IP address list' {
            $IPAddressList.GetType().FullName | Should -Be 'NordVPNIPAddressList'
            $IPAddressList.GetType().BaseType.FullName | Should -Be 'System.Collections.ArrayList'
        }

        $IPAddress = [NordVPNIPAddress]::new()
        $IPAddress.Id = (GenID)
        $IPAddress.Version = [UInt16](4, 6 | Get-Random)
        $IPAddress.InstanceId = (GenID)
        $IPAddress.Created = (GenDate)
        $IPAddress.Updated = (GenDate)
        $IPAddress.IPAddress = (GenCode)

        It 'Can construct new IP entry' {
            $IPAddress.GetType().FullName | Should -Be 'NordVPNIPAddress'
            $IPAddress.GetType().BaseType.FullName | Should -Be 'System.Object'
        }

        It 'IP addresses can be added to IPAddressList' {
            { $IPAddressList.Add($IPAddress) } | Should -Not -Throw
            $IPAddressList[0] | Should -Be $IPAddress
        }

        It 'IPAddress can be cloned' {
            ObjCloneTest $IPAddress
        }

        It 'IPAddressList can be cloned' {
            ListCloneTest $IPAddressList
        }

    }

    Context 'Values' {

        $ValueList = [NordVPNValueList]::new()
        It 'Can construct new Value list' {
            $ValueList.GetType().FullName | Should -Be 'NordVPNValueList'
            $ValueList.GetType().BaseType.FullName | Should -Be 'System.Collections.ArrayList'
        }

        $Value = [NordVPNValue]::new()
        $Value.Id = (GenID)
        $Value.Value = (GenFName)

        It 'Can construct new value entry' {
            $Value.GetType().FullName | Should -Be 'NordVPNValue'
            $Value.GetType().BaseType.FullName | Should -Be 'System.Object'
        }

        It 'Values can be added to ValueList' {
            { $ValueList.Add($Value) } | Should -Not -Throw
            $ValueList[0] | Should -Be $Value
        }

        It 'Value can be cloned' {
            ObjCloneTest $Value
        }

        It 'ValueList can be cloned' {
            ListCloneTest $ValueList
        }

    }

    Context 'Specifications' {

        $SpecificationList = [NordVPNSpecificationList]::new()
        It 'Can construct new specification list' {
            $SpecificationList.GetType().FullName | Should -Be 'NordVPNSpecificationList'
            $SpecificationList.GetType().BaseType.FullName | Should -Be 'System.Collections.ArrayList'
        }

        $Specification = [NordVPNSpecification]::new()
        $Specification.Id = (GenID)
        $Specification.FriendlyName = (GenFName)
        $Specification.Code = (GenCode)
        $Val = [NordVPNValue]::new((GenID), (GenFName))
        $Specification.Values = [NordVPNValueList]::new()
        $Specification.Values.Add($Val)

        It 'Can construct new specification entry' {
            $Specification.GetType().FullName | Should -Be 'NordVPNSpecification'
            $Specification.GetType().BaseType.FullName | Should -Be 'NordVPNItem'
        }

        It 'Specifications can be added to SpecificationList' {
            { $SpecificationList.Add($Specification) } | Should -Not -Throw
            $SpecificationList[0] | Should -Be $Specification
        }

        It 'Specification can be cloned' {
            ObjCloneTest $Specification
        }

        It 'SpecificationList can be cloned' {
            ListCloneTest $SpecificationList
        }

    }

    Context 'Locations' {

        $LocationList = [NordVPNLocationList]::new()
        It 'Can construct new location list' {
            $LocationList.GetType().FullName | Should -Be 'NordVPNLocationList'
            $LocationList.GetType().BaseType.FullName | Should -Be 'System.Collections.ArrayList'
        }

        $Location = [NordVPNLocation]::new()
        $Location.Id = (GenID)
        $Location.CityCode = (GenCode)
        $Location.CountryCode = (GenCountryCode)
        $Location.Created = (GenDate)
        $Location.Updated = (GenDate)
        $Location.Latitude = (GenLatitude)
        $Location.Longitude = (GenLongitude)

        It 'Can construct new location entry' {
            $Location.GetType().FullName | Should -Be 'NordVPNLocation'
            $Location.GetType().BaseType.FullName | Should -Be 'System.Object'
        }

        It 'Locations can be added to LocationList' {
            { $LocationList.Add($Location) } | Should -Not -Throw
            $LocationList[0] | Should -Be $Location
        }

        It 'Location can be cloned' {
            ObjCloneTest $Location
        }

        It 'LocationList can be cloned' {
            ListCloneTest $LocationList
        }

    }

    Context 'Servers' {

        $ServerList = [NordVPNServerList]::new()
        It 'Can construct new server list' {
            $ServerList.GetType().FullName | Should -Be 'NordVPNServerList'
            $ServerList.GetType().BaseType.FullName | Should -Be 'System.Collections.ArrayList'
        }

        $Server = [NordVPNServer]::new()
        It 'Can construct new Server entry' {
            $Server.GetType().FullName | Should -Be 'NordVPNServer'
            $Server.GetType().BaseType.FullName | Should -Be 'NordVPNDatedItem'
        }

        $Server.Id = (GenID)
        $Server.FriendlyName = (GenFName)
        $Server.Code = (GenCode)
        $Server.Created = (GenDate)
        $Server.Updated = (GenDate)
        $Server.Latitude = (GenLatitude)
        $Server.Longitude = (GenLongitude)
        $Server.PrimaryIP = (GenFName)
        $Server.Hostname = (GenCode)
        $Server.Load = (Get-Random -Minimum 0 -Maximum 100)
        $Server.Status = (GenCode)

        $Country = [NordVPNCountry]::new()
        $Country.Id = (GenID)
        $Country.FriendlyName = (GenFName)
        $Country.Code = (GenCountryCode)
        { $Server.Country = $Country } | Should -Not -Throw
        { $City = [NordVPNCity]::new(
                (GenID), (GenFName), (GenCode), (GenLatitude), (GenLongitude),
                (Get-Random -Minimum -100 -Maximum 100), (GenCode)
            )
            $Server.City = $City
        } | Should -Not -Throw


        It 'Locations can be added to server entry' {
            $Location = [NordVPNLocation]::new()
            $Location.Id = (GenID)
            $Location.CityCode = (GenCode)
            $Location.CountryCode = (GenCountryCode)
            $Location.Created = (GenDate)
            $Location.Updated = (GenDate)
            $Location.Latitude = (GenLatitude)
            $Location.Longitude = (GenLongitude)
            $LocationList = [NordVPNLocationList]::new()
            $LocationList.Add($Location)
            {$Server.Locations = $LocationList} | Should -Not -Throw
        }

        It 'Specifications can be added to server entry' {
            $Specification = [NordVPNSpecification]::new()
            $Specification.Id = (GenID)
            $Specification.FriendlyName = (GenFName)
            $Specification.Code = (GenCode)
            $Val = [NordVPNValue]::new((GenID), (GenFName))
            $Specification.Values = [NordVPNValueList]::new()
            $Specification.Values.Add($Val)
            $SpecList = [NordVPNSpecificationList]::new()
            $SpecList.Add($Specification)
            { $Server.Specifications = $SpecList } | Should -Not -Throw
        }

        It 'IP addresses can be added to server entry' {
            $IPAddress = [NordVPNIPAddress]::new()
            $IPAddress.Id = (GenID)
            $IPAddress.Version = [UInt16](4, 6 | Get-Random)
            $IPAddress.InstanceId = (GenID)
            $IPAddress.Created = (GenDate)
            $IPAddress.Updated = (GenDate)
            $IPAddress.IPAddress = (GenCode)
            $IPList = [NordVPNIPAddressList]::new()
            $IPList.Add($IPAddress)
            { $Server.IPs = $IPList } | Should -Not -Throw
        }

        It 'Services can be added to server entry' {
            $Service = [NordVPNService]::new()
            $Service.Id = (GenID)
            $Service.FriendlyName = (GenFName)
            $Service.Code = (GenCode)
            $Service.Created = (GenDate)
            $Service.Updated = (GenDate)
            $ServiceList = [NordVPNServiceList]::new()
            $ServiceList.Add($Service)
            { $Server.Services = $ServiceList } | Should -Not -Throw
        }

        It 'Groups can be added to server entry' {
            $Group = [NordVPNGroup]::new()
            $Group.Id = (GenID)
            $Group.FriendlyName = (GenFName)
            $Group.Code = (GenCode)
            $Group.Created = (GenDate)
            $Group.Updated = (GenDate)
            $Group.Type = [NordVPNDatedItem]::new()
            $Group.Type.Id = (GenID)
            $Group.Type.FriendlyName = (GenFName)
            $Group.Type.Code = (GenCode)
            $Group.Type.Created = (GenDate)
            $Group.Type.Updated = (GenDate)
            $GroupList = [NordVPNGroupList]::new()
            $GroupList.Add($Group)
            { $Server.Groups = $GroupList } | Should -Not -Throw
        }

        It 'Technologies can be added to server entry' {
            $Technology = [NordVPNTechnology]::new()
            $Technology.Id = (GenID)
            $Technology.FriendlyName = (GenFName)
            $Technology.Code = (GenCode)
            $Technology.Created = (GenDate)
            $Technology.Updated = (GenDate)
            $Technology.Status = (GenCode)
            $TechnologyList = [NordVPNTechnologyList]::new()
            $TechnologyList.Add($Technology)
            { $Server.Technologies = $TechnologyList } | Should -Not -Throw
        }

        It 'Servers can be added to ServerList' {
            { $ServerList.Add($Server) } | Should -Not -Throw
            $ServerList[0] | Should -Be $Server
        }

        It 'Server can be cloned' {
            ObjCloneTest $Server
        }

        It 'ServerList can be cloned' {
            ListCloneTest $ServerList
        }

    }

}

InModuleScope $ModuleName {

    $TestSettings = Get-Content .\tests\TestSettings.tmp -ErrorAction Stop
    try { [String]$TestID = $TestSettings[0] } catch { $TestID = '<unknown>' }
    try { [String]$TestSamples = $TestSettings[1] } catch { $TestSamples = 5 }
    try { [String]$ModuleName = $TestSettings[2] } catch { $ModuleName = 'NordVPN-Servers' }

    Write-Information "Test $TestID now in module scope $ModuleName, list samples $TestSamples" `
        -InformationAction Continue

    # Reference values
    $emptyDate = [datetime]::MinValue

    $CountryListRaw = Import-CliXml .\tests\countries_raw.xml
    $GroupListRaw = Import-CliXml .\tests\groups_raw.xml
    $TechnologyListRaw = Import-CliXml .\tests\technologies_raw.xml
    $ServerListRaw = Import-Clixml .\tests\servers_raw.xml

    $CountryListProc = Import-CliXml .\tests\countries_proc.xml
    $GroupListProc = Import-CliXml .\tests\groups_proc.xml
    $TechnologyListProc = Import-CliXml .\tests\technologies_proc.xml
    $CityListProc = Import-CliXml .\tests\cities_proc.xml
    $ServerListProc = Import-Clixml .\tests\servers_proc.xml
    $RecommendedListProc = Import-Clixml .\tests\recommended_proc.xml

    $CountryMatchURL = 'https://api\.nordvpn\.com/v1/servers/countries'
    $GroupMatchURL = 'https://api\.nordvpn\.com/v1/servers/groups'
    $TechnologyMatchURL = 'https://api\.nordvpn\.com/v1/technologies'
    $ServerMatchURL = 'https://api\.nordvpn\.com/v1/servers\?'
    $RecommendedMatchURL = 'https://api\.nordvpn\.com/v1/servers/recommendations'

    # Shortcuts to mock API calls
    Function MockCountries {
        Mock Get-List {
            Write-Debug 'Mocking Country API'
            return $CountryListRaw
        } -ParameterFilter {
            $URL -match $CountryMatchURL
        }
    }
    Function MockGroups {
        Mock Get-List {
            Write-Debug 'Mocking Country API'
            return $GroupListRaw
        } -ParameterFilter {
            $URL -match $GroupMatchURL
        }
    }
    Function MockTechnologies {
        Mock Get-List {
            Write-Debug 'Mocking Country API'
            return $TechnologyListRaw
        } -ParameterFilter {
            $URL -match $TechnologyMatchURL
        }
    }
    Function MockServers {
        Mock Get-List {
            Write-Debug 'Mocking Country API'
            return $ServerListRaw
        } -ParameterFilter {
            $URL -match $ServerMatchURL -or
            $URL -match $RecommendedMatchURL
        }
    }

    Describe 'Cache functionality' -Tag 'Offline', 'Cache' {

        $CountryCacheFile = 'TestDrive:\countries_cache.xml'
        $GroupCacheFile = 'TestDrive:\groups_cache.xml'
        $TechnologyCacheFile = 'TestDrive:\technologies_cache.xml'
        Clear-Cache

        Context 'Initialisation' {

            It 'Empty cache at initialisation' {
                $CountryCacheDate | Should -Be $emptyDate
                $GroupCacheDate | Should -Be $emptyDate
                $TechnologyCacheDate | Should -Be $emptyDate
                $CountryCache | Should -BeNullOrEmpty
                $GroupCache | Should -BeNullOrEmpty
                $TechnologyCache | Should -BeNullOrEmpty
            }

        }

        Context 'Population' {

            MockCountries
            It 'Country cache populated after country list download' {
                Get-CountryList | Out-Null
                $CountryCacheDate | Should -BeGreaterThan $emptyDate
                $CountryCache.GetType() | Should -Be 'NordVPNCountryList'
                $CountryCache | Export-Clixml $CountryCacheFile
                Compare-Object (Import-Clixml $CountryCacheFile) $CountryListProc `
                | Should -BeNullOrEmpty
            }

            MockGroups
            It 'Group cache populated after group list download' {
                Get-GroupList | Out-Null
                $GroupCacheDate | Should -BeGreaterThan $emptyDate
                $GroupCache.GetType() | Should -Be 'NordVPNGroupList'
                $GroupCache | Export-Clixml $GroupCacheFile
                Compare-Object (Import-Clixml $GroupCacheFile) $GroupListProc `
                | Should -BeNullOrEmpty
            }

            MockTechnologies
            It 'Technology cache populated after technology list download' {
                Get-TechnologyList | Out-Null
                $TechnologyCacheDate | Should -BeGreaterThan $emptyDate
                $TechnologyCache.GetType() | Should -Be 'NordVPNTechnologyList'
                $TechnologyCache | Export-Clixml $TechnologyCacheFile
                Compare-Object (Import-Clixml $TechnologyCacheFile) $TechnologyListProc `
                | Should -BeNullOrEmpty
            }

        }

        Context 'Utilisation' {

            Mock Get-List { return $true }
            It 'Country cache utilised if not expired' {
                Get-CountryList | Out-Null
                Assert-MockCalled Get-List -Times 0
            }

            It 'Group cache utilised if not expired' {
                Get-GroupList | Out-Null
                Assert-MockCalled Get-List -Times 0
            }

            It 'Technology cache utilised if not expired' {
                Get-TechnologyList | Out-Null
                Assert-MockCalled Get-List -Times 0
            }

        }

        Context 'Expiry' {

            $expiryDate = (Get-Date).AddSeconds(-601)
            $script:CountryCacheDate = $expiryDate
            $script:GroupCacheDate = $expiryDate
            $script:TechnologyCacheDate = $expiryDate
            $script:CountryCache = @()
            $script:GroupCache = @()
            $script:TechnologyCache = @()

            MockCountries
            It 'Country list downloaded on cache expiry' {
                Get-CountryList | Out-Null
                $CountryCacheDate | Should -Not -Be $expiryDate
                $CountryCache | Should -Not -BeNullOrEmpty
                $CountryCache | Export-Clixml $CountryCacheFile
                Compare-Object (Import-Clixml $CountryCacheFile) $CountryListProc `
                | Should -BeNullOrEmpty
            }

            MockGroups
            It 'Group list downloaded on cache expiry' {
                Get-GroupList | Out-Null
                $GroupCacheDate | Should -Not -Be $expiryDate
                $GroupCache | Should -Not -BeNullOrEmpty
                $GroupCache | Export-Clixml $GroupCacheFile
                Compare-Object (Import-Clixml $GroupCacheFile) $GroupListProc `
                | Should -BeNullOrEmpty
            }

            MockTechnologies
            It 'Technology list downloaded on cache expiry' {
                Get-TechnologyList | Out-Null
                $TechnologyCacheDate | Should -Not -Be $expiryDate
                $TechnologyCache | Should -Not -BeNullOrEmpty
                $TechnologyCache | Export-Clixml $TechnologyCacheFile
                Compare-Object (Import-Clixml $TechnologyCacheFile) $TechnologyListProc `
                | Should -BeNullOrEmpty
            }

        }

        Context 'Manual clearing' {

            It 'Country cache cleared on user request' {
                Clear-CountryCache
                $CountryCache | Should -BeNullOrEmpty
                $CountryCacheDate | Should -Be $emptyDate
            }

            It 'Group cache cleared on user request' {
                Clear-GroupCache
                $GroupCache | Should -BeNullOrEmpty
                $GroupCacheDate | Should -Be $emptyDate
            }

            It 'Technology cache cleared on user request' {
                Clear-TechnologyCache
                $TechnologyCache | Should -BeNullOrEmpty
                $TechnologyCacheDate | Should -Be $emptyDate
            }

        }

    }

    Describe 'Server fallback file functionality' -Tag 'Offline', 'Server' {

        Context 'Exceptions' {

            Mock Test-Path { $false }
            $SETTINGS.OfflineMode = $true
            It 'throws error when neither ZIP/XML fallback found' {
                { Get-ServerList } | Should -Throw 'not found! Cannot create fallback file.'
            }

            $ServersCompressed = $ServerFallback, '.zip' -join ''
            Mock Test-Path { return $true } -Verifiable -ParameterFilter { $Path -eq $ServersCompressed }
            It 'Attempts to extract ZIP if XML not found' {
                Mock Expand-Archive -Verifiable { }
                { Get-ServerList } | Should -Throw 'Unable to expand server fallback archive'
                Assert-MockCalled Test-Path -Times 1
                Assert-MockCalled Expand-Archive -Times 1
                Assert-VerifiableMock
            }

            Mock Import-Clixml -Verifiable { }
            Mock Test-Path { return $true } -Verifiable
            It 'Attempts to read XML extracted from archive' {
                { Get-ServerList } | Should -Throw 'Unable to import server fallback list from'
                Assert-MockCalled Test-Path -Times 2
                Assert-MockCalled Expand-Archive -Times 1
                Assert-MockCalled Import-Clixml -Times 1
                Assert-VerifiableMock
            }
            $SETTINGS.OfflineMode = $false

        }

        Context 'Normal operation' {

            $SETTINGS.OfflineMode = $true
            MockCountries
            MockGroups
            MockTechnologies
            It 'Can extract ZIP and read XML fallback' {
                $svrs = Get-ServerList
                $expectedMembers = @{
                    Id             = 'System.UInt64'
                    FriendlyName   = 'System.String'
                    Created        = 'System.DateTime'
                    Updated        = 'System.DateTime'
                    Hostname       = 'System.String'
                    Load           = 'System.UInt16'
                    Status         = 'System.String'
                    PrimaryIP      = 'System.String'
                    Country        = 'Deserialized.NordVPNCountry'
                    City           = 'Deserialized.NordVPNCity'
                    Longitude      = 'System.Double'
                    Latitude       = 'System.Double'
                    Locations      = 'Deserialized.NordVPNLocationList'
                    Services       = 'Deserialized.NordVPNServiceList'
                    Technologies   = 'Deserialized.NordVPNTechnologyList'
                    Specifications = 'Deserialized.NordVPNSpecificationList'
                    IPs            = 'Deserialized.NordVPNIPAddressList'
                    Groups         = 'Deserialized.NordVPNGroupList'
                }
                $svrs | Should -Not -BeNullOrEmpty
                for ($i = 0; $i -lt 50; $i++) {
                    $svr = $svrs | Get-Random
                    $svr.PSObject.TypeNames | Should -Contain 'Deserialized.NordVPNServer'
                    foreach ($mem in $expectedMembers.Keys) {
                        $svr.PSObject.Members.Name | Should -Contain $mem
                        $svr.$mem.PSObject.TypeNames | Should -Contain $expectedMembers.$mem
                    }
                }
            }
            $SETTINGS.OfflineMode = $false
            Remove-Item .\NordVPN_Servers.xml -Force -ErrorAction SilentlyContinue

            Remove-Item .\NordVPN_Servers.xml.zip -Force -ErrorAction SilentlyContinue
            MockServers
            It 'Can regenerate server fallback files' {
                Get-ServerList -UpdateFallback | Out-Null
                '.\NordVPN_Servers.xml.zip' | Should -Exist
                '.\NordVPN_Servers.xml' | Should -Exist
                Compare-Object $ServerListProc (Import-Clixml .\NordVPN_Servers.xml) | Should -BeNullOrEmpty
            }
            Remove-Item .\NordVPN_Servers.xml -Force -ErrorAction SilentlyContinue

        }

    }

    Describe 'Peripheral fallbacks' -Tag 'Offline', 'Peripheral' {

        Context 'Manual utilisation' {

            Mock Import-CliXml { }
            It 'XML fallbacks used when -Offline is passed' {
                Get-CountryList -Offline | Out-Null
                Get-GroupList -Offline | Out-Null
                Get-TechnologyList -Offline | Out-Null
                Assert-MockCalled Import-CliXml -Times 3
            }

            It 'XML fallbacks used when offline setting is present' {
                $SETTINGS.OfflineMode = $true
                Get-CountryList | Out-Null
                Get-GroupList | Out-Null
                Get-TechnologyList | Out-Null
                Assert-MockCalled Import-CliXml -Times 3
                $SETTINGS.OfflineMode = $false
            }

        }

        Context 'Normal operation' {

            It 'Can read country XML fallback' {
                $ctrys = Get-CountryList -Offline
                $expectedMembers = @(
                    "Id"
                    "FriendlyName"
                    "Code"
                    "Cities"
                )
                $expectedMembersCity = @(
                    "Id"
                    "FriendlyName"
                    "Code"
                    "Longitude"
                    "Latitude"
                    "HubScore"
                    "CountryCode"
                )
                $ctrys | Should -Not -BeNullOrEmpty
                foreach ($ctry in $ctrys) {
                    $ctry.PSObject.TypeNames | Should -Contain 'Deserialized.NordVPNCountry'
                    foreach ($mem in $expectedMembers) {
                        $ctry.PSObject.Members.Name | Should -Contain $mem
                    }
                    foreach ($city in $ctry.Cities) {
                        foreach ($mem in $expectedMembersCity) {
                            $city.PSObject.Members.Name | Should -Contain $mem
                        }
                    }
                }
            }

            It 'Can read group XML fallback' {
                $groups = Get-GroupList -Offline
                $expectedMembers = @(
                    "Id"
                    "FriendlyName"
                    "Code"
                    "Created"
                    "Updated"
                    "Type"
                )
                $expectedMembersType = @(
                    "Id"
                    "FriendlyName"
                    "Code"
                    "Created"
                    "Updated"
                )
                $groups | Should -Not -BeNullOrEmpty
                foreach ($grp in $groups) {
                    $grp.PSObject.TypeNames | Should -Contain 'Deserialized.NordVPNGroup'
                    foreach ($mem in $expectedMembers) {
                        $grp.PSObject.Members.Name | Should -Contain $mem
                    }
                    foreach ($mem in $expectedMembersType) {
                        $grp.Type.PSObject.Members.Name | Should -Contain $mem
                    }
                }
            }

            It 'Can read technology XML fallback' {
                $techs = Get-TechnologyList -Offline
                $expectedMembers = @(
                    "Id"
                    "FriendlyName"
                    "Code"
                    "Created"
                    "Updated"
                )
                $techs | Should -Not -BeNullOrEmpty
                foreach ($tech in $techs) {
                    $tech.PSObject.TypeNames | Should -Contain 'Deserialized.NordVPNTechnology'
                    foreach ($mem in $expectedMembers) {
                        $tech.PSObject.Members.Name | Should -Contain $mem
                    }
                }
            }

        }

        Context 'Regeneration' {

            MockCountries
            Clear-CountryCache
            It 'Can regenerate country fallback file from cache' {
                Get-CountryList | Out-Null
                Remove-Item $CountryFallback -Force -ErrorAction SilentlyContinue
                $CountryFallback | Should -Not -Exist
                Get-CountryList -UpdateFallback | Out-Null
                $CountryFallback | Should -Exist
                Compare-Object (Import-Clixml $CountryFallback) `
                ($CountryListProc) | Should -BeNullOrEmpty
            }
            It 'Can regenerate country fallback file from API' {
                Remove-Item $CountryFallback -Force -ErrorAction SilentlyContinue
                $CountryFallback | Should -Not -Exist
                Clear-CountryCache
                Get-CountryList -UpdateFallback | Out-Null
                $CountryFallback | Should -Exist
                Compare-Object (Import-Clixml $CountryFallback) `
                ($CountryListProc) | Should -BeNullOrEmpty
            }

            MockGroups
            Clear-GroupCache
            It 'Can regenerate group fallback file from cache' {
                Get-GroupList | Out-Null
                Remove-Item $GroupFallback -Force -ErrorAction SilentlyContinue
                $GroupFallback | Should -Not -Exist
                Get-GroupList -UpdateFallback | Out-Null
                $GroupFallback | Should -Exist
                Compare-Object (Import-Clixml $GroupFallback) `
                ($GroupListProc) | Should -BeNullOrEmpty
            }
            It 'Can regenerate group fallback file from API' {
                Remove-Item $GroupFallback -Force -ErrorAction SilentlyContinue
                $GroupFallback | Should -Not -Exist
                Clear-GroupCache
                Get-GroupList -UpdateFallback | Out-Null
                $GroupFallback | Should -Exist
                Compare-Object (Import-Clixml $GroupFallback) `
                ($GroupListProc) | Should -BeNullOrEmpty
            }

            MockTechnologies
            Clear-TechnologyCache
            It 'Can regenerate technology fallback file from cache' {
                Get-TechnologyList | Out-Null
                Remove-Item $TechnologyFallback -Force -ErrorAction SilentlyContinue
                $TechnologyFallback | Should -Not -Exist
                Get-TechnologyList -UpdateFallback | Out-Null
                $TechnologyFallback | Should -Exist
                Compare-Object (Import-Clixml $TechnologyFallback) `
                ($TechnologyListProc) | Should -BeNullOrEmpty
            }
            It 'Can regenerate technology fallback file from API' {
                Remove-Item $TechnologyFallback -Force -ErrorAction SilentlyContinue
                $TechnologyFallback | Should -Not -Exist
                Clear-TechnologyCache
                Get-TechnologyList -UpdateFallback | Out-Null
                $TechnologyFallback | Should -Exist
                Compare-Object (Import-Clixml $TechnologyFallback) `
                ($TechnologyListProc) | Should -BeNullOrEmpty
            }

        }

    }

    Describe 'List handling' -Tag 'Offline', 'Server', 'Peripheral' {

        Context 'Peripheral API calls' {

            Clear-Cache
            Mock Invoke-RestMethod { }
            Mock Import-CliXml -Verifiable { }
            It 'Should use fallback if country API returns no data' {
                Get-CountryList | Out-Null
                Assert-VerifiableMock
            }

            It 'Should use fallback if group API returns no data' {
                Get-GroupList | Out-Null
                Assert-VerifiableMock
            }

            It 'Should use fallback if technology API returns no data' {
                Get-TechnologyList | Out-Null
                Assert-VerifiableMock
            }

            Mock Get-List -Verifiable { }
            $expectedErr = 'Invalid data returned by Get-List!'
            It 'Should throw exception when country list not returned' {
                { Get-CountryList } | Should -Throw $expectedErr
                Assert-VerifiableMock
            }

            It 'Should throw exception when group list not returned' {
                { Get-GroupList } | Should -Throw $expectedErr
                Assert-VerifiableMock
            }

            It 'Should throw exception when technology list not returned' {
                { Get-TechnologyList } | Should -Throw $expectedErr
                Assert-VerifiableMock
            }

        }

        Context 'General API calls' {

            Mock Invoke-RestMethod {
                throw [System.Net.WebException]::new("Pester Test", [System.Net.WebExceptionStatus]::Success)
            }

            $SETTINGS.OfflineMode = $false
            It 'Should handle web exception from API' {
                Get-List -URL "localhost" | Should -BeFalse
            }

            Mock Invoke-RestMethod {
                throw 'Pester Test'
            }

            It 'Should handle general exception accessing API' {
                Get-List -URL "localhost" | Should -BeFalse
            }

            $TestData = @((New-Guid).Guid)
            Mock Invoke-RestMethod { $TestData }
            It 'Should return proper list data if API call succeeded' {
                Get-List -URL "localhost" | Should -Be $TestData
            }
        }

        Context 'Server API calls' {

            Mock Invoke-RestMethod { }
            $SETTINGS.OfflineMode = $true
            It 'Get-List does not make API calls in Offline Mode' {
                Get-List -URL "localhost"
                Assert-MockCalled Invoke-RestMethod -Times 0
            }

            It 'Get-RecommendedList throws error in offline mode' {
                $expectedErr = 'Cannot use recommendations API when offline mode is enabled!'
                { Get-RecommendedList } | Should -Throw $expectedErr
            }
            $SETTINGS.OfflineMode = $false

            Mock Get-List { } -ParameterFilter {
                $URL -match $RecommendedMatchURL -or
                $URL -match $ServerMatchURL
            }

            It 'Get-RecommendedList throws error when no data returned from API' {
                { Get-RecommendedList } | Should -Throw $FailedList
            }

            It 'Get-ServerList throws error when no data returned from API' {
                { Get-ServerList } | Should -Throw $expectedErr
            }

            Mock Get-List { return $true } -ParameterFilter { $URL -match $RecommendedMatchURL }
            It 'Get-RecommendedList shows warning when no data was returned due to filters' {
                $expectedErr = 'No results found for search with filters'
                { Get-RecommendedList -Country US -Group legacy_standard -Technology l2tp `
                        -WarningAction:Stop } | Should -Throw $expectedErr
            }

            $expectedErr = 'Parameter set cannot be resolved'
            It 'Get-ServerList throws error when -Raw and -Offline are passed together' {
                { Get-ServerList -Offline -Raw } | Should -Throw $expectedErr
            }

            It 'Get-ServerList throws error when -Ofline and -UpdateFallback are passed together' {
                { Get-ServerList -Offline -UpdateFallback } | Should -Throw $expectedErr
            }

            It 'Get-ServerList throws error when -Raw and -UpdateFallback are passed together' {
                { Get-ServerList -Raw -UpdateFallback } | Should -Throw $expectedErr
            }

            $SETTINGS.OfflineMode = $true
            It 'Get-ServerList throws error when -UpdateFallback is passed in offline mode' {
                $expectedErr = 'You cannot use the -UpdateFallback switch in offline mode'
                { Get-ServerList -UpdateFallback } | Should -Throw $expectedErr
            }

            It 'Get-ServerList throws error when -Raw is passed in offline mode' {
                $expectedErr = 'You cannot use the -Raw switch in offline mode, or with -UpdateFallback.'
                { Get-ServerList -Raw } | Should -Throw $expectedErr
            }
            $SETTINGS.OfflineMode = $false

            MockServers
            MockCountries
            MockGroups
            MockTechnologies
            It 'Get-ServerList deletes uncompressed fallback file only when delete setting enabled' {
                Expand-Archive $ServersCompressed .\ -Force
                $ServerFallback | Should -Exist
                Get-ServerList | Out-Null
                $ServerFallback | Should -Exist
                $SETTINGS.DeleteServerFallbackAfterUse = $true
                Get-ServerList | Out-Null
                $ServerFallback | Should -Not -Exist
                $SETTINGS.DeleteServerFallbackAfterUse = $false
            }

            Mock ConvertFrom-ServerEntry { }
            It 'Get-Serverlist throws error when data processing fails' {
                { Get-ServerList } | Should -Throw $FailedConv
            }

        }

    }

    Describe 'Data outputs' -Tag 'Offline', 'Server', 'Peripheral' {

        Clear-Cache
        $countryTestFile = 'TestDrive:\countries_calc.xml'
        $cityTestFile = 'TestDrive:\cities_calc.xml'
        $cityoffTestFile = 'TestDrive:\cities_calc_off.xml'
        $cityFiltTestFile = 'TestDrive:\countries_calc_filt.xml'
        $groupTestFile = 'TestDrive:\groups_calc.xml'
        $technologyTestFile = 'TestDrive:\technologies_calc.xml'
        $serverTestFile = 'TestDrive:\servers_calc.xml'
        $recommendedTestFile = 'TestDrive:\recommended_calc.xml'

        Context 'Country, group, and technology lists' {

            MockCountries
            MockGroups
            MockTechnologies

            $ctryList = Get-CountryList
            It 'Produces country list data' {
                $ctryList | Export-Clixml $countryTestFile
                Compare-Object (Import-Clixml $countryTestFile) ($CountryListProc) `
                | Should -BeNullOrEmpty
            }

            It 'Produces city list data' {
                Get-CityList | Export-Clixml $cityTestFile
                Compare-Object (Import-Clixml $cityTestFile) ($CityListProc) `
                | Should -BeNullOrEmpty
            }

            It 'Produces city list data from country fallback' {
                Get-CityList -Offline | Export-Clixml $cityoffTestFile
                Compare-Object (Import-Clixml $cityoffTestFile) ($CityListProc) `
                | Should -BeNullOrEmpty
            }

            It 'Produces filtered city list when -Country is passed' {
                Get-CityList -Country US | Export-Clixml $cityFiltTestFile
                Compare-Object (Import-Clixml $cityFiltTestFile) `
                ($CityListProc | Where-Object CountryCode -eq 'US') `
                | Should -BeNullOrEmpty
            }

            $grpList = Get-GroupList
            It 'Produces group list data' {
                $grpList | Export-Clixml $groupTestFile
                Compare-Object (Import-Clixml $groupTestFile) ($GroupListProc) `
                | Should -BeNullOrEmpty
            }


            $techList = Get-TechnologyList
            It 'Produces technology list data' {
                $techList | Export-Clixml $technologyTestFile
                Compare-Object (Import-Clixml $technologyTestFile) ($TechnologyListProc) `
                | Should -BeNullOrEmpty
            }

            It 'Produces detached clone of country list via method member' {
                $ctryClone = $ctryList.Clone()
                Compare-Object $ctryList $ctryClone `
                | Should -BeNullOrEmpty
                $ctryList.Clear()
                Compare-Object $ctryList $ctryClone `
                | Should -Not -BeNullOrEmpty
                $ctryClone | Export-Clixml $countryTestFile
                Compare-Object (Import-Clixml $countryTestFile) ($CountryListProc) `
                | Should -BeNullOrEmpty
            }

            It 'Produces detached clone of group list via method member' {
                $grpClone = $grpList.Clone()
                Compare-Object $grpList $grpClone `
                | Should -BeNullOrEmpty
                $grpList.Clear()
                Compare-Object $grpList $grpClone `
                | Should -Not -BeNullOrEmpty
                $grpClone | Export-Clixml $groupTestFile
                Compare-Object (Import-Clixml $groupTestFile) ($GroupListProc) `
                | Should -BeNullOrEmpty
            }

            It 'Produces detached clone of Technology list via method member' {
                $techClone = $techList.Clone()
                Compare-Object $techList $techClone `
                | Should -BeNullOrEmpty
                $techList.Clear()
                Compare-Object $techList $techClone `
                | Should -Not -BeNullOrEmpty
                $techClone | Export-Clixml $TechnologyTestFile
                Compare-Object (Import-Clixml $TechnologyTestFile) ($TechnologyListProc) `
                | Should -BeNullOrEmpty
            }

        }

        Context 'Server lists' {

            MockCountries
            MockGroups
            MockTechnologies
            MockServers
            Clear-Cache

            $svrList = Get-ServerList
            It 'Produces server list data' {
                $svrList | Export-Clixml $serverTestFile
                Compare-Object (Import-Clixml $serverTestFile) ($ServerListProc) `
                | Should -BeNullOrEmpty
            }

            It 'Produces recommended server list data' {
                Get-RecommendedList | Export-Clixml $recommendedTestFile
                Compare-Object (Import-Clixml $recommendedTestFile) ($ServerListProc) `
                | Should -BeNullOrEmpty
            }

            It 'Produces recommended list data with filters' {
                Get-RecommendedList -Country US -Group legacy_standard -Technology openvpn_udp `
                | Export-Clixml $recommendedTestFile
                Compare-Object (Import-Clixml $recommendedTestFile) ($RecommendedListProc) `
                | Should -BeNullOrEmpty
            }

            It 'Produces detached clone of server list via method member' {
                $svrClone = $svrList.Clone()
                Compare-Object $svrList $svrClone `
                | Should -BeNullOrEmpty
                $svrList.Clear()
                $svrList | Should -BeNullOrEmpty
                $svrClone | Export-Clixml $serverTestFile
                Compare-Object (Import-Clixml $serverTestFile) ($ServerListProc) `
                | Should -BeNullOrEmpty
            }

            It 'Produces raw recommended RESTful API data on request' {
                Get-RecommendedList -Raw | Export-Clixml $recommendedTestFile
                Compare-Object (Import-Clixml $recommendedTestFile) ($ServerListRaw) `
                | Should -BeNullOrEmpty
            }

            It 'Produces raw RESTful API data on request' {
                Get-ServerList -Raw | Export-Clixml $serverTestFile
                Compare-Object (Import-Clixml $serverTestFile) ($ServerListRaw) `
                | Should -BeNullOrEmpty
            }

        }

    }

    Describe 'Module settings' -Tag 'Offline', 'Settings' {

        Context 'Retrieval' {

            Reset-Module -Force
            It 'Can retrieve internal values' {
                foreach ($setting in $DefaultSettings.Keys) {
                    Get-ModuleSetting $setting | Should -Be $SETTINGS.$setting
                }
            }

            It 'Can retrieve default values' {
                foreach ($setting in $DefaultSettings.Keys) {
                    Get-ModuleSetting $setting -Default | Should -Be $DefaultSettings.$setting[1]
                }
            }

            It 'Can retrieve required value types' {
                foreach ($setting in $DefaultSettings.Keys) {
                    Get-ModuleSetting $setting -Type | Should -Be $DefaultSettings.$setting[0]
                }
            }

            It 'Can retrieve all values on request' {
                Compare-Object (Get-ModuleSetting) $DefaultSettings | Should -BeNullOrEmpty
            }

            It 'Throws error when passed invalid setting name' {
                { Get-ModuleSetting -Name (New-Guid).Guid } | Should -Throw
            }
        }

        Context 'Modification' {

            $targetSettings = [pscustomobject]@{
                CountryCacheLifetime         = [UInt32](Get-Random -Min 1 -Max 999)
                GroupCacheLifetime           = [UInt32](Get-Random -Min 1 -Max 999)
                TechnologyCacheLifetime      = [UInt32](Get-Random -Min 1 -Max 999)
                OfflineMode                  = $true, $false | Get-Random
                DeleteServerFallbackAfterUse = $true, $false | Get-Random
            }

            Reset-Module -Force
            foreach ($setting in $targetSettings.PSObject.Properties.Name) {
                It "Can modify the internal state of setting: $setting" {
                    $SETTINGS.$setting | Should -Be $DefaultSettings.$setting[1]
                    Set-ModuleSetting -Name $setting -Value $targetSettings.$setting -Force
                    $SETTINGS.$setting | Should -Be $targetSettings.$setting
                }
            }

            It 'Writes out any changes to settings file' {
                Compare-Object (Get-Content .\NordVPN-Servers.settings.json | ConvertFrom-Json) `
                ($targetSettings) | Should -BeNullOrEmpty
            }

            foreach ($setting in $targetSettings.PSObject.Properties.Name) {
                It "Can reset the internal state of setting: $setting" {
                    Set-ModuleSetting -Name $setting -Force
                    $SETTINGS.$setting | Should -Be $DefaultSettings.$setting[1]
                }
            }

            It "Accepts integers for boolean properties" {
                { Set-ModuleSetting -Name OfflineMode -Value 0 } | Should -Not -Throw
                { Set-ModuleSetting -Name DeleteServerFallbackAfterUse -Value 0 } | Should -Not -Throw
            }

            $badTypes = @{
                CountryCacheLifetime    = "Not a number"
                GroupCacheLifetime      = @{ }
                TechnologyCacheLifetime = @("Definitely not a number")
            }
            It "Throws error on incorrect data type" {
                foreach ($setting in $badTypes.Keys) {
                    { Set-ModuleSetting -Name $setting -Value $badTypes.$setting } `
                    | Should -Throw 'does not match required type:'
                }
            }

            It 'Throws error when passed invalid setting name' {
                { Set-ModuleSetting -Name (New-Guid).Guid -Value (Get-Random) } `
                | Should -Throw
            }
        }

        Context 'Loading in' {

            It 'Can generate new settings profile/file if deleted' {
                Remove-Item $SettingsFile -Force -ErrorAction SilentlyContinue
                $SettingsFile | Should -Not -Exist
                LoadSettings
                $SettingsFile | Should -Exist
                $newSettings = Get-Content $SettingsFile | ConvertFrom-Json
                foreach ($setting in $DefaultSettings.Keys) {
                    $newSettings.$setting | Should -Be $DefaultSettings.$setting[1]
                    $SETTINGS.$setting | Should -Be $DefaultSettings.$setting[1]
                }
            }

            It 'Skips invalid settings not defined in DefaultSettings' {
                $settingData = Get-Content $SettingsFile | ConvertFrom-Json
                $randName = (New-Guid).Guid
                $settingData | Add-Member -NotePropertyName $randName -NotePropertyValue 0
                $SettingData | ConvertTo-Json | Set-Content $SettingsFile -Force
                LoadSettings
                $SETTINGS.$randName | Should -BeNullOrEmpty
            }

        }

    }

    Describe 'Dynamic parameters' -Tag 'Offline', 'Param' {

        Context 'Generation' {

            function TestParamSet($p, $pOff, $name, $type, $help, $set) {
                Compare-Object $p $pOff | Should -BeNullOrEmpty
                $p | Should -BeOfType [System.Management.Automation.RuntimeDefinedParameter]
                $p.Name | Should -Be $name
                $p.ParameterType | Should -Be $type
                foreach ($attrib in ($p.Attributes)) {
                    switch ($attrib.TypeId) {
                        [System.Management.Automation.ParameterAttribute] {
                            $attrib.HelpMessage | Should -Be $help
                            $pSets | Should -Contain $attrib.ParameterSet
                        }
                        [System.Management.Automation.ValidateSetAttribute] {
                            $attrib.ValidValues | Should -Be $set
                        }
                    }
                }
            }

            $paramSets = @("ParamSet1", "ParamSet2")
            $expectedName = 'Country'
            $expectedType = [String]
            $expectedHelp = 'Please enter a 2-digit ISO 3166-1 country code ' `
                + 'e.g GB (run Get-NordVPNCountryList for reference)'
            $expectedSet = $CountryListProc | Select-Object Code
            MockCountries
            It 'Can provide dynamic country codes' {
                $param = Get-CountryDynamicParam 0 $paramSets -Offline:$false
                $paramOffline = Get-CountryDynamicParam 0 $paramSets -Offline:$true
                TestParamSet $param $paramOffline $expectedName $expectedType $expectedHelp $expectedSet
            }

            Mock Get-CountryList { }
            It 'Can provide dynamic country codes when country list unavailable' {
                $param = Get-CountryDynamicParam 0 $paramSets -Offline:$false
                $paramOffline = Get-CountryDynamicParam 0 $paramSets -Offline:$true
                TestParamSet $param $paramOffline $expectedName $expectedType $expectedHelp $expectedSet
            }

            $expectedName = 'Group'
            $expectedType = [String]
            $expectedHelp = 'Please enter a group code e.g. legacy_standard ' `
                + '(run Get-NordVPNGroupList for reference)'
            $expectedSet = $GroupListProc | Select-Object Code
            MockGroups
            It 'Can provide dynamic group codes' {
                $param = Get-GroupDynamicParam 0 $paramSets -Offline:$false
                $paramOffline = Get-GroupDynamicParam 0 $paramSets -Offline:$true
                TestParamSet $param $paramOffline $expectedName $expectedType $expectedHelp $expectedSet
            }

            Mock Get-GroupList { }
            It 'Can provide dynamic group codes when group list unavailable' {
                $param = Get-GroupDynamicParam 0 $paramSets -Offline:$false
                $paramOffline = Get-GroupDynamicParam 0 $paramSets -Offline:$true
                TestParamSet $param $paramOffline $expectedName $expectedType $expectedHelp $expectedSet
            }

            $expectedName = 'Technology'
            $expectedType = [String]
            $expectedHelp = 'Please enter a technology code e.g. openvpn_udp ' `
                + '(run Get-NordVPNTechnologyList for reference)'
            $expectedSet = $TechnologyListProc | Select-Object Code
            MockTechnologies
            It 'Can provide dynamic technology codes' {
                $param = Get-TechnologyDynamicParam 0 $paramSets -Offline:$false
                $paramOffline = Get-TechnologyDynamicParam 0 $paramSets -Offline:$true
                TestParamSet $param $paramOffline $expectedName $expectedType $expectedHelp $expectedSet
            }

            Mock Get-TechnologyList { }
            It 'Can provide dynamic technology codes when technology list unavailable' {
                $param = Get-TechnologyDynamicParam 0 $paramSets -Offline:$false
                $paramOffline = Get-TechnologyDynamicParam 0 $paramSets -Offline:$true
                TestParamSet $param $paramOffline $expectedName $expectedType $expectedHelp $expectedSet
            }

        }

    }

    Describe 'Online Tests' -Tag 'Online', 'Integration', 'Server', 'Peripheral' {

        $testConnect = Invoke-RestMethod 'https://api.nordvpn.com/v1/servers?limit=10' -ErrorAction Stop
        It 'Test network connection before online tests' {
            $testConnect | Should -HaveCount 10
        }

        Reset-Module -Force

        $ListBaseType = 'System.Collections.ArrayList'
        $ItemType = 'NordVPNItem'
        $DatedType = 'NordVPNDatedItem'

        function TestServer($ServerList, $NumServers) {
            It 'Can download and parse server list' {
                $ServerList.GetType().FullName | Should -Be 'NordVPNServerList'
                $ServerList.GetType().BaseType.FullName | Should -Be $ListBaseType
                $ServerList | Should -HaveCount $NumServers
            }

            for ($i = 1; $i -le [math]::Min($TestSamples, $ServerList.Count); $i++) {
                $randServer = $ServerList | Get-Random
                It "Contains correct server members: random sample #$i" {
                    $expectedMembers = @(
                        'City', 'Code', 'Country', 'Created', 'FriendlyName', 'Groups', 'Hostname', 'Id',
                        'IPs', 'Latitude', 'Load', 'Locations', 'Longitude', 'PrimaryIP', 'Services',
                        'Specifications', 'Status', 'Technologies', 'Updated'
                    )
                    $randServer.GetType().FullName | Should -Be 'NordVPNServer'
                    $randServer.GetType().BaseType.FullName | Should -Be $DatedType
                    Compare-Object ($randServer | Get-Member -Type Properties).Name `
                        $expectedMembers | Should -BeNullOrEmpty
                }

                It '    Each server contains correct country member' {
                    $expectedMembers = @('Id', 'FriendlyName', 'Code', 'Cities')
                    $randServer.Country.GetType().FullName | Should -Be 'NordVPNCountry'
                    $randServer.Country.GetType().BaseType.FullName | Should -Be $ItemType
                    Compare-Object ($randServer.Country | Get-Member -Type Properties).Name `
                        $expectedMembers | Should -BeNullOrEmpty
                }

                It '    Each server contains correct city member' {
                    $expectedMembers = @(
                        'Id', 'FriendlyName', 'Code', 'CountryCode', 'Latitude', 'Longitude', 'HubScore'
                    )
                    $randServer.City.GetType().FullName | Should -Be 'NordVPNCity'
                    $randServer.City.GetType().BaseType.FullName | Should -Be $ItemType
                    Compare-Object ($randServer.City | Get-Member -Type Properties).Name `
                        $expectedMembers | Should -BeNullOrEmpty
                }

                It '    Each server contains correct location members' {
                    $expectedMembers = @(
                        'CityCode', 'CountryCode', 'Created', 'Id', 'Latitude', 'Longitude', 'Updated'
                    )
                    $randServer.Locations.GetType().FullName | Should -Be 'NordVPNLocationList'
                    $randServer.Locations.GetType().BaseType.FullName | Should -Be $ListBaseType
                    $randServer.Locations | ForEach-Object {
                        $_.GetType().FullName | Should -Be 'NordVPNLocation'
                        $_.GetType().BaseType.FullName | Should -Be 'System.Object'
                        Compare-Object ($_ | Get-Member -Type Properties).Name `
                            $expectedMembers | Should -BeNullOrEmpty
                    }
                }

                It '    Each server contains correct service members' {
                    $expectedMembers = @(
                        'Id', 'FriendlyName', 'Code', 'Created', 'Updated'
                    )
                    $randServer.Services.GetType().FullName | Should -Be 'NordVPNServiceList'
                    $randServer.Services.GetType().BaseType.FullName | Should -Be $ListBaseType
                    $randServer.Services | ForEach-Object {
                        $_.GetType().FullName | Should -Be 'NordVPNService'
                        $_.GetType().BaseType.FullName | Should -Be $DatedType
                        Compare-Object ($_ | Get-Member -Type Properties).Name `
                            $expectedMembers | Should -BeNullOrEmpty
                    }
                }

                It '    Each server contains correct specification members' {
                    $expectedMembers = @(
                        'Id', 'FriendlyName', 'Code', 'Values'
                    )
                    $randServer.Specifications.GetType().FullName | Should -Be 'NordVPNSpecificationList'
                    $randServer.Specifications.GetType().BaseType.FullName | Should -Be $ListBaseType
                    $randServer.Specifications | ForEach-Object {
                        $_.GetType().FullName | Should -Be 'NordVPNSpecification'
                        $_.GetType().BaseType.FullName | Should -Be $ItemType
                        Compare-Object ($_ | Get-Member -Type Properties).Name `
                            $expectedMembers | Should -BeNullOrEmpty
                    }
                }

                It '    Each server contains correct group members' {
                    $expectedMembers = @(
                        'Id', 'FriendlyName', 'Code', 'Created', 'Updated', 'Type'
                    )
                    $randServer.Groups.GetType().FullName | Should -Be 'NordVPNGroupList'
                    $randServer.Groups.GetType().BaseType.FullName | Should -Be $ListBaseType
                    $randServer.Groups | ForEach-Object {
                        $_.GetType().FullName | Should -Be 'NordVPNGroup'
                        $_.GetType().BaseType.FullName | Should -Be $DatedType
                        Compare-Object ($_ | Get-Member -Type Properties).Name `
                            $expectedMembers | Should -BeNullOrEmpty
                    }
                }

                It '    Each server contains correct technology members' {
                    $expectedMembers = @(
                        'Id', 'FriendlyName', 'Code', 'Created', 'Updated', 'Status'
                    )
                    $randServer.Technologies.GetType().FullName | Should -Be 'NordVPNTechnologyList'
                    $randServer.Technologies.GetType().BaseType.FullName | Should -Be $ListBaseType
                    $randServer.Technologies | ForEach-Object {
                        $_.GetType().FullName | Should -Be 'NordVPNTechnology'
                        $_.GetType().BaseType.FullName | Should -Be $DatedType
                        Compare-Object ($_ | Get-Member -Type Properties).Name `
                            $expectedMembers | Should -BeNullOrEmpty
                    }
                }

                It '    Each server contains correct IP address members' {
                    $expectedMembers = @(
                        'Id', 'InstanceID', 'Version', 'Created', 'Updated', 'IPAddress'
                    )
                    $randServer.IPs.GetType().FullName | Should -Be 'NordVPNIPAddressList'
                    $randServer.IPs.GetType().BaseType.FullName | Should -Be $ListBaseType
                    $randServer.IPs | ForEach-Object {
                        $_.GetType().FullName | Should -Be 'NordVPNIPAddress'
                        $_.GetType().BaseType.FullName | Should -Be 'System.Object'
                        Compare-Object ($_ | Get-Member -Type Properties).Name `
                            $expectedMembers | Should -BeNullOrEmpty
                    }
                }
            }
        }

        Context 'Country API' {
            Clear-CountryCache

            $CountryList = Get-CountryList
            It 'Can download and parse country list' {
                $CountryList.GetType().FullName | Should -Be 'NordVPNCountryList'
                $CountryList.GetType().BaseType.FullName | Should -Be $ListBaseType
                $CountryList.Count | Should -BeGreaterThan 50
            }

            for ($i = 1; $i -le [math]::Min($TestSamples, $CountryList.Count); $i++) {
                $randCountry = $CountryList | Get-Random
                It "Contains correct country members: random sample #$i" {
                    $expectedMembers = @('Id', 'FriendlyName', 'Code', 'Cities')
                    $randCountry.GetType().FullName | Should -Be 'NordVPNCountry'
                    $randCountry.GetType().BaseType.FullName | Should -Be $ItemType
                    Compare-Object ($randCountry | Get-Member -Type Properties).Name `
                        $expectedMembers | Should -BeNullOrEmpty
                }

                It '    Each country contains correct city members' {
                    $expectedMembers = @(
                        'Id', 'FriendlyName', 'Code', 'CountryCode', 'Latitude', 'Longitude', 'HubScore'
                    )
                    $randCountry.Cities.GetType().FullName | Should -Be 'NordVPNCityList'
                    $randCountry.Cities.GetType().BaseType.FullName | Should -Be $ListBaseType
                    $randCountry.Cities | ForEach-Object {
                        $_.GetType().FullName | Should -Be 'NordVPNCity'
                        $_.GetType().BaseType.FullName | Should -Be $ItemType
                        Compare-Object ($_ | Get-Member -Type Properties).Name `
                            $expectedMembers | Should -BeNullOrEmpty
                    }
                }
            }

        }

        Context 'City API' {
            Clear-CountryCache

            $CityList = Get-CityList
            It 'Can download and parse city list' {
                $CityList.GetType().FullName | Should -Be 'NordVPNCityList'
                $CityList.GetType().BaseType.FullName | Should -Be $ListBaseType
                $CityList.Count | Should -BeGreaterThan 50
            }

            for ($i = 1; $i -le [math]::Min($TestSamples, $CityList.Count); $i++) {
                $randCity = $CityList | Get-Random
                It "Contains correct city members: random sample #$i" {
                    $expectedMembers = @(
                        'Id', 'FriendlyName', 'Code', 'CountryCode', 'Latitude', 'Longitude', 'HubScore'
                    )
                    $randCity.GetType().FullName | Should -Be 'NordVPNCity'
                    $randCity.GetType().BaseType.FullName | Should -Be $ItemType
                    Compare-Object ($randCity | Get-Member -Type Properties).Name `
                        $expectedMembers | Should -BeNullOrEmpty
                }
            }

        }

        Context 'Group API' {
            Clear-GroupCache

            $GroupList = Get-GroupList
            It 'Can download and parse group list' {
                $GroupList.GetType().FullName | Should -Be 'NordVPNGroupList'
                $GroupList.GetType().BaseType.FullName | Should -Be $ListBaseType
                $GroupList.Count | Should -BeGreaterThan 5
            }

            for ($i = 1; $i -le [math]::Min($TestSamples, $GroupList.Count); $i++) {
                $randGroup = $GroupList | Get-Random
                It "Contains correct group members: random sample #$i" {
                    $expectedMembers = @('Id', 'FriendlyName', 'Code', 'Created', 'Updated', 'Type')
                    $randGroup.GetType().FullName | Should -Be 'NordVPNGroup'
                    $randGroup.GetType().BaseType.FullName | Should -Be $DatedType
                    Compare-Object ($randGroup | Get-Member -Type Properties).Name `
                        $expectedMembers | Should -BeNullOrEmpty
                }

                It '    Each group contains correct type members' {
                    $expectedMembers = @('Id', 'FriendlyName', 'Code', 'Created', 'Updated')
                    $randGroup.Type.GetType().FullName | Should -Be $DatedType
                    $randGroup.Type.GetType().BaseType.FullName | Should -Be $ItemType
                    Compare-Object ($randGroup.Type | Get-Member -Type Properties).Name `
                        $expectedMembers | Should -BeNullOrEmpty
                }
            }
        }

        Context 'Technology API' {
            Clear-TechnologyCache

            $TechnologyList = Get-TechnologyList
            It 'Can download and parse technology list' {
                $TechnologyList.GetType().FullName | Should -Be 'NordVPNTechnologyList'
                $TechnologyList.GetType().BaseType.FullName | Should -Be $ListBaseType
                $TechnologyList.Count | Should -BeGreaterThan 10
            }

            for ($i = 1; $i -le [math]::Min($TestSamples, $TechnologyList.Count); $i++) {
                $randTechnology = $TechnologyList | Get-Random
                It "Contains correct technology members: random sample #$i" {
                    $expectedMembers = @('Id', 'FriendlyName', 'Code', 'Created', 'Updated', 'Status')
                    $randTechnology.GetType().FullName | Should -Be 'NordVPNTechnology'
                    $randTechnology.GetType().BaseType.FullName | Should -Be $DatedType
                    Compare-Object ($randTechnology | Get-Member -Type Properties).Name `
                        $expectedMembers | Should -BeNullOrEmpty
                }
            }

        }

        Context 'Raw Server API' {
            Clear-Cache
            $RawList = Get-ServerList -First 1000

            TestServer $RawList 1000

            It 'Can return raw NordVPN API data' {
                Compare-Object (Get-ServerList -First 200 -Raw) `
                (Invoke-RestMethod 'https://api.nordvpn.com/v1/servers?limit=200') `
                | Should -BeNullOrEmpty
            }

        }

        Context 'Recommended Server API' {

            $RecommendedList = Get-RecommendedList -Limit 1000

            TestServer $RecommendedList 1000

            It 'Can filter by country' {
                Get-RecommendedList -Country GB -Limit 200 `
                | Where-Object { $_.Country.Code -ne 'GB' } `
                | Should -BeNullOrEmpty
            }

            It 'Can filter by technology' {
                Get-RecommendedList -Technology ikev2 -Limit 200 `
                | Where-Object { $_.Technologies.Code -notcontains 'ikev2' } `
                | Should -BeNullOrEmpty
            }

            It 'Can filter by group' {
                Get-RecommendedList -Group asia_pacific -Limit 200 `
                | Where-Object { $_.Groups.Code -notcontains 'asia_pacific' } `
                | Should -BeNullOrEmpty
            }

            It 'Can return raw NordVPN API data' {
                Compare-Object (Get-RecommendedList -Limit 200 -Raw) `
                (Invoke-RestMethod 'https://api.nordvpn.com/v1/servers/recommendations?limit=200') `
                | Should -BeNullOrEmpty
            }

        }

    }

}

Write-Information "Reacahed end of test $TestID" -InformationAction Continue

Pop-Location
