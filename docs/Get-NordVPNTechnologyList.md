---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version: https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Get-NordVPNTechnologyList.md
schema: 2.0.0
---

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
By default, the required data is downloaded from the NordVPN web API and processed to produce an array of technology entries, each of which is a hashtable.

The structure of a technology entry is as follows (powershell notation):

@{
     Id           = \[Int64\] # Unique ID for technology
     Code         = \[String\] # Unique short code for technology
     FriendlyName = \[String\] # Full name of technology
     Created      = \[DateTime\] # When technology entry was first registered
     Updated      = \[DateTime\] # When technology entry was last revised
 }

## EXAMPLES

### Example 1
```
PS C:\> Get-NordVPNTechnologyList | Select-Object Id, FriendlyName, Code

Id FriendlyName              Code
-- ------------              ----
 1 IKEv2/IPSec               ikev2
 3 OpenVPN UDP               openvpn_udp
 5 OpenVPN TCP               openvpn_tcp
 7 Socks 5                   socks
 9 HTTP Proxy                proxy
11 PPTP                      pptp
13 L2TP/IPSec                l2tp
15 OpenVPN UDP Obfuscated    openvpn_xor_udp
17 OpenVPN TCP Obfuscated    openvpn_xor_tcp
19 HTTP CyberSec Proxy       proxy_cybersec
21 HTTP Proxy (SSL)          proxy_ssl
23 HTTP CyberSec Proxy (SSL) proxy_ssl_cybersec
26 IKEv2/IPSec IPv6          ikev2_v6
29 OpenVPN UDP IPv6          openvpn_udp_v6
32 OpenVPN TCP IPv6          openvpn_tcp_v6
35 Wireguard                 wireguard_udp
38 OpenVPN UDP TLS Crypt     openvpn_udp_tls_crypt
41 OpenVPN TCP TLS Crypt     openvpn_tcp_tls_crypt
42 OpenVPN UDP Dedicated     openvpn_dedicated_udp
45 OpenVPN TCP Dedicated     openvpn_dedicated_tcp
48 v2ray                     v2ray
```

Displays a list of all compatible NordVPN server technologies, by their names, short codes, and IDs.

### Example 2
```
PS C:\> $allServers = Get-NordVPNServerList
PS C:\> Get-NordVPNTechnologyList | Select-Object FriendlyName, Code | `
>> Format-Table FriendlyName, @{
>>     Label = "No. Servers"
>>     Expression = {
>>         $techCode = $_.Code
>>         ($allServers | Where-Object {$_.Technologies.Code -contains $techCode}).Count
>>     }
>> } -AutoSize

FriendlyName              No. Servers
------------              -----------
IKEv2/IPSec                      5169
OpenVPN UDP                      5353
OpenVPN TCP                      5355
Socks 5                          3413
HTTP Proxy                       3984
PPTP                                0
L2TP/IPSec                          0
OpenVPN UDP Obfuscated            458
OpenVPN TCP Obfuscated            467
HTTP CyberSec Proxy              3981
HTTP Proxy (SSL)                 5150
HTTP CyberSec Proxy (SSL)        5141
IKEv2/IPSec IPv6                    0
OpenVPN UDP IPv6                    0
OpenVPN TCP IPv6                    0
Wireguard                         970
OpenVPN UDP TLS Crypt               0
OpenVPN TCP TLS Crypt               0
OpenVPN UDP Dedicated             118
OpenVPN TCP Dedicated             118
v2ray                               0
```

Displays a list of NordVPN supported server technologies, with the number of servers compatible with that technology.
Notable is the use of a calculated property in Format-Table.

### Example 3
```
PS C:\> $allServers = Get-NordVPNServerList
PS C:\> $numServers = $allServers.Count
PS C:\> Get-NordVPNTechnologyList | Select-Object FriendlyName, Code | `
>> Select-Object FriendlyName, @{
>>     Label = "% Server support"
>>     Expression = {
>>         $techCode = $_.Code
>>         $numSupport = ($allServers | Where-Object {$_.Technologies.Code -contains $techCode}).Count
>>         $pcSupport = $numSupport / $numServers
>>         if ($pcSupport -gt 0) {'{0,6:p2}' -f $pcSupport}
>>     }
>> } | Where-Object "% Server support" -ne $null | Format-Table -AutoSize

FriendlyName              % Server support
------------              ----------------
IKEv2/IPSec               88.82%
OpenVPN UDP               91.97%
OpenVPN TCP               92.03%
Socks 5                   58.04%
HTTP Proxy                67.80%
OpenVPN UDP Obfuscated     7.80%
OpenVPN TCP Obfuscated     7.95%
HTTP CyberSec Proxy       67.74%
HTTP Proxy (SSL)          88.43%
HTTP CyberSec Proxy (SSL) 88.37%
Wireguard                 17.29%
OpenVPN UDP Dedicated      2.01%
OpenVPN TCP Dedicated      2.01%
```

Similar to example 2, except the percentage of servers that support each technology is being calculated.
The technologies with no current support are also excluded from the list.

Here, the -f Format operator (https://docs.microsoft.com/en-us/dotnet/api/system.string.format)is used to take a decimal value and display a padded percentage to 2 d.p.

## PARAMETERS

### -Offline
Temporarily overrides the OfflineMode setting and uses the fallback file stored in NordVPN_Technologies.xml .
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
Passing this switch causes the function to update the NordVPN_Technologies.xml fallback file, using the data retrieved from the NordVPN web API or cache.
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
Further calls after the initial download will retrieve data from a local cache of the group list until the number of seconds defined with `Set-NordVPNTechnologyCacheLifetime` (default: 600s) has passed, after which the cache will be updated using the API.
To force downloading from the API, run `Clear-NordVPNTechnologyCache` first.

If the module is configured to only use the fallback files, with the command `Set-NordVPNModuleSetting OfflineMode 1`, the technology list will be retrieved from NordVPN_Technologies.xml in the module directory.
This is useful for offline environments.
Use `Set-NordVPNModuleSetting OfflineMode 0` to restore web API usage.

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Get-NordVPNTechnologyList.md)

[Help Index]()
