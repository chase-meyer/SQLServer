function Get-DatabaseFiles {
    param (
        [string]$Directory = "C:\Path\To\Your\Database\Directory", # Default local directory
        [int]$LogFileSizeThresholdMB = 1000 # Threshold for log files that may need shrinking
    )

    # Validate the directory path
    if (-not (Test-Path -Path $Directory)) {
        Write-Error "The specified directory '$Directory' does not exist."
        return
    }

    # Prompt for credentials if required
    $useCredentials = Read-Host "Does this directory require authentication? (y/n)"
    if ($useCredentials -eq 'y') {
        $credentials = Get-Credential
        $driveName = "TempDrive"
        New-PSDrive -Name $driveName -PSProvider FileSystem -Root $Directory -Credential $credentials -ErrorAction Stop
        $Directory = "${driveName}:\"
    }

    # Get all .mdf and .ldf files in the directory and subdirectories
    $dbFiles = Get-ChildItem -Path $Directory -Recurse -Include "*.mdf", "*.ldf" | ForEach-Object {
        [PSCustomObject]@{
            Directory    = $_.DirectoryName
            FileName     = $_.Name
            SizeKB       = [math]::Round($_.Length / 1KB, 2)
            SizeMB       = [math]::Round($_.Length / 1MB, 2)
            SizeGB       = [math]::Round($_.Length / 1GB, 2)
            LastModified = $_.LastWriteTime
            IsLogFile    = ($_.Extension -eq ".ldf")
            NeedsShrink  = ($_.Extension -eq ".ldf" -and [math]::Round($_.Length / 1MB, 2) -gt $LogFileSizeThresholdMB)
        }
    } | Group-Object Directory | Sort-Object { ($_.Group | Measure-Object -Property SizeMB -Sum).Sum } -Descending

    # Display the results
    foreach ($group in $dbFiles) {
        $totalSizeBytes = ($group.Group | Measure-Object -Property SizeMB -Sum).Sum
        Write-Host "Directory: $($group.Name)" -ForegroundColor Cyan
        Write-Host "Total Size: $([math]::Round($totalSizeBytes * 1024, 2)) KB" -ForegroundColor Yellow
        Write-Host "Total Size: $([math]::Round($totalSizeBytes, 2)) MB" -ForegroundColor Yellow
        Write-Host "Total Size: $([math]::Round($totalSizeBytes / 1024, 2)) GB" -ForegroundColor Yellow

        $group.Group | ForEach-Object {
            Write-Host "File: $($_.FileName)" -ForegroundColor Green
            Write-Host "Size: $($_.SizeKB) KB | $($_.SizeMB) MB | $($_.SizeGB) GB" -ForegroundColor Green
            Write-Host "Last Modified: $($_.LastModified)" -ForegroundColor Green
            if ($_.NeedsShrink) {
                Write-Host "Note: This log file may need shrinking." -ForegroundColor Red
            }
        }
        Write-Host ""
    }

    # Remove temporary drive if created
    if ($useCredentials -eq 'y') {
        Remove-PSDrive -Name $driveName -ErrorAction SilentlyContinue
    }

    return $dbFiles # Return the list of database files
}