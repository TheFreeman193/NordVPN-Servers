@{
RootModule = 'NordVPN-Servers.psm1'
ModuleVersion = '0.1.27'
CompatiblePSEditions = @('Desktop', 'Core')
GUID = '49e3429a-230b-4bc4-81bf-eaa6f0bd2927'
Author = 'Nicholas Bissell'
CompanyName = 'TheFreeman193'
Copyright = '(c) 2020 Nicholas Bissell. MIT License.'
Description = 'A cross-platform PowerShell module for interacting with the NordVPN API.'
PowerShellVersion = '5.1'
ClrVersion = '4.0'
ProcessorArchitecture = 'None'
FunctionsToExport = @(
    'Set-ModuleSetting'
    'Get-ModuleSetting'
    'Reset-ModuleSettings'
    'Clear-CountryCache'
    'Clear-GroupCache'
    'Clear-TechnologyCache'
    'Clear-Caches'
    'Get-Countries'
    'Get-Groups'
    'Get-Technologies'
    'Get-Cities'
    'Show-Countries'
    'Show-Groups'
    'Show-Technologies'
    'Show-Cities'
    'Get-Servers'
    'Get-RecommendedServers'
)
VariablesToExport = @()
AliasesToExport = @()
FileList = @(
    '.\COPYING'
    '.\LICENSE.md'
    '.\NordVPN_Countries.xml'
    '.\NordVPN_Groups.xml'
    '.\NordVPN_Technologies.xml'
    '.\NordVPN-Servers.ico'
    '.\NordVPN-Servers.png'
    '.\NordVPN-Servers.settings.json'
    '.\README.md'
)
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('NordVPN','Servers','Find','List','VPN', 'API-Client', 'NordVPN-Site', 'Countries', 'Cities', 'Countries-Cities', 'Groups', 'Technologies', 'VPN-Manager', 'Search')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/TheFreeman193/NordVPN-Servers/blob/master/LICENSE.md'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/TheFreeman193/NordVPN-Servers'

        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/TheFreeman193/NordVPN-Servers/master/NordVPN-Servers.png'

        # ReleaseNotes of this module
        ReleaseNotes = @'
== 0.1.27 - 6th April 2020
- First alpha
'@

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/TheFreeman193/NordVPN-Servers/blob/master/README.md'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
DefaultCommandPrefix = 'NordVPN'

}
