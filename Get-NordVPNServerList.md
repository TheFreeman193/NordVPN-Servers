
# Get-NordVPNServerList

## SYNOPSIS
Gets the list of NordVPN servers.

## SYNTAX

### DefaultOperation (Default)
```
Get-NordVPNServerList [[-First] <UInt16>] [-UpdateFallback] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### RawData
```
Get-NordVPNServerList [[-First] <UInt16>] [-Raw] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Offline
```
Get-NordVPNServerList [-Offline] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Returns a list of NordVPN servers.
By default, this function returns all servers that match the passed parameters,
but the search can be limited to the first x servers with  `-First x`.

NOTE : Using the `-First` parameter will result in some servers matching the
filters being missed. You should only do so if this instance is acceptable.

This function utilises the raw NordVPN servers web API.
This means that a large quantity of data (~20 MB) must be downloaded and
parsed, as the raw API does not support direct filtering, and therefore this
must be done locally. For this reason, it is recommended to use
`Get-NordVPNRecommendedList` which utilises the recommended servers API, which
supports direct filtering. This function should be used in scenarios where all
servers need to be indexed, including those that are full/unavailable.

The structures of objects returned by this function can be found in the about
topic [About NordVPN-Servers Classes](.\about_NordVPN-Servers_Classes.md).

## EXAMPLES

### Example 1
```
PS C:\> $allServers = Get-NordVPNServerList
PS C:\> $allServers.Count
5871
PS C:\> $allServers[0]

Name                           Value
----                           -----
CountryCode                    US
Services                       {1, 5}
Status                         online
Updated                        03/04/2020 15:15:18
Created                        22/09/2016 00:00:00
CityCode                       manassas
City                           {CountryCode, Longitude, Code, Id…}
Specifications                 {8}
Hostname                       us349.nordvpn.com
PrimaryIP                      162.210.198.129
Groups                         {11, 15, 21}
Id                             590772
Country                        {Cities, Code, FriendlyName, Id}
Locations                      {21}
IPs                            {793}
Load                           100
Technologies                   {9, 5, 3, 7…}
```

Downloads the NordVPN server list, outputs the number of servers currently
registered, and shows the entry for the first server. This demonstrates the
structure of the Server entry.

### Example 2
```
PS C:\> Get-NordVPNServerList -Country JP -Group legacy_obfuscated_servers -Technology openvpn_xor_udp | Select-Object CityCode, Hostname, PrimaryIP, Load

CityCode Hostname          PrimaryIP     Load
-------- --------          ---------     ----
tokyo    jp492.nordvpn.com 212.102.50.66   11
tokyo    jp493.nordvpn.com 212.102.50.67    5
tokyo    jp494.nordvpn.com 212.102.50.68   17
tokyo    jp495.nordvpn.com 212.102.50.69   25
tokyo    jp496.nordvpn.com 212.102.50.71   22
tokyo    jp497.nordvpn.com 212.102.50.72   68
tokyo    jp498.nordvpn.com 212.102.50.73   49
tokyo    jp499.nordvpn.com 212.102.50.74    9
tokyo    jp500.nordvpn.com 212.102.50.76    9
tokyo    jp501.nordvpn.com 212.102.50.77   46
tokyo    jp502.nordvpn.com 212.102.50.78   15
tokyo    jp503.nordvpn.com 212.102.50.79   24
tokyo    jp504.nordvpn.com 212.102.50.81    6
tokyo    jp505.nordvpn.com 212.102.50.82   13
tokyo    jp506.nordvpn.com 212.102.50.83   15
tokyo    jp507.nordvpn.com 212.102.50.84   13
```

Displays a list of all obfuscated servers in Japan, using the country, group,
and technology filters.

### Example 3
```
PS C:\> Get-NordVPNServerList -UpdateFallback -Offline
Get-NordVPNServerList: Parameter set cannot be resolved using the specified named parameters. One or more parameters issued cannot be used together or an insufficient number of parameters were provided.
PS C:\> Get-NordVPNServerList -UpdateFallback -First 100
Get-NordVPNServerList: Parameter set cannot be resolved using the specified named parameters. One or more parameters issued cannot be used together or an insufficient number of parameters were provided.
PS C:\> Get-NordVPNServerList -Offline -First 100
Get-NordVPNServerList: Parameter set cannot be resolved using the specified named parameters. One or more parameters issued cannot be used together or an insufficient number of parameters were provided.
```

Demonstrates the mutual exclusivity of the `-Offline`, `-UpdateFallback`, and
`-First <int>` parameters. The `-First` parameter is designed to reduce the
amount of data received from the API, at the expensive of completeness in
results if any filters are applied. Since this results in an incomplete list,
the function will not allow the fallback file to be updated.

Likewise, the `-First` parameter is inconsequential when using local data.
The fallback file will also not be updated if the data is being retrieved from
it.

### Example 4
```
PS C:\> $MyRequirements = @(
>> [pscustomobject]@{Country = 'DE'; Group = 'legacy_obfuscated_servers'}
>> [pscustomobject]@{Country = 'BR'; Technology = 'ikev2'}
>> [pscustomobject]@{Country = 'US'; Group = 'legacy_obfuscated_servers'; Technology='openvpn_dedicated_udp'}
>> )
PS C:\> $MyRequirements | Get-NordVPNServerList | Select-Object Hostname, CountryCode, Load

WARNING: No servers in the first 5873 results matched the filters! Filters:
        Country: US
        Group: legacy_obfuscated_servers
        Technology: openvpn_dedicated_udp
Try increasing the value of the -First parameter or changing the filters.
Hostname          CountryCode Load
--------          ----------- ----
de666.nordvpn.com DE            72
de667.nordvpn.com DE            60
de668.nordvpn.com DE            72
de669.nordvpn.com DE            95
de670.nordvpn.com DE           100
de671.nordvpn.com DE            74
de672.nordvpn.com DE            55
de673.nordvpn.com DE            96
de726.nordvpn.com DE           100
de727.nordvpn.com DE           100
de728.nordvpn.com DE            54
de729.nordvpn.com DE            46
de730.nordvpn.com DE            24
de731.nordvpn.com DE           100
de732.nordvpn.com DE            31
de733.nordvpn.com DE           100
br13.nordvpn.com  BR            45
br14.nordvpn.com  BR            34
br15.nordvpn.com  BR            43
br16.nordvpn.com  BR            38
br17.nordvpn.com  BR            44
br18.nordvpn.com  BR            30
br19.nordvpn.com  BR            39
br20.nordvpn.com  BR            48
br21.nordvpn.com  BR            31
br22.nordvpn.com  BR           100
br23.nordvpn.com  BR            58
br24.nordvpn.com  BR            31
br25.nordvpn.com  BR            29
br26.nordvpn.com  BR            32
br27.nordvpn.com  BR            24
br28.nordvpn.com  BR            42
br29.nordvpn.com  BR            17
br30.nordvpn.com  BR            13
br31.nordvpn.com  BR            13
br32.nordvpn.com  BR            31
br33.nordvpn.com  BR            59
br34.nordvpn.com  BR            16
br35.nordvpn.com  BR            23
br36.nordvpn.com  BR            61
br37.nordvpn.com  BR            41
br38.nordvpn.com  BR            35
br39.nordvpn.com  BR            23
br40.nordvpn.com  BR            23
br41.nordvpn.com  BR            49
br42.nordvpn.com  BR            28
br43.nordvpn.com  BR            45
br44.nordvpn.com  BR            17
br45.nordvpn.com  BR             3
br46.nordvpn.com  BR             5
br48.nordvpn.com  BR             4
br49.nordvpn.com  BR             3
br50.nordvpn.com  BR             3
```

Creates three custom filter profiles, passes them to `Get-NordVPNServerList`
and displays the results as a list with the hostname, country code and current
load. Notable is the warning displayed when the filter returns no results. In
this case, the third request, there are no US servers that support both
obfuscation and dedicated IP allocations.

It is also important to note that piping to `Get-NordVPNServerList` does not
result in multiple API calls, unlike `Get-NordVPNRecommendedList`. The entire
servers list is retrieved once, and then filters are applied for each object in
the pipeline. You can also pipe requests to the function when the `-Offline` or
`-UpdateFallback` switches are present, since the filters are not applied until
after the server list is processed.

### Example 5
```
PS C:\> (Measure-Command {Get-NordVPNServerList}).TotalSeconds
18.4931146
PS C:\> (Measure-Command {Get-NordVPNServerList -UpdateFallback}).TotalSeconds
25.496875
PS C:\> (Measure-Command {Get-NordVPNServerList -Offline}).TotalSeconds
3.1637942
PS C:\> (Get-ItemProperty .\NordVPN_Servers.xml).Length / 1MB
117.799512863159
PS C:\> (Get-ItemProperty .\NordVPN_Servers.xml.zip).Length / 1MB
2.66928958892822
```

Demonstrates the time taken to download and process all server entries, as well
as the additional time when these processed entries are written to file and
compressed. The operation is ~40% longer when the fallback file is updated.
However, using the fallback file which contains pre-processed server entries,
is 5-6x faster than downloading and processing this data.
This is true even when the setting `DeleteServerFallbackAfterUse` is enabled,
meaning the archive is extracted each time the function is run.

It is therefore important to consider how often the list of registered servers
needed to be updated, and the fallback used where necessary to improve
performance and reduce load on the web API.

Also notable is the size of the uncompressed server fallback file (~50 MB).
When the file is updated, it is automatically compressed to a much more
reasonable ~2 MB. By default, the uncompressed file is kept to improve
performance when using the local data. However, on systems where storage space
is an important consideration, such as thin clients, the setting
`DeleteServerFallbackAfterUse` can be enabled, which causes the uncompressed
file to be deleted after each use. In this way, it behaves as a temporary file
and only the much smaller compressed version needs to persist on the disk.

Use `Set-NordVPNModuleSetting DeleteServerFallbackAfterUse 1` to enable this
feature.

### Example 6
```
PS C:\> Set-NordVPNModuleSetting OfflineMode 1
PS C:\> (Measure-Command {Get-NordVPNServerList}).TotalSeconds
2.8380877
```

This shows the functionality of the OfflineMode module setting.
When enabled, the Countries, Groups, Technologies, and Servers lists are
retrieved only from the local fallback files.
This is useful in scenarios where network access may be temporarily limited.

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

### -First
Searches only the number of servers specified (1-65535).

`NOTE:` Lowering this number may result in some servers matching the filters to
be missed.

```yaml
Type: UInt16
Parameter Sets: DefaultOperation, RawData
Aliases:

Required: False
Position: 0
Default value: 8192
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offline
Temporarily overrides the OfflineMode setting and uses the fallback file stored
in NordVPN_Servers.xml.zip. This does not change the value of the setting but
is useful when many calls to `Get-NordVPNServerList` will be made. The first
call can be used to update the fallback with `-UpdateFallback` and subsequent
calls can utilise `-Offline` to use the downloaded copy.

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

### -Raw
Returns the raw server entry data without processing.
This speeds up operation but results in an inconsistent data structure due to
the API's naming conventions.

You cannot use this switch with the `-Offline` or `-UpdateFallback` parameters.

```yaml
Type: SwitchParameter
Parameter Sets: RawData
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateFallback
Passing this switch causes the function to update the NordVPN_Servers.xml.zip
file, using the data retrieved from the NordVPN web API or cache. This is
useful if many called will be made to `Get-NordVPNServerList`, since the
offline data can be loaded much more quickly and does not need to be parsed,
unlike data directly from the web API.

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

### NordVPNServerList
## NOTES
If the module is configured to only use the fallback files, with the command
`Set-NordVPNModuleSetting OfflineMode 1`, the server list will be retrieved
from NordVPN_Servers.xml in the module directory. This is useful for offline
environments.

Use `Set-NordVPNModuleSetting OfflineMode 0` to restore web API usage.

NOTE : The NordVPN_Servers.xml fallback file is not included with the module as
must be generated using `Get-NordVPNServerList -UpdateFallback` should this
functionality be required.

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Get-NordVPNServerList.html)

[Help Index](./HELPINDEX.md)
