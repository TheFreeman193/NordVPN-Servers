---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version: https://thefreeman193.github.io/NordVPN-Servers/Show-NordVPNTechnologyList.html
schema: 2.0.0
---

# Show-NordVPNTechnologyList

## SYNOPSIS
Shows all the NordVPN server technologies in a neat format.

## SYNTAX

```
Show-NordVPNTechnologyList [<CommonParameters>]
```

## DESCRIPTION
Displays a formatted table of NordVPN compatible technologies.
This output is useful for cross-referencing technologies with their codes/IDs.

## EXAMPLES

### Example 1
```
PS C:\> Show-NordVPNTechnologyList

Server Technologies:

Id FriendlyName              Code                  Created             Updated
-- ------------              ----                  -------             -------
 1 IKEv2/IPSec               ikev2                 2017-03-21 12:00:24 2017-09-05 14:20:16
 3 OpenVPN UDP               openvpn_udp           2017-05-04 08:03:24 2017-05-09 19:27:37
 5 OpenVPN TCP               openvpn_tcp           2017-05-09 19:28:14 2017-05-09 19:28:14
 7 Socks 5                   socks                 2017-05-09 19:28:57 2017-06-13 14:27:05
 9 HTTP Proxy                proxy                 2017-05-09 19:29:09 2017-06-13 14:25:29
11 PPTP                      pptp                  2017-05-09 19:29:16 2017-05-09 19:29:16
13 L2TP/IPSec                l2tp                  2017-05-09 19:29:26 2017-09-05 14:19:42
15 OpenVPN UDP Obfuscated    openvpn_xor_udp       2017-05-26 14:04:04 2017-11-07 08:37:53
17 OpenVPN TCP Obfuscated    openvpn_xor_tcp       2017-05-26 14:04:27 2017-11-07 08:38:16
19 HTTP CyberSec Proxy       proxy_cybersec        2017-08-22 12:44:49 2017-08-22 12:44:49
21 HTTP Proxy (SSL)          proxy_ssl             2017-10-02 12:45:14 2017-10-02 12:45:14
23 HTTP CyberSec Proxy (SSL) proxy_ssl_cybersec    2017-10-02 12:50:49 2017-10-02 12:50:49
26 IKEv2/IPSec IPv6          ikev2_v6              2018-09-18 13:35:16 2018-09-18 13:35:16
29 OpenVPN UDP IPv6          openvpn_udp_v6        2018-09-18 13:35:38 2018-09-18 13:35:38
32 OpenVPN TCP IPv6          openvpn_tcp_v6        2018-09-18 13:36:02 2018-09-18 13:36:02
35 Wireguard                 wireguard_udp         2019-02-14 14:08:43 2019-02-14 14:08:43
38 OpenVPN UDP TLS Crypt     openvpn_udp_tls_crypt 2019-03-21 14:52:42 2019-03-21 14:52:42
41 OpenVPN TCP TLS Crypt     openvpn_tcp_tls_crypt 2019-03-21 14:53:05 2019-03-21 14:53:05
42 OpenVPN UDP Dedicated     openvpn_dedicated_udp 2019-09-19 14:49:18 2019-09-19 14:49:18
45 OpenVPN TCP Dedicated     openvpn_dedicated_tcp 2019-09-19 14:49:54 2019-09-19 14:49:54
48 v2ray                     v2ray                 2019-10-28 13:29:37 2019-10-28 13:29:37
```

Displays a list of NordVPN's compatible server technologies.
Each entry details the name, ID, code, and creation/update dates of the technology entry.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Show-NordVPNTechnologyList.html)

[Help Index]()

