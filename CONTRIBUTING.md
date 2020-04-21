# Contributing to the NordVPN-Servers project

First of all, thank you for being a part of this and the wider GitHub community! :heart:

## Code of conduct

[![Contributor Covenant](./CONTRIBUTING.svg)][code of conduct]

Please adhere to the **[code of conduct][code of conduct]** which is
 adapted from the [contributor covenant 2.0][cc2].

The [tl;dr][tldr] of this is be kind, be patient, and be respectful to others.

If you see any abuse or violation of GitHub's Terms of Service, please report
it, either using [this email][email] or via GitHub's
[report abuse][github report] page.

## Issues and bugs

If you have an issue with module that cannot be resolved by reviewing the
 [help documentation][help index], please [create an issue][create issue].
 The same applies if you have discovered a bug or unexpected functionality in
 the module.

### Creating an issue

When [creating an issue][create issue], please be as descriptive as possible.
The better you describe the issue, the quicker it can be resolved. The
recommended format for an issue is:

- A paragraph describing the issue in detail, ideally including *fenced* output
  or screenshots. See below for using code fences to wrap output.
- Full details of the environment, including the contents of `$PSVersionTable`,
  which version of the module you were using and the current settings (can be
  found in `NordVPN-Servers.settings.json` in the module folder.)
- Steps on how to reproduce the issue, again in as much detail as possible.

See the examples below for how to include these in your
issue description.

### How to include output in issues

#### Example of output text

Use code fences to produce tidy output from the console:

~~~
```powershell
<paste your console output here>
```
~~~

~~~powershell
Write-Error @FailedList : Unable to access country cache
    + CategoryInfo          : InvalidData: (:) [Write-Error], Country cache not expired but empty
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException
~~~

#### Example $PSVersionTable

Use code fences to produce tidy output from this variable:
~~~
```powershell
<paste your $PSVersionTable output here>
```
~~~

~~~powershell
PSVersion                      7.0.0
PSEdition                      Core
GitCommitId                    7.0.0
OS                             Microsoft Windows 10.0.18363
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0
~~~

#### Example NordVPN-Servers.settings.json

Use code fences to produce tidy data from this file:
~~~
```json
<paste the contents of NordVPN-Servers.settings.json here>
```
~~~

~~~json
{
  "CountryCacheLifetime": 600,
  "GroupCacheLifetime": 600,
  "TechnologyCacheLifetime": 600,
  "OfflineMode": false,
  "DeleteServerFallbackAfterUse": false
}
~~~

## Pull requests

If you've forked the repository and have made constructive changes, you may
 wish to consider opening a Pull Request. All constructive and beneficial pull
 requests are considered, but please do not be offended if they are not merged.
 As this project is released under the [MIT License][license], you are welcome
 to derive from this source in your own projects.

### Requirements

Please familiarise yourself with the module structure and coding style first.
Maintaining consistency with the existing style will help other developers and
will increase the likelihood of your pull request being merged.

#### Coding style

- Where possible, it is best to use the
  [PoshCode best practices][code style] guide; this is a comprehensive and
  popular style that is easily readable.
- All scripts and documents in this repository use the Windows CR-LF line
  ending style (0x0D 0x0A). Please ensure you maintain this EOL format.

#### Including documentation

This project uses a specific documentation workflow to generate MAML help files
 for the module. Please do not directly modify the markdown/XML/text help
 files, but include documentation for new functions, parameters etc. in the
 pull request description, and these will be updated in a separate commit.

#### Commit signing

The repository does not currently require [GPG][gpg] commit
 signatures, but this may change in future. You should consider this anyway!
 It is free, relatively straightforward to set up, and adds an extra level of
 authenticity to your work. Read more
 [here][git code signing].

[code of conduct]: ./CODE_OF_CONDUCT.md
[email]: mailto:thefreeman193@aol.co.uk
[github report]: https://github.com/contact/report-abuse
[help index]: .docs/INDEX.md
[create issue]: https://github.com/TheFreeman193/NordVPN-Servers/issues/new
[license]: ./LICENSE.md
[cc2]: https://www.contributor-covenant.org/version/2/0/code_of_conduct.html
[git code signing]: https://help.github.com/en/github/authenticating-to-github/signing-commits?algolia-query=signing
[code style]: https://poshcode.gitbooks.io/powershell-practice-and-style/content/
[tldr]: https://en.wiktionary.org/wiki/tl;dr
[gpg]: https://gnupg.org/
