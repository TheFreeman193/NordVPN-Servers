
# Base classes

class NordVPNItem {
    [ValidateNotNullOrEmpty()][String]$Code
    [ValidateNotNullOrEmpty()][UInt64]$Id
    [ValidateNotNullOrEmpty()][String]$FriendlyName
}


class NordVPNDatedItem : NordVPNItem {
    [ValidateNotNullOrEmpty()][DateTime]$Created
    [ValidateNotNullOrEmpty()][DateTime]$Updated
}

# Entry classes

class NordVPNCountry : NordVPNItem, System.ICloneable {
    [NordVPNCityList]$Cities
    NordVPNCountry (
        [UInt64]$id,
        [String]$fname,
        [String]$code,
        $cities
    ) {
        $this.Id = $id
        $this.FriendlyName = $fname
        $this.Code = $code
        $this.Cities = [NordVPNCityList]::new()
        foreach ($city in $cities) {
            $this.Cities.Add(
                [NordVPNCity]::new(
                    $city.id,
                    $city.name,
                    $city.dns_name,
                    $city.latitude,
                    $city.longitude,
                    $city.hub_score,
                    $code
                )
            )
        }
    }
    NordVPNCountry (
        [UInt64]$id,
        [String]$fname,
        [String]$code
    ) {
        $this.Id = $id
        $this.FriendlyName = $fname
        $this.Code = $code
    }
    NordVPNCountry() { }
    [Object] Clone() {
        $newCountry = [NordVPNCountry]::new()
        foreach ($prop in $this.PSObject.Properties) {
            switch ($prop.Name) {
                'Cities' {
                    $newCountry.Cities = [NordVPNCityList]::new()
                    foreach ($city in $this.Cities) {
                        $newCountry.Cities.Add(
                            [NordVPNCity]::new(
                                $city.Id,
                                $city.FriendlyName,
                                $city.Code,
                                $city.Latitude,
                                $city.Longitude,
                                $city.HubScore,
                                $this.Code
                            )
                        )
                    }
                    break
                }
                default { $newCountry.$($prop.Name) = $this.$($prop.Name) }
            }
        }
        return $newCountry
    }
}


class NordVPNGroup : NordVPNDatedItem, System.ICloneable {

    [ValidateNotNullOrEmpty()][NordVPNDatedItem]$Type
    NordVPNGroup (
        [UInt64]$id,
        [String]$fname,
        [String]$code,
        [DateTime]$created,
        [DateTime]$updated,
        [UInt64]$typeid,
        [String]$typefname,
        [String]$typecode,
        [DateTime]$typecreated,
        [DateTime]$typeupdated
    ) {
        $this.Id = $id
        $this.FriendlyName = $fname
        $this.Code = $code
        $this.Created = $created
        $this.Updated = $updated
        $this.Type = [NordVPNDatedItem]::new()
        $this.Type.Id = $typeid
        $this.Type.FriendlyName = $typefname
        $this.Type.Code = $typecode
        $this.Type.Created = $typecreated
        $this.Type.Updated = $typeupdated
    }
    NordVPNGroup() { }
    [Object] Clone() {
        $newGroup = [NordVPNGroup]::new()
        foreach ($prop in $this.PSObject.Properties) {
            if ($null -ne $this.$($prop.Name)) {
                switch ($prop.Name) {
                    'Type' {
                        $newGroup.Type = [NordVPNDatedItem]::new()
                        foreach ($tprop in ($this.Type.PSObject.Properties)) {
                            $newGroup.Type.$($tprop.Name) = $this.Type.$($tprop.Name)
                        }
                        break
                    }
                    default {
                        $newGroup.$($prop.Name) = $this.$($prop.Name)
                    }
                }
            }
        }
        return $newGroup
    }
}


class NordVPNTechnology : NordVPNDatedItem, System.ICloneable {
    [String]$Status
    NordVPNTechnology (
        [UInt64]$id,
        [String]$fname,
        [String]$code,
        [DateTime]$created,
        [DateTime]$updated,
        [String]$status
    ) {
        $this.Id = $id
        $this.FriendlyName = $fname
        $this.Code = $code
        $this.Created = $created
        $this.Updated = $updated
        $this.Status = $status
    }
    NordVPNTechnology (
        [UInt64]$id,
        [String]$fname,
        [String]$code,
        [DateTime]$created,
        [DateTime]$updated
    ) {
        $this.Id = $id
        $this.FriendlyName = $fname
        $this.Code = $code
        $this.Created = $created
        $this.Updated = $updated
    }
    NordVPNTechnology() { }
    [Object] Clone() {
        $newTechnology = [NordVPNTechnology]::new()
        foreach ($prop in $this.PSObject.Properties) {
            switch ($prop.name) {
                'Status' {
                    if ($null -ne $this.Status) {
                        $newTechnology.Status = $this.Status
                    }
                }
                default { $newTechnology.$($prop.Name) = $this.$($prop.Name) }
            }
        }
        return $newTechnology
    }
}


class NordVPNCity : NordVPNItem, System.ICloneable {
    [ValidateNotNullOrEmpty()][Double]$Longitude
    [ValidateNotNullOrEmpty()][Double]$Latitude
    [ValidateNotNullOrEmpty()][String]$CountryCode
    [Int16]$HubScore
    NordVPNCity (
        [UInt64]$id,
        [String]$fname,
        [String]$code,
        [Double]$lat,
        [Double]$lon,
        [Int16]$score,
        [String]$ccode
    ) {
        $this.Id = $id
        $this.FriendlyName = $fname
        $this.Code = $code
        $this.Latitude = [Math]::Round($lat, 6)
        $this.Longitude = [Math]::Round($lon, 6)
        $this.HubScore = $score
        $this.CountryCode = $ccode
    }
    NordVPNCity() { }
    [Object] Clone() {
        $newCity = [NordVPNCity]::new()
        foreach ($prop in $this.PSObject.Properties) {
            $newCity.$($prop.Name) = $this.$($prop.Name)
        }
        return $newCity
    }
}


class NordVPNService : NordVPNDatedItem, System.ICloneable {
    NordVPNService (
        [UInt64]$id,
        [String]$fname,
        [String]$code,
        [DateTime]$created,
        [DateTime]$updated
    ) {
        $this.Id = $id
        $this.FriendlyName = $fname
        $this.Code = $code
        $this.Created = $created
        $this.Updated = $updated
    }
    NordVPNService() { }
    [Object] Clone() {
        $newService = [NordVPNService]::new()
        foreach ($prop in $this.PSObject.Properties) {
            $newService.$($prop.Name) = $this.$($prop.Name)
        }
        return $newService
    }
}


class NordVPNIPAddress : System.ICloneable {
    [ValidateNotNullOrEmpty()][String]$IPAddress
    [ValidateNotNullOrEmpty()][UInt64]$Id
    [ValidateNotNullOrEmpty()][DateTime]$Created
    [ValidateNotNullOrEmpty()][DateTime]$Updated
    [ValidateNotNullOrEmpty()][UInt16]$Version
    [ValidateNotNullOrEmpty()][UInt64]$InstanceId
    NordVPNIPAddress (
        [UInt64]$id,
        [DateTime]$created,
        [DateTime]$updated,
        [UInt16]$ver,
        [String]$ip,
        [UInt64]$iid
    ) {
        $this.Id = $id
        $this.Version = $ver
        $this.IPAddress = $ip
        $this.Created = $created
        $this.Updated = $updated
        $this.InstanceId = $iid
    }
    NordVPNIPAddress() { }
    [Object] Clone() {
        $newIP = [NordVPNIPAddress]::new()
        foreach ($prop in $this.PSObject.Properties) {
            $newIP.$($prop.Name) = $this.$($prop.Name)
        }
        return $newIP
    }
}


class NordVPNValue : System.ICloneable {
    [ValidateNotNullOrEmpty()][Object]$Value
    [ValidateNotNullOrEmpty()][UInt64]$Id
    NordVPNValue (
        $id,
        $val
    ) {
        $this.Id = $id
        $this.Value = $val
    }
    NordVPNValue() { }
    [Object] Clone() {
        $newVal = [NordVPNValue]::new()
        foreach ($prop in $this.PSObject.Properties) {
            $newVal.$($prop.Name) = $this.$($prop.Name)
        }
        return $newVal
    }
}


class NordVPNSpecification : NordVPNItem, System.ICloneable {
    [NordVPNValueList]$Values
    NordVPNSpecification (
        [UInt64]$id,
        [String]$fname,
        [String]$code,
        [Object[]]$vals
    ) {
        $this.Id = $id
        $this.FriendlyName = $fname
        $this.Code = $code
        $this.Values = [NordVPNValueList]::new()
        foreach ($val in $vals) {
            $this.Values.Add([NordVPNValue]::new($val.id, $val.value))
        }
    }
    NordVPNSpecification() { }
    [Object] Clone() {
        $newSpec = [NordVPNSpecification]::new()
        foreach ($prop in $this.PSObject.Properties) {
            switch ($prop.Name) {
                'Values' {
                    $newSpec.Values = [NordVPNValueList]::new()
                    foreach ($val in $this.Values) {
                        $newSpec.Values.Add(
                            [NordVPNValue]::new(
                                $val.Id,
                                $val.Value
                            )
                        )
                    }
                    break
                }
                default { $newSpec.$($prop.Name) = $this.$($prop.Name) }
            }
        }
        return $newSpec
    }
}


class NordVPNLocation : System.ICloneable {
    [ValidateNotNullOrEmpty()][String]$CityCode
    [ValidateNotNullOrEmpty()][UInt64]$Id
    [ValidateNotNullOrEmpty()][DateTime]$Created
    [ValidateNotNullOrEmpty()][DateTime]$Updated
    [ValidateNotNullOrEmpty()][String]$CountryCode
    [ValidateNotNullOrEmpty()][Double]$Latitude
    [ValidateNotNullOrEmpty()][Double]$Longitude

    NordVPNLocation (
        [UInt64]$id,
        [DateTime]$created,
        [DateTime]$updated,
        [String]$countrycode,
        [String]$citycode,
        [Double]$lat,
        [Double]$lon
    ) {
        $this.Id = $id
        $this.Created = $created
        $this.Updated = $updated
        $this.CountryCode = $countrycode
        $this.CityCode = $citycode
        $this.Latitude = [math]::Round($lat, 6)
        $this.Longitude = [math]::Round($lon, 6)
    }
    NordVPNLocation() { }
    [Object] Clone() {
        $newLocation = [NordVPNLocation]::new()
        foreach ($prop in $this.PSObject.Properties) {
            $newLocation.$($prop.Name) = $this.$($prop.Name)
        }
        return $newLocation
    }
}


class NordVPNServer: NordVPNDatedItem, System.ICloneable {
    [ValidateNotNullOrEmpty()][String]$Hostname
    [ValidateNotNullOrEmpty()][String]$PrimaryIP
    [ValidateNotNullOrEmpty()][UInt16]$Load
    [ValidateNotNullOrEmpty()][String]$Status
    [ValidateNotNullOrEmpty()][NordVPNCountry]$Country
    [ValidateNotNullOrEmpty()][NordVPNCity]$City
    [ValidateNotNullOrEmpty()][Double]$Longitude
    [ValidateNotNullOrEmpty()][Double]$Latitude
    [ValidateNotNullOrEmpty()][NordVPNLocationList]$Locations
    [ValidateNotNullOrEmpty()][NordVPNServiceList]$Services
    [ValidateNotNullOrEmpty()][NordVPNTechnologyList]$Technologies
    [ValidateNotNullOrEmpty()][NordVPNSpecificationList]$Specifications
    [ValidateNotNullOrEmpty()][NordVPNIPAddressList]$IPs
    [ValidateNotNullOrEmpty()][NordVPNGroupList]$Groups
    NordVPNServer(
        [UInt64]$Id,
        [String]$FriendlyName,
        [DateTime]$Created,
        [DateTime]$Updated,
        [String]$PrimaryIP,
        [String]$Hostname,
        [UInt16]$Load,
        [String]$Status,
        [NordVPNCountry]$Country,
        [NordVPNCity]$City,
        [Double]$Longitude,
        [Double]$Latitude,
        [NordVPNLocationList]$Locations,
        [NordVPNServiceList]$Services,
        [NordVPNTechnologyList]$Technologies,
        [NordVPNSpecificationList]$Specifications,
        [NordVPNIPAddressList]$IPs,
        [NordVPNGroupList]$Groups
    ) {
        $this.Id = $Id
        $this.FriendlyName = $FriendlyName
        $this.Created = $Created
        $this.Updated = $Updated
        $this.Code = $Hostname.Split(".")[0]
        $this.PrimaryIP = $PrimaryIP
        $this.Hostname = $Hostname
        $this.Load = $Load
        $this.Status = $Status
        $this.Country = $Country
        $this.City = $City
        $this.Longitude = $Longitude
        $this.Latitude = $Latitude
        $this.Locations = $Locations
        $this.Services = $Services
        $this.Technologies = $Technologies
        $this.Specifications = $Specifications
        $this.IPs = $IPs
        $this.Groups = $Groups
    }
    NordVPNServer() { }
    [Object] Clone() {
        $newServer = [NordVPNServer]::new()
        foreach ($prop in $this.PSObject.Properties) {
            switch ($prop.Name) {
                'Country' {$newServer.Country = $this.Country.Clone(); break}
                'City' {$newServer.City = $this.City.Clone(); break}
                'Locations' {$newServer.Locations = $this.Locations.Clone(); break}
                'Services' {$newServer.Services = $this.Services.Clone(); break}
                'Technologies' {$newServer.Technologies = $this.Technologies.Clone(); break}
                'Specifications' {$newServer.Specifications = $this.Specifications.Clone(); break}
                'IPs' {$newServer.IPs = $this.IPs.Clone(); break}
                'Groups' {$newServer.Groups = $this.Groups.Clone(); break}
                default { $newServer.$($prop.Name) = $this.$($prop.Name) }
            }
        }
        return $newServer
    }
}


# List classes

class NordVPNCountryList : System.Collections.ArrayList, System.ICloneable {
    [Void] Add ($Country) {
        if ($Country.GetType().Name -eq 'NordVPNCountry') {
            ([System.Collections.ArrayList]$this).Add($Country)
        }
    }
    [Object] Clone() {
        $newList = [NordVPNCountryList]::new()
        foreach ($ctry in $this) {
            $newList.Add($ctry.Clone())
        }
        return $newList
    }
}


class NordVPNCityList : System.Collections.ArrayList, System.ICloneable {
    [Void] Add ($City) {
        if ($City.GetType().Name -eq 'NordVPNCity') {
            ([System.Collections.ArrayList]$this).Add($City)
        }
    }
    [Object] Clone() {
        $newList = [NordVPNCityList]::new()
        foreach ($city in $this) {
            $newList.Add($city.Clone())
        }
        return $newList
    }
}


class NordVPNGroupList : System.Collections.ArrayList, System.ICloneable {
    [Void] Add ($Group) {
        if ($Group.GetType().Name -eq 'NordVPNGroup') {
            ([System.Collections.ArrayList]$this).Add($Group)
        }
    }
    [Object] Clone() {
        $newList = [NordVPNGroupList]::new()
        foreach ($grp in $this) {
            $newList.Add($grp.Clone())
        }
        return $newList
    }
}


class NordVPNTechnologyList : System.Collections.ArrayList, System.ICloneable {
    [Void] Add ($Technology) {
        if ($Technology.GetType().Name -eq 'NordVPNTechnology') {
            ([System.Collections.ArrayList]$this).Add($Technology)
        }
    }
    [Object] Clone() {
        $newList = [NordVPNTechnologyList]::new()
        foreach ($tech in $this) {
            $newList.Add($tech.Clone())
        }
        return $newList
    }
}


class NordVPNValueList : System.Collections.ArrayList, System.ICloneable {
    [Void] Add ($Value) {
        if ($Value.GetType().Name -eq 'NordVPNValue') {
            ([System.Collections.ArrayList]$this).Add($Value)
        }
    }
    [Object] Clone() {
        $newList = [NordVPNValueList]::new()
        foreach ($val in $this) {
            $newList.Add($val.Clone())
        }
        return $newList
    }
}


class NordVPNLocationList : System.Collections.ArrayList, System.ICloneable {
    [Void] Add ($Location) {
        if ($Location.GetType().Name -eq 'NordVPNLocation') {
            ([System.Collections.ArrayList]$this).Add($Location)
        }
    }
    [Object] Clone() {
        $newList = [NordVPNLocationList]::new()
        foreach ($loc in $this) {
            $newList.Add($loc.Clone())
        }
        return $newList
    }
}


class NordVPNServiceList : System.Collections.ArrayList, System.ICloneable {
    [Void] Add ($Service) {
        if ($Service.GetType().Name -eq 'NordVPNService') {
            ([System.Collections.ArrayList]$this).Add($Service)
        }
    }
    [Object] Clone() {
        $newList = [NordVPNServiceList]::new()
        foreach ($svc in $this) {
            $newList.Add($svc.Clone())
        }
        return $newList
    }
}


class NordVPNIPAddressList : System.Collections.ArrayList, System.ICloneable {
    [Void] Add ($IPAddress) {
        if ($IPAddress.GetType().Name -eq 'NordVPNIPAddress') {
            ([System.Collections.ArrayList]$this).Add($IPAddress)
        }
    }
    [Object] Clone() {
        $newList = [NordVPNIPAddressList]::new()
        foreach ($ip in $this) {
            $newList.Add($ip.Clone())
        }
        return $newList
    }
}


class NordVPNSpecificationList : System.Collections.ArrayList, System.ICloneable {
    [Void] Add ($Specification) {
        if ($Specification.GetType().Name -eq 'NordVPNSpecification') {
            ([System.Collections.ArrayList]$this).Add($Specification)
        }
    }
    [Object] Clone() {
        $newList = [NordVPNSpecificationList]::new()
        foreach ($spec in $this) {
            $newList.Add($spec.Clone())
        }
        return $newList
    }
}


class NordVPNServerList : System.Collections.ArrayList, System.ICloneable {
    [Void] Add ($Server) {
        if ($Server.GetType().Name -eq 'NordVPNServer') {
            ([System.Collections.ArrayList]$this).Add($Server)
        }
    }
    [Object] Clone() {
        $newList = [NordVPNServerList]::new()
        $total = $this.Count
        $i = 0
        foreach ($svr in $this) {
            if ($i % 100 -eq 0) {
                $pcc = [Math]::Floor(($i / $total) * 100)
                Write-Progress -Activity "Cloning server list" -Id 4 `
                    -PercentComplete $pcc -CurrentOperation "$i/$total ($pcc%)"
            }
            $newList.Add($svr.Clone())
            $i++
        }
        Write-Progress -Activity "Cloning server list" -Id 4 -Completed
        return $newList
    }
}
