#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '4.0' }

[CmdletBinding(DefaultParameterSetName = 'Full Test')]
param (
    [Parameter (Position = 0, ParameterSetName = 'Partial Test')]
    [String[]]
    $TestName,
    [Parameter (Position = 1, ParameterSetName = 'Partial Test')]
    [String[]]
    $Tag,
    [Parameter (Position = 2, ParameterSetName = 'Partial Test')]
    [String[]]
    $ExcludeTag,
    [Parameter (Position = 3, ParameterSetName = 'Partial Test')]
    [Parameter (Position = 3, ParameterSetName = 'Full Test')]
    [Int64]
    $TestSamples = 5
)

$ModulePath = Resolve-Path (Split-Path $PSScriptRoot)
if ((Split-Path $ModulePath -Leaf) -match '\d+\.\d+\.\d+') {
    $ModuleName = Split-Path (Split-Path $ModulePath) -Leaf
} else {
    $ModuleName = Split-Path $ModulePath -Leaf
}
Push-Location $ModulePath

if (!((Test-Path NordVPN-Servers.psm1 -PathType Leaf) -and (Test-Path .\tests\ -PathType Container))) {
    throw ("Couldn't find the NordVPN-Servers module. This script" +
        " must be run from the /tests directory in the module root!")
}
if (!(Test-Path tests\testdata.zip)) {
    throw 'Test data archive not present!'
}
if (Test-Path tests\TestSettings.tmp -PathType Leaf) {
    throw 'TestSettings.tmp exists! Another test is in progress'
}


Write-Information "Preparing for test..." -InformationAction Continue

# Shortcut for keeping existing files out of the way
$TestID = (New-Guid).Guid
$ShortID = $TestID.Split('-')[-1]

Set-Content -Path .\tests\TestSettings.tmp -Value "$TestID`n$TestSamples`n$ModuleName" -Force

# Shortcut to list of test data files
function GetTestData {
    $prefixes = @(
        'cities_*'
        'countries_*'
        'groups_*'
        'technologies_*'
        'servers_*'
        'recommended_*'
    )
    [System.IO.FileInfo[]]$list = @()
    $list = Get-ChildItem .\tests\*_raw.xml -File -Include $prefixes
    $list += Get-ChildItem .\tests\*_proc.xml -File -Include $prefixes

    $list
}

[System.Collections.ArrayList]$ProtectedFiles = @()
function ProtectFile($Path) {
    if (Test-Path ".\$Path") {
        Copy-Item ".\$Path" ".\$Path.test-$ShortID" -Force -ErrorAction Stop
        [void]$ProtectedFiles.Add($Path)
        Write-Information "Protected File $Path    =>    $Path.test-$ShortID" -InformationAction Continue
    }
}

function RestoreFiles {
    foreach ($Path in $ProtectedFiles) {
        if (Test-Path ".\$Path.test-$ShortID") {
            if (Test-Path ".\$Path") {
                Remove-Item ".\$Path" -Force
            }
            Rename-Item ".\$Path.test-$ShortID" "$Path" -Force -ErrorAction Stop
            Write-Information "Restored File $Path    <=    $Path.test-$ShortID" -InformationAction Continue
        }
        else {
            Write-Warning "Protected file $Path couldn't be restored, it is missing."
        }
    }
}

try {

    # Ensure we don't mess with the existing configuration
    ProtectFile 'NordVPN_Servers.xml'
    ProtectFile 'NordVPN_Servers.xml.zip'
    ProtectFile 'NordVPN-Servers.settings.json'
    ProtectFile 'NordVPN_Countries.xml'
    ProtectFile 'NordVPN_Groups.xml'
    ProtectFile 'NordVPN_Technologies.xml'

    $PESTER_CFG = @{
        Script = @{
            Path = '.\tests\NordVPN-Servers.Tests.ps1'
            Parameters = @{
                TestID = $TestID
                TestSamples = $TestSamples
            }
        }
        Strict = $true
    }

    switch ($PSBoundParameters) {
        {$_.TestName} {$PESTER_CFG.TestName = $_.TestName}
        {$_.Tag} {$PESTER_CFG.Tag = $_.Tag}
        {$_.ExcludeTag} {$PESTER_CFG.ExcludeTag = $_.ExcludeTag}
    }

    if ($PSCmdlet.ParameterSetName -eq 'Full Test') {
        $PESTER_CFG.CodeCoverage = '.\NordVPN-Servers.Classes.ps1', '.\NordVPN-Servers.psm1'
        $PESTER_CFG.CodeCoverageOutputFileFormat = 'JaCoCo'
        $PESTER_CFG.CodeCoverageOutputFile ='.\tests\CodeCoverage.xml'
        $PESTER_CFG.CodeCoverageOutputFileEncoding = 'utf8'
        $PESTER_CFG.OutputFormat = 'NUnitXml'
        $PESTER_CFG.OutputFile = '.\tests\TestResult.xml'
    }

    # Extract test data
    Expand-Archive .\tests\testdata.zip .\tests -Force -ErrorAction Stop

    Write-Information "`n`nStarting test $TestID ($($PSCmdlet.ParameterSetName))" -InformationAction Continue

    Invoke-Pester @PESTER_CFG

}
catch {

    Write-Warning "Pester invocation failed! Details: "
    $_ | Select-Object * -ExpandProperty Exception

}
finally {

    # Restore existing configuration
    RestoreFiles

    # Remove test data
    GetTestData | Remove-Item -force

    Remove-Item .\tests\TestSettings.tmp -Force

    Write-Information "`n`nFinished test $TestID" -InformationAction Continue

    Pop-Location

}
