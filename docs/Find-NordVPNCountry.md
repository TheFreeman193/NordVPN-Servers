# Find-NordVPNCountry

## SYNOPSIS
Searches for countries with NordVPN servers.

## SYNTAX

### By Friendly Name (Default)
```
Find-NordVPNCountry [-FriendlyName] <String> [-Offline] [<CommonParameters>]
```

### By Id
```
Find-NordVPNCountry -Id <String> [-Offline] [<CommonParameters>]
```

### By Code
```
Find-NordVPNCountry -Code <String> [-Offline] [<CommonParameters>]
```

## DESCRIPTION
Searches for and returns a list of countries that contain NordVPN servers.

By default, the required data is downloaded from the NordVPN web API and
processed to produce an array of matching country entries, each of which is a
NordVPNCountry object.

Please see [About NordVPN-Servers Classes](./about_NordVPN-Servers_Classes.md)
to view the complete structure of a country entry.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-NordVPNCountry -Code A?

   ID Name                            Code Cities
   -- ----                            ---- ------
    2 Albania                          AL  Tirana
   10 Argentina                        AR  Buenos Aires
   13 Australia                        AU  Adelaide, Brisbane, Melbourne, Perth, Sydney
   14 Austria                          AT  Vienna
  226 United Arab Emirates             AE  Dubai
```

Searches for all countries hosting NordVPN servers, whose ISO country code
begins with the letter 'A'.

### Example 2
```powershell
PS C:\> Find-NordVPNCountry -Id 2??

   ID Name                            Code Cities
   -- ----                            ---- ------
  200 South Africa                     ZA  Johannesburg
  202 Spain                            ES  Madrid
  208 Sweden                           SE  Stockholm
  209 Switzerland                      CH  Zurich
  211 Taiwan                           TW  Taipei
  214 Thailand                         TH  Bangkok
  220 Turkey                           TR  Istanbul
  225 Ukraine                          UA  Kiev
  226 United Arab Emirates             AE  Dubai
  227 United Kingdom                   GB  London
  228 United States                    US  Atlanta, Buffalo, Charlotte, Chicago, Dallas, Denver, Los
                                           Angeles, Manassas, Miami, New York, Phoenix, Saint Louis,
                                           Salt Lake City, San Francisco, Seattle
  234 Vietnam                          VN  Hanoi
```

Searches for all countries hosting NordVPN servers, whose ID is in the range
200-299.

## PARAMETERS

### -Code
Please enter a 2-letter country Code.
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

### -FriendlyName
Please enter a country name.
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

### -Id
Please enter a country ID.
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
in *NordVPN_Countries.xml*. This does not change the value of the setting but
is useful when access to the web API is not available.

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

### NordVPNCountry

## NOTES

Please refer to the help topic for [Get-NordVPNCountryList](./Get-NordVPNCountryList.md)
for more details on offline usage, caching, and fallback files.

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Find-NordVPNCountry.md)

[Help Index](./INDEX.md)
