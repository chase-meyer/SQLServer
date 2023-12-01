-- Precaution: 
--    * Shrink log files only when you have a good reason to do so. Log files are an essential part of your 
--          database's recovery strategy, and if you shrink a log file while a transaction is running, you break the
--          log chain. This means that you can't restore your database to a point in time after the shrink operation.
-- Reasons to shrink log files:
--    * you are in full recovery mode, but you are not taking log backups often enough (or at all).
--    * you are in full recovery mode, but you don't need point-in-time recovery.
--    * you had a very large transaction that bloated the log file.
-- Considerations:
--    * a log file needs to accommodate the sum of any concurrent transactions that can occure
--    * Log file autogrowth is expensive, so you want to avoid it.
--    * you want a practical size of log file.
--    * you want 10-50% larger than the largest it has ever been.
--          keep in mind that the log file will grow to exess if backups are not taken.

USE yourdb;
GO
DBCC SHRINKFILE(N'yourdb_log', 200); -- unit is MB, adjust this appropriately
GO