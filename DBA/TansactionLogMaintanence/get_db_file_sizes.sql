DECLARE @command varchar(1000) 
SELECT @command = 'USE ? SELECT file_id, type_desc, name, physical_name, \
                       DB_ID(''?'') AS db_id, \
                       CAST(FILEPROPERTY(name, ''SpaceUsed'') AS decimal(19,4)) * 8 / 1024. AS space_used_mb, \
                       CAST(size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128.0 AS decimal(19,4)) AS space_unused_mb, \
                       CAST(size AS decimal(19,4)) * 8 / 1024. AS space_allocated_mb, \
                       CAST(max_size AS decimal(19,4)) * 8 / 1024. AS max_size_mb \
				   FROM sys.database_files '

EXEC sp_MSforeachdb @command 