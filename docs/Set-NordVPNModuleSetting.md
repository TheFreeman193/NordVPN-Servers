---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version:
schema: 2.0.0
---

# Set-NordVPNModuleSetting

## SYNOPSIS
Modifies or resets a setting for the module.

## SYNTAX

### SetDefault (Default)
```
Set-NordVPNModuleSetting [-Force] [-WhatIf] [-Confirm] [-Name] <String> [<CommonParameters>]
```

### SetValue
```
Set-NordVPNModuleSetting [-Force] [-WhatIf] [-Confirm] [-Name] <String> [-Value] <Object> [<CommonParameters>]
```

## DESCRIPTION
This function is used to modify persistent settings for the NordVPN-Servers
module. It also allows resetting individual settings to their defaults. Use
this to configure the cache lifetimes, offline mode, and whether or not the
extracted NordVPN_Servers.xml fallback file is deleted after use.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-NordVPNModuleSetting CountryCacheLifetime 3600 -Verbose
VERBOSE: Performing the operation "Update value: 3600" on target "Setting: CountryCacheLifetime".
VERBOSE: Settings changed: Updated settings file 'NordVPN-Servers.settings.json'
```

Sets the country cache lifetime to one hour. Using the verbose switch, it is
possible to observe that the setting is changed in the module memory, and the
persistent settings file NordVPN-Servers.settings.json is then updated.

### Example 2
```powershell
PS C:\> Set-NordVPNModuleSetting CountryCacheLifetime -Verbose

Reset setting to default
This will reset 'CountryCacheLifetime' to its default of 600. Are you sure?
[Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"): y
VERBOSE: Performing the operation "Reset default: 600" on target "Setting: CountryCacheLifetime".
VERBOSE: Settings changed: Updated settings file 'NordVPN-Servers.settings.json'
```

Resets the country cache lifetime its default of 10 minutes. This action always
provoke a confirmation.

### Example 3
```powershell
PS C:\> $currentValue = Get-NordVPNModuleSetting TechnologyCacheLifetime
PS C:\> $currentValue
600
PS C:\> Set-NordVPNModuleSetting TechnologyCacheLifetime -Verbose ($currentValue + 300)
VERBOSE: Performing the operation "Update value: 900" on target "Setting: TechnologyCacheLifetime".
VERBOSE: Settings changed: Updated settings file 'NordVPN-Servers.settings.json'
```

Adds five minutes to the technology cache lifetime.

### Example 5
```powershell
PS C:\> Get-NordVPNModuleSetting DeleteServerFallbackAfterUse
False
PS C:\> Set-NordVPNModuleSetting DeleteServerFallbackAfterUse $true
Get-NordVPNModuleSetting DeleteServerFallbackAfterUse
True
PS C:\> Set-NordVPNModuleSetting DeleteServerFallbackAfterUse 0
Get-NordVPNModuleSetting DeleteServerFallbackAfterUse
False
PS C:\> Set-NordVPNModuleSetting DeleteServerFallbackAfterUse 1
Get-NordVPNModuleSetting DeleteServerFallbackAfterUse
True
```

Demonstrates that both $true/$false, and 1/0 work when changing boolean
settings. The function automatically attempts to cast the input value to
the required type of the setting.

## PARAMETERS

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The name of the module setting to be changed/reset.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: TechnologyCacheLifetime, DeleteServerFallbackAfterUse, CountryCacheLifetime, OfflineMode, GroupCacheLifetime

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
The new value for the setting.
If this parameter is not passed, the setting will be reset to its default.

```yaml
Type: Object
Parameter Sets: SetValue
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Sets or resets the module setting without confirmation.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Set-NordVPNModuleSettings.md)

[Help Index](./INDEX.md)
