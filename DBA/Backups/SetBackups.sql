-- Schedule a full backup every 30 days
IF (DAY(GETDATE()) = 1)
BEGIN
    BACKUP DATABASE [YourDatabaseName] 
    TO DISK = 'C:\Backups\YourDatabaseName_FULL.bak' 
    WITH FORMAT, INIT, NAME = 'Full Backup';
END
ELSE
BEGIN
    -- Schedule incremental backups daily
    BACKUP DATABASE [YourDatabaseName] 
    TO DISK = 'C:\Backups\YourDatabaseName_DIFF.bak' 
    WITH DIFFERENTIAL, INIT, NAME = 'Incremental Backup';
END

-- Cleanup old backup files (older than 30 days)
DECLARE @DeleteCommand NVARCHAR(MAX);
SET @DeleteCommand = 'forfiles /p "C:\Backups" /s /m *.bak /d -30 /c "cmd /c del @path"';
EXEC xp_cmdshell @DeleteCommand;