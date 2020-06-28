#Requires -Assembly System.Xml.XmlDocument

$ModulePath = Resolve-Path (Split-Path $PSScriptRoot)
Push-Location $ModulePath

if (!(Test-Path .\tests\CodeCoverage.xml -PathType Leaf)) {
    throw "Cannot find CodeCoverage.xml!"
}
if (!(Test-Path .\tests\TestResult.xml -PathType Leaf)) {
    throw "Cannot find TestResult.xml!"
}
$Red = '#e05d44'
$Green = '#4c1'
$Orange = '#fe7d37'

$MasterTemplate = @'
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{0}" height="20">
    <linearGradient id="b" x2="0" y2="100%">
        <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
        <stop offset="1" stop-opacity=".1"/>
    </linearGradient>
    <clipPath id="a">
        <rect width="{0}" height="20" rx="3" fill="#fff"/>
    </clipPath>
    <g clip-path="url(#a)">
        <path fill="#555" d="{1}"/>
        <path fill="{{2}}" d="{2}"/>
        <path fill="url(#b)" d="{3}"/>
    </g>
    <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="110">
        <text x="{4}" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="{6}">
            {8}
        </text>
        <text x="{4}" y="140" transform="scale(.1)" textLength="{6}">
            {8}
        </text>
        <text x="{5}" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="{7}">
            {9}
        </text>
        <text x="{5}" y="140" transform="scale(.1)" textLength="{7}">
            {9}
        </text>
    </g>
</svg>
'@

$TestResultVals = @(
    '138'
    'M0 0h39v20H0z'
    'M39 0h99v20H39z'
    'M0 0h138v20H0z'
    '205'
    '875'
    '290'
    '890'
    'Tests'
    '{0}/{1} Passed'
)
$CodeCoverageVals = @(
    '106'
    'M0 0h63v20H0z'
    'M63 0h43v20H63z'
    'M0 0h106v20H0z'
    '325'
    '835'
    '530'
    '{1}'
    'Coverage'
    '{0}'
)

$TestResultTemplate = $MasterTemplate -f $TestResultVals
$CodeCoverageTemplate = $MasterTemplate -f $CodeCoverageVals

[System.Xml.XmlDocument]$CoverageReport = Get-Content .\tests\CodeCoverage.xml
$counter = $CoverageReport.report.counter | Where-Object type -eq 'INSTRUCTION'
$total = [Int64]$counter.missed + [Int64]$counter.covered

$TotalCoverage = [Int64]$counter.covered / $total
$TotalCoveragePretty = '{0:p0}' -f $TotalCoverage
if ($TotalCoverage -lt 1) {
    $CovCol = $Red
    $CovTxtSize = '250'
} else {
    $CovCol = $Green
    $CovTxtSize = '330'
}

$CoverageBadge = $CodeCoverageTemplate -f $TotalCoveragePretty, $CovTxtSize, $CovCol

Set-Content -Path .\tests\CodeCoverage.svg -Value $CoverageBadge -Encoding utf8 -Force

Write-Output "Generated code coverage badge ($TotalCoveragePretty)"

[System.Xml.XmlDocument]$TestResult = Get-Content .\tests\TestResult.xml
$total = [Int64]$TestResult.'test-results'.total
$TotalSucceeded = $total - (
    [Int64]$TestResult.'test-results'.errors +
    [Int64]$TestResult.'test-results'.failures +
    [Int64]$TestResult.'test-results'.'not-run' +
    [Int64]$TestResult.'test-results'.inconclusive +
    [Int64]$TestResult.'test-results'.invalid
)
if ($TotalSucceeded -lt $total) {
    if (($total - $TotalSucceeded)/$total -ge 0.1) {
        $TestCol = $Red
    } else {
        $TestCol = $Orange
    }
} else {
    $TestCol = $Green
}

$TestBadge = $TestResultTemplate -f $TotalSucceeded, $total, $TestCol

Set-Content -Path .\tests\TestResult.svg -Value $TestBadge -Encoding utf8 -Force

Write-Output "Generated test result badge ($TotalSucceeded/$total)"

Pop-Location
