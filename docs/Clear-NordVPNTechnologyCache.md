---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version:
schema: 2.0.0
---

# Clear-NordVPNTechnologyCache

## SYNOPSIS
Clears the offline cache of NordVPN supported technologies.

## SYNTAX

```
Clear-NordVPNTechnologyCache [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Clears the offline cache of NordVPN supported technologies.
Clearing this will cause the list to be downloaded again when
needed by the module.

## EXAMPLES

### Example 1
```powershell
PS C:\> Clear-NordVPNTechnologyCache
PS C:\> Get-NordVPNTechnologyList >$null
```

Clears the technology cache and regenerates it by getting the
technology list from the API.

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

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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
If you are running `Get-NordVPNTechnologyList` with the `-UpdateFallback`
parameter, the fallback file *NordVPN_Technologies.xml* may be updated from the
cache. If you wish to ensure the files are updated using the latest data from
the API, you should run `Clear-NordVPNTechnologyCache` to ensure the data is
redownloaded.

The cache only persists as long as the PowerShell session in which the module
is loaded. If the module is first loaded without an internet connection, no
cache will be created and the fallback file *NordVPN_Technologies.xml* will be
used instead. If you wish to avoid unnecessary attempts to download the latest
data from the NordVPN API, you can call `Get-NordVPNTechnologyList -Offline`
which skips any API requests and uses the fallback file instead.

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Clear-NordVPNTechnologyCache.md)

[Help Index](./INDEX.md)
