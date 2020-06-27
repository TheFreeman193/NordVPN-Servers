# Find-NordVPNCity

## SYNOPSIS
Searches for cities with NordVPN servers.

## SYNTAX

### By Friendly Name (Default)
```
Find-NordVPNCity [-FriendlyName] <String> [-Offline] [<CommonParameters>]
```

### By Id
```
Find-NordVPNCity -Id <String> [-Offline] [<CommonParameters>]
```

### By Code
```
Find-NordVPNCity -Code <String> [-Offline] [<CommonParameters>]
```

### By Country Code
```
Find-NordVPNCity -CountryCode <String> [-Offline] [<CommonParameters>]
```

### By Hub Score
```
Find-NordVPNCity -HubScore <String> [-Offline] [<CommonParameters>]
```

## DESCRIPTION
Searches for and returns a list of cities that contain NordVPN servers.

By default, the required data is downloaded from the NordVPN web API and
processed to produce an array of matching city entries, each of which is a
NordVPNCity object.

Please see [About NordVPN-Servers Classes](./about_NordVPN-Servers_Classes.md)
to view the complete structure of a city entry.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-NordVPNCity -CountryCode CA
     ID Country Friendly Name             City Code                     Latitude    Longitude HubScore
     -- ------- -------------             ---------                     --------    --------- --------
1048463   CA    Montreal                  montreal                          45.5   -73.583333    0
1054250   CA    Toronto                   toronto                      43.666667   -79.416667    0
1054610   CA    Vancouver                 vancouver                        49.25  -123.133333    0
```

Searches for all cities in Canada which host NordVPN servers.

### Example 2
```powershell
PS C:\> Find-NordVPNCity -FriendlyName *a

         ID Country Friendly Name             City Code                     Latitude    Longitude HubScore
         -- ------- -------------             ---------                     --------    --------- --------
     308615   AL    Tirana                    tirana                         41.3275    19.818889    0
     448799   AT    Vienna                    vienna                            48.2    16.366667    0
     777368   BG    Sofia                     sofia                        42.683333    23.316667    0
    2099627   CY    Nicosia                   nicosia                      35.166667    33.366667    0
    3560288   ID    Jakarta                   jakarta                      -6.174444   106.829444    0
    5192828   LV    Riga                      riga                             56.95         24.1    0
    7884305   SK    Bratislava                bratislava                       48.15    17.116667    0
    7874306   SI    Ljubljana                 ljubljana                    46.055278    14.514444    0
    8792429   US    Atlanta                   atlanta                      33.748889   -84.388056    0
```

Searches for all cities which host NordVPN servers, whose names finish with
the letter 'a'.

## PARAMETERS

### -Code
Please enter a city code.
Wildcard characters (?*\[\]) are allowed.

```yaml
Type: String
Parameter Sets: ByCode
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -CountryCode
Please enter a 2-letter country code.
Wildcard characters (?*\[\]) are allowed.

```yaml
Type: String
Parameter Sets: ByCountryCode
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -FriendlyName
Please enter a city name.
Wildcard characters (?*\[\]) are allowed.

```yaml
Type: String
Parameter Sets: ByFriendlyName
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -HubScore
Please enter a hub score.
Wildcard characters (?*\[\]) are allowed.

```yaml
Type: String
Parameter Sets: ByHubScore
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -Id
Please enter a city ID.
Wildcard characters (?*\[\]) are allowed.

```yaml
Type: String
Parameter Sets: ById
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -Offline
Temporarily overrides the OfflineMode setting and uses the fallback file stored
in *NordVPN_Countries.xml*, which is needed to retrieve the list of cities.
This does not change the value of the setting but is useful when access to the
web API is not available.

The fallback file can be updated when online with `-UpdateFallback`.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### NordVPNCity

## NOTES

Please refer to the help topic for [Get-NordVPNCityList](./Get-NordVPNCityList.md)
for more details on offline usage, caching, and fallback files.

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Find-NordVPNCity.html)

[Help Index](./HELPINDEX.md)
