
# About NordVPN-Servers Classes
## about_NordVPN-Servers_Classes

# SHORT DESCRIPTION
Describes the custom classes utilised by NordVPN-Servers PowerShell module.

# LONG DESCRIPTION
The NordVPN-Servers module utilises custom classes to handle the data entries
provided by the NordVPN web API. Most of the data returned from the module's
functions comes in the form of lists. The class names for these take the form
`NordVPN<type>List`, and these are derived from .NET ArrayLists. Each entry in
the list is a custom class too, and these vary in their constructors and
properties. They are named similarly; `NordVPN<type>` The structure of each
type is detailed below:

## BASE TYPES: `NordVPNItem`, `NordVPNDatedItem`
Most types for the NordVPN-Servers module are derived from these simple
classes. They include the following properties:

```powershell
[NordVPNItem] : [Object]
{
    [UInt64]Id
    [String]Code
    [String]FriendlyName
}

[NordVPNDatedItem] : [NordVPNItem]
{
    [DateTime]Created
    [DateTime]Updated
}
```

## `NordVPNCountry`, `NordVPNCountryList`
The `NordVPNCountry` class contains information about a single country that
hosts NordVPN servers. `NordVPNCountryList` holds several of these entries.

```powershell
[NordVPNCountry] : [NordVPNItem], ICloneable
{
    Id           = [UInt64]          # Unique ID for country
    Code         = [String]          # Two-letter unique short code for country
    FriendlyName = [String]          # Full name of country
    Cities       = [NordVPNCityList] # List of City entries [1]
}
```

- <sup>\[1\]</sup> When a `Country` entry is included in a `Server` entry, the
  **Cities** property is empty.

Currently the following countries host NordVPN servers:

```
 ID Name                            Code Cities
 -- ----                            ---- ------
  2 Albania                         AL   Tirana
 10 Argentina                       AR   Buenos Aires
 13 Australia                       AU   Adelaide, Brisbane, Melbourne,
                                         Perth, Sydney
 14 Austria                         AT   Vienna
 21 Belgium                         BE   Brussels
 27 Bosnia and Herzegovina          BA   Sarajevo
 30 Brazil                          BR   San Paulo
 33 Bulgaria                        BG   Sofia
 38 Canada                          CA   Montreal, Toronto, Vancouver
 43 Chile                           CL   Santiago
 52 Costa Rica                      CR   San Jose
 54 Croatia                         HR   Zagreb
 56 Cyprus                          CY   Nicosia
 57 Czech Republic                  CZ   Prague
 58 Denmark                         DK   Copenhagen
 68 Estonia                         EE   Tallinn
 73 Finland                         FI   Helsinki
 74 France                          FR   Paris
 80 Georgia                         GE   Tbilisi
 81 Germany                         DE   Berlin, Frankfurt
 84 Greece                          GR   Athens
 97 Hong Kong                       HK   Hong Kong
 98 Hungary                         HU   Budapest
 99 Iceland                         IS   Reykjavik
100 India                           IN   Chennai, Mumbai
101 Indonesia                       ID   Jakarta
104 Ireland                         IE   Dublin
105 Israel                          IL   Tel Aviv
106 Italy                           IT   Milan
108 Japan                           JP   Tokyo
119 Latvia                          LV   Riga
126 Luxembourg                      LU   Steinsel
131 Malaysia                        MY   Kuala Lumpur
140 Mexico                          MX   Mexico
142 Moldova                         MD   Chisinau
153 Netherlands                     NL   Amsterdam
156 New Zealand                     NZ   Auckland
128 North Macedonia                 MK   Skopje
163 Norway                          NO   Oslo
174 Poland                          PL   Warsaw
175 Portugal                        PT   Lisbon
179 Romania                         RO   Bucharest
192 Serbia                          RS   Belgrad
195 Singapore                       SG   Singapore
196 Slovakia                        SK   Bratislava
197 Slovenia                        SI   Ljubljana
200 South Africa                    ZA   Johannesburg
114 South Korea                     KR   Seoul
202 Spain                           ES   Madrid
208 Sweden                          SE   Stockholm
209 Switzerland                     CH   Zurich
211 Taiwan                          TW   Taipei
214 Thailand                        TH   Bangkok
220 Turkey                          TR   Istanbul
225 Ukraine                         UA   Kiev
226 United Arab Emirates            AE   Dubai
227 United Kingdom                  GB   London
228 United States                   US   Atlanta, Buffalo, Charlotte, Chicago,
                                         Dallas, Denver, Los Angeles, Manassas,
                                         Miami, New York, Phoenix, Saint Louis,
                                         Salt Lake City, San Francisco, Seattle
234 Vietnam                         VN   Hanoi
```

## `NordVPNCity`, `NordVPNCityList`
The `NordVPNCity` class contains information about a city that hosts NordVPN
servers. `NordVPNCityList` holds several of these entries.

```powershell
[NordVPNCity] : [NordVPNItem], ICloneable
{
    Id           = [UInt64] # Unique ID for city
    Code         = [String] # Unique code for city
    FriendlyName = [String] # Full name of city
    Latitude     = [Double] # Latitude of city (+ve: N/-ve: S)
    Longitude    = [Double] # Longitude of city (+ve: E/-ve: W)
    CountryCode  = [String] # Two letter code of the country the city is in
    HubScore     = [Int16]  # Hub score /100, currently not used
}
```

A list of countries (and cities) that host NordVPN servers can be found above.

## `NordVPNGroup`, `NordVPNGroupList`
The `NordVPNGroup` class contains information about a NordVPN server group.
The API groups servers by region, and by legacy categories.
`NordVPNGroupList` holds several of these entries.

```powershell
[NordVPNGroup] : [NordVPNDatedItem], ICloneable
{
    Id           = [UInt64]   # Unique ID for Group
    Code         = [String]   # Unique code for Group
    FriendlyName = [String]   # Full name of Group
    Created      = [DateTime] # When group was first registered
    Updated      = [DateTime] # When group was last revised
    Type         = [NordVPNDatedItem] {
        Id           = [UInt64]   # Unique ID for Group Type
        FriendlyName = [String]   # Full name of Group Type
        Code         = [String]   # Unique code for Group Type
        Created      = [DateTime] # When type was first registered
        Updated      = [DateTime] # When type was last revised
    }
}
```

Currently, the following groups are registered by the API:

```
ID Name                    Group Code                       Type
-- ----                    ----------                       ----
 1 Double VPN              legacy_double_vpn                Legacy
 3 Onion Over VPN          legacy_onion_over_vpn            Legacy (unused)
 5 Ultra fast TV           legacy_ultra_fast_tv             Legacy (unused)
 7 Anti DDoS               legacy_anti_ddos                 Legacy (unused)
 9 Dedicated IP            legacy_dedicated_ip              Legacy
11 Standard VPN servers    legacy_standard                  Legacy
13 Netflix USA             legacy_netflix_usa               Legacy (unused)
15 P2P                     legacy_p2p                       Legacy
17 Obfuscated Servers      legacy_obfuscated_servers        Legacy
19 Europe                  europe                           Regions
21 The Americas            the_americas                     Regions
23 Asia Pacific            asia_pacific                     Regions
25 Africa, the Middle East africa_the_middle_east_and_india Regions
   and India
```

## `NordVPNTechnology`, `NordVPNTechnologyList`
The `NordVPNTechnology` class contains information about a technology supported
by NordVPN. `NordVPNTechnologyList` holds several of these entries.

```powershell
[NordVPNTechnology] : [NordVPNDatedItem], ICloneable
{
    Id           = [UInt64]   # Unique ID for technology
    Code         = [String]   # Unique code for technology
    FriendlyName = [String]   # Full name of technology
    Created      = [DateTime] # When technology was first registered
    Updated      = [DateTime] # When technology was last revised
    Status       = [String]   # Whether the technology is enabled [1]
}
```

- <sup>\[1\]</sup> The **Status** property is only present when a `Technology`
  is included in the `Technologies` property of a `Server` entry.

Technologies currently supported by NordVPN are:

```
ID Name                      Code                  Availability
-- ----                      ----                  ------
 1 IKEv2/IPSec               ikev2                 Available
 3 OpenVPN UDP               openvpn_udp           Available
 5 OpenVPN TCP               openvpn_tcp           Available
 7 Socks 5                   socks                 Available
 9 HTTP Proxy                proxy                 Available
11 PPTP                      pptp                  PERMANENTLY DISABLED
13 L2TP/IPSec                l2tp                  PERMANENTLY DISABLED
15 OpenVPN UDP Obfuscated    openvpn_xor_udp       Available
17 OpenVPN TCP Obfuscated    openvpn_xor_tcp       Available
19 HTTP CyberSec Proxy       proxy_cybersec        Available
21 HTTP Proxy (SSL)          proxy_ssl             Available
23 HTTP CyberSec Proxy (SSL) proxy_ssl_cybersec    Available
26 IKEv2/IPSec IPv6          ikev2_v6              Reserved for future use
29 OpenVPN UDP IPv6          openvpn_udp_v6        Reserved for future use
32 OpenVPN TCP IPv6          openvpn_tcp_v6        Reserved for future use
35 Wireguard                 wireguard_udp         Reserved for future use
38 OpenVPN UDP TLS Crypt     openvpn_udp_tls_crypt Reserved for future use
41 OpenVPN TCP TLS Crypt     openvpn_tcp_tls_crypt Reserved for future use
42 OpenVPN UDP Dedicated     openvpn_dedicated_udp Available
45 OpenVPN TCP Dedicated     openvpn_dedicated_tcp Available
48 v2ray                     v2ray                 Reserved for future use
```

## `NordVPNServer`, `NordVPNServerList`
`NordVPNServer` is the primary class uses for returning details about a NordVPN
server. `NordVPNServerList` holds multiple server entries and is the type
returned by `Get-NordVPNRecommendedList` and `Get-NordVPNServerList`.

```powershell
[NordVPNServer] : [NordVPNDatedItem], ICloneable
{
  Id             = [UInt64]   # Unique ID for server
  FriendlyName   = [String]   # Full name of the server
  Created        = [DateTime] # When server entry was first registered
  Updated        = [DateTime] # When server entry was last revised
  Hostname       = [String]   # The DNS hostname of the server
  Load           = [UInt16]   # The percentage load on the server
  Status         = [String]   # The current status of the server
  PrimaryIP      = [String]   # The main IPv4 address used by the server
  Latitude       = [Double]   # Latitude of the server (+ve: N/-ve: S)
  Longitude      = [Double]   # Longitude of the server (+ve: E/-ve: W)
  Country        = [NordVPNCountry]           # Country entry [1]
  City           = [NordVPNCity]              # City entry [2]
  Groups         = [NordVPNGroupList]         # Groups the server is in [3]
  Technologies   = [NordVPNTechnologyList]    # Supported Technologies [4]
  Services       = [NordVPNServiceList]       # Supported Services [5]
  Specifications = [NordVPNSpecificationList] # Additional Data [6]
  IPs            = [NordVPNIPAddressList]     # Server IP Addresses [7]
  Locations      = [NordVPNLocationList]      # Associated Locations [8]
}
```

- <sup>\[1\]</sup> The **Country** property is a single `NordVPNCountry` object
  representing the country where the server is located. In this case, the
  **Cities** property of the entry is empty and instead the single city
  associated with the server is provided in the **City** property. It is
  important to note that unlike when returned from `Get-NordVPNCountryList`,
  the entry is not wrapped in a `NordVPNCountryList`.
- <sup>\[2\]</sup> The **City** property is a single `NordVPNCity` object
  representing the city where the server is located. As above, the entry is not
  wrapped in a `NordVPNCityList` in this case.
- <sup>\[3\]</sup> The **Groups** property is a list of groups that this server
  is included in. Each entry is a `NordVPNGroup` object (see above).
- <sup>\[4\]</sup> The **Technologies** property is a list of VPN technologies
  that this server supports. Each entry is a `NordVPNTechnology` object (see
  above).
- <sup>\[5\]</sup> The **Services** property is a list of services that the
  server can provide. Each entry is a `NordVPNService` object (see below).
- <sup>\[6\]</sup> The **Specifications** property is a list of additional
  metadata provided about the server. Each entry is a `NordVPNSpecification`
  and contains a `NordVPNValueList` (see below).
- <sup>\[7\]</sup> The **IPs** property is a list of IP addresses that can be
  used to access the server. Each entry is a `NordVPNIPAddress` (see below).
- <sup>\[8\]</sup> The **Locations** property is a list of locations associated
  with the server. Each entry is a `NordVPNLocation` (see below), and presently
  each server is only associated with a single physical location.

## `NordVPNService`, `NordVPNServiceList`
The structure of a `NordVPNService` entry is as follows:

```powershell
[NordVPNService] : [NordVPNDatedItem], ICloneable
{
    Id           = [UInt64]   # Unique ID for the service
    FriendlyName = [String]   # Full name of the service
    Code         = [String]   # Short code for the service
    Created      = [DateTime] # When the service was first registered
    Updated      = [DateTime] # When the service was last revised
}
```

Currently the server will provide one or both of the following services:

```
Id Code  FriendlyName
-- ----  ------------
 1 vpn   VPN
 5 proxy Proxy
```

## `NordVPNSpecification`, `NordVPNSpecificationList`

The structure of a `NordVPNSpecification` entry is as follows:

```powershell
[NordVPNSpecification] : [NordVPNItem], ICloneable
{
    Id           = [UInt64]           # Unique ID for the specification
    FriendlyName = [String]           # Full name of the specification
    Code         = [String]           # Short code for the specification
    Values       = [NordVPNValueList] # List of key-value pairs for the spec
}
```

### `NordVPNValue`, `NordVPNValueList`

```powershell
[NordVPNValue] : [Object], ICloneable
{
    Id    = [UInt64] # Unique ID for the value
    Value = [object] # Actual value data
}
```

Currently all servers only define a single specification; the software version
running on the server:

```
Id Code    FriendlyName Value 0:Id Value 0:Data
-- ----    ------------ ---------- ------------
8  version Version             257        2.1.0
```

## `NordVPNIPAddress`, `NordVPNIPAddressList`

The structure of a `NordVPNIPAddress` entry is as follows:

```powershell
[NordVPNIPAddress] : [Object], ICloneable
{
    Id         = [UInt64]   # Unique ID for the IP
    Version    = [String]   # The internet protocol version of the IP
    Address    = [String]   # The IP address in dot-decimal notation
    InstanceId = [UInt64]   # Unique ID for the IP instance
    Created    = [DateTime] # When the IP was first registered
    Updated    = [DateTime] # When the IP assignment was last revised
}
```

## `NordVPNLocation`, `NordVPNLocationList`

The structure of a `NordVPNLocation` entry is as follows:

```powershell
[NordVPNLocation] : [Object], ICloneable
{
    Id          = [Int64]    # Unique ID for the location
    Latitude    = [Double]   # Latitude of location (+ve: N/-ve: S)
    Longitude   = [Double]   # Longitude of location (+ve: E/-ve: W)
    CountryCode = [String]   # Two-letter code for country location is in
    CityCode    = [String]   # Unique short code for city location is in
    Created     = [DateTime] # When location was first registered
    Updated     = [DateTime] # When location entry was last revised
}
```

# NOTE
Deleting the `NordVPN-Servers.settings.json` file will result in the module
settings being reverted to their defaults.

# SEE ALSO

- [Get-NordVPNRecommendedList](./Get-NordVPNRecommendedList.md)
- [Get-NordVPNServerList](./Get-NordVPNRecommendedList.md)
- [Get-NordVPNCountryList](./Get-NordVPNRecommendedList.md)
- [Get-NordVPNCityList](./Get-NordVPNRecommendedList.md)
- [Get-NordVPNGroupList](./Get-NordVPNRecommendedList.md)
- [Get-NordVPNTechnologyList](./Get-NordVPNRecommendedList.md)
- **[Module Homepage](./index.md)**
- **[Help Index](./HELPINDEX.md)**

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/about_NordVPN-Servers_Classes.html)

# KEYWORDS

- about_NordVPNServers_Classes
- about_NordVPNServers_Entries
- about_NordVPNServers_Types
- about_NordVPNServers_Objects
- about_NordVPNServers
