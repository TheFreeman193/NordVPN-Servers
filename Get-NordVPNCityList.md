
# Get-NordVPNCityList

## SYNOPSIS
Gets a list of cities with NordVPN servers.

## SYNTAX

### DefaultOperation (Default)
```
Get-NordVPNCityList [[-Country] <String>] [<CommonParameters>]
```

### Offline
```
Get-NordVPNCityList [-Offline] [[-Country] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns a list of all cities with NordVPN servers, either globally or within a
specific country with the `-Country` parameter. By default, the required data
is downloaded from the NordVPN web API and processed to produce a list of
city entries, each of which is a NordVPNCity object.

Please see [About NordVPN-Servers Classes](./about_NordVPN-Servers_Classes.md)
to view the complete structure of a city entry.

## EXAMPLES

### Example 1
```
PS C:\> Get-NordVPNCityList

     ID Country Friendly Name             City Code                     Latitude    Longitude HubScore
     -- ------- -------------             ---------                     --------    --------- --------
 308615   AL    Tirana                    tirana                         41.3275    19.818889    0
 384866   AR    Buenos Aires              buenos-aires                  -34.5875     -58.6725    0
 452717   AU    Adelaide                  adelaide                    -34.928661   138.598633    0
 456494   AU    Brisbane                  brisbane                     -27.47101   153.024292    0
 470813   AU    Melbourne                 melbourne                   -37.813938   144.963425    0
 475799   AU    Perth                     perth                        -31.95224   115.861397    0
 479570   AU    Sydney                    sydney                      -33.861481   151.205475    0
 448799   AT    Vienna                    vienna                            48.2    16.366667    0
 654293   BE    Brussels                  brussels                     50.833333     4.333333    0
 556823   BA    Sarajevo                  sarajevo                         43.85    18.383333    0
 943973   BR    San Paulo                 san-paulo                   -23.533333   -46.616667    0
 777368   BG    Sofia                     sofia                        42.683333    23.316667    0
1048463   CA    Montreal                  montreal                          45.5   -73.583333    0
1054250   CA    Toronto                   toronto                      43.666667   -79.416667    0
1054610   CA    Vancouver                 vancouver                        49.25  -123.133333    0
1227092   CL    Santiago                  santiago                        -33.45   -70.666667    0
2062994   CR    San Jose                  san-jose                      9.893385   -84.105407    0
3308120   HR    Zagreb                    zagreb                            45.8           16    0
2099627   CY    Nicosia                   nicosia                      35.166667    33.366667    0
2144945   CZ    Prague                    prague                       50.083333    14.466667    0
2382515   DK    Copenhagen                copenhagen                   55.666667    12.583333    0
2514182   EE    Tallinn                   tallinn                      59.433889    24.728056    0
2704343   FI    Helsinki                  helsinki                     60.175556    24.934167    0
2886284   FR    Paris                     paris                        48.866667     2.333333    0
3032063   GE    Tbilisi                   tbilisi                         41.725    44.790833    -5
2181458   DE    Berlin                    berlin                       52.516667         13.4    0
2215709   DE    Frankfurt                 frankfurt                    50.116667     8.683333    0
3131903   GR    Athens                    athens                       37.983333    23.733333    0
3232931   HK    Hong Kong                 hong-kong                    22.283333       114.15    0
3348344   HU    Budapest                  budapest                          47.5    19.083333    0
4509791   IS    Reykjavik                 reykjavik                        64.15       -21.95    0
3988130   IN    Chennai                   chennai                      13.083333    80.283333    0
4041548   IN    Mumbai                    mumbai                          18.975    72.825833    0
3560288   ID    Jakarta                   jakarta                      -6.174444   106.829444    0
3939200   IE    Dublin                    dublin                       53.333056    -6.248889    0
3964220   IL    Tel Aviv                  tel-aviv                     32.066667    34.766667    0
4542737   IT    Milan                     milan                        45.466667          9.2    0
4633349   JP    Tokyo                     tokyo                           35.685   139.751389    0
5192828   LV    Riga                      riga                             56.95         24.1    0
5173235   LU    Steinsel                  steinsel                     49.676944     6.123889    0
5820143   MY    Kuala Lumpur              kuala-lumpur                  3.166667        101.7    0
5677037   MX    Mexico                    mexico                       19.434167   -99.138611    0
5295179   MD    Chisinau                  chisinau                     47.005556      28.8575    0
6076868   NL    Amsterdam                 amsterdam                        52.35     4.916667    0
6144239   NZ    Auckland                  auckland                    -36.866667   174.766667    0
5386019   MK    Skopje                    skopje                              42    21.433333    0
6127364   NO    Oslo                      oslo                         59.916667        10.75    0
6863429   PL    Warsaw                    warsaw                           52.25           21    0
6906665   PT    Lisbon                    lisbon                       38.716667    -9.133333    0
6953096   RO    Bucharest                 bucharest                    44.433333         26.1    0
7030907   RS    Belgrad                   belgrad                      44.818611    20.468056    0
7867982   SG    Singapore                 singapore                     1.293056   103.855833    0
7884305   SK    Bratislava                bratislava                       48.15    17.116667    0
7874306   SI    Ljubljana                 ljubljana                    46.055278    14.514444    0
9383693   ZA    Johannesburg              johannesburg                -26.205171    28.049815    0
4879586   KR    Seoul                     seoul                          37.5985     126.9783    0
2619989   ES    Madrid                    madrid                       40.408566     -3.69222    0
7852919   SE    Stockholm                 stockholm                    59.333333        18.05    0
1171814   CH    Zurich                    zurich                       47.366667         8.55    0
8544365   TW    Taipei                    taipei                       25.039167      121.525    0
8121638   TH    Bangkok                   bangkok                      13.753979   100.501444    0
8401790   TR    Istanbul                  istanbul                     41.018611    28.964722    0
8615126   UA    Kiev                      kiev                         50.433333    30.516667    0
    728   AE    Dubai                     dubai                        25.258172    55.304717    0
2989907   GB    London                    london                       51.514125    -0.093689    0
8792429   US    Atlanta                   atlanta                      33.748889   -84.388056    0
8963153   US    Buffalo                   buffalo                      42.886389   -78.878611    0
8980922   US    Charlotte                 charlotte                    35.226944   -80.843333    0
8815352   US    Chicago                   chicago                          41.85       -87.65    0
9080300   US    Dallas                    dallas                       32.783333        -96.8    0
8770934   US    Denver                    denver                       39.739167  -104.984167    0
8761958   US    Los Angeles               los-angeles                  34.052222  -118.242778    0
9113744   US    Manassas                  manassas                     38.750833   -77.475556    0
8787782   US    Miami                     miami                        25.773889   -80.193889    0
8971718   US    New York                  new-york                     40.714167   -74.006389    0
8741960   US    Phoenix                   phoenix                      33.448333  -112.073333    0
8934551   US    Saint Louis               saint-louis                  38.627222   -90.197778    0
9097865   US    Salt Lake City            salt-lake-city               40.760833  -111.890278    0
8766359   US    San Francisco             san-francisco                37.769814     -122.466    0
9128402   US    Seattle                   seattle                      47.606389  -122.330833    0
9270302   VN    Hanoi                     hanoi                        21.033333       105.85    0
```

Retrieves the list of US cities which host NordVPN servers and gets the unique
code for each, alongside its name.

### Example 2
```
PS C:\> $allServers = Get-NordVPNServerList
PS C:\> (Get-NordVPNCityList).GetEnumerator() | Sort-Object CountryCode | `
>> Format-Table CountryCode,FriendlyName, @{
>>     Label = "No. Servers"
>>     Expression = {
>>         $cityCode = $_.Code
>>         ($allServers | Where-Object {$_.City.Code -eq $cityCode}).Count
>>     }
>> } -AutoSize

CountryCode FriendlyName   No. Servers
----------- ------------   -----------
AE          Dubai                   20
AL          Tirana                   6
AR          Buenos Aires            18
AT          Vienna                  29
AU          Adelaide                23
AU          Brisbane                43
AU          Melbourne               37
AU          Perth                   28
AU          Sydney                  55
BA          Sarajevo                 2
BE          Brussels                50
BG          Sofia                   17
BR          San Paulo               21
CA          Vancouver              113
CA          Toronto                133
CA          Montreal               157
CH          Zurich                  99
CL          Santiago                10
CR          San Jose                 5
CY          Nicosia                  7
CZ          Prague                  29
DE          Berlin                  78
DE          Frankfurt              159
DK          Copenhagen              63
EE          Tallinn                 13
ES          Madrid                  60
FI          Helsinki                24
FR          Paris                  218
GB          London                 391
GE          Tbilisi                  3
GR          Athens                  16
HK          Hong Kong               76
HR          Zagreb                   4
HU          Budapest                16
ID          Jakarta                 14
IE          Dublin                  36
IL          Tel Aviv                18
IN          Chennai                  8
IN          Mumbai                  20
IS          Reykjavik                8
IT          Milan                   64
JP          Tokyo                   90
KR          Seoul                   10
LU          Steinsel                19
LV          Riga                    13
MD          Chisinau                 4
MK          Skopje                   2
MX          Mexico                  14
MY          Kuala Lumpur             9
NL          Amsterdam              220
NO          Oslo                    57
NZ          Auckland                24
PL          Warsaw                  39
PT          Lisbon                  25
RO          Bucharest               16
RS          Belgrad                 20
SE          Stockholm              131
SG          Singapore              124
SI          Ljubljana                5
SK          Bratislava              10
TH          Bangkok                  6
TR          Istanbul                 7
TW          Taipei                  96
UA          Kiev                    22
US          Miami                  144
US          San Francisco          152
US          Salt Lake City          38
US          Saint Louis             51
US          Phoenix                 51
US          New York               443
US          Manassas                41
US          Seattle                105
US          Denver                  60
US          Dallas                 149
US          Chicago                 96
US          Charlotte               43
US          Buffalo                 65
US          Atlanta                 84
US          Los Angeles            227
VN          Hanoi                   15
ZA          Johannesburg            48
```

Displays a list of cities that host NordVPN servers, with the number of servers
in each city. Notable is the use of a calculated property in Format-Table.

### Example 3
```
PS C:\> $country = 'DE'
PS C:\> $cities = (Get-NordVPNCityList -Country $country).FriendlyName
PS C:\> $recommended = Get-NordVPNRecommendedList -Limit 8192 -Country $country
PS C:\> foreach ($city in $cities) {
>>     Write-Host "Top 5 servers in $city`:"
>>     $recommended | Where-Object {$_.City.FriendlyName -eq $city} | `
>>         Select-Object -ExpandProperty Hostname -First 5 | Format-List
>> }
Top 5 servers in Berlin:
de660.nordvpn.com
de661.nordvpn.com
de693.nordvpn.com
de852.nordvpn.com
de841.nordvpn.com
Top 5 servers in Frankfurt:
de856.nordvpn.com
de828.nordvpn.com
de738.nordvpn.com
de710.nordvpn.com
de858.nordvpn.com
```

Gets the top 5 NordVPN servers in each city that hosts servers, in Germany.

- Line 1 stores the country code for Germany (DE).
- Line 2 gets an array of names for each city in Germany with servers.
- Line 3 uses `Get-NordVPNRecommendedList` to get a list of all the recommended
  servers in Germany.
- Lines 4-8 loop through the `$cities` array and select the first 5 servers
  from the `$recommended` list for each city name. The result is two lists of
  5 servers.

Notable is the use of the backtick \` to continue a long command on the next
line, as well as to escape the colon after the `$city` variable on line 6.

## PARAMETERS

### -Country
The 2-letter short code of the country to filter by (run
`Show-NordVPNCountryList` and see the Code column for reference)

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

### -Offline
Temporarily overrides the OfflineMode setting and uses the fallback file stored
in *NordVPN_Countries.xml*, which is needed to retrieve the list of cities.
This does not change the value of the setting but is useful when access to the
web API is not available.

The fallback file can be updated when online with
`Get-NordVPNCountryList -UpdateFallback`.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### NordVPNCityList
## NOTES
This function relies on `Get-NordVPNCountryList` as city details are included
as part of the countries list. Further calls after the initial download will
utilise a local cache of the country list until the number of seconds defined
with `Set-NordVPNCountryCacheLifetime` (default: 600s) has passed, after which
the cache will be updated using the API.

If the module is configured to only use the fallback files, with the command
`Set-NordVPNModuleSetting OfflineMode 1`, the country list, and therefore city
list, will be retrieved from the XML fallback file in the module directory.

As the list returned is a custom class, in order to pass it through the
pipeline, you should use the [GetEnumerator()](https://docs.microsoft.com/en-us/dotnet/api/system.collections.ienumerable.getenumerator)
method, e.g `(Get-NordVPNCountryList).GetEnumerator() | ...`

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Get-NordVPNCityList.html)

[Help Index](./HELPINDEX.md)
