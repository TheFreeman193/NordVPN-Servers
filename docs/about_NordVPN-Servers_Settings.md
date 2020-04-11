# About NordVPN-Servers Settings
## about_NordVPN-Servers_Settings

# SHORT DESCRIPTION
Describes the persistent settings of the NordVPN-Servers PowerShell module.

# LONG DESCRIPTION
The NordVPN-Servers module utilises persistent settings stored in the module
root, as JSON file `NordVPN-Servers.settings.json`. The settings can be
changed in this file directly, or using the command
`Set-NordVPNModuleSetting [-Name] <string> [[-Value] <object>]`. The currently
available settings are described below:

- `CountryCacheLifetime` How long the country cache remains valid after being
  downloaded, in seconds. After this time, the cache is redownloaded the next
  time it is needed.

- `GroupCacheLifetime` How long the group cache remains valid after being
  downloaded, in seconds. After this time, the cache is redownloaded the next
  time it is needed.

- `TechnologyCacheLifetime` How long the technology cache remains valid after
  being downloaded, in seconds. After this time, the cache is redownloaded the
  next time it is needed.

- `OfflineMode` When this setting is enabled, the country, group, and
  technology lists are retrieved from the fallback files in the module root
  directory. The `Get-NordVPNServerList` function also uses local fallback files,
  and `Get-NordVPNRecommendedList` is unavailable in this mode. The files used
  are described later in this topic.

- `DeleteServerFallbackAfterUse` When `Get-NordVPNServerList` is used with the
  `-Offline` switch or when *OfflineMode* is enabled, the compressed server
  list is expanded and read from. If this setting is disabled (default) then
  the expanded fallback file is kept when the function has completed. If
  enabled, the file is deleted and must be re-expanded on the next call. This
  option exists for scenarios where physical disk space is a limitation such as
  on thin clients.

## FALLBACK FILES
The fallback files are stored in the module directory and contain pre-processed
copies of the data available from the NordVPN web API. They are stored in CLI
XML format.

|                   Filename | Approx. size |
| -------------------------: | :----------- |
|    `NordVPN_Countries.xml` | 115 KB       |
|       `NordVPN_Groups.xml` | 18 KB        |
| `NordVPN_Technologies.xml` | 12 KB        |
|      `NordVPN_Servers.xml` | 50 MB        |
|  `NordVPN_Servers.xml.zip` | 2.7 MB       |

The final item in the list is the compressed version of the server fallback file.

These files can be updated using the `-UpdateFallback` switch parameter in the
functions `Get-NordVPNCountryList`, `Get-NordVPNGroupList`,
`Get-NordVPNTechnologyList`, and `Get-NordVPNServerList`. The files are utilised
when the *OfflineMode* setting is enabled, or when the `-Offline` switch
parameter is passed to one of the four functions above.

# EXAMPLES
The `Get-NordVPNModuleSetting` function is used to retrieve the values of one
or all module settings. Not passing any parameters displays the current value
of all settings. The function can also display the required type and default
value of a setting. See the [Get-NordVPNModuleSetting](.\Get-NordVPNModuleSetting.md)
help topic for full usage.

```powershell
Get-NordVPNModuleSetting

Name                           Value
----                           -----
TechnologyCacheLifetime        600
DeleteServerFallbackAfterUse   False
CountryCacheLifetime           600
OfflineMode                    False
GroupCacheLifetime             600
```

The `Set-NordVPNModuleSetting` function is used to set the values of a module
setting. The function will also reset a setting to default if the `-Value`
parameter is omitted. See the [Set-NordVPNModuleSetting](.\Set-NordVPNModuleSetting.md)
help topic for full usage.

```powershell
# Sets the country cache lifetime to 5 minutes.
Set-NordVPNModuleSetting CountryCacheLifetime 300

# Sets the country cache lifetime back to default
Set-NordVPNModuleSetting CountryCacheLifetime

Reset setting to default
This will reset 'CountryCacheLifetime' to its default of 600. Are you sure?
[Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"): y
```

The `Reset-NordVPNModule` function is used to reset the values of a
module setting to its default value. See the
[Reset-NordVPNModule](.\Reset-NordVPNModule.md) help topic for
full usage.

```powershell
Get-NordVPNModuleSetting

Name                           Value
----                           -----
TechnologyCacheLifetime        500
DeleteServerFallbackAfterUse   True
CountryCacheLifetime           300
OfflineMode                    False
GroupCacheLifetime             400

# Resets all module settings back to default
Reset-NordVPNModule

Get-NordVPNModuleSetting

Name                           Value
----                           -----
TechnologyCacheLifetime        600
DeleteServerFallbackAfterUse   False
CountryCacheLifetime           600
OfflineMode                    False
GroupCacheLifetime             600
```

# NOTE
Deleting the `NordVPN-Servers.settings.json` file will result in the module
settings being reverted to their defaults.

# SEE ALSO

- [Set-NordVPNModuleSetting](./Set-NordVPNModuleSetting.md)
- [Get-NordVPNModuleSetting](./Get-NordVPNModuleSetting.md)
- [Reset-NordVPNModule](./Reset-NordVPNModule.md)
- **[Module Homepage](../README.md)**
- **[Help Index](./INDEX.md)**

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/about_NordVPN-Servers_Settings.md)

# KEYWORDS

- about_NordVPNServers_Settings
- about_NordVPNServers_Configuration
- about_NordVPNServers_Setup
- about_NordVPNServers
