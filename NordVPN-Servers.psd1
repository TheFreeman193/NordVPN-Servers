@{
RootModule = 'NordVPN-Servers.psm1'
ModuleVersion = '0.4.0'
CompatiblePSEditions = @('Desktop', 'Core')
GUID = '49e3429a-230b-4bc4-81bf-eaa6f0bd2927'
Author = 'Nicholas Bissell'
CompanyName = 'TheFreeman193'
Copyright = '(c) 2020 Nicholas Bissell (TheFreeman193). MIT License.'
Description = 'A cross-platform PowerShell module for interacting with the NordVPN API.'
PowerShellVersion = '5.1'
ClrVersion = '4.0'
ProcessorArchitecture = 'None'
RequiredModules = @(
    @{
        ModuleName = "Microsoft.PowerShell.Archive"
        ModuleVersion="1.0.1.0"
        GUID="eb74e8da-9ae2-482a-a648-e96550fb8733"
    }
)
FunctionsToExport = @(
    'Set-ModuleSetting'
    'Get-ModuleSetting'
    'Reset-Module'
    'Clear-CountryCache'
    'Clear-GroupCache'
    'Clear-TechnologyCache'
    'Clear-Cache'
    'Get-CountryList'
    'Get-GroupList'
    'Get-TechnologyList'
    'Get-CityList'
    'Show-CountryList'
    'Show-GroupList'
    'Show-TechnologyList'
    'Show-CityList'
    'Get-ServerList'
    'Get-RecommendedList'
)
VariablesToExport = @()
AliasesToExport = @()
FileList = @(
    '.\COPYING'
    '.\LICENSE.md'
    '.\NordVPN_Countries.xml'
    '.\NordVPN_Groups.xml'
    '.\NordVPN_Technologies.xml'
    '.\NordVPN_Servers.xml.zip'
    '.\NordVPN-Servers.ico'
    '.\NordVPN-Servers.png'
    '.\NordVPN-Servers.settings.json'
    '.\README.md'
)
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('PSEdition_Desktop', 'PSEdition_Core', 'Windows', 'Linux', 'MacOS', 'NordVPN', 'API',
                'NordVPN-API', 'NordVPN-Servers', 'VPN', 'API-Client', 'NordVPN-Site', 'Countries',
                'Cities', 'Groups', 'Technologies', 'VPN-Manager', 'Search'
        )

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/TheFreeman193/NordVPN-Servers/blob/master/LICENSE.md'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/TheFreeman193/NordVPN-Servers'

        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/TheFreeman193/NordVPN-Servers/master/NordVPN-Servers.png'

        # ReleaseNotes of this module
        ReleaseNotes = @'
## 0.4.0 - 15th April 2020

- Add hardcoded country, group, and technology codes as last-line
  fallbacks
- Fix issue where -Force switch does not suppress prompt for
  Set-NordVPNModuleSetting/Reset-NordVPNModule
- Change handling of parameter sets in Get-NordVPNModuleSetting
- Fix issue where settings file is not written if read-only (+R)
  attribute set
- Change debug, error, and warning messages for internal function
  Get-List
- Change exception handling in internal function Get-List
- Change handling of unexpected Get-List outputs in
  Get-(Country,Group,Technology)List functions
- Change warning for fallback file usage in online mode to verbose
  message
- Change calls to Write-Host in Show-* functions to Write-Output and
  increase contrast (Grey => White)
- Add invalid entry handling for settings import from JSON
- Fix issue where -First parameter fails to resolve in
  Get-NordVPNServerList
- Fix issue where Get-NordVPNServerList filters do not handle single-
  server outputs (PS unwrapping)
- Fix issue where PSCX definition of Expand-Archive was interfering
  with Pester tests.
- Update manifest tags, copyright
- Add -Offline switch parameter to Show-* Functions
- Fix some incorrect logic when handling -Raw switch for
  Get-NordVPNServerList
- Add -Offline switch parameter to internal DynamicParam providers, to
  prevent API calls when Get-* or Show-* functions are called with
  -Offline
- Tidy up some inconsistent code (w/o functional changes)

## 0.2.1 - 7th April 2020

- Update version to alpha 0.2
- Add -Offline parameter to Get-NordVPNCityList
- Update manifest to include zipped server fallback
- Remove some obsolete code
- Convert most hashtables to custom objects for easier downstream
  processing
- Add explicit typecasts where missing
- Remove surplus write-progress calls
- Tidy up code / consistency
- Force UTF-8 for XML export
- Fix some non-terminating error conditions

## 0.1.27 - 6th April 2020

- First alpha on GitHub
'@

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        RequireLicenseAcceptance = $false

        # External dependent modules of this module
        ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/TheFreeman193/NordVPN-Servers/blob/master/README.md'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
DefaultCommandPrefix = 'NordVPN'

}
