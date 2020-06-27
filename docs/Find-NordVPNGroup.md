# Find-NordVPNGroup

## SYNOPSIS
Searches for NordVPN server groups.

## SYNTAX

### By Friendly Name (Default)
```
Find-NordVPNGroup [-FriendlyName] <String> [-Offline] [<CommonParameters>]
```

### By Id
```
Find-NordVPNGroup -Id <String> [-Offline] [<CommonParameters>]
```

### By Code
```
Find-NordVPNGroup -Code <String> [-Offline] [<CommonParameters>]
```

### By Type Code
```
Find-NordVPNGroup -TypeCode <String> [-Offline] [<CommonParameters>]
```

## DESCRIPTION
Searches for and returns a list of groups used to tag NordVPN servers.

By default, the required data is downloaded from the NordVPN web API and
processed to produce an array of matching group entries, each of which is a
NordVPNGroup object.

Please see [About NordVPN-Servers Classes](./about_NordVPN-Servers_Classes.md)
to view the complete structure of a group entry.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-NordVPNGroup -TypeCode legacy*

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
```

Searches for all NordVPN server groups with a type code beginning with legacy.
This returns all groups with type 'legacy_group_category'.

### Example 2
```powershell
PS C:\> Find-NordVPNGroup -TypeCode regions

 ID Name                      Group Code                             Type          Created     Updated
  -- ----                      ----------                             ----          -------     -------
  19 Europe                    europe                                 Regions     2017/10/27  2017/10/27
  21 The Americas              the_americas                           Regions     2017/10/27  2017/10/30
  23 Asia Pacific              asia_pacific                           Regions     2017/10/27  2017/10/30
  25 Africa, the Middle East   africa_the_middle_east_and_india       Regions     2017/10/27  2017/10/30
     and India
```

Searches for all NordVPN server region groups.

## PARAMETERS

### -Code
Please enter a group Code.
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
Please enter a group name.
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
Please enter a group ID.
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

### -TypeCode
Please enter a group type code e.g. 'regions'.
Wildcard characters (?*\[\]) are allowed.

```yaml
Type: String
Parameter Sets: ByTypeCode
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -Offline
Temporarily overrides the OfflineMode setting and uses the fallback file stored
in *NordVPN_Groups.xml*. This does not change the value of the setting but is
useful when access to the web API is not available.

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

### NordVPNGroup

## NOTES

Please refer to the help topic for [Get-NordVPNGroupList](./Get-NordVPNGroupList.md)
for more details on offline usage, caching, and fallback files.

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Find-NordVPNGroup.md)

[Help Index](./INDEX.md)
