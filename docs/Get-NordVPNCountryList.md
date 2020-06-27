
# Get-NordVPNCountryList

## SYNOPSIS
Gets a list of countries with NordVPN servers.

## SYNTAX

### DefaultOperation (Default)
```
Get-NordVPNCountryList [-UpdateFallback] [<CommonParameters>]
```

### Offline
```
Get-NordVPNCountryList [-Offline] [<CommonParameters>]
```

## DESCRIPTION
Returns a list of all countries with NordVPN servers.
By default, the required data is downloaded from the NordVPN web API and
processed to produce a list of country entries, each of which is a
NordVPNCountry object.

Please see [About NordVPN-Servers Classes](./about_NordVPN-Servers_Classes.md)
to view the complete structure of a country entry.

## EXAMPLES

### Example 1
```
PS C:\> Get-NordVPNCountryList

   ID Name                            Code Cities
   -- ----                            ---- ------
    2 Albania                          AL  Tirana
   10 Argentina                        AR  Buenos Aires
   13 Australia                        AU  Adelaide, Brisbane, Melbourne, Perth, Sydney
   14 Austria                          AT  Vienna
   21 Belgium                          BE  Brussels
   27 Bosnia and Herzegovina           BA  Sarajevo
   30 Brazil                           BR  San Paulo
   33 Bulgaria                         BG  Sofia
   38 Canada                           CA  Montreal, Toronto, Vancouver
   43 Chile                            CL  Santiago
   52 Costa Rica                       CR  San Jose
   54 Croatia                          HR  Zagreb
   56 Cyprus                           CY  Nicosia
   57 Czech Republic                   CZ  Prague
   58 Denmark                          DK  Copenhagen
   68 Estonia                          EE  Tallinn
   73 Finland                          FI  Helsinki
   74 France                           FR  Paris
   80 Georgia                          GE  Tbilisi
   81 Germany                          DE  Berlin, Frankfurt
   84 Greece                           GR  Athens
   97 Hong Kong                        HK  Hong Kong
   98 Hungary                          HU  Budapest
   99 Iceland                          IS  Reykjavik
  100 India                            IN  Chennai, Mumbai
  101 Indonesia                        ID  Jakarta
  104 Ireland                          IE  Dublin
  105 Israel                           IL  Tel Aviv
  106 Italy                            IT  Milan
  108 Japan                            JP  Tokyo
  119 Latvia                           LV  Riga
  126 Luxembourg                       LU  Steinsel
  131 Malaysia                         MY  Kuala Lumpur
  140 Mexico                           MX  Mexico
  142 Moldova                          MD  Chisinau
  153 Netherlands                      NL  Amsterdam
  156 New Zealand                      NZ  Auckland
  128 North Macedonia                  MK  Skopje
  163 Norway                           NO  Oslo
  174 Poland                           PL  Warsaw
  175 Portugal                         PT  Lisbon
  179 Romania                          RO  Bucharest
  192 Serbia                           RS  Belgrad
  195 Singapore                        SG  Singapore
  196 Slovakia                         SK  Bratislava
  197 Slovenia                         SI  Ljubljana
  200 South Africa                     ZA  Johannesburg
  114 South Korea                      KR  Seoul
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

Gets the list of countries that currently host NordVPN servers and shows the
unique ID, full name, ISO code, and cities with servers, for each.

### Example 2
```
PS C:\> $allServers = Get-NordVPNServerList
PS C:\> Get-NordVPNCountryList | `
>> Format-Table FriendlyName, @{
>>     Label = "No. Servers"
>>     Expression = {
>>         $countryCode = $_.Code
>>         ($allServers | Where-Object {$_.Country.Code -eq $countryCode}).Count
>>     }
>> } -AutoSize

FriendlyName           No. Servers
------------           -----------
Albania                          6
Argentina                       18
Australia                      186
Austria                         29
Belgium                         50
Bosnia and Herzegovina           2
Brazil                          21
Bulgaria                        17
Canada                         403
Chile                           10
Costa Rica                       5
Croatia                          4
Cyprus                           7
Czech Republic                  29
Denmark                         63
Estonia                         13
Finland                         24
France                         218
Georgia                          3
Germany                        237
Greece                          16
Hong Kong                       76
Hungary                         16
Iceland                          8
India                           28
Indonesia                       14
Ireland                         36
Israel                          18
Italy                           64
Japan                           90
Latvia                          13
Luxembourg                      19
Malaysia                         9
Mexico                          14
Moldova                          4
Netherlands                    220
New Zealand                     24
North Macedonia                  2
Norway                          57
Poland                          39
Portugal                        25
Romania                         16
Serbia                          20
Singapore                      124
Slovakia                        10
Slovenia                         5
South Africa                    48
South Korea                     10
Spain                           60
Sweden                         131
Switzerland                     99
Taiwan                          96
Thailand                         6
Turkey                           7
Ukraine                         22
United Arab Emirates            20
United Kingdom                 391
United States                 1749
Vietnam                         15
```

Displays a list of countries with NordVPN servers, with the number of servers
in each country. Notable is the use of a calculated property in Format-Table.

## PARAMETERS

### -Offline
Temporarily overrides the OfflineMode setting and uses the fallback file stored
in *NordVPN_Countries.xml*. This does not change the value of the setting but
is useful when access to the web API is not available.

The fallback file can be updated when online with `-UpdateFallback`.

```yaml
Type: SwitchParameter
Parameter Sets: Offline
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateFallback
Passing this switch causes the function to update the *NordVPN_Countries.xml*
fallback file, using the data retrieved from the NordVPN web API or cache.
This functionality cannot be used when OfflineMode is enabled or the `-Offline`
switch parameter is passed.

```yaml
Type: SwitchParameter
Parameter Sets: DefaultOperation
Aliases:

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

### NordVPNCountryList
## NOTES
The module utilises a countries cache to reduce API calls.
Further calls after the initial download will retrieve data from a local cache
of the country list until the number of seconds defined with
`Set-NordVPNCountryCacheLifetime` (default: 600s) has passed, after which the
cache will be updated using the API.
To force downloading from the API, run `Clear-NordVPNCountryCache` first.

If the module is configured to only use the fallback files, with the command
`Set-NordVPNModuleSetting OfflineMode 1`, the country list will be retrieved
from NordVPN_Countries.xml in the module directory.
This is useful for offline environments.

Use `Set-NordVPNModuleSetting OfflineMode 0` to restore web API usage.

As the list returned is a custom class, in order to pass it through the
pipeline, you should use the [GetEnumerator()](https://docs.microsoft.com/en-us/dotnet/api/system.collections.ienumerable.getenumerator)
method, e.g `(Get-NordVPNCountryList).GetEnumerator() | ...`

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Get-NordVPNCountryList.md)

[Help Index](./INDEX.md)
