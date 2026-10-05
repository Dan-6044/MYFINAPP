using System.Data;
using Microsoft.Data.SqlClient;
using MYFIN.API.Data;
using MYFIN.API.DTOs.Masters;

namespace MYFIN.API.Services;

public class TransactionTypeRuleService :
    ITransactionTypeRuleService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public TransactionTypeRuleService(
        SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<TransactionTypeRuleResponse>>
        GetTransactionTypeRulesAsync(
            int? transactionTypeId = null,
            string? entrySide = null)
    {
        if (transactionTypeId.HasValue &&
            transactionTypeId.Value <= 0)
        {
            throw new ArgumentException(
                "Transaction type ID must be greater than zero.",
                nameof(transactionTypeId));
        }

        if (!string.IsNullOrWhiteSpace(entrySide))
        {
            entrySide = entrySide.Trim().ToUpperInvariant();

            if (entrySide is not ("D" or "C"))
            {
                throw new ArgumentException(
                    "EntrySide must be D or C.",
                    nameof(entrySide));
            }
        }

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        const string sql = """
            SELECT
                ttr.TransactionTypeRuleID,
                ttr.TransactionTypeID,
                tt.TransactionTypeCode,
                tt.TransactionTypeName,
                tt.IsSystem AS TransactionTypeIsSystem,
                tt.IsActive AS TransactionTypeIsActive,

                ttr.EntrySide,

                ttr.MainHeadID,
                mh.MainHeadCode,
                mh.MainHeadName,
                mh.AccountingType,
                mh.NormalBalance,

                ttr.SequenceNo,
                ttr.IsRequired,
                ttr.CreatedAt

            FROM GS.TransactionTypeRules ttr

            INNER JOIN GS.TransactionTypes tt
                ON tt.TransactionTypeID = ttr.TransactionTypeID

            INNER JOIN GS.MainHeads mh
                ON mh.MainHeadID = ttr.MainHeadID

            WHERE
                (
                    @TransactionTypeID IS NULL
                    OR ttr.TransactionTypeID = @TransactionTypeID
                )
                AND
                (
                    @EntrySide IS NULL
                    OR ttr.EntrySide = @EntrySide
                )

            ORDER BY
                tt.TransactionTypeCode,
                ttr.EntrySide,
                ttr.SequenceNo,
                ttr.TransactionTypeRuleID;
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@TransactionTypeID", SqlDbType.Int)
            {
                Value = transactionTypeId.HasValue
                    ? transactionTypeId.Value
                    : DBNull.Value
            });

        command.Parameters.Add(
            new SqlParameter("@EntrySide", SqlDbType.Char, 1)
            {
                Value = string.IsNullOrWhiteSpace(entrySide)
                    ? DBNull.Value
                    : entrySide
            });

        var results =
            new List<TransactionTypeRuleResponse>();

        await using var reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            results.Add(
                MapTransactionTypeRule(reader));
        }

        return results;
    }

    public async Task<TransactionTypeRuleResponse?>
        GetTransactionTypeRuleAsync(
            int transactionTypeRuleId)
    {
        if (transactionTypeRuleId <= 0)
        {
            throw new ArgumentException(
                "Transaction type rule ID must be greater than zero.",
                nameof(transactionTypeRuleId));
        }

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        const string sql = """
            SELECT
                ttr.TransactionTypeRuleID,
                ttr.TransactionTypeID,
                tt.TransactionTypeCode,
                tt.TransactionTypeName,
                tt.IsSystem AS TransactionTypeIsSystem,
                tt.IsActive AS TransactionTypeIsActive,

                ttr.EntrySide,

                ttr.MainHeadID,
                mh.MainHeadCode,
                mh.MainHeadName,
                mh.AccountingType,
                mh.NormalBalance,

                ttr.SequenceNo,
                ttr.IsRequired,
                ttr.CreatedAt

            FROM GS.TransactionTypeRules ttr

            INNER JOIN GS.TransactionTypes tt
                ON tt.TransactionTypeID = ttr.TransactionTypeID

            INNER JOIN GS.MainHeads mh
                ON mh.MainHeadID = ttr.MainHeadID

            WHERE
                ttr.TransactionTypeRuleID =
                    @TransactionTypeRuleID;
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter(
                "@TransactionTypeRuleID",
                SqlDbType.Int)
            {
                Value = transactionTypeRuleId
            });

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        return MapTransactionTypeRule(reader);
    }

    public async Task<TransactionTypeRuleResponse>
        CreateTransactionTypeRuleAsync(
            CreateTransactionTypeRuleRequest request)
    {
        if (request is null)
        {
            throw new ArgumentException(
                "Request cannot be null.");
        }

        ValidateTransactionTypeRuleRequest(
            request.EntrySide,
            request.SequenceNo);

        var entrySide =
            request.EntrySide.Trim().ToUpperInvariant();

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        /*
         * Validate the parent transaction type.
         *
         * This also protects system transaction types.
         */
        await EnsureTransactionTypeIsActiveAsync(
            connection,
            request.TransactionTypeID);

        /*
         * Validate the Main Head.
         */
        await EnsureMainHeadIsActiveAsync(
            connection,
            request.MainHeadID);

        /*
         * Validate the actual database uniqueness rule:
         *
         * TransactionTypeID + EntrySide + SequenceNo
         */
        await EnsureTransactionTypeRuleIsAvailableAsync(
            connection,
            request.TransactionTypeID,
            entrySide,
            request.SequenceNo,
            null);

        const string sql = """
            INSERT INTO GS.TransactionTypeRules
            (
                TransactionTypeID,
                EntrySide,
                MainHeadID,
                SequenceNo,
                IsRequired,
                CreatedAt
            )
            OUTPUT INSERTED.TransactionTypeRuleID

            VALUES
            (
                @TransactionTypeID,
                @EntrySide,
                @MainHeadID,
                @SequenceNo,
                @IsRequired,
                SYSDATETIME()
            );
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter(
                "@TransactionTypeID",
                SqlDbType.Int)
            {
                Value = request.TransactionTypeID
            });

        command.Parameters.Add(
            new SqlParameter(
                "@EntrySide",
                SqlDbType.Char,
                1)
            {
                Value = entrySide
            });

        command.Parameters.Add(
            new SqlParameter(
                "@MainHeadID",
                SqlDbType.Int)
            {
                Value = request.MainHeadID
            });

        command.Parameters.Add(
            new SqlParameter(
                "@SequenceNo",
                SqlDbType.Int)
            {
                Value = request.SequenceNo
            });

        command.Parameters.Add(
            new SqlParameter(
                "@IsRequired",
                SqlDbType.Bit)
            {
                Value = request.IsRequired
            });

        var result =
            await command.ExecuteScalarAsync();

        var transactionTypeRuleId =
            Convert.ToInt32(result);

        var created =
            await GetTransactionTypeRuleAsync(
                transactionTypeRuleId);

        if (created is null)
        {
            throw new InvalidOperationException(
                "Transaction type rule was created but could not be retrieved.");
        }

        return created;
    }

    public async Task<TransactionTypeRuleResponse>
        UpdateTransactionTypeRuleAsync(
            int transactionTypeRuleId,
            UpdateTransactionTypeRuleRequest request)
    {
        if (transactionTypeRuleId <= 0)
        {
            throw new ArgumentException(
                "Transaction type rule ID must be greater than zero.",
                nameof(transactionTypeRuleId));
        }

        if (request is null)
        {
            throw new ArgumentException(
                "Request cannot be null.");
        }

        ValidateTransactionTypeRuleRequest(
            request.EntrySide,
            request.SequenceNo);

        var entrySide =
            request.EntrySide.Trim().ToUpperInvariant();

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        /*
         * First retrieve the existing rule.
         *
         * IMPORTANT:
         * We finish reading the DataReader before
         * executing another command on this connection.
         */
        int transactionTypeId;

        const string existingSql = """
            SELECT
                TransactionTypeRuleID,
                TransactionTypeID

            FROM GS.TransactionTypeRules

            WHERE
                TransactionTypeRuleID =
                    @TransactionTypeRuleID;
            """;

        await using (
            var existingCommand =
                new SqlCommand(
                    existingSql,
                    connection))
        {
            existingCommand.Parameters.Add(
                new SqlParameter(
                    "@TransactionTypeRuleID",
                    SqlDbType.Int)
                {
                    Value = transactionTypeRuleId
                });

            await using var reader =
                await existingCommand.ExecuteReaderAsync();

            if (!await reader.ReadAsync())
            {
                throw new KeyNotFoundException(
                    $"Transaction type rule {transactionTypeRuleId} was not found.");
            }

            transactionTypeId =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "TransactionTypeID"));
        }

        /*
         * Validate the parent transaction type.
         *
         * This protects system transaction types
         * from being modified.
         */
        await EnsureTransactionTypeIsActiveAsync(
            connection,
            transactionTypeId);

        /*
         * Validate the Main Head.
         */
        await EnsureMainHeadIsActiveAsync(
            connection,
            request.MainHeadID);

        /*
         * Validate the actual unique constraint:
         *
         * TransactionTypeID + EntrySide + SequenceNo
         */
        await EnsureTransactionTypeRuleIsAvailableAsync(
            connection,
            transactionTypeId,
            entrySide,
            request.SequenceNo,
            transactionTypeRuleId);

        const string updateSql = """
            UPDATE GS.TransactionTypeRules

            SET
                EntrySide = @EntrySide,
                MainHeadID = @MainHeadID,
                SequenceNo = @SequenceNo,
                IsRequired = @IsRequired

            WHERE
                TransactionTypeRuleID =
                    @TransactionTypeRuleID;
            """;

        await using var command =
            new SqlCommand(
                updateSql,
                connection);

        command.Parameters.Add(
            new SqlParameter(
                "@EntrySide",
                SqlDbType.Char,
                1)
            {
                Value = entrySide
            });

        command.Parameters.Add(
            new SqlParameter(
                "@MainHeadID",
                SqlDbType.Int)
            {
                Value = request.MainHeadID
            });

        command.Parameters.Add(
            new SqlParameter(
                "@SequenceNo",
                SqlDbType.Int)
            {
                Value = request.SequenceNo
            });

        command.Parameters.Add(
            new SqlParameter(
                "@IsRequired",
                SqlDbType.Bit)
            {
                Value = request.IsRequired
            });

        command.Parameters.Add(
            new SqlParameter(
                "@TransactionTypeRuleID",
                SqlDbType.Int)
            {
                Value = transactionTypeRuleId
            });

        var rowsAffected =
            await command.ExecuteNonQueryAsync();

        if (rowsAffected == 0)
        {
            throw new KeyNotFoundException(
                $"Transaction type rule {transactionTypeRuleId} was not found.");
        }

        var updated =
            await GetTransactionTypeRuleAsync(
                transactionTypeRuleId);

        if (updated is null)
        {
            throw new InvalidOperationException(
                "Transaction type rule was updated but could not be retrieved.");
        }

        return updated;
    }

    private static void ValidateTransactionTypeRuleRequest(
        string entrySide,
        int sequenceNo)
    {
        if (string.IsNullOrWhiteSpace(entrySide))
        {
            throw new ArgumentException(
                "EntrySide is required.");
        }

        var normalizedEntrySide =
            entrySide.Trim().ToUpperInvariant();

        if (normalizedEntrySide is not ("D" or "C"))
        {
            throw new ArgumentException(
                "EntrySide must be D or C.");
        }

        if (sequenceNo <= 0)
        {
            throw new ArgumentException(
                "SequenceNo must be greater than zero.");
        }
    }

    private static async Task EnsureTransactionTypeIsActiveAsync(
        SqlConnection connection,
        int transactionTypeId)
    {
        if (transactionTypeId <= 0)
        {
            throw new ArgumentException(
                "Transaction type ID must be greater than zero.");
        }

        const string sql = """
            SELECT
                IsActive,
                IsSystem

            FROM GS.TransactionTypes

            WHERE
                TransactionTypeID =
                    @TransactionTypeID;
            """;

        await using var command =
            new SqlCommand(
                sql,
                connection);

        command.Parameters.Add(
            new SqlParameter(
                "@TransactionTypeID",
                SqlDbType.Int)
            {
                Value = transactionTypeId
            });

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            throw new KeyNotFoundException(
                $"Transaction type {transactionTypeId} was not found.");
        }

        var isActive =
            reader.GetBoolean(
                reader.GetOrdinal(
                    "IsActive"));

        var isSystem =
            reader.GetBoolean(
                reader.GetOrdinal(
                    "IsSystem"));

        if (!isActive)
        {
            throw new InvalidOperationException(
                "Transaction type rules cannot be created or modified under an inactive transaction type.");
        }

        if (isSystem)
        {
            throw new InvalidOperationException(
                "Transaction type rules for system transaction types cannot be created or modified through this API.");
        }
    }

    private static async Task EnsureMainHeadIsActiveAsync(
        SqlConnection connection,
        int mainHeadId)
    {
        if (mainHeadId <= 0)
        {
            throw new ArgumentException(
                "Main head ID must be greater than zero.");
        }

        const string sql = """
            SELECT
                IsActive

            FROM GS.MainHeads

            WHERE
                MainHeadID =
                    @MainHeadID;
            """;

        await using var command =
            new SqlCommand(
                sql,
                connection);

        command.Parameters.Add(
            new SqlParameter(
                "@MainHeadID",
                SqlDbType.Int)
            {
                Value = mainHeadId
            });

        var result =
            await command.ExecuteScalarAsync();

        if (result is null)
        {
            throw new KeyNotFoundException(
                $"Main head {mainHeadId} was not found.");
        }

        var isActive =
            Convert.ToBoolean(result);

        if (!isActive)
        {
            throw new InvalidOperationException(
                "Transaction type rules cannot reference an inactive main head.");
        }
    }

    private static async Task EnsureTransactionTypeRuleIsAvailableAsync(
        SqlConnection connection,
        int transactionTypeId,
        string entrySide,
        int sequenceNo,
        int? excludingTransactionTypeRuleId)
    {
        const string sql = """
            SELECT TOP (1)
                TransactionTypeRuleID

            FROM GS.TransactionTypeRules

            WHERE
                TransactionTypeID = @TransactionTypeID

                AND EntrySide = @EntrySide

                AND SequenceNo = @SequenceNo

                AND
                (
                    @ExcludingTransactionTypeRuleID IS NULL
                    OR TransactionTypeRuleID <>
                        @ExcludingTransactionTypeRuleID
                );
            """;

        await using var command =
            new SqlCommand(
                sql,
                connection);

        command.Parameters.Add(
            new SqlParameter(
                "@TransactionTypeID",
                SqlDbType.Int)
            {
                Value = transactionTypeId
            });

        command.Parameters.Add(
            new SqlParameter(
                "@EntrySide",
                SqlDbType.Char,
                1)
            {
                Value = entrySide
            });

        command.Parameters.Add(
            new SqlParameter(
                "@SequenceNo",
                SqlDbType.Int)
            {
                Value = sequenceNo
            });

        command.Parameters.Add(
            new SqlParameter(
                "@ExcludingTransactionTypeRuleID",
                SqlDbType.Int)
            {
                Value = excludingTransactionTypeRuleId.HasValue
                    ? excludingTransactionTypeRuleId.Value
                    : DBNull.Value
            });

        var result =
            await command.ExecuteScalarAsync();

        if (result != null)
        {
            throw new InvalidOperationException(
                "This transaction type already has a rule for the specified entry side and sequence number.");
        }
    }

    private static TransactionTypeRuleResponse
        MapTransactionTypeRule(
            SqlDataReader reader)
    {
        return new TransactionTypeRuleResponse
        {
            TransactionTypeRuleID =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "TransactionTypeRuleID")),

            TransactionTypeID =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "TransactionTypeID")),

            TransactionTypeCode =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "TransactionTypeCode")),

            TransactionTypeName =
                reader.GetString(
                    reader.GetOrdinal(
                        "TransactionTypeName")),

            TransactionTypeIsSystem =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "TransactionTypeIsSystem")),

            TransactionTypeIsActive =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "TransactionTypeIsActive")),

            EntrySide =
                reader.GetString(
                    reader.GetOrdinal(
                        "EntrySide"))
                    .Trim(),

            MainHeadID =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "MainHeadID")),

            MainHeadCode =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "MainHeadCode")),

            MainHeadName =
                reader.GetString(
                    reader.GetOrdinal(
                        "MainHeadName")),

            AccountingType =
                reader.GetString(
                    reader.GetOrdinal(
                        "AccountingType")),

            NormalBalance =
                reader.GetString(
                    reader.GetOrdinal(
                        "NormalBalance")),

            SequenceNo =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "SequenceNo")),

            IsRequired =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "IsRequired")),

            CreatedAt =
                reader.GetDateTime(
                    reader.GetOrdinal(
                        "CreatedAt"))
        };
    }
}