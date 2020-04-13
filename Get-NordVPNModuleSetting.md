---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version:
schema: 2.0.0
---

# Get-NordVPNModuleSetting

## SYNOPSIS
Gets the value of a module setting.

## SYNTAX

### GetAll (Default)
```
Get-NordVPNModuleSetting [<CommonParameters>]
```

### GetDefault
```
Get-NordVPNModuleSetting [-Default] [-Name] <String> [<CommonParameters>]
```

### GetType
```
Get-NordVPNModuleSetting [-Type] [-Name] <String> [<CommonParameters>]
```

### GetValue
```
Get-NordVPNModuleSetting [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
Retrieves the current value of a module setting. The default value and required
type of the setting value can also be obtained.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-NordVPNModuleSetting GroupCacheLifetime
600
```

Retrieves the value of the group cache lifetime, i.e. how long before the list
of NordVPN server groups is downloaded again.

### Example 2
```powershell
PS C:\> Get-NordVPNModuleSetting CountryCacheLifetime
300
PS C:\> Get-NordVPNModuleSetting CountryCacheLifetime -Default
600
PS C:\> Get-NordVPNModuleSetting CountryCacheLifetime -Type

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     UInt32                                   System.ValueType
```

Retrieves the current value of the country cache lifetime, its default value,
and the value type of the setting. As the setting value uses a 32-bit unsigned
integer, this means the maximum lifetime of the cache can be 4294967295
seconds, or 136 years.

### Example 3
```powershell
PS C:\> Get-NordVPNModuleSetting

Name                           Value
----                           -----
DeleteServerFallbackAfterUse   False
OfflineMode                    False
TechnologyCacheLifetime        600
CountryCacheLifetime           600
GroupCacheLifetime             600
```

Retrieves the values of all module settings. This is the default functionality
when no parameters are passed.

### Example 4
```powershell
PS C:\> (Get-NordVPNModuleSetting).GetEnumerator() | Format-Table `
>> @{Label = "Setting"; Expression = {$_.Name}},
>> @{Label = "Type"; Expression = {Get-NordVPNModuleSetting $_.Name -Type}},
>> @{Label = "Default value"; Expression = {Get-NordVPNModuleSetting $_.Name -Default}},
>> @{Label = "Current Value"; Expression = {Get-NordVPNModuleSetting $_.Name}}

Setting                      Type           Default value Current Value
-------                      ----           ------------- -------------
DeleteServerFallbackAfterUse System.Boolean         False         False
TechnologyCacheLifetime      System.UInt32            600           600
CountryCacheLifetime         System.UInt32            600           600
OfflineMode                  System.Boolean         False         False
GroupCacheLifetime           System.UInt32            600           600
```

Gets the name, value type, and default/current values of every module setting,
and displays them in a table.

## PARAMETERS

### -Default
Causes the function to return the default value of the setting instead.

```yaml
Type: SwitchParameter
Parameter Sets: GetDefault
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The name of the module setting to get the value, default value or type of.

```yaml
Type: String
Parameter Sets: GetDefault, GetType, GetValue
Aliases:
Accepted values: TechnologyCacheLifetime, DeleteServerFallbackAfterUse, CountryCacheLifetime, OfflineMode, GroupCacheLifetime

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Causes the function to return the required value type of the setting instead.

```yaml
Type: SwitchParameter
Parameter Sets: GetType
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Get-NordVPNModuleSetting.html)

[Help Index](./HELPINDEX.md)
