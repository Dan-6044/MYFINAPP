using Microsoft.Data.SqlClient;

namespace MYFIN.API.Data;

public class SqlConnectionFactory
{
    private readonly IConfiguration _configuration;

    public SqlConnectionFactory(
        IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public SqlConnection CreateConnection()
    {
        var connectionString =
            _configuration.GetConnectionString("MYFIN");

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                "MYFIN database connection string is not configured.");
        }

        return new SqlConnection(connectionString);
    }
}