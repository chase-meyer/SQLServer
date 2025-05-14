DECLARE @DatabaseName NVARCHAR(128);
SET @DatabaseName = N'YourDatabaseName';
-- Replace with your database name

SELECT name, database_id, recovery_model_desc
FROM sys.databases
WHERE name = @DatabaseName;
GO