---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version: https://thefreeman193.github.io/NordVPN-Servers/Show-NordVPNGroupList.html
schema: 2.0.0
---

# Show-NordVPNGroupList

## SYNOPSIS
Shows all the NordVPN server groups in a neat format.

## SYNTAX

```
Show-NordVPNGroupList [<CommonParameters>]
```

## DESCRIPTION
Displays a formatted table of NordVPN server groups.
This output is useful for cross-referencing group names with their codes/IDs.

## EXAMPLES

### Example 1
```
PS C:\> Show-NordVPNGroupList

Server Groups:

Id FriendlyName                      Code                             Type            Created             Updated
-- ------------                      ----                             ----            -------             -------
 1 Double VPN                        legacy_double_vpn                Legacy category 2017-06-13 13:41:00 2017-06-13 1…
 3 Onion Over VPN                    legacy_onion_over_vpn            Legacy category 2017-06-13 13:41:22 2017-11-06 1…
 5 Ultra fast TV                     legacy_ultra_fast_tv             Legacy category 2017-06-13 13:41:42 2017-06-13 1…
 7 Anti DDoS                         legacy_anti_ddos                 Legacy category 2017-06-13 13:42:08 2017-06-13 1…
 9 Dedicated IP                      legacy_dedicated_ip              Legacy category 2017-06-13 13:42:36 2018-08-22 1…
11 Standard VPN servers              legacy_standard                  Legacy category 2017-06-13 13:43:00 2017-06-13 1…
13 Netflix USA                       legacy_netflix_usa               Legacy category 2017-06-13 13:43:20 2017-06-13 1…
15 P2P                               legacy_p2p                       Legacy category 2017-06-13 13:43:38 2017-06-13 1…
17 Obfuscated Servers                legacy_obfuscated_servers        Legacy category 2017-06-13 13:44:10 2017-06-13 1…
19 Europe                            europe                           Regions         2017-10-27 14:17:17 2017-10-27 1…
21 The Americas                      the_americas                     Regions         2017-10-27 14:23:03 2017-10-30 0…
23 Asia Pacific                      asia_pacific                     Regions         2017-10-27 14:23:51 2017-10-30 0…
25 Africa, the Middle East and India africa_the_middle_east_and_india Regions         2017-10-27 14:40:12 2017-10-30 0…
```

Displays a list of NordVPN server groups.
Each entry details the name, ID, code, type, and creation/update dates of the group.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Show-NordVPNGroupList.html)

[Help Index]()

