-- Guide to change autogrowth settings for a database
-- https://blog.sqlauthority.com/2023/07/19/sql-server-monitoring-database-autogrowth-settings/ 
--
-- Set Reasonable Initial Sizes: The initial size of a database should be set to an appropriate value based on the 
--     expected data size. This can help prevent frequent auto-growth events, which can impact performance.
-- 
-- Use Appropriate Autogrowth Increments: Rather than allowing the database to grow by a small, fixed-size each 
--     time, consider setting autogrowth to occur in percentages. This can help prevent the creation of too many
--     virtual log files (VLFs) in transaction log files. However, be cautious about setting the percentage too 
--     high, as this can lead to the database suddenly consuming a lot of disk space.
-- 
-- Monitor Free Space and Growth Events: Regularly monitor the free space in your database files and the number of 
--     autogrowth events. Frequent autogrowth events can impact performance and indicate that the initial file size 
--     or growth increment is too small.
-- 
-- Consider Instant File Initialization (IFI): IFI is a feature in SQL Server that allows data files to be instantly 
--     initialized. This can greatly reduce the time it takes for autogrowth events to occur, but it doesn’t apply to log
--     files. Note that IFI has security implications that should be considered.
-- 
-- Regularly Review and Adjust Settings: As your database usage changes, so should your autogrowth settings. Regularly 
--     review these settings and make adjustments as necessary.
-- 
-- Ensure Enough Disk Space: Autogrowth can only work if there is sufficient disk space. Always monitor your disk space 
--     usage and ensure enough space for your databases to grow.
-- 
-- Avoid Using ‘Autoshrink’: While it might seem like a good counterpart to autogrowth, autoshrink can lead to fragmented 
--     databases and should generally be avoided.
-- 
-- Pre-grow Your Databases: If you know you will be importing a large amount of data, pre-grow your databases to 
--     accommodate this data. This can help avoid performance hits from autogrowth events.


ALTER DATABASE databasename  
MODIFY FILE (NAME = filename, FILEGROWTH = 256MB);