-- This T-SQL script checks the autogrowth and autoshrink settings for all databases on the server.

SELECT DB_NAME(mf.database_id) AS [Database Name],  
mf.name AS [File Name],
mf.growth AS [Growth Value],
CASE WHEN mf.is_percent_growth = 1 
   THEN 'Percentage Growth'
   ELSE 'MB Growth'
   END AS [Growth Type]
FROM sys.master_files mf 
WHERE mf.is_percent_growth = 1
   OR mf.growth > 128;