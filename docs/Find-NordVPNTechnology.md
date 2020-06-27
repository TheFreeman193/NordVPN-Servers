# Find-NordVPNTechnology

## SYNOPSIS
Searches for supported technologies of NordVPN servers.

## SYNTAX

### By Friendly Name (Default)
```
Find-NordVPNTechnology [-FriendlyName] <String> [-Offline] [<CommonParameters>]
```

### By Id
```
Find-NordVPNTechnology [-Id] <String> [-Offline] [<CommonParameters>]
```

### By Code
```
Find-NordVPNTechnology [-Code] <String> [-Offline] [<CommonParameters>]
```

## DESCRIPTION
Searches for and returns a list of technologies supported by NordVPN servers.

By default, the required data is downloaded from the NordVPN web API and
processed to produce an array of matching technology entries, each of which is
a NordVPNTechnology object.

Please see [About NordVPN-Servers Classes](./about_NordVPN-Servers_Classes.md)
to view the complete structure of a technology entry.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-NordVPNTechnology -Code openvpn*

  ID Name                           Code                               Created             Updated
  -- ----                           ----                               -------             -------
   3 OpenVPN UDP                    openvpn_udp                  2017/05/04 08:03:24 2017/05/09 19:27:37
   5 OpenVPN TCP                    openvpn_tcp                  2017/05/09 19:28:14 2017/05/09 19:28:14
  15 OpenVPN UDP Obfuscated         openvpn_xor_udp              2017/05/26 14:04:04 2017/11/07 08:37:53
  17 OpenVPN TCP Obfuscated         openvpn_xor_tcp              2017/05/26 14:04:27 2017/11/07 08:38:16
  29 OpenVPN UDP IPv6               openvpn_udp_v6               2018/09/18 13:35:38 2018/09/18 13:35:38
  32 OpenVPN TCP IPv6               openvpn_tcp_v6               2018/09/18 13:36:02 2018/09/18 13:36:02
  38 OpenVPN UDP TLS Crypt          openvpn_udp_tls_crypt        2019/03/21 14:52:42 2019/03/21 14:52:42
  41 OpenVPN TCP TLS Crypt          openvpn_tcp_tls_crypt        2019/03/21 14:53:05 2019/03/21 14:53:05
  42 OpenVPN UDP Dedicated          openvpn_dedicated_udp        2019/09/19 14:49:18 2019/09/19 14:49:18
  45 OpenVPN TCP Dedicated          openvpn_dedicated_tcp        2019/09/19 14:49:54 2019/09/19 14:49:54
```

Searches for all NordVPN server technologies with codes beginning with
'openvpn'.

### Example 2
```
PS C:\> $allServers = Get-NordVPNServerList
PS C:\> $numServers = $allServers.Count
PS C:\> Find-NordVPNTechnology -FriendlyName *UDP* | `
>> Format-Table FriendlyName, @{
>>     Label = "% Server support"
>>     FormatString = '{0,6:p2}'
>>     Expression = {
>>         $techCode = $_.Code
>>         $numSupport = ($allServers | Where-Object {$_.Technologies.Code -contains $techCode}).Count
>>         $numSupport / $numServers
>>     }
>> } -AutoSize

FriendlyName           % Server support
------------           ----------------
OpenVPN UDP                      90.46%
OpenVPN UDP Obfuscated            9.52%
OpenVPN UDP IPv6                  0.00%
OpenVPN UDP TLS Crypt             0.00%
OpenVPN UDP Dedicated             2.56%
```

Searches for all server technologies with 'UDP' in the friendly name and
displays beside each the percentage of NordVPN servers that currently support
it.

## PARAMETERS

### -Code
Please enter a technology Code.
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
Please enter a technology name.
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
Please enter a technology ID.
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
in *NordVPN_Technologies.xml*. This does not change the value of the setting
but is useful when access to the web API is not available.

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

### NordVPNTechnology

## NOTES

Please refer to the help topic for [Get-NordVPNTechnologyList](./Get-NordVPNTechnologyList.md)
for more details on offline usage, caching, and fallback files.

## RELATED LINKS
