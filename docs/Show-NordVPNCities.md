---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version:
schema: 2.0.0
---

# Show-NordVPNCities

## SYNOPSIS
Shows all the cities with NordVPN servers in a neat format.

## SYNTAX

```
Show-NordVPNCities [[-Country] <String>] [<CommonParameters>]
```

## DESCRIPTION
Displays a formatted table of cities that contain NordVPN servers. This output
is useful for cross-referencing city names with their codes/IDs.

## EXAMPLES

### Example 1
```powershell
PS C:\> Show-NordVPNCities

Server Cities:

    Id FriendlyName   Country Code             Latitude    Longitude HubScore
    -- ------------   ------- ----             --------    --------- --------
   728 Dubai          AE      dubai           25.258172    55.304717
308615 Tirana         AL      tirana            41.3275   19.8188889
384866 Buenos Aires   AR      buenos-aires     -34.5875     -58.6725
448799 Vienna         AT      vienna               48.2    16.366667
452717 Adelaide       AU      adelaide       -34.928661   138.598633
456494 Brisbane       AU      brisbane        -27.47101   153.024292
...
```

Displays a list of all the cities in the world with NordVPN servers.

### Example 2
```powershell
PS C:\> Show-NordVPNCities -Country DE

Server Cities:

     Id FriendlyName Country Code       Latitude Longitude HubScore
     -- ------------ ------- ----       -------- --------- --------
2181458 Berlin       DE      berlin    52.516667      13.4
2215709 Frankfurt    DE      frankfurt 50.116667  8.683333
```

Displays a list of all the cities in Germany.

### Example 3
```powershell
PS C:\> $MyCountries = @(
>> [pscustomobject]@{Country = 'DE'}
>> [pscustomobject]@{Country = 'BR'}
>> )
PS C:\> $MyCountries | Show-NordVPNCities

Server Cities:

     Id FriendlyName Country Code       Latitude Longitude HubScore
     -- ------------ ------- ----       -------- --------- --------
2181458 Berlin       DE      berlin    52.516667      13.4
2215709 Frankfurt    DE      frankfurt 50.116667  8.683333


    Id FriendlyName Country Code        Latitude  Longitude HubScore
    -- ------------ ------- ----        --------  --------- --------
943973 San Paulo    BR      san-paulo -23.533333 -46.616667
```

Creates an array of custom objects, each with a `Country` property, and
passes it through the pipeline to `Get-NordVPNCities`. The result is a
table for each country containing the cities with NordVPN servers.

## PARAMETERS

### -Country
A 2-digit ISO 3166-1 country code to filter the results by. You can see a list
of country codes using `Show-NordVPNCountries`. Examples include GB (United
Kingdom), US (United States), and DE (Germany).

A list of available countries is generated dynamically using
`Get-NordVPNCountries`, and can be accessed by pressing the tab key after
typing `-Country`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AL, AR, AU, AT, BE, BA, BR, BG, CA, CL, CR, HR, CY, CZ, DK, EE, FI, FR, GE, DE, GR, HK, HU, IS, IN, ID, IE, IL, IT, JP, LV, LU, MY, MX, MD, NL, NZ, MK, NO, PL, PT, RO, RS, SG, SK, SI, ZA, KR, ES, SE, CH, TW, TH, TR, UA, AE, GB, US, VN

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Show-NordVPNCities.md)

[Help Index](./INDEX.md)
