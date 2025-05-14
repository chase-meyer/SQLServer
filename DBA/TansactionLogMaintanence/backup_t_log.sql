-- Parameterized script to back up the transaction log
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @BackupDevice NVARCHAR(256);

-- Set the database name and backup device
SET @DatabaseName = N'YourDatabaseName';
-- Replace with your database name
SET @BackupDevice = N'C:\Path\To\Your\BackupDevice.bak';
-- Replace with your backup device path

-- Back up the transaction log
BACKUP LOG @DatabaseName
TO DISK = @BackupDevice
WITH NOFORMAT, NOINIT, NAME = N'Transaction Log Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;
GO