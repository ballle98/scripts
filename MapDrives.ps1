[CmdletBinding()]
param(
    [string]$CredentialPath = (Join-Path ([Environment]::GetFolderPath('UserProfile')) 'MapDrivesCredential.txt'),
    [string]$DriveListPath = (Join-Path ([Environment]::GetFolderPath('UserProfile')) 'MapDrivesList.csv'),
    [ValidateRange(1, 10)]
    [int]$RetryCount = 3,
    [ValidateRange(0, 300)]
    [int]$RetryDelaySeconds = 30
)

$ErrorActionPreference = 'Stop'

function Get-DriveName {
    param([string]$DriveLetter)

    $name = $DriveLetter.Trim().TrimEnd(':').ToUpperInvariant()
    if ($name -notmatch '^[A-Z]$') {
        throw "Invalid DriveLetter '$DriveLetter'. Use a single letter, with or without a colon."
    }

    return $name
}

if (Test-Path -LiteralPath $CredentialPath -PathType Leaf) {
    $credential = Import-Clixml -LiteralPath $CredentialPath
    if ($credential -isnot [System.Management.Automation.PSCredential]) {
        throw "The file '$CredentialPath' does not contain a PowerShell credential. Delete it and run MapDrives again to recreate it."
    }
}
else {
    Write-Host "No saved network credential was found."
    $credential = Get-Credential -Message 'Enter the username and password used by the configured network shares.'
    if ($null -eq $credential) {
        throw 'Credential entry was cancelled.'
    }

    $credential | Export-Clixml -LiteralPath $CredentialPath -Force
    Write-Host "Saved the encrypted credential to $CredentialPath."
}

if (-not (Test-Path -LiteralPath $DriveListPath -PathType Leaf)) {
    throw @"
Drive list not found: $DriveListPath
Copy MapDrivesList.example.csv to that location and edit its DriveLetter and RemotePath values.
"@
}

$driveList = @(Import-Csv -LiteralPath $DriveListPath)
if ($driveList.Count -eq 0) {
    throw "The drive list '$DriveListPath' contains no mappings."
}

$mappings = foreach ($mapping in $driveList) {
    if (-not $mapping.PSObject.Properties['DriveLetter'] -or
        -not $mapping.PSObject.Properties['RemotePath']) {
        throw "The drive list '$DriveListPath' must contain DriveLetter and RemotePath columns."
    }

    $driveName = Get-DriveName -DriveLetter $mapping.DriveLetter
    $remotePath = $mapping.RemotePath.Trim()
    if ($remotePath -notmatch '^\\\\[^\\]+\\[^\\]+') {
        throw "Invalid RemotePath '$remotePath' for drive ${driveName}:. Use a UNC path such as \\server\share."
    }

    [pscustomobject]@{
        DriveName  = $driveName
        LocalPath  = "${driveName}:"
        RemotePath = $remotePath
    }
}

$duplicates = $mappings | Group-Object -Property DriveName | Where-Object Count -gt 1
if ($duplicates) {
    $duplicateNames = ($duplicates.Name | ForEach-Object { "${_}:" }) -join ', '
    throw "Duplicate drive letters in '$DriveListPath': $duplicateNames"
}

$pending = @($mappings)
for ($attempt = 1; $attempt -le $RetryCount -and $pending.Count -gt 0; $attempt++) {
    $failed = @()

    foreach ($mapping in $pending) {
        try {
            $existing = Get-SmbMapping -LocalPath $mapping.LocalPath -ErrorAction SilentlyContinue
            if ($existing -and
                $existing.Status -eq 'OK' -and
                $existing.RemotePath -eq $mapping.RemotePath) {
                Write-Host "$($mapping.LocalPath) is already mapped to $($mapping.RemotePath)."
                continue
            }

            if ($existing) {
                Write-Host "Removing the existing $($mapping.LocalPath) mapping to $($existing.RemotePath)."
                Remove-SmbMapping -LocalPath $mapping.LocalPath -Force -UpdateProfile -ErrorAction Stop
            }

            Write-Host "Mapping $($mapping.LocalPath) to $($mapping.RemotePath)."
            New-PSDrive -Name $mapping.DriveName `
                -PSProvider FileSystem `
                -Root $mapping.RemotePath `
                -Credential $credential `
                -Persist `
                -Scope Global `
                -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Warning "Could not map $($mapping.LocalPath) to $($mapping.RemotePath): $($_.Exception.Message)"
            $failed += $mapping
        }
    }

    $pending = @($failed)
    if ($pending.Count -gt 0 -and $attempt -lt $RetryCount) {
        Write-Host "Retrying $($pending.Count) failed mapping(s) in $RetryDelaySeconds seconds."
        Start-Sleep -Seconds $RetryDelaySeconds
    }
}

if ($pending.Count -gt 0) {
    $failedDrives = ($pending.LocalPath -join ', ')
    throw "Unable to map the following drive(s) after $RetryCount attempt(s): $failedDrives"
}
