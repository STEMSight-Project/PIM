<#
Copy testing files from Back-End and Front-End to Desktop artifacts folder.
Rules:
- Include files under Back-End and Front-End that contain 'test' or 'testing' in the filename (case-insensitive)
- Include files that are in directories named 'tests', 'testing_files', '__tests__' under Back-End and Front-End
- Preserve relative path structure under the artifacts folder on the Desktop
#>

param(
    [string] $RepoRoot = "C:\Users\Mike\PIM Detector\PIM",
    [string] $DestRoot = (Join-Path $env:USERPROFILE 'Desktop\artifacts_clean'),
    [switch] $ExcludeNodeModules = $true,
    [switch] $ExcludePycache = $true,
    [switch] $ExcludeSnapshots = $true,
    [switch] $ExcludePytestCache = $true,
    [switch] $ExcludeCompiled = $true,
    [switch] $CreateZip = $true
)

try {
    Write-Host "Repo root: $RepoRoot"
    Write-Host "Destination: $DestRoot"

    if ((Test-Path $DestRoot) -eq $false) {
        New-Item -Path $DestRoot -ItemType Directory -Force | Out-Null
        Write-Host "Created destination folder: $DestRoot"
    }

    $srcDirs = @(
        (Join-Path $RepoRoot 'Back-End'),
        (Join-Path $RepoRoot 'Front-End')
    )

    $dirPatternNames = @('tests','testing_files','__tests__')
    $namePattern = '(?i)test|testing' # case-insensitive

    $filesToCopy = @()
    foreach ($src in $srcDirs) {
        if (-not (Test-Path $src)) { continue }
        Write-Host "Scanning: $src"
        $items = Get-ChildItem -Path $src -Recurse -File -ErrorAction SilentlyContinue
        foreach ($it in $items) {
            $include = $false
            if ($it.Name -match $namePattern) { $include = $true }
            foreach ($d in $dirPatternNames) {
                if ($it.FullName -match '(?i)[\\/]' + [regex]::Escape($d) + '[\\/]') { $include = $true }
            }

            # Exclude patterns
            if ($ExcludeNodeModules -and ($it.FullName -match '(?i)[\\/]node_modules[\\/]')) { $include = $false }
            if ($ExcludePycache -and ($it.FullName -match '(?i)[\\/]__pycache__[\\/]')) { $include = $false }
            if ($ExcludePytestCache -and ($it.FullName -match '(?i)[\\/]\.pytest_cache[\\/]')) { $include = $false }
            if ($ExcludeSnapshots -and ($it.FullName -match '(?i)[\\/]__snapshots__[\\/]')) { $include = $false }
            if ($ExcludeSnapshots -and ($it.Extension -eq '.snap')) { $include = $false }
            if ($ExcludeCompiled -and ($it.Extension -in '.pyc', '.pyo', '.class', '.dll', '.so')) { $include = $false }

            if ($include) { $filesToCopy += $it }
        }
    }

    $filesToCopy = $filesToCopy | Sort-Object FullName -Unique
    if ($filesToCopy.Count -eq 0) {
        Write-Host "No matching test files found under Back-End or Front-End."
        exit 0
    }

    foreach ($f in $filesToCopy) {
        $rel = $f.FullName.Substring($RepoRoot.Length)
        $rel = $rel.TrimStart('\','/')
        $targetFile = Join-Path $DestRoot $rel
        $targetDir = Split-Path $targetFile -Parent
        if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
        Copy-Item -Path $f.FullName -Destination $targetFile -Force
        Write-Host "Copied: $rel"
    }

    Write-Host "Copied $($filesToCopy.Count) files to $DestRoot"
    if ($CreateZip) {
        $zipTarget = Join-Path $env:USERPROFILE 'Desktop\artifacts_clean.zip'
        if (Test-Path $zipTarget) { Remove-Item $zipTarget -Force }
        Compress-Archive -Path (Join-Path $DestRoot '*') -DestinationPath $zipTarget -Force
        Write-Host "Created ZIP archive: $zipTarget"
    }
    exit 0
}
catch {
    Write-Error "Error: $_"
    exit 1
}
