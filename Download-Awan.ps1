param(
    [Uri]$BaseUrl = 'https://github.com/wuhanawan-oss/awan-watermark-download/releases/latest/download',
    [string]$Destination = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Awan-Download-20261004')
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if ($BaseUrl.Scheme -ne 'https') { throw 'Use an HTTPS download URL.' }
$releaseBase = $BaseUrl.AbsoluteUri.TrimEnd('/')
if (-not (Test-Path -LiteralPath $Destination)) { New-Item -ItemType Directory -Path $Destination | Out-Null }
if (-not (Test-Path -LiteralPath $Destination -PathType Container)) { throw 'Destination is not a folder.' }
$downloadRoot = (Resolve-Path -LiteralPath $Destination).Path
$manifestPath = Join-Path $downloadRoot 'awan-download.json'
Invoke-WebRequest -Uri "$releaseBase/awan-download.json" -OutFile $manifestPath -UseBasicParsing
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($manifest.version -ne '1.2.1' -or $manifest.archive -ne 'Awan-v1.2-batch-fp16-win64.zip') { throw 'Unexpected package version or name.' }
function FetchChecked($url, $path, $size, $sha) {
    if ([Uri]$url -and ([Uri]$url).Scheme -ne 'https') { throw 'Download URL must use HTTPS.' }
    if ($sha -notmatch '^[a-fA-F0-9]{64}$') { throw 'Invalid checksum.' }
    if (-not (Test-Path -LiteralPath $path)) {
        Write-Host "Downloading $([IO.Path]::GetFileName($path))"
        Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
    }
    if ((Get-Item -LiteralPath $path).Length -ne [long]$size) { throw "Size mismatch: $path. Choose a new destination to retry." }
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $sha) { throw "Checksum mismatch: $path" }
}
$partPaths = @()
foreach ($part in $manifest.parts) {
    if ($part.name -notmatch '^Awan-v1\.2-batch-fp16-win64\.zip\.part\d{3}$') { throw 'Invalid part name.' }
    $partPath = Join-Path $downloadRoot $part.name
    FetchChecked $part.url $partPath $part.bytes $part.sha256
    $partPaths += $partPath
}
$archivePath = Join-Path $downloadRoot $manifest.archive
if (-not (Test-Path -LiteralPath $archivePath)) {
    $stream = [IO.File]::Open($archivePath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
    try {
        foreach ($partPath in $partPaths) {
            $source = [IO.File]::OpenRead($partPath)
            try { $source.CopyTo($stream) } finally { $source.Dispose() }
        }
    } finally { $stream.Dispose() }
}
if ((Get-Item -LiteralPath $archivePath).Length -ne [long]$manifest.bytes) { throw 'Combined size mismatch.' }
if ((Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash -ne $manifest.sha256) { throw 'Combined checksum mismatch.' }
if ($manifest.update.name -ne 'Awan-update-v1.2.1-win64.zip') { throw 'Unexpected update name.' }
$patchPath = Join-Path $downloadRoot $manifest.update.name
FetchChecked $manifest.update.url $patchPath $manifest.update.bytes $manifest.update.sha256
if ($manifest.install_root -ne 'Awan-1.2-batch-fp16-20261003') { throw 'Invalid install folder.' }
$softwareRoot = Join-Path $downloadRoot 'software-v1.2.1'
if (Test-Path -LiteralPath $softwareRoot) { throw 'Software folder already exists; choose a new destination.' }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::ExtractToDirectory($archivePath, $softwareRoot)
$installRoot = [IO.Path]::GetFullPath((Join-Path $softwareRoot $manifest.install_root))
if (-not (Test-Path -LiteralPath $installRoot -PathType Container)) { throw 'Base package folder missing.' }
$boundary = $installRoot + [IO.Path]::DirectorySeparatorChar
$patch = [IO.Compression.ZipFile]::OpenRead($patchPath)
$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
try {
    if ($patch.Entries.Count -ne $manifest.update.files.Count) { throw 'Unexpected update entries.' }
    foreach ($entry in $patch.Entries) {
        $relative = $entry.FullName
        if (-not $seen.Add($relative) -or $relative -match '[:\x00-\x1f]' -or $relative -match '(^[\\/]|(^|[\\/])\.\.([\\/]|$))') { throw 'Unsafe update path.' }
        $expected = @($manifest.update.files | Where-Object { $_.path -eq $relative })
        if ($expected.Count -ne 1 -or $entry.Length -ne [long]$expected[0].bytes) { throw 'Unexpected update file.' }
        $target = [IO.Path]::GetFullPath((Join-Path $installRoot $relative))
        if (-not $target.StartsWith($boundary, [StringComparison]::OrdinalIgnoreCase)) { throw 'Update path leaves install folder.' }
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target)) | Out-Null
        [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
        if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash -ne $expected[0].sha256) { throw "Update file checksum mismatch: $relative" }
    }
} finally { $patch.Dispose() }
Write-Host "Version 1.2.1 ready: $installRoot"
Write-Host 'Open the application EXE yourself. No application or model has been started.'
