DECLARE @SourceDatabase NVARCHAR(128),
        @BackupPath NVARCHAR(260),
        @TargetDatabase NVARCHAR(128),
        @DataFilePath NVARCHAR(260),
        @LogFilePath NVARCHAR(260),
        @LogicalDataName NVARCHAR(128),
        @LogicalLogName NVARCHAR(128);

-- Set parameters
-- Replace with the source database name
SET @SourceDatabase = 'YourSourceDatabaseName';
-- Replace with the backup file path
SET @BackupPath = 'C:\Backup\SourceDatabase.bak';
-- Replace with the target database name
SET @TargetDatabase = 'YourTargetDatabaseName';
-- Replace with the target data file path
SET @DataFilePath = 'C:\Data\TargetDatabase_Data.mdf';
-- Replace with the target log file path
SET @LogFilePath = 'C:\Data\TargetDatabase_Log.ldf';

-- Get logical file names
CREATE TABLE #FileList
(
    LogicalName NVARCHAR(128),
    PhysicalName NVARCHAR(260),
    [Type] CHAR(1),
    FileGroupName NVARCHAR(128) NULL,
    Size BIGINT,
    MaxSize BIGINT,
    FileId INT,
    CreateLSN NUMERIC(25,0) NULL,
    DropLSN NUMERIC(25,0) NULL,
    UniqueId UNIQUEIDENTIFIER NULL,
    ReadOnlyLSN NUMERIC(25,0) NULL,
    ReadWriteLSN NUMERIC(25,0) NULL,
    BackupSizeInBytes BIGINT,
    SourceBlockSize INT,
    FileGroupId INT NULL,
    LogGroupGUID UNIQUEIDENTIFIER NULL,
    DifferentialBaseLSN NUMERIC(25,0) NULL,
    DifferentialBaseGUID UNIQUEIDENTIFIER NULL,
    IsReadOnly BIT,
    IsPresent BIT,
    TDEThumbprint VARBINARY(32) NULL
);

INSERT INTO #FileList
EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @BackupPath + '''');

-- Assign logical names to variables
SELECT TOP 1
    @LogicalDataName = LogicalName
FROM #FileList
WHERE [Type] = 'D';

SELECT TOP 1
    @LogicalLogName = LogicalName
FROM #FileList
WHERE [Type] = 'L';

-- Drop temporary table
DROP TABLE #FileList;

-- Backup the source database
BACKUP DATABASE @SourceDatabase
TO DISK = @BackupPath
WITH INIT;

-- Restore the backup to the new database
RESTORE DATABASE @TargetDatabase
FROM DISK = @BackupPath
WITH MOVE @LogicalDataName TO @DataFilePath,
     MOVE @LogicalLogName TO @LogFilePath;