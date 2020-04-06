---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version:
schema: 2.0.0
---

# Get-NordVPNCountries

## SYNOPSIS
Gets a list of countries with NordVPN servers.

## SYNTAX

### DefaultOperation (Default)
```
Get-NordVPNCountries [-UpdateFallback] [<CommonParameters>]
```

### Offline
```
Get-NordVPNCountries [-Offline] [<CommonParameters>]
```

## DESCRIPTION
Returns a list of all countries with NordVPN servers. By default, the required
data is downloaded from the NordVPN web API and processed to produce an array
of country entries, each of which is a hashtable.

The structure of a country entry is as follows (powershell notation):

```powershell
@{
    Id           = [Int64] # Unique ID for country
    Code         = [String] # Two-letter unique short code for country
    FriendlyName = [String] # Full name of country
    Cities       = [Array] # Array of City entries&sup1;
}
```

&sup1;To see the structure of a City entry, run `Get-Help Get-NordVPNCities`
and refer to the function description.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-NordVPNCountries | Select Id, FriendlyName, Code

 Id FriendlyName           Code
 -- ------------           ----
  2 Albania                AL
 10 Argentina              AR
 13 Australia              AU
 14 Austria                AT
 21 Belgium                BE
 27 Bosnia and Herzegovina BA
 30 Brazil                 BR
 33 Bulgaria               BG
 38 Canada                 CA
 43 Chile                  CL
 52 Costa Rica             CR
 54 Croatia                HR
 56 Cyprus                 CY
 57 Czech Republic         CZ
 58 Denmark                DK
 68 Estonia                EE
 73 Finland                FI
 74 France                 FR
 80 Georgia                GE
 81 Germany                DE
 84 Greece                 GR
 97 Hong Kong              HK
 98 Hungary                HU
 99 Iceland                IS
100 India                  IN
101 Indonesia              ID
104 Ireland                IE
105 Israel                 IL
106 Italy                  IT
108 Japan                  JP
119 Latvia                 LV
126 Luxembourg             LU
131 Malaysia               MY
140 Mexico                 MX
142 Moldova                MD
153 Netherlands            NL
156 New Zealand            NZ
128 North Macedonia        MK
163 Norway                 NO
174 Poland                 PL
175 Portugal               PT
179 Romania                RO
192 Serbia                 RS
195 Singapore              SG
196 Slovakia               SK
197 Slovenia               SI
200 South Africa           ZA
114 South Korea            KR
202 Spain                  ES
208 Sweden                 SE
209 Switzerland            CH
211 Taiwan                 TW
214 Thailand               TH
220 Turkey                 TR
225 Ukraine                UA
226 United Arab Emirates   AE
227 United Kingdom         GB
228 United States          US
234 Vietnam                VN
```

Gets the list of countries that currently host NordVPN servers and shows the
unique ID, full name, and ISO country code for each.

### Example 2
```powershell
PS C:\> $allServers = Get-NordVPNServers
PS C:\> Get-NordVPNCountries | Select-Object FriendlyName, Code | `
>> Format-Table FriendlyName, @{
>>     Label = "No. Servers"
>>     Expression = {($allServers | Where-Object CountryCode -eq $_.Code).Count}
>> }

FriendlyName           No. Servers
------------           -----------
Albania                          9
Argentina                       21
Australia                      270
Austria                         41
Belgium                         84
Bosnia and Herzegovina           4
Brazil                          32
Bulgaria                        25
Canada                         442
Chile                           10
Costa Rica                       5
Croatia                          7
Cyprus                           7
Czech Republic                  55
Denmark                         90
Estonia                         12
Finland                         40
France                         255
Georgia                          4
Germany                        312
Greece                          14
Hong Kong                       84
Hungary                         21
Iceland                         11
India                           31
Indonesia                       11
Ireland                         65
Israel                          19
Italy                           71
Japan                           70
Latvia                          25
Luxembourg                      19
Malaysia                        10
Mexico                          14
Moldova                          7
Netherlands                    272
New Zealand                     40
North Macedonia                  2
Norway                          82
Poland                          63
Portugal                        25
Romania                         27
Serbia                          40
Singapore                      124
Slovakia                        28
Slovenia                         5
South Africa                    43
South Korea                     10
Spain                           48
Sweden                         196
Switzerland                    135
Taiwan                          18
Thailand                         7
Turkey                          15
Ukraine                         13
United Arab Emirates            20
United Kingdom                 624
United States                 1781
Vietnam                         13
```

Displays a list of countries with NordVPN servers, with the number of servers
in each country. Notable is the use of a calculated property in Format-Table.

## PARAMETERS

### -Offline
Temporarily overrides the *OfflineMode* setting and uses the fallback
file stored in *NordVPN_Countries.xml*. This does not change the value of
the setting but is useful when access to the web API is not available. The
fallback file can be updated when online with `-UpdateFallback`.

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

### -UpdateFallback
Passing this switch causes the function to update the *NordVPN_Countries.xml*
fallback file, using the data retrieved from the NordVPN web API or cache. This
functionality cannot be used when *OfflineMode* is enabled or the `-Offline`
switch parameter is passed.

```yaml
Type: SwitchParameter
Parameter Sets: DefaultOperation
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

### None

## OUTPUTS

### System.Array

## NOTES
The module utilises a countries cache to reduce API calls. Further calls after
the initial download will retrieve data from a local cache of the country list
until the number of seconds defined with `Set-NordVPNCountryCacheLifetime`
(default: 600s) has passed, after which the cache will be updated using the
API. To force downloading from the API, run `Clear-NordVPNCountryCache` first.

If the module is configured to only use the fallback files, with the command
`Set-NordVPNModuleSetting OfflineMode 1`, the country list will be retrieved from
*NordVPN_Countries.xml* in the module directory. This is useful for offline
environments. Use `Set-NordVPNModuleSetting OfflineMode 0` to restore web API usage.

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Get-NordVPNCountries.md)

[Help Index](./INDEX.md)
