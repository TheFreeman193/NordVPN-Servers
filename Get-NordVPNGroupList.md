---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version: https://thefreeman193.github.io/NordVPN-Servers/Get-NordVPNGroupList.html
schema: 2.0.0
---

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
By default, the required data is downloaded from the NordVPN web API and processed to produce an array of group entries, each of which is a hashtable.

The structure of a group entry is as follows (powershell notation):

@{
     Id           = \[Int64\] # Unique ID for group
     Code         = \[String\] # Unique short code for group
     FriendlyName = \[String\] # Full name of group
     Created      = \[DateTime\] # When group entry was first registered
     Updated      = \[DateTime\] # When group entry was last revised
     Type         = \[Hashtable\]@{
         Id           = \[Int32\] # Unique ID for group type
         Created      = \[DateTime\] # When group type entry was first registered
         Updated      = \[DateTime\] # When group type entry was last revised
         FriendlyName = \[String\] # Full name of group type
         Code         = \[String\] # Unique short code for group type
     }
 }

## EXAMPLES

### Example 1
```
PS C:\> PS C:\> Get-NordVPNGroupList | Select-Object Id, FriendlyName, Code, @{
>>     Label = "Type"
>>     Expression = {$_.Type.FriendlyName}
>> }

Id FriendlyName                      Code                             Type
-- ------------                      ----                             ----
 1 Double VPN                        legacy_double_vpn                Legacy category
 3 Onion Over VPN                    legacy_onion_over_vpn            Legacy category
 5 Ultra fast TV                     legacy_ultra_fast_tv             Legacy category
 7 Anti DDoS                         legacy_anti_ddos                 Legacy category
 9 Dedicated IP                      legacy_dedicated_ip              Legacy category
11 Standard VPN servers              legacy_standard                  Legacy category
13 Netflix USA                       legacy_netflix_usa               Legacy category
15 P2P                               legacy_p2p                       Legacy category
17 Obfuscated Servers                legacy_obfuscated_servers        Legacy category
19 Europe                            europe                           Regions
21 The Americas                      the_americas                     Regions
23 Asia Pacific                      asia_pacific                     Regions
25 Africa, the Middle East and India africa_the_middle_east_and_india Regions
```

Displays a list of all NordVPN server groups, and their codes, IDs, and types.

### Example 2
```
PS C:\> $allServers = Get-NordVPNServerList
PS C:\> Get-NordVPNGroupList | Select-Object FriendlyName, Code | `
>> Format-Table FriendlyName, @{
>>     Label = "No. Servers"
>>     Expression = {
>>         $groupCode = $_.Code
>>         ($allServers | Where-Object {$_.Groups.Code -contains $groupCode}).Count
>>     }
>> } -AutoSize

FriendlyName                      No. Servers
------------                      -----------
Double VPN                                 67
Onion Over VPN                              0
Ultra fast TV                               0
Anti DDoS                                   0
Dedicated IP                              118
Standard VPN servers                     5177
Netflix USA                                 0
P2P                                      4988
Obfuscated Servers                        467
Europe                                   2737
The Americas                             2307
Asia Pacific                              657
Africa, the Middle East and India         128
```

Displays a list of NordVPN server groups, with the number of servers in each group.
Notable is the use of a calculated property in Format-Table.

Observing the mutual exclusivity of some groups, the total number of servers can be calculated and verified:

Taking the the sum of Double VPN, Dedicated IP, Standard, and Obfuscated servers: 67 + 118 + 5177 + 467 = 5829 .
Taking the sum of Europe, Americas, APAC and AMEI: 2737 + 2307 + 657 + 128 = 5829 .

## PARAMETERS

### -Offline
Temporarily overrides the OfflineMode setting and uses the fallback file stored in NordVPN_Groups.xml .
This does not change the value of the setting but is useful when access to the web API is not available.
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
Passing this switch causes the function to update the NordVPN_Groups.xml fallback file, using the data retrieved from the NordVPN web API or cache.
This functionality cannot be used when OfflineMode is enabled or the `-Offline` switch parameter is passed.

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

### System.Array
## NOTES
The module utilises a group cache to reduce API calls.
Further calls after the initial download will retrieve data from a local cache of the group list until the number of seconds defined with `Set-NordVPNGroupCacheLifetime` (default: 600s) has passed, after which the cache will be updated using the API.
To force downloading from the API, run `Clear-NordVPNGroupCache` first.

If the module is configured to only use the fallback files, with the command `Set-NordVPNModuleSetting OfflineMode 1`, the group list will be retrieved from NordVPN_Groups.xml in the module directory.
This is useful for offline environments.
Use `Set-NordVPNModuleSetting OfflineMode 0` to restore web API usage.

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Get-NordVPNGroupList.html)
