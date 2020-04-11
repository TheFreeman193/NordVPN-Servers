---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version: https://thefreeman193.github.io/NordVPN-Servers/Reset-NordVPNModule.html
schema: 2.0.0
---

# Reset-NordVPNModule

## SYNOPSIS
Resets all settings for the module.

## SYNTAX

```
Reset-NordVPNModule [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Resets all settings for the NordVPN-Servers module back to their default values.
The function will always prompt for confirmation before this happens, unless the `-Force` switch parameter is passed.

## EXAMPLES

### Example 1
```
PS C:\> Reset-NordVPNModule -Verbose

Reset settings to default
This will reset all NordVPN-Servers module settings to their defaults. Are you sure?
[Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"): y
VERBOSE: Performing the operation "Reset defaults" on target "All settings".
VERBOSE: Settings changed: Updated settings file 'NordVPN-Servers.settings.json'
```

Demonstrates the confirmation and operations performed when the module settings are reset.
If the confirmation prompt is accepted with 'Y', the settings are first cleared in the module memory, before the settings file is updated.

## PARAMETERS

### -Force
Resets the module setting default without confirmation.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: False
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
Default value: False
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

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Reset-NordVPNModule.html)

[Help Index]()
