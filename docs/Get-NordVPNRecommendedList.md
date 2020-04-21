
# Get-NordVPNRecommendedList

## SYNOPSIS
Gets a list of servers recommended by NordVPN.

## SYNTAX

```
Get-NordVPNRecommendedList [[-Limit] <UInt16>] [-Raw] [[-Country] <String>] [[-Group] <String>]
 [[-Technology] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns a list of servers recommended by NordVPN, sorted by lowest Load.
By default, this function returns the best five servers with the passed
parameters, but this limit can be set with the `-Limit` parameter, to return
from 1 server to the entire sorted list.

The recommended server functionality of the NordVPN web API permits direct
filtering in the API request, meaning only details of servers matching the
country, technology, and group specified will need to be downloaded. This is in
contrast to `Get-NordVPNServerList`, which uses the raw list functionality of
the web API and does not support direct filtering.

This function is therefore much more efficient as less data must be downloaded
and no filtering needs to be done locally. It is suggested to use this function
unless absolutely necessary (such as where all servers must be indexed,
including those that are full/unavailable.)

The structures of objects returned by this function can be found in the about
topic [About NordVPN-Servers Classes](.\about_NordVPN-Servers_Classes.md).

## EXAMPLES

### Example 1
```
PS C:\> Get-NordVPNRecommendedList | Select-Object Hostname, Status, CountryCode, Load

Hostname           Status CountryCode Load
--------           ------ ----------- ----
uk1774.nordvpn.com online GB             8
uk1773.nordvpn.com online GB            10
uk1091.nordvpn.com online GB            10
uk1239.nordvpn.com online GB            11
uk1419.nordvpn.com online GB            12
```

Gets the 5 NordVPN servers with the lowest loads near to the computer where the
command is run on, and shows the DNS hostname, status, country, and load %.

### Example 2
```
PS C:\> Get-NordVPNRecommendedList -Limit 1 -Group asia_pacific -Technology openvpn_udp | `
>> Select-Object Hostname, PrimaryIP, Load

Hostname         PrimaryIP     Load
--------         ---------     ----
kr20.nordvpn.com 210.217.18.72   34
```

Gets the NordVPN server with the lowest load in the APAC region, that supports
OpenVPN over the UDP protocol.

### Example 3
```
PS C:\> Get-NordVPNRecommendedList -Limit 10000 -Country FR `
>> -Group legacy_dedicated_ip -Technology openvpn_tcp | `
>> Select Hostname, PrimaryIP, Load

Hostname          PrimaryIP     Load
--------          ---------     ----
fr399.nordvpn.com 37.120.204.67   12
fr439.nordvpn.com 185.93.2.199    17
fr440.nordvpn.com 185.93.2.206    18
```

Gets all NordVPN servers in France that support dedicated IP allocation and
OpenVPN over TCP/IP, displaying the hostname, IP, and Load for each.

### Example 4
```
PS C:\> $MyRequirements = @(
>> [pscustomobject]@{Country = 'DE'; Group = 'legacy_obfuscated_servers'}
>> [pscustomobject]@{Country = 'BR'; Technology = 'ikev2'}
>> [pscustomobject]@{Country = 'US'; Technology = 'openvpn_xor_udp'}
>> [pscustomobject]@{Country = 'US'; Technology = 'openvpn_xor_udp'; Group = 'legacy_obfuscated_servers'}
>> [pscustomobject]@{Country = 'US'; Technology = 'openvpn_dedicated_udp'}
>> [pscustomobject]@{Country = 'US'; Technology = 'openvpn_dedicated_udp'; Group = 'legacy_dedicated_ip'}
>> )
PS C:\> $MyRequirements | Get-NordVPNRecommendedList | Select-Object Hostname, CountryCode, Load

Hostname          CountryCode Load
--------          ----------- ----
de732.nordvpn.com DE            37
de730.nordvpn.com DE            60
de733.nordvpn.com DE            61
de726.nordvpn.com DE            64
de669.nordvpn.com DE            32
br46.nordvpn.com  BR            10
br45.nordvpn.com  BR            11
br41.nordvpn.com  BR            11
br48.nordvpn.com  BR            14
br35.nordvpn.com  BR            14
WARNING: No results found for search with filters:
  Country: US
  Technology: openvpn_xor_udp
Try adjusting the filters.
us4906.nordvpn.c… US            25
us4859.nordvpn.c… US            30
us4896.nordvpn.c… US            33
us4912.nordvpn.c… US            38
us4907.nordvpn.c… US            40
WARNING: No results found for search with filters:
  Country: US
  Technology: openvpn_dedicated_udp
Try adjusting the filters.
us4955.nordvpn.c… US             8
us2917.nordvpn.c… US            10
us2914.nordvpn.c… US            10
us2905.nordvpn.c… US            11
us2938.nordvpn.c… US            12
```

Creates three custom filter profiles, passes them to `Get-NordVPNRecommendedList`
and displays the results as a list with the hostname, country code and current
load.

Notable is that the recommendations functionality of the NordVPN web API will
not display servers filtered by certain technologies, unless the associated
group is also supplied. See the notes section of this help for more details.

## PARAMETERS

### -Country
A 2-digit ISO 3166-1 country code to filter the results by.
You can see a list of country codes using `Show-NordVPNCountryList`.
Examples include GB (United Kingdom), US (United States), and DE (Germany).

A list of available countries is generated dynamically using
`Get-NordVPNCountryList`, and can be accessed by typing `-Country` followed by
a space and pressing the tab key.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AL, AR, AU, AT, BE, BA, BR, BG, CA, CL, CR, HR, CY, CZ, DK, EE, FI, FR, GE, DE, GR, HK, HU, IS, IN, ID, IE, IL, IT, JP, LV, LU, MY, MX, MD, NL, NZ, MK, NO, PL, PT, RO, RS, SG, SK, SI, ZA, KR, ES, SE, CH, TW, TH, TR, UA, AE, GB, US, VN

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Group
The short code of the group to filter the results by.
You can see a list of country codes using `Show-NordVPNGroupList`.
Examples include legacy_standard (Standard Servers) and the_americas (Americas
region).

A list of available groups is generated dynamically using `Get-NordVPNGroupList`,
and can be accessed by typing `-Group` followed by a space and pressing the
tab key.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: legacy_double_vpn, legacy_onion_over_vpn, legacy_ultra_fast_tv, legacy_anti_ddos, legacy_dedicated_ip, legacy_standard, legacy_netflix_usa, legacy_p2p, legacy_obfuscated_servers, europe, the_americas, asia_pacific, africa_the_middle_east_and_india

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Limit
The maximum number of servers to return (1-65535).
NOTE : fewer results may be returned from the search if filters are applied.

If no value is passed with `-Limit`, the function returns the top 5 servers.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: 5
Accept pipeline input: False
Accept wildcard characters: False
```

### -Raw
Returns the raw server entry data without processing.
This speeds up operation but results in an inconsistent data structure due to
the API's naming conventions.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Technology
The short code of the technology to filter the results by.
You can see a list of country codes using `Show-NordVPNTechnologyList`.
Examples include ikev2 (IKEv2/IPSec), openvpn_xor_udp (Obfuscated OpenVPN/UDP),
and proxy_ssl (HTTPS Proxy/SSL).

A list of available technologies is generated dynamically using
`Get-NordVPNTechnologyList`, and can be accessed by typing `-Technology`
followed by a space and pressing the tab key.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: ikev2, openvpn_udp, openvpn_tcp, socks, proxy, pptp, l2tp, openvpn_xor_udp, openvpn_xor_tcp, proxy_cybersec, proxy_ssl, proxy_ssl_cybersec, ikev2_v6, openvpn_udp_v6, openvpn_tcp_v6, wireguard_udp, openvpn_udp_tls_crypt, openvpn_tcp_tls_crypt, openvpn_dedicated_udp, openvpn_dedicated_tcp, v2ray

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### NordVPNServerList
## NOTES
IMPORTANT : Even if the module is configured to only use the fallback files,
with the command `Set-NordVPNModuleSetting OfflineMode 1`, this function will
still attempt to utilise the NordVPN web API. This is because recommendations
are inherently dynamic and therefore it would be futile to store these offline.

To work with server lists offline, you should use `Get-NordVPNServerList`,
which responds to the offline mode and can use a list stored in
NordVPN_Servers.xml in the module directory.

The recommendations functionality of the NordVPN web API will not display
servers filtered by certain technologies, unless the associated group is also
supplied. These required pairings are as follows:

```
      Technology Code Group Code
      --------------- ----------
openvpn_dedicated_udp legacy_dedicated_ip
openvpn_dedicated_tcp legacy_dedicated_ip
      openvpn_xor_udp legacy_obfuscated_servers
      openvpn_xor_tcp legacy_obfuscated_servers
```

## RELATED LINKS

[Help Page on GitHub](https://github.com/TheFreeman193/NordVPN-Servers/blob/master/docs/Get-NordVPNRecommendedList.md)

[Help Index](./INDEX.md)
