param(
    [Uri]$BaseUrl = 'https://github.com/wuhanawan-oss/awan-watermark-download/releases/latest/download',
    [string]$Destination = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Awan-Download-20261003')
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if ($BaseUrl.Scheme -ne 'https') { throw 'Use an HTTPS release download URL.' }
$releaseBase = $BaseUrl.AbsoluteUri.TrimEnd('/')
if (Test-Path -LiteralPath $Destination) {
    if (-not (Test-Path -LiteralPath $Destination -PathType Container)) { throw 'Destination is not a folder.' }
} else {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}
$downloadRoot = (Resolve-Path -LiteralPath $Destination).Path
$manifestPath = Join-Path $downloadRoot 'awan-download.json'
Invoke-WebRequest -Uri "$releaseBase/awan-download.json" -OutFile $manifestPath -UseBasicParsing
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($manifest.archive -ne 'Awan-v1.2-batch-fp16-win64.zip') { throw 'Unexpected archive name.' }
if ($manifest.sha256 -notmatch '^[a-fA-F0-9]{64}$') { throw 'Invalid archive checksum.' }
$archivePath = Join-Path $downloadRoot $manifest.archive
if (Test-Path -LiteralPath $archivePath) { throw 'Archive already exists; choose another destination.' }
$partPaths = @()
foreach ($part in $manifest.parts) {
    if ($part.name -notmatch '^Awan-v1\.2-batch-fp16-win64\.zip\.part\d{3}$') { throw 'Invalid part name.' }
    if ($part.sha256 -notmatch '^[a-fA-F0-9]{64}$') { throw 'Invalid part checksum.' }
    $partPath = Join-Path $downloadRoot $part.name
    if (-not (Test-Path -LiteralPath $partPath)) {
        Write-Host "Downloading $($part.name)"
        Invoke-WebRequest -Uri "$releaseBase/$($part.name)" -OutFile $partPath -UseBasicParsing
    }
    if ((Get-Item -LiteralPath $partPath).Length -ne [long]$part.bytes) { throw "Size mismatch: $($part.name)" }
    if ((Get-FileHash -LiteralPath $partPath -Algorithm SHA256).Hash -ne $part.sha256) { throw "Checksum mismatch: $($part.name)" }
    $partPaths += $partPath
}
$archiveStream = [IO.File]::Open($archivePath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
try {
    foreach ($partPath in $partPaths) {
        $inputStream = [IO.File]::OpenRead($partPath)
        try { $inputStream.CopyTo($archiveStream) } finally { $inputStream.Dispose() }
    }
} finally { $archiveStream.Dispose() }
if ((Get-Item -LiteralPath $archivePath).Length -ne [long]$manifest.bytes) { throw 'Combined size mismatch.' }
if ((Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash -ne $manifest.sha256) { throw 'Combined checksum mismatch.' }
Write-Host "Complete: $archivePath"
Write-Host 'Extract the whole ZIP into a new folder, then open the application EXE. This script does not run the application.'
