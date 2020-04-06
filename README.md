# NordVPN-Servers
![GitHub](https://img.shields.io/github/license/TheFreeman193/NordVPN-Servers)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/TheFreeman193/NordVPN-Servers)
![Platforms](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-orange)
![PowerShell](https://img.shields.io/badge/PowerShell-Desktop%205.1%20%7C%20Core%206.0-blue)

A cross-platform PowerShell module for interacting with the NordVPN API.

## Introduction
This module provides various functions for retrieving country, grouping, technology, and server information from the web API provided by NordVPN. Possible filter parameters are generated dynamically by retrieving lists of valid entries from the API. A list of countries, groups, and technologies is stored locally as an offline fallback, and these can be updated.

## Documentation
A full set of Markdown help files can be found [here](./docs/INDEX.md).

## Configuration
Information on the module settings can be found [here](./docs/about_NordVPN-Servers_Settings.md)

## License
This module and its associated assets are released under the **[MIT license](./LICENSE.md)**.

## Contributing
Suggestions and pull requests are welcomed, provided they are beneficial and well-documented.

### Translations
If you'd like to translate a help file, please create a pull request. Approved translations will also be added to the PowerShell Gallery.

## Requirements
This module works in PowerShell Desktop 5.1 and later, and PowerShell Core 6.1 and later.

---

## Module Usage

### Get-NordVPNCountries

```powershell
Get-NordVPNCountries [-UpdateFallback] [<CommonParameters>]
```

### Get-NordVPNGroups

```powershell
Get-NordVPNGroups [-UpdateFallback] [<CommonParameters>]
```

### Get-NordVPNTechnologies

```powershell
Get-NordVPNTechnologies [-UpdateFallback] [<CommonParameters>]
```

### Get-NordVPNCities

```powershell
Get-NordVPNCities [[-Country] <String>]  [<CommonParameters>]
```

### Get-NordVPNRecommendedServers

```powershell
Get-NordVPNRecommendedServers [[-Limit] <uint16>] [-Raw] [[-Country] <String>] [[-Group] <String>] [[-Technology] <String>] [<CommonParameters>]
```

### Get-NordVPNServers

```powershell
Get-NordVPNServers [[-First] <uint16>] [[-Country] <String>] [[-Group] <String>] [[-Technology] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]

Get-NordVPNServers [[-First] <uint16>] [[-Country] <String>] [[-Group] <String>] [[-Technology] <String>] -Offline [-WhatIf] [-Confirm] [<CommonParameters>]

Get-NordVPNServers [[-First] <uint16>] [[-Country] <String>] [[-Group] <String>] [[-Technology] <String>] -UpdateFallback [-WhatIf] [-Confirm] [<CommonParameters>]

Get-NordVPNServers [[-First] <uint16>] [-Raw] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Show-NordVPNCountries

```powershell
Show-NordVPNCountries [<CommonParameters>]
```

### Show-NordVPNGroups

```powershell
Show-NordVPNGroups [<CommonParameters>]
```

### Show-NordVPNTechnologies

```powershell
Show-NordVPNTechnologies [<CommonParameters>]
```

### Show-NordVPNCities

```powershell
Show-NordVPNCities [[-Country] <String>] [<CommonParameters>]
```

## Module settings

### Get-NordVPNModuleSetting

```powershell
Get-NordVPNModuleSetting [<CommonParameters>]
```

### Set-NordVPNModuleSetting

```powershell
Set-NordVPNModuleSetting [-Name] <String> [-Value] <Object> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Set-NordVPNModuleSetting [-Name] <String> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Reset-NordVPNModuleSettings

```powershell
Reset-NordVPNModuleSettings [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## Cache functions

### Clear-NordVPNCountryCache

```powershell
Clear-NordVPNCountryCache [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Clear-NordVPNGroupCache

```powershell
Clear-NordVPNGroupCache [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Clear-NordVPNTechnologyCache

```powershell
Clear-NordVPNTechnologyCache [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Clear-NordVPNCaches

```powershell
Clear-NordVPNCaches [-WhatIf] [-Confirm] [<CommonParameters>]
```
