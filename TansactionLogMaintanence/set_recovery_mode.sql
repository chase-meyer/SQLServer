-- Set the recovery mode to full
-- Reasons to select the full database recovery model:
--     * To support mission-critical applications
--     * Design High Availability keys
--     * To facilitate the recovery of all the data with zero or nominal data loss
--     * If the database designed to have multiple filegroups, and you want to perform a piecemeal restore of reading/write secondary filegroups and, optionally, read-only filegroups
--     * Allow random point-in-time restoration
--     * Restore individual sheets
--     * Sustain high administration overhead
-- Advantage: No work is misplaced due to a lost or damaged data file. It can recuperate to a random point in time.
-- Disadvantage: The transaction log file is not truncated until the log backup is performed. The transaction log file may grow rapidly.
--     If the log is damaged, the database can be restored only to the point of the last backup.
USE [master];
GO
ALTER DATABASE [yourdb]
SET RECOVERY FULL;
GO

-- Set the recovery mode to simple
-- Reasons to select the simple database recovery model:
--     * It is most suitable for development and Test Databases
--     * Simple reporting or application database, where data loss is tolerable
--     * The point-of-failure recovery is exclusively for full and distinction backups
--     * No administrative overhead
-- Advantage: It allows high-performance bulk copy operations, and regains log space to keep space requests small.
-- Disadvantage: The database can be restored only to the point of the last backup.
USE [master];
GO
ALTER DATABASE [yourdb]
SET RECOVERY SIMPLE;
GO

-- Set the recovery mode to bulk-logged
-- Reasons to select the bulk-logged database recovery model:
--    * importing large amounts of data and want to keep the transaction log small
--    * performing bulk operations, such as:
--          * BCP operations
--          * When using INSERT with SELECT
--          * SELECT INTO clauses
--          * When using the WRITE, WRITETEXT,UPDATETEXT
-- * when this option is set the INDEX creation is minimally logged
USE [master];
GO
ALTER DATABASE [yourdb]
SET RECOVERY BULK_LOGGED;
GO