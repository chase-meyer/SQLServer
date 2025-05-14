-- Desc: This will show the reason why each database's transaction log is not being reused.
--       Possible reasons are:
--       * Log backup needs to be run (if you could lose a day’s worth of data, consider simple recovery mode)
--       * Active backup running – because the full backup needs the transaction log to be able to restore to a specific point in time
--       * Active transaction – somebody typed BEGIN TRAN and locked their workstation for the weekend
--       * Database mirroring, replication, or AlwaysOn Availability Groups - the log is being used to send data to another server



SELECT name, database_id, log_reuse_wait, log_reuse_wait_desc
FROM sys.databases