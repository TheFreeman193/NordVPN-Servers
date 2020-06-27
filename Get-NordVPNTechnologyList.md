
# Get-NordVPNTechnologyList

## SYNOPSIS
Gets a list of the supported technologies of NordVPN servers.

## SYNTAX

### DefaultOperation (Default)
```
Get-NordVPNTechnologyList [-UpdateFallback] [<CommonParameters>]
```

### Offline
```
Get-NordVPNTechnologyList [-Offline] [<CommonParameters>]
```

## DESCRIPTION
Returns a list of all technologies that NordVPN servers support.
By default, the required data is downloaded from the NordVPN web API and
processed to produce a list of technology entries, each of which is a
NordVPNTechnology object.

Please see [About NordVPN-Servers Classes](./about_NordVPN-Servers_Classes.md)
to view the complete structure of a technology entry.

## EXAMPLES

### Example 1
```
PS C:\> Get-NordVPNTechnologyList

  ID Name                           Code                               Created             Updated
  -- ----                           ----                               -------             -------
   1 IKEv2/IPSec                    ikev2                        2017/03/21 12:00:24 2017/09/05 14:20:16
   3 OpenVPN UDP                    openvpn_udp                  2017/05/04 08:03:24 2017/05/09 19:27:37
   5 OpenVPN TCP                    openvpn_tcp                  2017/05/09 19:28:14 2017/05/09 19:28:14
   7 Socks 5                        socks                        2017/05/09 19:28:57 2017/06/13 14:27:05
   9 HTTP Proxy                     proxy                        2017/05/09 19:29:09 2017/06/13 14:25:29
  11 PPTP                           pptp                         2017/05/09 19:29:16 2017/05/09 19:29:16
  13 L2TP/IPSec                     l2tp                         2017/05/09 19:29:26 2017/09/05 14:19:42
  15 OpenVPN UDP Obfuscated         openvpn_xor_udp              2017/05/26 14:04:04 2017/11/07 08:37:53
  17 OpenVPN TCP Obfuscated         openvpn_xor_tcp              2017/05/26 14:04:27 2017/11/07 08:38:16
  19 HTTP CyberSec Proxy            proxy_cybersec               2017/08/22 12:44:49 2017/08/22 12:44:49
  21 HTTP Proxy (SSL)               proxy_ssl                    2017/10/02 12:45:14 2017/10/02 12:45:14
  23 HTTP CyberSec Proxy (SSL)      proxy_ssl_cybersec           2017/10/02 12:50:49 2017/10/02 12:50:49
  26 IKEv2/IPSec IPv6               ikev2_v6                     2018/09/18 13:35:16 2018/09/18 13:35:16
  29 OpenVPN UDP IPv6               openvpn_udp_v6               2018/09/18 13:35:38 2018/09/18 13:35:38
  32 OpenVPN TCP IPv6               openvpn_tcp_v6               2018/09/18 13:36:02 2018/09/18 13:36:02
  35 Wireguard                      wireguard_udp                2019/02/14 14:08:43 2019/02/14 14:08:43
  38 OpenVPN UDP TLS Crypt          openvpn_udp_tls_crypt        2019/03/21 14:52:42 2019/03/21 14:52:42
  41 OpenVPN TCP TLS Crypt          openvpn_tcp_tls_crypt        2019/03/21 14:53:05 2019/03/21 14:53:05
  42 OpenVPN UDP Dedicated          openvpn_dedicated_udp        2019/09/19 14:49:18 2019/09/19 14:49:18
  45 OpenVPN TCP Dedicated          openvpn_dedicated_tcp        2019/09/19 14:49:54 2019/09/19 14:49:54
  48 Skylark                        skylark                      2019/10/28 13:29:37 2020/05/14 06:18:41
```

Displays a list of all compatible NordVPN server technologies, along with
their names, short codes, and IDs.

### Example 2
```
PS C:\> $allServers = Get-NordVPNServerList
PS C:\> Get-NordVPNTechnologyList | `
>> Format-Table FriendlyName, @{
>>     Label = "No. Servers"
>>     Expression = {
>>         $techCode = $_.Code
>>         ($allServers | Where-Object {$_.Technologies.Code -contains $techCode}).Count
>>     }
>> } -AutoSize

FriendlyName              No. Servers
------------              -----------
IKEv2/IPSec                      4274
OpenVPN UDP                      4492
OpenVPN TCP                      4492
Socks 5                           443
HTTP Proxy                       1799
PPTP                                0
L2TP/IPSec                          0
OpenVPN UDP Obfuscated            473
OpenVPN TCP Obfuscated            473
HTTP CyberSec Proxy              1799
HTTP Proxy (SSL)                 4273
HTTP CyberSec Proxy (SSL)        4273
IKEv2/IPSec IPv6                    0
OpenVPN UDP IPv6                    0
OpenVPN TCP IPv6                    0
Wireguard                        4230
OpenVPN UDP TLS Crypt               0
OpenVPN TCP TLS Crypt               0
OpenVPN UDP Dedicated             127
OpenVPN TCP Dedicated             127
Skylark                             1
```

Displays a list of NordVPN supported server technologies, with the number of
servers compatible with that technology.
Notable is the use of a calculated property in Format-Table.

### Example 3
```
PS C:\> $allServers = Get-NordVPNServerList
PS C:\> $numServers = $allServers.Count
PS C:\> (Get-NordVPNTechnologyList).GetEnumerator() | `
>> Format-Table FriendlyName, @{
>>     Label = "% Server support"
>>     Expression = {
>>         $techCode = $_.Code
>>         $numSupport = ($allServers | Where-Object {$_.Technologies.Code -contains $techCode}).Count
>>         $numSupport / $numServers
>>     }
>>     FormatString = '{0,6:p2}'
>> } -AutoSize

FriendlyName              % Server support
------------              ----------------
IKEv2/IPSec                         86.07%
OpenVPN UDP                         90.46%
OpenVPN TCP                         90.46%
Socks 5                              8.92%
HTTP Proxy                          36.23%
OpenVPN UDP Obfuscated               9.52%
OpenVPN TCP Obfuscated               9.52%
HTTP CyberSec Proxy                 36.23%
HTTP Proxy (SSL)                    86.05%
HTTP CyberSec Proxy (SSL)           86.05%
Wireguard                           85.18%
OpenVPN UDP Dedicated                2.56%
OpenVPN TCP Dedicated                2.56%
Skylark                              0.02%
PPTP                                 0.00%
L2TP/IPSec                           0.00%
IKEv2/IPSec IPv6                     0.00%
OpenVPN UDP IPv6                     0.00%
OpenVPN TCP IPv6                     0.00%
OpenVPN UDP TLS Crypt                0.00%
OpenVPN TCP TLS Crypt                0.00%
```

Similar to example 2, except the percentage of servers that support each
technology is being calculated. The technologies with no current support
are also excluded from the list.

Here, the -f [Format operator](https://docs.microsoft.com/en-us/dotnet/api/system.string.format)
is used to take a decimal value and display a padded percentage to 2 d.p.

## PARAMETERS

### -Offline
Temporarily overrides the OfflineMode setting and uses the fallback file stored
in *NordVPN_Technologies.xml*. This does not change the value of the setting
but is useful when access to the web API is not available.

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
Passing this switch causes the function to update the
*NordVPN_Technologies.xml* fallback file, using the data retrieved from the
NordVPN web API or cache. This functionality cannot be used when OfflineMode is
enabled or the `-Offline` switch parameter is passed.

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

### NordVPNTechnologyList
## NOTES
The module utilises a group cache to reduce API calls.
Further calls after the initial download will retrieve data from a local cache
of the group list until the number of seconds defined with
`Set-NordVPNTechnologyCacheLifetime` (default: 600s) has passed, after which
the cache will be updated using the API.

To force downloading from the API, run `Clear-NordVPNTechnologyCache` first.

If the module is configured to only use the fallback files, with the command
`Set-NordVPNModuleSetting OfflineMode 1`, the technology list will be retrieved
from NordVPN_Technologies.xml in the module directory. This is useful for
offline environments.

Use `Set-NordVPNModuleSetting OfflineMode 0` to restore web API usage.

As the list returned is a custom class, in order to pass it through the
pipeline, you should use the [GetEnumerator()](https://docs.microsoft.com/en-us/dotnet/api/system.collections.ienumerable.getenumerator)
method, e.g `(Get-NordVPNTechnologyList).GetEnumerator() | ...`

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Get-NordVPNTechnologyList.html)

[Help Index](./HELPINDEX.md)
