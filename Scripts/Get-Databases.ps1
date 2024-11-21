param (
    [string[]]$ServerInstances = @("localhost"),
    [string]$Database = "master",
    [string]$Username,
    [string]$Password
)

# Load the SQL Server module
Import-Module SqlServer

foreach ($ServerInstance in $ServerInstances) {
    Write-Output "Databases on server: $ServerInstance"
    
    # Create a SQL Server connection string
    if ($PSBoundParameters.ContainsKey('Username') -and $PSBoundParameters.ContainsKey('Password')) {
        $connectionString = "Server=$ServerInstance;Database=$Database;User Id=$Username;Password=$Password;"
    }
    else {
        $connectionString = "Server=$ServerInstance;Database=$Database;Integrated Security=True;"
    }

    # Create a SQL Server connection
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = $connectionString

    try {
        # Open the connection
        $SqlConnection.Open()

        # Create a SQL command
        $SqlCommand = $SqlConnection.CreateCommand()
        $SqlCommand.CommandText = "SELECT name FROM sys.databases"

        # Execute the command and get the results
        $SqlDataReader = $SqlCommand.ExecuteReader()

        # Output the results
        while ($SqlDataReader.Read()) {
            Write-Output $SqlDataReader["name"]
        }
    }
    catch {
        Write-Error "Failed to connect to server: $ServerInstance, Error: $_"
    }
    finally {
        # Close the connection
        $SqlConnection.Close()
    }
}
