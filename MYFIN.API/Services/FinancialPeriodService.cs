using Microsoft.Data.SqlClient;
using MYFIN.API.Data;
using MYFIN.API.DTOs.FinancialPeriods;
using System.Security.Claims;

namespace MYFIN.API.Services;

public class FinancialPeriodService : IFinancialPeriodService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public FinancialPeriodService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<FinancialPeriodResponse>> GetFinancialPeriodsAsync(
        int? userId = null)
    {
        const string sql = """
            SELECT
                FinancialPeriodID,
                PeriodCode,
                PeriodName,
                StartDate,
                EndDate,
                Status,
                CreatedAt,
                ClosedAt,
                UserID,
                IsCurrent,
                OpenedAt,
                ClosedBy,
                UpdatedAt
            FROM FIN.FinancialPeriods
            WHERE (@UserID IS NULL OR UserID = @UserID)
            ORDER BY StartDate DESC, FinancialPeriodID DESC;
            """;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        await using var command = new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@UserID", System.Data.SqlDbType.Int)
            {
                Value = userId.HasValue
                    ? userId.Value
                    : DBNull.Value
            });

        var results = new List<FinancialPeriodResponse>();

        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            results.Add(MapFinancialPeriod(reader));
        }

        return results;
    }

    public async Task<FinancialPeriodResponse?> GetFinancialPeriodAsync(
        int financialPeriodId)
    {
        const string sql = """
            SELECT
                FinancialPeriodID,
                PeriodCode,
                PeriodName,
                StartDate,
                EndDate,
                Status,
                CreatedAt,
                ClosedAt,
                UserID,
                IsCurrent,
                OpenedAt,
                ClosedBy,
                UpdatedAt
            FROM FIN.FinancialPeriods
            WHERE FinancialPeriodID = @FinancialPeriodID;
            """;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        await using var command = new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@FinancialPeriodID", System.Data.SqlDbType.Int)
            {
                Value = financialPeriodId
            });

        await using var reader = await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        return MapFinancialPeriod(reader);
    }

    public async Task<FinancialPeriodResponse?> GetCurrentFinancialPeriodAsync(
        int userId)
    {
        const string sql = """
            SELECT
                FinancialPeriodID,
                PeriodCode,
                PeriodName,
                StartDate,
                EndDate,
                Status,
                CreatedAt,
                ClosedAt,
                UserID,
                IsCurrent,
                OpenedAt,
                ClosedBy,
                UpdatedAt
            FROM FIN.FinancialPeriods
            WHERE UserID = @UserID
              AND IsCurrent = 1;
            """;

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        await using var command = new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@UserID", System.Data.SqlDbType.Int)
            {
                Value = userId
            });

        await using var reader = await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        return MapFinancialPeriod(reader);
    }

    public async Task<FinancialPeriodResponse> CreateFinancialPeriodAsync(
        CreateFinancialPeriodRequest request)
    {
        var periodCode = request.PeriodCode.Trim();
        var periodName = request.PeriodName.Trim();

        if (string.IsNullOrWhiteSpace(periodCode))
        {
            throw new ArgumentException(
                "PeriodCode is required.",
                nameof(request));
        }

        if (string.IsNullOrWhiteSpace(periodName))
        {
            throw new ArgumentException(
                "PeriodName is required.",
                nameof(request));
        }

        var startDate = request.StartDate.Date;
        var endDate = request.EndDate.Date;

        if (endDate < startDate)
        {
            throw new ArgumentException(
                "EndDate must be greater than or equal to StartDate.",
                nameof(request));
        }

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        await using var transaction =
            (SqlTransaction)await connection.BeginTransactionAsync();

        try
        {
            /*
             * ========================================================
             * VERIFY USER
             * ========================================================
             * The user must exist and be active before the financial
             * period can be created.
             */
            const string userSql = """
                SELECT COUNT(1)
                FROM GS.Users
                WHERE UserID = @UserID
                  AND Status = 'A';
                """;

            await using (var userCommand =
                new SqlCommand(userSql, connection, transaction))
            {
                userCommand.Parameters.Add(
                    new SqlParameter("@UserID", System.Data.SqlDbType.Int)
                    {
                        Value = request.UserID
                    });

                var userExists =
                    Convert.ToInt32(
                        await userCommand.ExecuteScalarAsync());

                if (userExists == 0)
                {
                    throw new InvalidOperationException(
                        "User does not exist or is inactive.");
                }
            }

            /*
             * ========================================================
             * PREVENT OVERLAPPING FINANCIAL PERIODS
             * ========================================================
             * A user cannot have two financial periods whose date
             * ranges overlap.
             */
            const string overlapSql = """
                SELECT COUNT(1)
                FROM FIN.FinancialPeriods WITH (UPDLOCK, HOLDLOCK)
                WHERE UserID = @UserID
                  AND @StartDate <= EndDate
                  AND @EndDate >= StartDate;
                """;

            await using (var overlapCommand =
                new SqlCommand(overlapSql, connection, transaction))
            {
                overlapCommand.Parameters.Add(
                    new SqlParameter("@UserID", System.Data.SqlDbType.Int)
                    {
                        Value = request.UserID
                    });

                overlapCommand.Parameters.Add(
                    new SqlParameter(
                        "@StartDate",
                        System.Data.SqlDbType.Date)
                    {
                        Value = startDate
                    });

                overlapCommand.Parameters.Add(
                    new SqlParameter(
                        "@EndDate",
                        System.Data.SqlDbType.Date)
                    {
                        Value = endDate
                    });

                var overlapCount =
                    Convert.ToInt32(
                        await overlapCommand.ExecuteScalarAsync());

                if (overlapCount > 0)
                {
                    throw new InvalidOperationException(
                        "The financial period dates overlap an existing period for this user.");
                }
            }

            /*
             * ========================================================
             * SET NEW PERIOD AS CURRENT
             * ========================================================
             * If the new period is marked as current, the existing
             * current period for this user is first cleared.
             *
             * The database filtered unique index:
             *
             * UX_FIN_FinancialPeriods_Current
             *
             * guarantees that only one current period can exist
             * for a user.
             */
            if (request.IsCurrent)
            {
                const string clearCurrentSql = """
                    UPDATE FIN.FinancialPeriods
                    SET
                        IsCurrent = 0,
                        UpdatedAt = SYSDATETIME()
                    WHERE UserID = @UserID
                      AND IsCurrent = 1;
                    """;

                await using var clearCurrentCommand =
                    new SqlCommand(
                        clearCurrentSql,
                        connection,
                        transaction);

                clearCurrentCommand.Parameters.Add(
                    new SqlParameter("@UserID", System.Data.SqlDbType.Int)
                    {
                        Value = request.UserID
                    });

                await clearCurrentCommand.ExecuteNonQueryAsync();
            }

            /*
             * ========================================================
             * INSERT FINANCIAL PERIOD
             * ========================================================
             */
            const string insertSql = """
                INSERT INTO FIN.FinancialPeriods
                (
                    PeriodCode,
                    PeriodName,
                    StartDate,
                    EndDate,
                    UserID,
                    IsCurrent
                )
                OUTPUT
                    INSERTED.FinancialPeriodID,
                    INSERTED.PeriodCode,
                    INSERTED.PeriodName,
                    INSERTED.StartDate,
                    INSERTED.EndDate,
                    INSERTED.Status,
                    INSERTED.CreatedAt,
                    INSERTED.ClosedAt,
                    INSERTED.UserID,
                    INSERTED.IsCurrent,
                    INSERTED.OpenedAt,
                    INSERTED.ClosedBy,
                    INSERTED.UpdatedAt
                VALUES
                (
                    @PeriodCode,
                    @PeriodName,
                    @StartDate,
                    @EndDate,
                    @UserID,
                    @IsCurrent
                );
                """;

            await using var insertCommand =
                new SqlCommand(
                    insertSql,
                    connection,
                    transaction);

            insertCommand.Parameters.Add(
                new SqlParameter(
                    "@PeriodCode",
                    System.Data.SqlDbType.VarChar,
                    20)
                {
                    Value = periodCode
                });

            insertCommand.Parameters.Add(
                new SqlParameter(
                    "@PeriodName",
                    System.Data.SqlDbType.VarChar,
                    100)
                {
                    Value = periodName
                });

            insertCommand.Parameters.Add(
                new SqlParameter(
                    "@StartDate",
                    System.Data.SqlDbType.Date)
                {
                    Value = startDate
                });

            insertCommand.Parameters.Add(
                new SqlParameter(
                    "@EndDate",
                    System.Data.SqlDbType.Date)
                {
                    Value = endDate
                });

            insertCommand.Parameters.Add(
                new SqlParameter(
                    "@UserID",
                    System.Data.SqlDbType.Int)
                {
                    Value = request.UserID
                });

            insertCommand.Parameters.Add(
                new SqlParameter(
                    "@IsCurrent",
                    System.Data.SqlDbType.Bit)
                {
                    Value = request.IsCurrent
                });

            /*
             * IMPORTANT:
             *
             * Keep the DataReader inside its own scope.
             * This guarantees that the reader is disposed before
             * the transaction is committed.
             */
            FinancialPeriodResponse result;

            await using (var reader =
                await insertCommand.ExecuteReaderAsync())
            {
                if (!await reader.ReadAsync())
                {
                    throw new InvalidOperationException(
                        "Financial period could not be created.");
                }

                result = MapFinancialPeriod(reader);
            }

            /*
             * The DataReader is now closed/disposed.
             * It is therefore safe to commit the transaction.
             */
            await transaction.CommitAsync();

            return result;
        }
        catch
        {
            if (transaction.Connection != null)
            {
                await transaction.RollbackAsync();
            }

            throw;
        }
    }

    public async Task<FinancialPeriodResponse> UpdateFinancialPeriodAsync(
        int financialPeriodId,
        UpdateFinancialPeriodRequest request)
    {
        var periodCode = request.PeriodCode.Trim();
        var periodName = request.PeriodName.Trim();

        if (string.IsNullOrWhiteSpace(periodCode))
        {
            throw new ArgumentException(
                "PeriodCode is required.",
                nameof(request));
        }

        if (string.IsNullOrWhiteSpace(periodName))
        {
            throw new ArgumentException(
                "PeriodName is required.",
                nameof(request));
        }

        var startDate = request.StartDate.Date;
        var endDate = request.EndDate.Date;

        if (endDate < startDate)
        {
            throw new ArgumentException(
                "EndDate must be greater than or equal to StartDate.",
                nameof(request));
        }

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        await using var transaction =
            (SqlTransaction)await connection.BeginTransactionAsync();

        try
        {
            const string sql = """
                UPDATE FIN.FinancialPeriods
                SET
                    PeriodCode = @PeriodCode,
                    PeriodName = @PeriodName,
                    StartDate = @StartDate,
                    EndDate = @EndDate,
                    UpdatedAt = SYSDATETIME()
                OUTPUT
                    INSERTED.FinancialPeriodID,
                    INSERTED.PeriodCode,
                    INSERTED.PeriodName,
                    INSERTED.StartDate,
                    INSERTED.EndDate,
                    INSERTED.Status,
                    INSERTED.CreatedAt,
                    INSERTED.ClosedAt,
                    INSERTED.UserID,
                    INSERTED.IsCurrent,
                    INSERTED.OpenedAt,
                    INSERTED.ClosedBy,
                    INSERTED.UpdatedAt
                WHERE FinancialPeriodID = @FinancialPeriodID;
                """;

            await using var command =
                new SqlCommand(sql, connection, transaction);

            command.Parameters.Add(
                new SqlParameter("@FinancialPeriodID", System.Data.SqlDbType.Int)
                {
                    Value = financialPeriodId
                });

            command.Parameters.Add(
                new SqlParameter("@PeriodCode", System.Data.SqlDbType.VarChar, 20)
                {
                    Value = periodCode
                });

            command.Parameters.Add(
                new SqlParameter("@PeriodName", System.Data.SqlDbType.VarChar, 100)
                {
                    Value = periodName
                });

            command.Parameters.Add(
                new SqlParameter("@StartDate", System.Data.SqlDbType.Date)
                {
                    Value = startDate
                });

            command.Parameters.Add(
                new SqlParameter("@EndDate", System.Data.SqlDbType.Date)
                {
                    Value = endDate
                });

            FinancialPeriodResponse result;

            await using (var reader =
                await command.ExecuteReaderAsync())
            {
                if (!await reader.ReadAsync())
                {
                    throw new InvalidOperationException(
                        "Financial period could not be updated.");
                }

                result = MapFinancialPeriod(reader);
            }

            await transaction.CommitAsync();

            return result;
        }
        catch
        {
            if (transaction.Connection != null)
            {
                await transaction.RollbackAsync();
            }

            throw;
        }
    }

    public async Task<FinancialPeriodResponse> CloseFinancialPeriodAsync(
        int financialPeriodId,
        int closedByUserId)
    {
        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        await using var command = new SqlCommand(
            "FIN.usp_CloseFinancialPeriod",
            connection);

        command.CommandType =
            System.Data.CommandType.StoredProcedure;

        command.Parameters.Add(
            new SqlParameter(
                "@FinancialPeriodID",
                System.Data.SqlDbType.Int)
            {
                Value = financialPeriodId
            });

        command.Parameters.Add(
            new SqlParameter(
                "@ClosedByUserID",
                System.Data.SqlDbType.Int)
            {
                Value = closedByUserId
            });

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            throw new InvalidOperationException(
                "Financial period could not be closed.");
        }

        return new FinancialPeriodResponse
        {
            FinancialPeriodID =
                reader.GetInt32(
                    reader.GetOrdinal("FinancialPeriodID")),

            PeriodCode =
                reader.GetString(
                    reader.GetOrdinal("PeriodCode")),

            PeriodName =
                reader.GetString(
                    reader.GetOrdinal("PeriodName")),

            Status =
                reader.GetString(
                    reader.GetOrdinal("Status")),

            IsCurrent =
                reader.GetBoolean(
                    reader.GetOrdinal("IsCurrent")),

            ClosedAt =
                reader.IsDBNull(
                    reader.GetOrdinal("ClosedAt"))
                    ? null
                    : reader.GetDateTime(
                        reader.GetOrdinal("ClosedAt")),

            ClosedBy =
                reader.IsDBNull(
                    reader.GetOrdinal("ClosedBy"))
                    ? null
                    : reader.GetInt32(
                        reader.GetOrdinal("ClosedBy"))
        };
    }

    private static FinancialPeriodResponse MapFinancialPeriod(
        SqlDataReader reader)
    {
        return new FinancialPeriodResponse
        {
            FinancialPeriodID =
                reader.GetInt32(
                    reader.GetOrdinal("FinancialPeriodID")),

            PeriodCode =
                reader.GetString(
                    reader.GetOrdinal("PeriodCode")),

            PeriodName =
                reader.GetString(
                    reader.GetOrdinal("PeriodName")),

            StartDate =
                reader.GetDateTime(
                    reader.GetOrdinal("StartDate")),

            EndDate =
                reader.GetDateTime(
                    reader.GetOrdinal("EndDate")),

            Status =
                reader.GetString(
                    reader.GetOrdinal("Status")),

            CreatedAt =
                reader.GetDateTime(
                    reader.GetOrdinal("CreatedAt")),

            ClosedAt =
                reader.IsDBNull(
                    reader.GetOrdinal("ClosedAt"))
                    ? null
                    : reader.GetDateTime(
                        reader.GetOrdinal("ClosedAt")),

            UserID =
                reader.GetInt32(
                    reader.GetOrdinal("UserID")),

            IsCurrent =
                reader.GetBoolean(
                    reader.GetOrdinal("IsCurrent")),

            OpenedAt =
                reader.GetDateTime(
                    reader.GetOrdinal("OpenedAt")),

            ClosedBy =
                reader.IsDBNull(
                    reader.GetOrdinal("ClosedBy"))
                    ? null
                    : reader.GetInt32(
                        reader.GetOrdinal("ClosedBy")),

            UpdatedAt =
                reader.IsDBNull(
                    reader.GetOrdinal("UpdatedAt"))
                    ? null
                    : reader.GetDateTime(
                        reader.GetOrdinal("UpdatedAt"))
        };
    }
}