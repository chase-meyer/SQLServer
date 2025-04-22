USE msdb;
GO

DECLARE @DatabaseName NVARCHAR(128) = NULL;
-- Set to NULL to show all databases, or specify a database name

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
    (@DatabaseName IS NULL OR bs.database_name = @DatabaseName) -- Filter by database if provided
    AND bs.type != 'D' AND bs.type != 'L'
-- Exclude full and transaction log backups
ORDER BY 
    bs.database_name, -- Sort by database name
    bs.backup_start_date DESC;