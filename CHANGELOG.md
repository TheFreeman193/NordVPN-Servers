# Changelog

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
