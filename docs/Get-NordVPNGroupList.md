
# Get-NordVPNGroupList

## SYNOPSIS
Gets a list of NordVPN server groups.

## SYNTAX

### DefaultOperation (Default)
```
Get-NordVPNGroupList [-UpdateFallback] [<CommonParameters>]
```

### Offline
```
Get-NordVPNGroupList [-Offline] [<CommonParameters>]
```

## DESCRIPTION
Returns a list of all groups that NordVPN servers are tagged with.
By default, the required data is downloaded from the NordVPN web API and
processed to produce a list of group entries, each of which is a
NordVPNGroup object.

Please see [About NordVPN-Servers Classes](./about_NordVPN-Servers_Classes.md)
to view the complete structure of a group entry.

## EXAMPLES

### Example 1
```
PS C:\> Get-NordVPNGroupList

  ID Name                      Group Code                             Type          Created     Updated
  -- ----                      ----------                             ----          -------     -------
   1 Double VPN                legacy_double_vpn                      Legacy      2017/06/13  2017/06/13
   3 Onion Over VPN            legacy_onion_over_vpn                  Legacy      2017/06/13  2017/11/06
   5 Ultra fast TV             legacy_ultra_fast_tv                   Legacy      2017/06/13  2017/06/13
   7 Anti DDoS                 legacy_anti_ddos                       Legacy      2017/06/13  2017/06/13
   9 Dedicated IP              legacy_dedicated_ip                    Legacy      2017/06/13  2018/08/22
  11 Standard VPN servers      legacy_standard                        Legacy      2017/06/13  2017/06/13
  13 Netflix USA               legacy_netflix_usa                     Legacy      2017/06/13  2017/06/13
  15 P2P                       legacy_p2p                             Legacy      2017/06/13  2017/06/13
  17 Obfuscated Servers        legacy_obfuscated_servers              Legacy      2017/06/13  2017/06/13
  19 Europe                    europe                                 Regions     2017/10/27  2017/10/27
  21 The Americas              the_americas                           Regions     2017/10/27  2017/10/30
  23 Asia Pacific              asia_pacific                           Regions     2017/10/27  2017/10/30
  25 Africa, the Middle East   africa_the_middle_east_and_india       Regions     2017/10/27  2017/10/30
```

Displays a list of all NordVPN server groups, and their codes, IDs, and types.

### Example 2
```
PS C:\> $allServers = Get-NordVPNServerList
PS C:\> Get-NordVPNGroupList | `
>> Format-Table FriendlyName, @{
>>     Label = "No. Servers"
>>     Expression = {
>>         $groupCode = $_.Code
>>         ($allServers | Where-Object {$_.Groups.Code -contains $groupCode}).Count
>>     }
>> } -AutoSize

FriendlyName                      No. Servers
------------                      -----------
Double VPN                                 90
Onion Over VPN                              3
Ultra fast TV                               0
Anti DDoS                                   0
Dedicated IP                              127
Standard VPN servers                     4271
Netflix USA                                 0
P2P                                      4020
Obfuscated Servers                        473
Europe                                   1974
The Americas                             2219
Asia Pacific                              650
Africa, the Middle East and India         121
```

Displays a list of NordVPN server groups, with the number of servers in each
group. Notable is the use of a calculated property in Format-Table.

Observing the mutual exclusivity of some groups, the total number of servers
can be calculated and verified:

- Taking the the sum of Double VPN, Onion, Dedicated IP, Standard, and Obfuscated
  servers: `90 + 3 + 127 + 4271 + 473 = 4964`.
- Taking the sum of Europe, Americas, APAC and AMEI:
  `1974 + 2219 + 650 + 121 = 4964`.

## PARAMETERS

### -Offline
Temporarily overrides the OfflineMode setting and uses the fallback file stored
in *NordVPN_Groups.xml*. This does not change the value of the setting but is
useful when access to the web API is not available.

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
Passing this switch causes the function to update the *NordVPN_Groups.xml*
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

### NordVPNGroupList
## NOTES
The module utilises a group cache to reduce API calls.
Further calls after the initial download will retrieve data from a local cache
of the group list until the number of seconds defined with
`Set-NordVPNGroupCacheLifetime` (default: 600s) has passed, after which the
cache will be updated using the API.

To force downloading from the API, run `Clear-NordVPNGroupCache` first.

If the module is configured to only use the fallback files, with the command
`Set-NordVPNModuleSetting OfflineMode 1`, the group list will be retrieved from
NordVPN_Groups.xml in the module directory. This is useful for offline
environments.

Use `Set-NordVPNModuleSetting OfflineMode 0` to restore web API usage.

As the list returned is a custom class, in order to pass it through the
pipeline, you should use the [GetEnumerator()](https://docs.microsoft.com/en-us/dotnet/api/system.collections.ienumerable.getenumerator)
method, e.g `(Get-NordVPNGroupList).GetEnumerator() | ...`

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Get-NordVPNGroupList.md)
