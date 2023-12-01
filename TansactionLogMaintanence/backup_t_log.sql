-- Back up the transaction log (full and bulk-logged recovery models)
-- Schedule regular transaction log backups to prevent the transaction log from filling up and to permit recovery of data to a specific point in time.
BACKUP LOG
  { database_name | @database_name_var }
  TO <backup_device> [ ,...n ]
  [ <MIRROR TO clause> ] [ next-mirror-to ]
  [ WITH { <general_WITH_options> | <log_specific_options> } [ ,...n ] ]
[;]
GO