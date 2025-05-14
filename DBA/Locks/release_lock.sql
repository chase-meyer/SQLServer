-- https://everyething.com/how-to-release-or-remove-lock-on-a-table-SQL-server

-- Create a lock on a table
BEGIN TRANSACTION
DELETE TOP (1) FROM dbo.MyTable 

-- This Select will run forever without any result because it is trying to access 
--     the row which is locked by the above delete statement.
SELECT * FROM dbo.MyTable

-- To Find locks on a table
SELECT
    OBJECT_NAME(P.object_id) AS TableName,
    Resource_type, request_status,  request_session_id	
FROM
    sys.dm_tran_locks dtl
    join sys.partitions P
ON dtl.resource_associated_entity_id = p.hobt_id
WHERE   OBJECT_NAME(P.object_id) = 'Titles' 

-- Create a lock on a table
BEGIN TRANSACTION
DELETE TOP (1) FROM dbo.MyTable 

-- This Select will run forever without any result because it is trying to access 
--     the row which is locked by the above delete statement.
SELECT * FROM dbo.MyTable

-- To Find locks on a table


-- Create a lock on a table
BEGIN TRANSACTION
DELETE TOP (1) FROM dbo.MyTable 

-- This Select will run forever without any result because it is trying to access 
--     the row which is locked by the above delete statement.
SELECT * FROM dbo.MyTable

-- To Find locks on a table


-- Create a lock on a table
BEGIN TRANSACTION
DELETE TOP (1) FROM dbo.MyTable 

-- This Select will run forever without any result because it is trying to access 
--     the row which is locked by the above delete statement.
SELECT * FROM dbo.MyTable

-- To Find locks on a table


-- Create a lock on a table
BEGIN TRANSACTION
DELETE TOP (1) FROM dbo.MyTable 

-- This Select will run forever without any result because it is trying to access 
--     the row which is locked by the above delete statement.
SELECT * FROM dbo.MyTable

-- To Find locks on a table


-- Create a lock on a table
BEGIN TRANSACTION
DELETE TOP (1) FROM dbo.MyTable 

-- This Select will run forever without any result because it is trying to access 
--     the row which is locked by the above delete statement.
SELECT * FROM dbo.MyTable

-- To Find locks on a table


-- Create a lock on a table
BEGIN TRANSACTION
DELETE TOP (1) FROM dbo.MyTable 

-- This Select will run forever without any result because it is trying to access 
--     the row which is locked by the above delete statement.
SELECT * FROM dbo.MyTable

-- To Find locks on a table


-- Create a lock on a table
BEGIN TRANSACTION
DELETE TOP (1) FROM dbo.MyTable 

-- This Select will run forever without any result because it is trying to access 
--     the row which is locked by the above delete statement.
SELECT * FROM dbo.MyTable

-- To Find locks on a table
--    SQL Server keeps all records internally which is available using Dynamic Management Views (DMVs) sys.dm_tran_locks
SELECT
    OBJECT_NAME(P.object_id) AS TableName,
    Resource_type, request_status,  request_session_id	
FROM
    sys.dm_tran_locks dtl
    join sys.partitions P
ON dtl.resource_associated_entity_id = p.hobt_id
WHERE   OBJECT_NAME(P.object_id) = 'Titles' 

-- TableName | Resource_type | request_status | request_session_id
-- ---------------------------------------------------------------
-- Titles    | PAGE          | GRANT          | 51
-- Titles    | PAGE          | GRANT          | 53
-- Titles    | KEY           | GRANT          | 51
-- Titles    | KEY           | GRANT          | 51
-- Titles    | KEY           | WAIT           | 53
--
-- You can see that Session 51 is locking the session 53 and that is why, the query in question with session 53
--     is waiting for session 51 to be completed.

-- To release the lock on a table
KILL 51

-- HOW TO KNOW WHICH QUERY IS BLOCKED BY WHICH SESSION
--    If you want to know more on which query is blocked by which query or how to find locked tables in 
--    SQL Server,, you can find that using sys.dm_exec_sql_text
SELECT blocking_session_id AS BlockingSessionID, session_id AS VictimSessionID,    
[text] AS VictimQuery, wait_time/1000 AS WaitDurationSecond
FROM sys.dm_exec_requests
CROSS APPLY sys.dm_exec_sql_text([sql_handle])
WHERE blocking_session_id > 0 

-- BlockingSessionID | VictimSessionID | VictimQuery | WaitDurationSecond
-- -----------------------------------------------------------------------
-- 51               | 53              | SELECT * FROM dbo.MyTable | 126
