﻿
# Clear-NordVPNCache

## SYNOPSIS
Clears the country, group, and technology caches.

## SYNTAX

```
Clear-NordVPNCache [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
A convenience function to clear all of the NordVPN-Servers list caches.
This is the same as calling:

- `Clear-NordVPNCountryCache`
- `Clear-NordVPNGroupCache`
- `Clear-NordVPNTechnologyCache`

## EXAMPLES

### Example 1
```
PS C:\> Clear-NordVPNCache -Verbose
VERBOSE: Cleared the NordVPN country cache.
VERBOSE: Cleared the NordVPN group cache.
VERBOSE: Cleared the NordVPN technology cache.
```

Using the `-Verbose` parameter to demonstrate the three caches being cleared.

## PARAMETERS

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
These caches store the mostly-static lists of NordVPN server technologies and groups, plus the list of countries with servers.
The caches exist to reduce the number of needed web calls to the NordVPN API since the entries are unlikely to change day-to-day.

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Clear-NordVPNCache.md)

[Help Index](./INDEX.md)
