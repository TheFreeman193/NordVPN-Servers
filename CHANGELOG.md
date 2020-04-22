# Changelog

## 0.5.2 - 22nd April 2020

- Remove unnecessary check in Get-NordVPNServerList
- Update testing suite to handle PS Gallery folder structure
- Update included fallback data

## 0.5.1 - 22nd April 2020

- Fix issue where Get-NordVPNCityList returns empty list in offline
  mode if -Offline switch not present
- Add handling of -First parameter in offline mode for
  Get-NordVPNServerList
- Update output types to reflect new custom classes

## 0.5.0 - 21st April 2020

NOTE: This version makes substantial changes to the data structures
returned by the module. Please consider this a breaking update

- Add custom formats for Country, City, Group, Technology, Location,
  IP address, Service, Server, and Specification entries/lists.
- Remove Show-* functions as format files make these obsolete
- Tidy some inconsistent code
- Add custom .NET classes for objects returned; these replace the
  PSCustomObject structures used previously
- Change Get-NordVPNServerList functionality to improve efficiency
- Removed filter params from Get-NordVPNServerList; piping the
  output through Where-Object is favourable
- Add some additional checks to Get-NordVPNServerList to ensure that
  incompatible switches are not accepted
- Add some extra DEBUG and VERBOSE information
- Change ConvertFrom-ServerEntry: re-write to utilise new custom
  classes and improve efficiency
- Change Get-* functions: re-write to utilise new custom classes

## 0.4.0 - 15th April 2020

- Add hardcoded country, group, and technology codes as last-line
  fallbacks
- Fix issue where -Force switch does not suppress prompt for
  Set-NordVPNModuleSetting/Reset-NordVPNModule
- Change handling of parameter sets in Get-NordVPNModuleSetting
- Fix issue where settings file is not written if read-only (+R)
  attribute set
- Change debug, error, and warning messages for internal function
  Get-List
- Change exception handling in internal function Get-List
- Change handling of unexpected Get-List outputs in
  Get-(Country,Group,Technology)List functions
- Change warning for fallback file usage in online mode to verbose
  message
- Change calls to Write-Host in Show-* functions to Write-Output and
  increase contrast (Grey => White)
- Add invalid entry handling for settings import from JSON
- Fix issue where -First parameter fails to resolve in
  Get-NordVPNServerList
- Fix issue where Get-NordVPNServerList filters do not handle single-
  server outputs (PS unwrapping)
- Fix issue where PSCX definition of Expand-Archive was interfering
  with Pester tests.
- Update manifest tags, copyright
- Add -Offline switch parameter to Show-* Functions
- Fix some incorrect logic when handling -Raw switch for
  Get-NordVPNServerList
- Add -Offline switch parameter to internal DynamicParam providers, to
  prevent API calls when Get-* or Show-* functions are called with
  -Offline
- Tidy up some inconsistent code (w/o functional changes)

## 0.2.1 - 7th April 2020

- Update version to alpha 0.2
- Add -Offline parameter to Get-NordVPNCityList
- Update manifest to include zipped server fallback
- Remove some obsolete code
- Convert most hashtables to custom objects for easier downstream
  processing
- Add explicit typecasts where missing
- Remove surplus write-progress calls
- Tidy up code / consistency
- Force UTF-8 for XML export
- Fix some non-terminating error conditions

## 0.1.27 - 6th April 2020

- First alpha on GitHub
