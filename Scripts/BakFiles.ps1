function Get-BakFiles {
    param (
        [string]$Directory = "C:\Path\To\Your\Backup\Directory", # Default local directory
        [int]$DaysOld = 30, # Default threshold for old files
        [switch]$DirectoriesOnly # Switch to display directories only
    )

    # Validate the directory path
    if (-not (Test-Path -Path $Directory)) {
        Write-Error "The specified directory '$Directory' does not exist."
        return
    }

    # Get all .bak files in the directory and subdirectories
    $bakFiles = Get-ChildItem -Path $Directory -Recurse -Filter "*.bak" | ForEach-Object {
        [PSCustomObject]@{
            Directory    = $_.DirectoryName
            FileName     = $_.FullName
            SizeMB       = [math]::Round($_.Length / 1MB, 2)
            LastModified = $_.LastWriteTime
            IsOld        = ($_.LastWriteTime -lt (Get-Date).AddDays(-$DaysOld))
        }
    }

    # Group files by directory and calculate total size and file count per directory
    $groupedByDirectory = $bakFiles | Group-Object Directory | ForEach-Object {
        $totalSizeBytes = ($_.Group | Measure-Object -Property SizeMB -Sum).Sum
        [PSCustomObject]@{
            Directory   = $_.Name
            TotalSizeKB = [math]::Round($totalSizeBytes * 1024, 2)
            TotalSizeMB = [math]::Round($totalSizeBytes, 2)
            TotalSizeGB = [math]::Round($totalSizeBytes / 1024, 2)
            FileCount   = $_.Group.Count
            Files       = $_.Group
        }
    } | Sort-Object TotalSizeMB -Descending # Sort directories by total size (largest to smallest)

    # Display the results
    foreach ($group in $groupedByDirectory) {
        Write-Host "Directory: $($group.Directory)" -ForegroundColor Cyan
        Write-Host "Total Size: $($group.TotalSizeKB) KB" -ForegroundColor Yellow
        Write-Host "Total Size: $($group.TotalSizeMB) MB" -ForegroundColor Yellow
        Write-Host "Total Size: $($group.TotalSizeGB) GB" -ForegroundColor Yellow
        Write-Host "Total Files: $($group.FileCount)" -ForegroundColor Green

        if (-not $DirectoriesOnly) {
            $group.Files | Sort-Object LastModified | Format-Table -Property FileName, SizeMB, LastModified, IsOld -AutoSize
        }
        Write-Host ""
    }

    return $groupedByDirectory # Return grouped directory output
}

function Remove-BakFiles {
    param (
        [string]$Directory = "C:\Path\To\Your\Backup\Directory", # Default local directory
        [int]$DaysOld = 30 # Default threshold for old files
    )

    # Validate the directory path
    if (-not (Test-Path -Path $Directory)) {
        Write-Error "The specified directory '$Directory' does not exist."
        return
    }

    # Create a log file in the current directory
    $logFile = Join-Path -Path (Get-Location) -ChildPath "BakFilesRemovalLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    Add-Content -Path $logFile -Value "Log started at $(Get-Date)`n"

    # Get all .bak files older than the specified number of days
    $oldBakFiles = Get-ChildItem -Path $Directory -Recurse -Filter "*.bak" | Where-Object {
        $_.LastWriteTime -lt (Get-Date).AddDays(-$DaysOld)
    } | Group-Object DirectoryName | ForEach-Object {
        $totalSizeBytes = ($_.Group | Measure-Object -Property Length -Sum).Sum
        [PSCustomObject]@{
            Directory   = $_.Name
            TotalSizeMB = [math]::Round($totalSizeBytes / 1MB, 2)
            Files       = $_.Group
        }
    } | Sort-Object TotalSizeMB -Descending # Sort directories by total size (largest to smallest)

    # Process each directory
    foreach ($group in $oldBakFiles) {
        Write-Host "Directory: $($group.Directory)" -ForegroundColor Cyan
        Write-Host "Total Size: $($group.TotalSizeMB) MB" -ForegroundColor Yellow
        Add-Content -Path $logFile -Value "Directory: $($group.Directory)`nTotal Size: $($group.TotalSizeMB) MB`n"

        $group.Files | ForEach-Object {
            Write-Host "File: $($_.FullName) | Last Modified: $($_.LastWriteTime)" -ForegroundColor Yellow
            Add-Content -Path $logFile -Value "File: $($_.FullName) | Last Modified: $($_.LastWriteTime)"
        }

        # Prompt user for confirmation
        $confirmation = Read-Host "Do you want to delete these files? (y/n)"
        if ($confirmation -eq 'y') {
            $group.Files | ForEach-Object {
                try {
                    Remove-Item -Path $_.FullName -Force
                    Write-Host "Removed: $($_.FullName)" -ForegroundColor Green
                    Add-Content -Path $logFile -Value "Removed: $($_.FullName)"
                }
                catch {
                    Write-Host "Failed to remove: $($_.FullName)" -ForegroundColor Red
                    Add-Content -Path $logFile -Value "Failed to remove: $($_.FullName)"
                }
            }
        }
        else {
            Write-Host "Skipped deletion for directory: $($group.Directory)" -ForegroundColor Cyan
            Add-Content -Path $logFile -Value "Skipped deletion for directory: $($group.Directory)"
        }
        Write-Host ""
        Add-Content -Path $logFile -Value "`n"
    }

    Add-Content -Path $logFile -Value "Log ended at $(Get-Date)`n"
    Write-Host "Log file created at: $logFile" -ForegroundColor Green
}

function Check-BackupHistory {
    param (
        [string]$SqlInstance = "YourSqlServerInstance", # SQL Server instance name
        [string]$DatabaseName = $null                  # Optional database name
    )

    # Query to get backup history
    $query = @"
    USE msdb;
    SELECT 
        bs.database_name,
        bs.backup_start_date,
        bs.backup_finish_date,
        bs.type AS backup_type,
        CASE bs.type
            WHEN 'D' THEN 'Full'
            WHEN 'I' THEN 'Differential'
            WHEN 'L' THEN 'Transaction Log'
        END AS backup_type_desc,
        bmf.physical_device_name AS backup_file
    FROM 
        backupset bs
    INNER JOIN 
        backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
    WHERE 
        (@DatabaseName IS NULL OR bs.database_name = @DatabaseName)
    ORDER BY 
        bs.database_name,
        bs.backup_start_date DESC;
"@

    # Execute the query
    $parameters = @{}
    if ($DatabaseName) {
        $parameters['DatabaseName'] = $DatabaseName
    }

    $backupHistory = Invoke-Sqlcmd -ServerInstance $SqlInstance -Query $query -Variable $parameters

    # Display the results
    if ($backupHistory) {
        $backupHistory | Format-Table -AutoSize
    }
    else {
        Write-Host "No backup history found." -ForegroundColor Yellow
    }
}

# Example usage:
# Get-BakFiles -Directory "C:\Path\To\Your\Backup\Directory" -DaysOld 30 -DirectoriesOnly
# Remove-BakFiles -Directory "C:\Path\To\Your\Backup\Directory" -DaysOld 30
# Check-BackupHistory -SqlInstance "YourSqlServerInstance"
# Check-BackupHistory -SqlInstance "YourSqlServerInstance" -DatabaseName "YourDatabaseName"
