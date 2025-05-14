USE msdb;
GO

DECLARE @DatabaseName NVARCHAR(128) = NULL;
-- Set to NULL to show all databases, or specify a database name

SELECT
    bs.database_name,
    bs.backup_start_date,
    bs.backup_finish_date,
    CONVERT(INT, FORMAT(bs.backup_start_date, 'yyyyMMdd')) AS start_date, -- Start date in YYYYMMDD format
    CONVERT(INT, FORMAT(DATEADD(MINUTE, -5, bs.backup_start_date), 'HHmmss')) AS start_time, -- Start time in HHMMSS format
    CONVERT(INT, FORMAT(DATEADD(MINUTE, 5, bs.backup_finish_date), 'HHmmss')) AS finish_time, -- Finish time in HHMMSS format
    bs.type AS backup_type,
    CASE bs.type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Transaction Log'
    END AS backup_type_desc,
    bmf.physical_device_name AS backup_file,
    bs.user_name AS created_by, -- User who created the backup
    CASE bs.software_vendor_id
        WHEN 4608 THEN 'SQL Server'
        ELSE 'Third-Party Tool'
    END AS software_vendor, -- Translate software_vendor_id to a readable format
    sj.name AS possible_job_name
-- SQL Server Agent job name that triggered the backup
FROM
    backupset bs
    INNER JOIN backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
    LEFT JOIN msdb.dbo.sysjobhistory sjh ON 
        sjh.run_date = CONVERT(INT, FORMAT(bs.backup_start_date, 'yyyyMMdd')) AND
        (
            (sjh.run_time >= CONVERT(INT, FORMAT(DATEADD(MINUTE, -5, bs.backup_start_date), 'HHmmss')) AND sjh.run_time <= 235959) OR
        (sjh.run_time <= CONVERT(INT, FORMAT(DATEADD(MINUTE, 5, bs.backup_finish_date), 'HHmmss')) AND sjh.run_time >= 0)
        )
    LEFT JOIN msdb.dbo.sysjobs sj ON sj.job_id = sjh.job_id
WHERE 
    (@DatabaseName IS NULL OR bs.database_name = @DatabaseName) -- Filter by database if provided
    AND bs.type != 'D' AND bs.type != 'L' -- Exclude full and transaction log backups
    AND YEAR(bs.backup_start_date) = YEAR(GETDATE())
-- Filter backups to this year
ORDER BY 
    bs.database_name, -- Sort by database name
    bs.backup_start_date DESC;