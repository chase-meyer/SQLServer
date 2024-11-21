param (
    [string]$ServerInstance = "localhost",
    [string]$Database = "master",
    [string]$Username,
    [string]$Password
)

# Load the SQL Server module
Import-Module SqlServer

# Create a SQL Server connection
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server=$ServerInstance;Database=$Database;User Id=$Username;Password=$Password;"

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

# Close the connection
$SqlConnection.Close()
