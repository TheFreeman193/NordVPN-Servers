---
external help file: NordVPN-Servers-help.xml
Module Name: NordVPN-Servers
online version: https://thefreeman193.github.io/NordVPN-Servers/Show-NordVPNCountryList.html
schema: 2.0.0
---

# Show-NordVPNCountryList

## SYNOPSIS
Shows all the countries with NordVPN servers in a neat format.

## SYNTAX

```
Show-NordVPNCountryList [<CommonParameters>]
```

## DESCRIPTION
Displays a formatted table of countries that contain NordVPN servers.
This output is useful for cross-referencing country names with their codes/IDs.

## EXAMPLES

### Example 1
```
PS C:\> Show-NordVPNCountryList

Server Countries:

 Id FriendlyName           Code Cities
 -- ------------           ---- ------
  2 Albania                AL   Tirana
 10 Argentina              AR   Buenos Aires
 13 Australia              AU   Adelaide/Brisbane/Melbourne/Perth/Sydney
 14 Austria                AT   Vienna
 21 Belgium                BE   Brussels
 27 Bosnia and Herzegovina BA   Sarajevo
...
```

Displays a list of countries with NordVPN servers.
Each entry details the name, ID, country code, and the names of the cities with servers in that country.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[This page on GitHub Pages](https://thefreeman193.github.io/NordVPN-Servers/Show-NordVPNCountryList.html)

[Help Index]()

