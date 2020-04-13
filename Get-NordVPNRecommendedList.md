---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version: https://thefreeman193.github.io/NordVPN-Servers/Get-NordVPNRecommendedList.html
schema: 2.0.0
---

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
By default, this function returns the best five servers with the passed parameters, but this limit can be set with the `-Limit` parameter, to return from 1 server to the entire sorted list.

The recommended server functionality of the NordVPN web API permits direct filtering in the API request, meaning only details of servers matching the country, technology, and group specified will need to be downloaded.
This is in contrast to `Get-NordVPNServerList`, which uses the raw list functionality of the web API and does not support direct filtering.
This function is therefore much more efficient as less data must be downloaded and no filtering needs to be done locally.
It is suggested to use this function unless absolutely necessary (such as where all servers must be indexed, including those that are full/unavailable.)

The structure of a server entry is as follows (powershell notation):

@{
     Id             = \[Int64\] # Unique ID for server
     Created        = \[DateTime\] # When server entry was first registered
     Updated        = \[DateTime\] # When server entry was last revised
     Hostname       = \[String\] # The DNS hostname of the server
     Load           = \[UInt16\] # The percentage load on the server
     Status         = \[String\] # The current status of the server
     PrimaryIP      = \[String\] # The main IPv4 address used by the server
     Country        = \[Hashtable\] # Country entry {1}
     CountryCode    = \[String\] # 2-letter code of country where server is located
     City           = \[Hashtable\] # City entry {2}
     CityCode       = \[String\] # Uniqude code of city where server is located
     Groups         = \[Array\] # Entries for groups this server is part of {3}
     Technologies   = \[Array\] # Entries for technologies supported by the server {4}
     Services       = \[Array\] # Entries for services the server supports {5}
     Specifications = \[Array\] # Entries for additional server metadata {6}
     IPs            = \[Array\] # Entries for IP addresses assoicated with the server {7}
     Locations      = \[Array\] # Entries for locations associated with server {8}
 }

{1} To see the structure of a Country entry, run `Get-Help Get-NordVPNCountryList` (./Get-NordVPNCountryList.md)and refer to the function description.

{2} To see the structure of a City entry, run `Get-Help Get-NordVPNCityList` (./Get-NordVPNCityList.md)and refer to the function description.

{3} To see the structure of a Group entry, run `Get-Help Get-NordVPNGroupList` (./Get-NordVPNGroupList.md)and refer to the function description.

{4} To see the structure of a Technology entry, run `Get-Help Get-NordVPNTechnologyList` (./Get-NordVPNTechnologyList.md)and refer to the function description.

{5} To see the structure of a Service entry, run `Get-Help Get-NordVPNTechnologyList` (./Get-NordVPNTechnologyList.md)and refer the structure of a technology entry in the function description.
Service entries utilise the same structure.

{6} The structure of a Specification entry is as follows (powershell notation):

@{
     Id           = \[Int64\] # Unique ID for the specification
     FriendlyName = \[String\] # Full name of the specification
     Code         = \[String\] # Short code for the specification
     Values       = \[Array\]@( # Metadata entries
         \[Hashtable\]@{
             Id    = \[Int64\] # Unique ID for the value
             Value = \[object\] # Actual value data
         }
         ...
     )
 }

{7} The structure of an IP Address entry is as follows (powershell notation):

@{
     Id      = # \[String\] Unique ID for the entry
     Version = # \[UInt16\] The internet protocol version of the IP
     Address = # \[String\] The IP address in dot-decimal notation
     EntryId = # \[String\] Unique ID for the IP itself
 }

{8} The structure of a location entry is as follows (powershell notation):

@{
     Id          = \[Int64\] # Unique ID for location
     Latitude    = \[Double\] # Latitude of location (+ve: N/-ve: S)
     Longitude   = \[Double\] # Longitude of location (+ve: E/-ve: W)
     CountryCode = \[String\] # Two-letter unique short code for associated country
     CityCode    = \[String\] # Unique short code for associated city
     Created     = \[DateTime\] # When location was first registered
     Updated     = \[DateTime\] # When location entry was last revised
 }

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

Gets the 5 NordVPN servers with the lowest loads near to the computer where the command is run on, and shows the DNS hostname, status, country, and load %.

### Example 2
```
PS C:\> Get-NordVPNRecommendedList -Limit 1 -Group asia_pacific -Technology openvpn_udp | `
>> Select-Object Hostname, PrimaryIP, Load

Hostname         PrimaryIP     Load
--------         ---------     ----
kr20.nordvpn.com 210.217.18.72   34
```

Gets the NordVPN server with the lowest load in the APAC region, that supports OpenVPN over the UDP protocol.

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

Gets all NordVPN servers in France that support dedicated IP allocation and OpenVPN over TCP/IP, displaying the hostname, IP, and Load for each.

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

Creates three custom filter profiles, passes them to `Get-NordVPNRecommendedList` and displays the results as a list with the hostname, country code and current load.
Notable is that the recommendations functionality of the NordVPN web API will not display servers filtered by certain technologies, unless the associated group is also supplied.
See the notes section of this help for more details.

## PARAMETERS

### -Country
A 2-digit ISO 3166-1 country code to filter the results by.
You can see a list of country codes using `Show-NordVPNCountryList`.
Examples include GB (United Kingdom), US (United States), and DE (Germany).

A list of available countries is generated dynamically using `Get-NordVPNCountryList`, and can be accessed by typing `-Country` followed by a space and pressing the tab key.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AL, AR, AU, AT, BE, BA, BR, BG, CA, CL, CR, HR, CY, CZ, DK, EE, FI, FR, GE, DE, GR, HK, HU, IS, IN, ID, IE, IL, IT, JP, LV, LU, MY, MX, MD, NL, NZ, MK, NO, PL, PT, RO, RS, SG, SK, SI, ZA, KR, ES, SE, CH, TW, TH, TR, UA, AE, GB, US, VN

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Group
The short code of the group to filter the results by.
You can see a list of country codes using `Show-NordVPNGroupList`.
Examples include legacy_standard (Standard Servers) and the_americas (Americas region).

A list of available groups is generated dynamically using `Get-NordVPNGroupList`, and can be accessed by typing `-Group` followed by a space and pressing the tab key.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: legacy_double_vpn, legacy_onion_over_vpn, legacy_ultra_fast_tv, legacy_anti_ddos, legacy_dedicated_ip, legacy_standard, legacy_netflix_usa, legacy_p2p, legacy_obfuscated_servers, europe, the_americas, asia_pacific, africa_the_middle_east_and_india

Required: False
Position: 2
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

### -Technology
The short code of the technology to filter the results by.
You can see a list of country codes using `Show-NordVPNTechnologyList`.
Examples include ikev2 (IKEv2/IPSec), openvpn_xor_udp (Obfuscated OpenVPN/UDP), and proxy_ssl (HTTPS Proxy/SSL).

A list of available technologies is generated dynamically using `Get-NordVPNTechnologyList`, and can be accessed by typing `-Technology` followed by a space and pressing the tab key.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: ikev2, openvpn_udp, openvpn_tcp, socks, proxy, pptp, l2tp, openvpn_xor_udp, openvpn_xor_tcp, proxy_cybersec, proxy_ssl, proxy_ssl_cybersec, ikev2_v6, openvpn_udp_v6, openvpn_tcp_v6, wireguard_udp, openvpn_udp_tls_crypt, openvpn_tcp_tls_crypt, openvpn_dedicated_udp, openvpn_dedicated_tcp, v2ray

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Raw
Returns the raw server entry data without processing.
This speeds up operation but results in an inconsistent data structure due to the API's naming conventions.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Array
## NOTES
IMPORTANT : Even if the module is configured to only use the fallback files, with the command `Set-NordVPNModuleSetting OfflineMode 1`, this function will still attempt to utilise the NordVPN web API.
This is because recommendations are inherently dynamic and therefore it would be futile to store these offline.
To work with server lists offline, you should use `Get-NordVPNServerList`, which responds to the offline mode and can use a list stored in NordVPN_Servers.xml in the module directory.

The recommendations functionality of the NordVPN web API will not display servers filtered by certain technologies, unless the associated group is also supplied.
These required pairings are as follows:

| Technology Code       | Group Code                | | --------------------: | :------------------------ | | openvpn_dedicated_udp | legacy_dedicated_ip       | | openvpn_dedicated_tcp | legacy_dedicated_ip       | | openvpn_xor_udp       | legacy_obfuscated_servers | | openvpn_xor_tcp       | legacy_obfuscated_servers |

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Get-NordVPNRecommendedList.html)

[Help Index]()
