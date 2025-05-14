param (
    [string[]]$ServerInstances = @("localhost")
)

# Load the SQL Server module
Import-Module SqlServer

foreach ($ServerInstance in $ServerInstances) {
    Write-Output "Instances on server: $ServerInstance"
    # Get the list of SQL Server instances on the specified server
    $instances = Get-ChildItem -Path "SQLSERVER:\SQL\$ServerInstance"

    # Output the instance names
    foreach ($instance in $instances) {
        Write-Output $instance.Name
    }
}
