---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version:
schema: 2.0.0
---

# Get-NordVPNCities

## SYNOPSIS
Gets a list of cities with NordVPN servers.

## SYNTAX

### DefaultOperation (Default)
```
Get-NordVPNCities [[-Country] <String>] [<CommonParameters>]
```

### Offline
```
Get-NordVPNCities [-Offline] [<CommonParameters>]
```

## DESCRIPTION
Returns a list of all cities with NordVPN servers, either globally or within a
specific country with the `-Country` parameter. By default, the required data
is downloaded from the NordVPN web API and processed to produce an array of
city entries, each of which is a hashtable.

The structure of a city entry is as follows (PowerShell notation):

```powershell
@{
    Id           = [Int64] # Unique ID for city
    Code         = [String] # Unique short code for city
    FriendlyName = [String] # Full name of city
    Latitude     = [Double] # Latitude of city (+ve: N/-ve: S)
    Longitude    = [Double] # Longitude of city (+ve: E/-ve: W)
    CountryCode  = [String] # Two letter unique code of country
    HubScore     = [Int16] # Hub score /100, currently not used
}
```

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-NordVPNCities -Country US | Select Code,FriendlyName

Code           FriendlyName
----           ------------
atlanta        Atlanta
buffalo        Buffalo
charlotte      Charlotte
chicago        Chicago
dallas         Dallas
denver         Denver
los-angeles    Los Angeles
manassas       Manassas
miami          Miami
new-york       New York
phoenix        Phoenix
saint-louis    Saint Louis
salt-lake-city Salt Lake City
san-francisco  San Francisco
seattle        Seattle
```

Retrieves the list of US cities which host NordVPN servers and gets the unique
code for each, alongside its name.

### Example 2
```powershell
PS C:\> $country = 'DE'
PS C:\> $cities = Get-NordVPNCities -Country $country | `
>> Select-Object -ExpandProperty Code
PS C:\> $recommended = Get-NordVPNRecommendedServers -Limit 8192 -Country $country
PS C:\> foreach ($city in $cities) {
>>     Write-Host "Top 5 servers in $city`:"
>>     $recommended | Where-Object {$_.City.Code -eq $city} | `
>>         Select-Object -ExpandProperty Hostname -First 5 | Format-List
>> }
Top 5 servers in berlin:
de659.nordvpn.com
de418.nordvpn.com
de647.nordvpn.com
de661.nordvpn.com
de448.nordvpn.com
Top 5 servers in frankfurt:
de749.nordvpn.com
de715.nordvpn.com
de570.nordvpn.com
de650.nordvpn.com
de717.nordvpn.com
```

Gets the top 5 NordVPN servers in each city that hosts servers, in Germany.
Line 1 stores the country code for Germany (DE). Lines 2-3 get an array of
codes for each city in Germany. Line 4 uses `Get-NordVPNRecommendedServers`
to get a list of all the recommended servers in Germany. Lines 5-8 loop
through the `$cities` array and select the first 5 servers from the
`$recommended` list for each city code. The result is two lists of 5 servers.

Notable is the use of the *backtick* \` to continue a long command on the next
line, as well as to escape the colon after the `$city` variable on line 6.

## PARAMETERS

### -Country
The 2-letter short code of the country to filter by (run `Show-NordVPNCountries`
and see the *Code* column for reference)

```yaml
Type: String
Parameter Sets: DefaultOperation
Aliases:
Accepted values: AL, AR, AU, AT, BE, BA, BR, BG, CA, CL, CR, HR, CY, CZ, DK, EE, FI, FR, GE, DE, GR, HK, HU, IS, IN, ID, IE, IL, IT, JP, LV, LU, MY, MX, MD, NL, NZ, MK, NO, PL, PT, RO, RS, SG, SK, SI, ZA, KR, ES, SE, CH, TW, TH, TR, UA, AE, GB, US, VN

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Offline
Temporarily overrides the *OfflineMode* setting and uses the fallback
file stored in *NordVPN_Countries.xml*, which is needed to retrieve the list of
cities. This does not change the value of the setting but is useful when access
to the web API is not available. The fallback file can be updated when online
with `Get-NordVPNCountries -UpdateFallback`.

```yaml
Type: SwitchParameter
Parameter Sets: Offline
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

### System.Array

## NOTES
This function relies on `Get-NordVPNCountries` as city details are included as
part of the countries list. Further calls after the initial download will
utilise a local cache of the country list until the number of seconds defined
with `Set-NordVPNCountryCacheLifetime` (default: 600s) has passed, after which
the cache will be updated using the API.

If the module is configured to only use the fallback files, with the command
`Set-NordVPNModuleSetting OfflineMode 1`, the country list, and therefore city list,
will be retrieved from the XML fallback file in the module directory.

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Get-NordVPNCities.md)

[Help Index](./INDEX.md)
