# Import SQL Server module
Import-Module SqlServer

# Define source and destination server details
# $sourceServer = ""
# $sourceDatabase = ""
$destinationServer = ""
$destinationDatabase = ""
$backupFile = ""
$backupFileOnDestination = ""

# Define credentials
# $sourceUsername = ""
# $sourcePassword = ConvertTo-SecureString "" -AsPlainText -Force
# $sourcePassword.MakeReadOnly()
$destinationUsername = ""
$destinationPassword = ConvertTo-SecureString "" -AsPlainText -Force
$destinationPassword.MakeReadOnly()

# Create PSCredential objects
# $sourceCredential = New-Object System.Management.Automation.PSCredential ($sourceUsername, $sourcePassword)
$destinationCredential = New-Object System.Management.Automation.PSCredential ($destinationUsername, $destinationPassword)

# try {
#     # Check if the directory exists and has write permissions
#     if (-not (Test-Path "C:\Temp")) {
#         Write-Error "Directory C:\Temp does not exist."
#         exit 1
#     }
#     $tempDir = Get-Item "C:\Temp"
#     if (-not $tempDir.Attributes -band [System.IO.FileAttributes]::Directory) {
#         Write-Error "C:\Temp is not a directory."
#         exit 1
#     }
#     if (-not (Test-Path -Path "C:\Temp" -PathType Container -ErrorAction SilentlyContinue)) {
#         Write-Error "No write permissions for directory C:\Temp."
#         exit 1
#     }

#     # Check SQL Server connection
#     try {
#         Invoke-Sqlcmd -ServerInstance $sourceServer -Credential $sourceCredential -Query "SELECT 1" -ErrorAction Stop
#         Write-Host "Connection to source SQL Server successful."
#     }
#     catch {
#         Write-Error "Cannot connect to source SQL Server: $sourceServer. Error: $_"
#         exit 1
#     }

#     # Backup the source database
#     Backup-SqlDatabase -ServerInstance $sourceServer -Database $sourceDatabase -Credential $sourceCredential -ErrorAction Stop -Verbose
#     Write-Host "Backup completed successfully."
# }
# catch {
#     Write-Error "Failed to backup the database: $_"
#     exit 1
# }

# if (Test-Path $backupFile) {
#     Write-Host "Backup file exists at $backupFile"
#     $backupFileDetails = Get-Item $backupFile
#     Write-Host "Backup file size: $($backupFileDetails.Length) bytes"
# }
# else {
#     Write-Error "Backup file not found at $backupFile"
#     exit 1
# }

try {
    # Check if the destination database exists
    $databaseExistsQuery = "IF DB_ID('$destinationDatabase') IS NULL SELECT 0 ELSE SELECT 1"
    $databaseExists = Invoke-Sqlcmd -ServerInstance $destinationServer -Credential $destinationCredential -Query $databaseExistsQuery -ErrorAction Stop

    if ($databaseExists.Column1 -eq 0) {
        Write-Host "Destination database does not exist. Creating database $destinationDatabase."
        $createDatabaseQuery = "CREATE DATABASE [$destinationDatabase]"
        Invoke-Sqlcmd -ServerInstance $destinationServer -Credential $destinationCredential -Query $createDatabaseQuery -ErrorAction Stop
        Write-Host "Database $destinationDatabase created successfully."
    }
    else {
        Write-Host "Destination database $destinationDatabase already exists."
    }
}
catch {
    Write-Error "Failed to check or create the destination database: $_"
    exit 1
}

try {
    # Restore the database to the destination server
    Restore-SqlDatabase -ServerInstance $destinationServer -Database $destinationDatabase -BackupFile $backupFileOnDestination -Credential $destinationCredential -ReplaceDatabase -ErrorAction Stop
    Write-Host "Restore completed successfully."
}
catch {
    Write-Error "Failed to restore the database: $_"
    exit 1
}

# Clean up the backup file
try {
    Remove-Item -Path $backupFile -ErrorAction Stop
    Write-Host "Backup file removed successfully."
}
catch {
    Write-Error "Failed to remove the backup file: $_"
}
