# NordVPN-Servers
[![License][img license]][license]
[![Code of Conduct][img cc2]][conduct]
[![GitHub release (semver)][img release]][release]
[![Commits since release][img commits since release]][commits]
[![Repo size][img size]][download zip]
[![GitHub Pages][img pages status]][pages home]

A cross-platform PowerShell module for interacting with the NordVPN API.

<!-- [![PowerShell Gallery][img ps gallery compat]][ps gallery] -->
<!-- [![PowerShell Gallery][img ps gallery release]][ps gallery] -->

## Introduction
This module provides various functions for retrieving country, grouping,
 technology, and server information from the web API provided by NordVPN.
 Possible filter parameters are generated dynamically by retrieving lists of
 valid entries from the API. A list of countries, groups, and technologies is
 stored locally as an offline fallback, and these can be updated.

## Documentation
A full set of Markdown help files can be found **[here][help index]**.

You can also see the GitHub Pages website **[here][pages home]**.

## Configuration
Information on configuring the module can be found
 **[here][about settings]**.

## License
This module and its associated assets are released under the
 **[MIT license][license]**.

## Contributing
Suggestions and pull requests are welcomed, provided they are beneficial and
 well-documented. A full contributing guide can be found
 **[here][contrib]**.

### Translations
If you'd like to translate a help file, please create a pull request. Approved
 translations will also be added to the PowerShell Gallery. The module itself
 does not currently support language files.

## Requirements
This module works in PowerShell Desktop 5.1 and later, and PowerShell Core 6.1
 and later. For PSCore, Windows, Linux, and macOS are supported.

## Code of Conduct

Please adhere to the **[code of conduct][conduct]** which is
 adapted from the
 [contributor covenant 2.0][cc2].
 Remember, we are a *community*.

## Changelog

The module changelog can be found **[here][changelog]**.

[license]: ./LICENSE.md
[conduct]: ./CODE_OF_CONDUCT.md
[release]: https://github.com/TheFreeman193/NordVPN-Servers/releases/latest
[commits]: https://github.com/TheFreeman193/NordVPN-Servers/commits/master
[changelog]: ./CHANGELOG.md
[contrib]: ./CONTRIBUTING.md
[help index]: ./docs/INDEX.md
[about settings]: ./docs/about_NordVPN-Servers_Settings.md
[cc2]: https://www.contributor-covenant.org/version/2/0/code_of_conduct.html
[img license]: https://img.shields.io/github/license/TheFreeman193/NordVPN-Servers?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMzIxIiB3aWR0aD0iMzIxIj48ZyBzdHJva2Utd2lkdGg9IjM1IiBzdHJva2U9IiNBMzFGMzQiPjxwYXRoIGQ9Ik0xNy41IDc2djE2Nm01Ny0xNjZ2MTEzbTU3LTExM3YxNjZtNTctMTY2djMzbTU4IDIwdjExMyIvPjxwYXRoIGQ9Ik0xODguNSAxMjl2MTEzIiBzdHJva2U9IiM4QThCOEMiLz48cGF0aCBkPSJNMjI5IDkyLjVoOTIiIHN0cm9rZS13aWR0aD0iMzMiLz48L2c+PC9zdmc+
[img cc2]: https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4?logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjU2IiBoZWlnaHQ9IjI1NiIgdmlld0JveD0iMCAwIDI1NiAyNTYiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+PHRpdGxlPkNvbnRyaWJ1dG9yIENvdmVuYW50IExvZ288L3RpdGxlPjxnIGlkPSJDYW52YXMiPjxnIGlkPSJHcm91cCI+PGcgaWQ9IlN1YnRyYWN0Ij48dXNlIHhsaW5rOmhyZWY9IiNwYXRoMF9maWxsIiBmaWxsPSIjRkZGRkZGIi8+PC9nPjxnIGlkPSJTdWJ0cmFjdCI+PHVzZSB4bGluazpocmVmPSIjcGF0aDFfZmlsbCIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoNTggMjQpIiBmaWxsPSIjRkZGRkZGIi8+PC9nPjwvZz48L2c+PGRlZnM+PHBhdGggaWQ9InBhdGgwX2ZpbGwiIGZpbGwtcnVsZT0iZXZlbm9kZCIgZD0iTSAxODIuNzg3IDEyLjI4NDZDIDE3My4wMDUgOS40OTQwOCAxNjIuNjc3IDggMTUyIDhDIDkwLjE0NDEgOCA0MCA1OC4xNDQxIDQwIDEyMEMgNDAgMTgxLjg1NiA5MC4xNDQxIDIzMiAxNTIgMjMyQyAxODguNDY0IDIzMiAyMjAuODU3IDIxNC41NzUgMjQxLjMwOCAxODcuNTk4QyAyMTkuODcgMjI4LjI3MiAxNzcuMTczIDI1NiAxMjggMjU2QyA1Ny4zMDc1IDI1NiAwIDE5OC42OTIgMCAxMjhDIDAgNTcuMzA3NSA1Ny4zMDc1IDAgMTI4IDBDIDE0Ny42MDQgMCAxNjYuMTc5IDQuNDA3MDkgMTgyLjc4NyAxMi4yODQ2WiIvPjxwYXRoIGlkPSJwYXRoMV9maWxsIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0gMTM3LjA5IDkuMjEzNDJDIDEyOS43NTQgNy4xMjA1NiAxMjIuMDA4IDYgMTE0IDZDIDY3LjYwODEgNiAzMCA0My42MDgxIDMwIDkwQyAzMCAxMzYuMzkyIDY3LjYwODEgMTc0IDExNCAxNzRDIDE0MS4zNDggMTc0IDE2NS42NDMgMTYwLjkzMSAxODAuOTgxIDE0MC42OThDIDE2NC45MDMgMTcxLjIwNCAxMzIuODggMTkyIDk2IDE5MkMgNDIuOTgwNyAxOTIgMCAxNDkuMDE5IDAgOTZDIDAgNDIuOTgwNyA0Mi45ODA3IDAgOTYgMEMgMTEwLjcwMyAwIDEyNC42MzQgMy4zMDUzMSAxMzcuMDkgOS4yMTM0MloiLz48L2RlZnM+PC9zdmc+
[img release]: https://img.shields.io/github/v/release/TheFreeman193/NordVPN-Servers?sort=semver&logo=GitHub
[img commits since release]: https://img.shields.io/github/commits-since/TheFreeman193/NordVPN-Servers/latest/master?sort=semver&logo=git&label=Commits
[img pages status]: https://img.shields.io/github/deployments/TheFreeman193/NordVPN-Servers/github-pages?label=Pages&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZlcnNpb249IjEuMiIgd2lkdGg9IjQzNS44MjciIGhlaWdodD0iNTA2LjcyOCIgdmlld0JveD0iMCAwIDEyMzAwIDE0MzAwLjk4NSIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCI+PHBhdGggZD0iTTExNTAgMTMxNTAuOTg1di0xMjAwMGg2NjY3bDMzMzMgMzMzM3Y4NjY3SDExNTB6IiBmaWxsPSIjZmZmIi8+PHBhdGggZD0iTTExNTAgMTMxNTAuOTg1di0xMjAwMGg2NjY3bDMzMzMgMzMzM3Y4NjY3SDExNTB6IiBmaWxsPSJub25lIiBzdHJva2U9IiMwMDAiIHN0cm9rZS13aWR0aD0iMzAwIi8+PHBhdGggZD0iTTc4MTYgMTE0OS45ODVsMzMzNCAzMzM0SDc4MTZ2LTMzMzRoMHoiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLXdpZHRoPSIzMDAiLz48L3N2Zz4K
[img size]: https://img.shields.io/github/repo-size/TheFreeman193/NordVPN-Servers?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyOS45NzggMjkuOTc4Ij48cGF0aCBkPSJNMjUuNDYyIDE5LjEwNXY2Ljg0OEg0LjUxNXYtNi44NDhILjQ4OXY4Ljg2MWMwIDEuMTExLjkgMi4wMTIgMi4wMTYgMi4wMTJoMjQuOTY3YzEuMTE1IDAgMi4wMTYtLjkgMi4wMTYtMi4wMTJ2LTguODYxaC00LjAyNnpNMTQuNjIgMTguNDI2bC01Ljc2NC02Ljk2NXMtLjg3Ny0uODI4LjA3NC0uODI4aDMuMjQ4VjkuMjE3LjQ5NFMxMi4wNDkgMCAxMi43OTMgMGg0LjU3MmMuNTM2IDAgLjUyNC40MTYuNTI0LjQxNlYxMC40MjRoMi45OThjMS4xNTQgMCAuMjg1Ljg2Ny4yODUuODY3cy00LjkwNCA2LjUxLTUuNTg4IDcuMTkzYy0uNDkyLjQ5NS0uOTY0LS4wNTgtLjk2NC0uMDU4eiIvPjwvc3ZnPg==
[img ps gallery compat]: https://img.shields.io/powershellgallery/p/NordVPN-Servers?color=blue&label=PowerShell&logo=powershell&logoColor=lightblue
[img ps gallery release]: https://img.shields.io/powershellgallery/v/NordVPN-Servers?label=Version
[pages home]: https://thefreeman193.github.io/NordVPN-Servers
[download zip]: https://github.com/TheFreeman193/NordVPN-Servers/archive/master.zip
[ps gallery]: https://www.powershellgallery.com/packages/NordVPN-Servers
