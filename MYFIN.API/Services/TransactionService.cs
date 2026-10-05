using System.Data;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using MYFIN.API.Data;
using MYFIN.API.DTOs.Accounts;
using MYFIN.API.DTOs.Reports;
using MYFIN.API.DTOs.Transactions;

namespace MYFIN.API.Services;

public class TransactionService : ITransactionService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public TransactionService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<CreateTransactionResponse> CreateAsync(
        CreateTransactionRequest request)
    {
        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(
                "FIN.usp_CreateTransaction",
                connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.Add(
            "@TransactionTypeID",
            SqlDbType.Int).Value =
            request.TransactionTypeID;

        command.Parameters.Add(
            "@FinancialPeriodID",
            SqlDbType.Int).Value =
            request.FinancialPeriodID;

        command.Parameters.Add(
            "@TransactionDate",
            SqlDbType.Date).Value =
            request.TransactionDate.Date;

        command.Parameters.Add(
            "@Description",
            SqlDbType.VarChar,
            500).Value =
            (object?)request.Description ??
            DBNull.Value;

        command.Parameters.Add(
            "@ReferenceNumber",
            SqlDbType.VarChar,
            100).Value =
            (object?)request.ReferenceNumber ??
            DBNull.Value;

        command.Parameters.Add(
            "@CreatedByUserID",
            SqlDbType.Int).Value =
            request.CreatedByUserID;

        var linesJson =
            JsonSerializer.Serialize(request.Lines);

        command.Parameters.Add(
            "@LinesJson",
            SqlDbType.NVarChar,
            -1).Value =
            linesJson;

        await using var reader =
            await command.ExecuteReaderAsync();

        var response = new CreateTransactionResponse();

        if (await reader.ReadAsync())
        {
            response.TransactionID =
                Convert.ToInt64(reader["TransactionID"]);

            response.TransactionNumber =
                Convert.ToString(reader["TransactionNumber"]) ?? string.Empty;

            response.TransactionTypeID =
                Convert.ToInt32(reader["TransactionTypeID"]);

            response.TransactionTypeCode =
                Convert.ToString(reader["TransactionTypeCode"]) ?? string.Empty;

            response.TransactionTypeName =
                Convert.ToString(reader["TransactionTypeName"]) ?? string.Empty;

            response.FinancialPeriodID =
                Convert.ToInt32(reader["FinancialPeriodID"]);

            response.PeriodCode =
                Convert.ToString(reader["PeriodCode"]) ?? string.Empty;

            response.TransactionDate =
                Convert.ToDateTime(reader["TransactionDate"]);

            response.Description =
                Convert.ToString(reader["Description"]) ?? string.Empty;

            response.ReferenceNumber =
                GetNullableString(reader, "ReferenceNumber");

            response.Status =
                Convert.ToString(reader["Status"]) ?? string.Empty;

            response.CreatedByUserID =
                Convert.ToInt32(reader["CreatedByUserID"]);

            response.CreatedAt =
                Convert.ToDateTime(reader["CreatedAt"]);

            response.UpdatedAt =
                GetNullableDateTime(reader, "UpdatedAt");

            response.PostedAt =
                GetNullableDateTime(reader, "PostedAt");
        }

        if (await reader.NextResultAsync())
        {
            while (await reader.ReadAsync())
            {
                response.Lines.Add(
                    new CreateTransactionLineResponse
                    {
                        TransactionLineID =
                            Convert.ToInt64(reader["TransactionLineID"]),

                        TransactionID =
                            Convert.ToInt64(reader["TransactionID"]),

                        LineSequence =
                            Convert.ToInt32(reader["LineSequence"]),

                        TransactionComponentID =
                            Convert.ToInt32(reader["TransactionComponentID"]),

                        ComponentCode =
                            Convert.ToString(reader["ComponentCode"]) ?? string.Empty,

                        ComponentName =
                            Convert.ToString(reader["ComponentName"]) ?? string.Empty,

                        COAID =
                            Convert.ToInt64(reader["COAID"]),

                        COACode =
                            Convert.ToString(reader["COACode"]) ?? string.Empty,

                        COAName =
                            Convert.ToString(reader["COAName"]) ?? string.Empty,

                        DebitAmount =
                            Convert.ToDecimal(reader["DebitAmount"]),

                        CreditAmount =
                            Convert.ToDecimal(reader["CreditAmount"]),

                        Description =
                            GetNullableString(reader, "Description")
                    });
            }
        }

        return response;
    }

    public async Task<ValidateTransactionResponse> ValidateAsync(
        long transactionId)
    {
        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(
                "FIN.usp_ValidateTransaction",
                connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.Add(
            "@TransactionID",
            SqlDbType.BigInt).Value =
            transactionId;

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            throw new InvalidOperationException(
                "The validation procedure returned no result.");
        }

        return new ValidateTransactionResponse
        {
            TransactionID =
                Convert.ToInt64(reader["TransactionID"]),

            TransactionNumber =
                Convert.ToString(reader["TransactionNumber"]) ?? string.Empty,

            TransactionTypeID =
                Convert.ToInt32(reader["TransactionTypeID"]),

            TransactionTypeCode =
                Convert.ToString(reader["TransactionTypeCode"]) ?? string.Empty,

            TransactionTypeName =
                Convert.ToString(reader["TransactionTypeName"]) ?? string.Empty,

            FinancialPeriodID =
                Convert.ToInt32(reader["FinancialPeriodID"]),

            TransactionDate =
                Convert.ToDateTime(reader["TransactionDate"]),

            Status =
                Convert.ToString(reader["Status"]) ?? string.Empty,

            TotalDebit =
                Convert.ToDecimal(reader["TotalDebit"]),

            TotalCredit =
                Convert.ToDecimal(reader["TotalCredit"]),

            Message =
                Convert.ToString(reader["Message"]) ?? string.Empty
        };
    }

    public async Task<PostTransactionResponse> PostAsync(
        long transactionId,
        int postedByUserId)
    {
        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(
                "FIN.usp_PostTransaction",
                connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.Add(
            "@TransactionID",
            SqlDbType.BigInt).Value =
            transactionId;

        command.Parameters.Add(
            "@PostedByUserID",
            SqlDbType.Int).Value =
            postedByUserId;

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            throw new InvalidOperationException(
                "The posting procedure returned no result.");
        }

        return new PostTransactionResponse
        {
            TransactionID =
                Convert.ToInt64(reader["TransactionID"]),

            TransactionNumber =
                Convert.ToString(reader["TransactionNumber"]) ?? string.Empty,

            TransactionStatus =
                Convert.ToString(reader["TransactionStatus"]) ?? string.Empty,

            JournalID =
                Convert.ToInt64(reader["JournalID"]),

            JournalNumber =
                Convert.ToString(reader["JournalNumber"]) ?? string.Empty,

            JournalStatus =
                Convert.ToString(reader["JournalStatus"]) ?? string.Empty,

            FinancialPeriodID =
                Convert.ToInt32(reader["FinancialPeriodID"]),

            JournalDate =
                Convert.ToDateTime(reader["JournalDate"]),

            PostedAt =
                Convert.ToDateTime(reader["PostedAt"]),

            TotalDebit =
                Convert.ToDecimal(reader["TotalDebit"]),

            TotalCredit =
                Convert.ToDecimal(reader["TotalCredit"]),

            Message =
                Convert.ToString(reader["Message"]) ?? string.Empty
        };
    }

    public async Task<TransactionDetailsResponse> GetDetailsAsync(
        long transactionId)
    {
        if (transactionId <= 0)
        {
            throw new ArgumentException(
                "Transaction ID must be greater than zero.");
        }

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        const string sql = """
            SELECT
                T.TransactionID,
                T.TransactionNumber,
                T.TransactionTypeID,
                TT.TransactionTypeCode,
                TT.TransactionTypeName,
                T.FinancialPeriodID,
                T.TransactionDate,
                T.Description,
                T.ReferenceNumber,
                T.Status,
                T.CreatedByUserID,
                T.CreatedAt,
                T.UpdatedAt,
                T.PostedAt,
                T.PostedByUserID,
                T.VoidedAt,
                T.VoidedByUserID,
                T.VoidReason
            FROM FIN.Transactions AS T
            INNER JOIN GS.TransactionTypes AS TT
                ON TT.TransactionTypeID = T.TransactionTypeID
            WHERE T.TransactionID = @TransactionID;

            SELECT
                TL.TransactionLineID,
                TL.LineSequence,
                TL.TransactionComponentID,
                TC.ComponentCode,
                TC.ComponentName,
                TL.COAID,
                COA.COACode,
                COA.COAName,
                TL.DebitAmount,
                TL.CreditAmount,
                TL.Description
            FROM FIN.TransactionLines AS TL
            INNER JOIN GS.TransactionComponents AS TC
                ON TC.TransactionComponentID =
                   TL.TransactionComponentID
            INNER JOIN GS.ChartOfAccounts AS COA
                ON COA.COAID = TL.COAID
            WHERE TL.TransactionID = @TransactionID
            ORDER BY TL.LineSequence;

            SELECT
                J.JournalID,
                J.JournalNumber,
                J.FinancialPeriodID,
                J.JournalDate,
                J.Description,
                J.Status,
                J.CreatedAt,
                J.PostedAt
            FROM FIN.Journals AS J
            WHERE J.TransactionID = @TransactionID
            ORDER BY J.JournalID;

            SELECT
                JL.JournalLineID,
                JL.LineSequence,
                JL.COAID,
                COA.COACode,
                COA.COAName,
                JL.DebitAmount,
                JL.CreditAmount,
                JL.Description
            FROM FIN.JournalLines AS JL
            INNER JOIN FIN.Journals AS J
                ON J.JournalID = JL.JournalID
            INNER JOIN GS.ChartOfAccounts AS COA
                ON COA.COAID = JL.COAID
            WHERE J.TransactionID = @TransactionID
            ORDER BY
                J.JournalID,
                JL.LineSequence;
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.AddWithValue(
            "@TransactionID",
            transactionId);

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            throw new KeyNotFoundException(
                $"Transaction {transactionId} was not found.");
        }

        var response = new TransactionDetailsResponse
        {
            TransactionID =
                Convert.ToInt64(reader["TransactionID"]),

            TransactionNumber =
                Convert.ToString(reader["TransactionNumber"]) ?? string.Empty,

            TransactionTypeID =
                Convert.ToInt32(reader["TransactionTypeID"]),

            TransactionTypeCode =
                Convert.ToString(reader["TransactionTypeCode"]) ?? string.Empty,

            TransactionTypeName =
                Convert.ToString(reader["TransactionTypeName"]) ?? string.Empty,

            FinancialPeriodID =
                Convert.ToInt32(reader["FinancialPeriodID"]),

            TransactionDate =
                Convert.ToDateTime(reader["TransactionDate"]),

            Description =
                reader["Description"] == DBNull.Value
                    ? null
                    : Convert.ToString(reader["Description"]),

            ReferenceNumber =
                reader["ReferenceNumber"] == DBNull.Value
                    ? null
                    : Convert.ToString(reader["ReferenceNumber"]),

            Status =
                Convert.ToString(reader["Status"]) ?? string.Empty,

            CreatedByUserID =
                Convert.ToInt32(reader["CreatedByUserID"]),

            CreatedAt =
                Convert.ToDateTime(reader["CreatedAt"]),

            UpdatedAt =
                reader["UpdatedAt"] == DBNull.Value
                    ? null
                    : Convert.ToDateTime(reader["UpdatedAt"]),

            PostedAt =
                reader["PostedAt"] == DBNull.Value
                    ? null
                    : Convert.ToDateTime(reader["PostedAt"]),

            PostedByUserID =
                reader["PostedByUserID"] == DBNull.Value
                    ? null
                    : Convert.ToInt32(reader["PostedByUserID"]),

            VoidedAt =
                reader["VoidedAt"] == DBNull.Value
                    ? null
                    : Convert.ToDateTime(reader["VoidedAt"]),

            VoidedByUserID =
                reader["VoidedByUserID"] == DBNull.Value
                    ? null
                    : Convert.ToInt32(reader["VoidedByUserID"]),

            VoidReason =
                reader["VoidReason"] == DBNull.Value
                    ? null
                    : Convert.ToString(reader["VoidReason"])
        };

        await reader.NextResultAsync();

        while (await reader.ReadAsync())
        {
            var debit =
                Convert.ToDecimal(reader["DebitAmount"]);

            var credit =
                Convert.ToDecimal(reader["CreditAmount"]);

            response.TotalDebit += debit;
            response.TotalCredit += credit;

            response.Lines.Add(
                new TransactionDetailLineResponse
                {
                    TransactionLineID =
                        Convert.ToInt64(reader["TransactionLineID"]),

                    LineSequence =
                        Convert.ToInt32(reader["LineSequence"]),

                    TransactionComponentID =
                        Convert.ToInt32(reader["TransactionComponentID"]),

                    ComponentCode =
                        Convert.ToString(reader["ComponentCode"]) ?? string.Empty,

                    ComponentName =
                        Convert.ToString(reader["ComponentName"]) ?? string.Empty,

                    COAID =
                        Convert.ToInt64(reader["COAID"]),

                    COACode =
                        Convert.ToString(reader["COACode"]) ?? string.Empty,

                    COAName =
                        Convert.ToString(reader["COAName"]) ?? string.Empty,

                    DebitAmount = debit,
                    CreditAmount = credit,

                    Description =
                        reader["Description"] == DBNull.Value
                            ? null
                            : Convert.ToString(reader["Description"])
                });
        }

        await reader.NextResultAsync();

        if (await reader.ReadAsync())
        {
            response.Journal =
                new TransactionJournalResponse
                {
                    JournalID =
                        Convert.ToInt64(reader["JournalID"]),

                    JournalNumber =
                        Convert.ToString(reader["JournalNumber"]) ?? string.Empty,

                    FinancialPeriodID =
                        Convert.ToInt32(reader["FinancialPeriodID"]),

                    JournalDate =
                        Convert.ToDateTime(reader["JournalDate"]),

                    Description =
                        reader["Description"] == DBNull.Value
                            ? null
                            : Convert.ToString(reader["Description"]),

                    Status =
                        Convert.ToString(reader["Status"]) ?? string.Empty,

                    CreatedAt =
                        Convert.ToDateTime(reader["CreatedAt"]),

                    PostedAt =
                        reader["PostedAt"] == DBNull.Value
                            ? null
                            : Convert.ToDateTime(reader["PostedAt"])
                };
        }

        await reader.NextResultAsync();

        if (response.Journal != null)
        {
            while (await reader.ReadAsync())
            {
                var debit =
                    Convert.ToDecimal(reader["DebitAmount"]);

                var credit =
                    Convert.ToDecimal(reader["CreditAmount"]);

                response.Journal.TotalDebit += debit;
                response.Journal.TotalCredit += credit;

                response.Journal.Lines.Add(
                    new TransactionJournalLineResponse
                    {
                        JournalLineID =
                            Convert.ToInt64(reader["JournalLineID"]),

                        LineSequence =
                            Convert.ToInt32(reader["LineSequence"]),

                        COAID =
                            Convert.ToInt64(reader["COAID"]),

                        COACode =
                            Convert.ToString(reader["COACode"]) ?? string.Empty,

                        COAName =
                            Convert.ToString(reader["COAName"]) ?? string.Empty,

                        DebitAmount = debit,
                        CreditAmount = credit,

                        Description =
                            reader["Description"] == DBNull.Value
                                ? null
                                : Convert.ToString(reader["Description"])
                    });
            }
        }

        return response;
    }

    private static string? GetNullableString(
        SqlDataReader reader,
        string columnName)
    {
        var value = reader[columnName];

        if (value == DBNull.Value)
        {
            return null;
        }

        return Convert.ToString(value);
    }

    private static DateTime? GetNullableDateTime(
        SqlDataReader reader,
        string columnName)
    {
        var value = reader[columnName];

        if (value == DBNull.Value)
        {
            return null;
        }

        return Convert.ToDateTime(value);
    }

    public async Task<TransactionListResponse> GetListAsync(
        int? financialPeriodId,
        string? status,
        int? transactionTypeId,
        DateTime? startDate,
        DateTime? endDate,
        int page,
        int pageSize)
    {
        if (page < 1)
        {
            page = 1;
        }

        if (pageSize < 1)
        {
            pageSize = 20;
        }

        if (pageSize > 100)
        {
            pageSize = 100;
        }

        if (startDate.HasValue &&
            endDate.HasValue &&
            startDate.Value.Date > endDate.Value.Date)
        {
            throw new ArgumentException(
                "startDate cannot be later than endDate.");
        }

        var offset = (page - 1) * pageSize;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        const string sql = """
            SELECT
                COUNT_BIG(*)
            FROM FIN.Transactions AS T
            WHERE
                (@FinancialPeriodID IS NULL
                    OR T.FinancialPeriodID = @FinancialPeriodID)
                AND
                (@Status IS NULL
                    OR T.Status = @Status)
                AND
                (@TransactionTypeID IS NULL
                    OR T.TransactionTypeID = @TransactionTypeID)
                AND
                (@StartDate IS NULL
                    OR T.TransactionDate >= @StartDate)
                AND
                (@EndDate IS NULL
                    OR T.TransactionDate <= @EndDate);

            SELECT
                T.TransactionID,
                T.TransactionNumber,
                T.TransactionTypeID,
                TT.TransactionTypeCode,
                TT.TransactionTypeName,
                T.FinancialPeriodID,
                T.TransactionDate,
                T.Description,
                T.ReferenceNumber,
                T.Status,
                T.CreatedByUserID,
                T.CreatedAt,
                T.UpdatedAt,
                T.PostedAt,
                T.PostedByUserID,
                T.VoidedAt,
                T.VoidedByUserID,
                T.VoidReason,
                ISNULL(SUM(TL.DebitAmount), 0) AS TotalDebit,
                ISNULL(SUM(TL.CreditAmount), 0) AS TotalCredit
            FROM FIN.Transactions AS T
            INNER JOIN GS.TransactionTypes AS TT
                ON TT.TransactionTypeID = T.TransactionTypeID
            LEFT JOIN FIN.TransactionLines AS TL
                ON TL.TransactionID = T.TransactionID
            WHERE
                (@FinancialPeriodID IS NULL
                    OR T.FinancialPeriodID = @FinancialPeriodID)
                AND
                (@Status IS NULL
                    OR T.Status = @Status)
                AND
                (@TransactionTypeID IS NULL
                    OR T.TransactionTypeID = @TransactionTypeID)
                AND
                (@StartDate IS NULL
                    OR T.TransactionDate >= @StartDate)
                AND
                (@EndDate IS NULL
                    OR T.TransactionDate <= @EndDate)
            GROUP BY
                T.TransactionID,
                T.TransactionNumber,
                T.TransactionTypeID,
                TT.TransactionTypeCode,
                TT.TransactionTypeName,
                T.FinancialPeriodID,
                T.TransactionDate,
                T.Description,
                T.ReferenceNumber,
                T.Status,
                T.CreatedByUserID,
                T.CreatedAt,
                T.UpdatedAt,
                T.PostedAt,
                T.PostedByUserID,
                T.VoidedAt,
                T.VoidedByUserID,
                T.VoidReason
            ORDER BY
                T.TransactionDate DESC,
                T.TransactionID DESC
            OFFSET @Offset ROWS
            FETCH NEXT @PageSize ROWS ONLY;
            """;

        await using var command =
            new Microsoft.Data.SqlClient.SqlCommand(
                sql,
                connection);

        command.Parameters.AddWithValue(
            "@FinancialPeriodID",
            (object?)financialPeriodId ?? DBNull.Value);

        command.Parameters.AddWithValue(
            "@Status",
            (object?)status ?? DBNull.Value);

        command.Parameters.AddWithValue(
            "@TransactionTypeID",
            (object?)transactionTypeId ?? DBNull.Value);

        command.Parameters.AddWithValue(
            "@StartDate",
            (object?)startDate?.Date ?? DBNull.Value);

        command.Parameters.AddWithValue(
            "@EndDate",
            (object?)endDate?.Date ?? DBNull.Value);

        command.Parameters.AddWithValue(
            "@Offset",
            offset);

        command.Parameters.AddWithValue(
            "@PageSize",
            pageSize);

        await using var reader =
            await command.ExecuteReaderAsync();

        var result = new TransactionListResponse
        {
            Page = page,
            PageSize = pageSize
        };

        if (await reader.ReadAsync())
        {
            result.TotalRecords =
                Convert.ToInt32(reader.GetInt64(0));
        }

        var totalPages =
            result.TotalRecords == 0
                ? 0
                : (int)Math.Ceiling(
                    result.TotalRecords /
                    (double)pageSize);

        result.TotalPages = totalPages;

        await reader.NextResultAsync();

        while (await reader.ReadAsync())
        {
            result.Transactions.Add(
                new TransactionListItemResponse
                {
                    TransactionID =
                        Convert.ToInt64(
                            reader["TransactionID"]),

                    TransactionNumber =
                        Convert.ToString(
                            reader["TransactionNumber"])
                        ?? string.Empty,

                    TransactionTypeID =
                        Convert.ToInt32(
                            reader["TransactionTypeID"]),

                    TransactionTypeCode =
                        Convert.ToString(
                            reader["TransactionTypeCode"])
                        ?? string.Empty,

                    TransactionTypeName =
                        Convert.ToString(
                            reader["TransactionTypeName"])
                        ?? string.Empty,

                    FinancialPeriodID =
                        Convert.ToInt32(
                            reader["FinancialPeriodID"]),

                    TransactionDate =
                        Convert.ToDateTime(
                            reader["TransactionDate"]),

                    Description =
                        reader["Description"] == DBNull.Value
                            ? null
                            : Convert.ToString(
                                reader["Description"]),

                    ReferenceNumber =
                        reader["ReferenceNumber"] == DBNull.Value
                            ? null
                            : Convert.ToString(
                                reader["ReferenceNumber"]),

                    Status =
                        Convert.ToString(
                            reader["Status"])
                        ?? string.Empty,

                    CreatedByUserID =
                        Convert.ToInt32(
                            reader["CreatedByUserID"]),

                    CreatedAt =
                        Convert.ToDateTime(
                            reader["CreatedAt"]),

                    UpdatedAt =
                        reader["UpdatedAt"] == DBNull.Value
                            ? null
                            : Convert.ToDateTime(
                                reader["UpdatedAt"]),

                    PostedAt =
                        reader["PostedAt"] == DBNull.Value
                            ? null
                            : Convert.ToDateTime(
                                reader["PostedAt"]),

                    PostedByUserID =
                        reader["PostedByUserID"] == DBNull.Value
                            ? null
                            : Convert.ToInt32(
                                reader["PostedByUserID"]),

                    VoidedAt =
                        reader["VoidedAt"] == DBNull.Value
                            ? null
                            : Convert.ToDateTime(
                                reader["VoidedAt"]),

                    VoidedByUserID =
                        reader["VoidedByUserID"] == DBNull.Value
                            ? null
                            : Convert.ToInt32(
                                reader["VoidedByUserID"]),

                    VoidReason =
                        reader["VoidReason"] == DBNull.Value
                            ? null
                            : Convert.ToString(
                                reader["VoidReason"]),

                    TotalDebit =
                        Convert.ToDecimal(
                            reader["TotalDebit"]),

                    TotalCredit =
                        Convert.ToDecimal(
                            reader["TotalCredit"])
                });
        }

        return result;
    }
public async Task<AccountStatementResponse?> GetAccountStatementAsync(
    long coaId,
    int? financialPeriodId,
    DateTime? startDate,
    DateTime? endDate)
{
    if (startDate.HasValue && endDate.HasValue &&
        startDate.Value.Date > endDate.Value.Date)
    {
        throw new ArgumentException(
            "startDate cannot be later than endDate.");
    }

    // FinancialPeriodID and explicit date range are mutually exclusive.
    if (financialPeriodId.HasValue &&
        (startDate.HasValue || endDate.HasValue))
    {
        throw new ArgumentException(
            "Use either financialPeriodId or startDate/endDate, not both.");
    }

    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    /*
       ============================================================
       1. Resolve the account and requested date range
       ============================================================
    */

    DateTime? resolvedStartDate = startDate?.Date;
    DateTime? resolvedEndDate = endDate?.Date;

    string? periodCode = null;
    string? periodName = null;

    const string accountSql = """
        SELECT
            COAID,
            COACode,
            COAName,
            SubheadID,
            CurrencyID,
            Description,
            IsControlAccount,
            AllowDirectPosting,
            IsActive,
            OpeningBalance,
            CreatedAt,
            UpdatedAt
        FROM GS.ChartOfAccounts
        WHERE COAID = @COAID;
        """;

        var accountCommand = new SqlCommand(accountSql, connection);

        accountCommand.Parameters.Add("@COAID", SqlDbType.BigInt)
            .Value = coaId;

        using var reader = await accountCommand.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        var account = new AccountStatementResponse
        {
            COAID = Convert.ToInt64(reader["COAID"]),
            COACode = Convert.ToString(reader["COACode"]) ?? string.Empty,
            COAName = Convert.ToString(reader["COAName"]) ?? string.Empty,
            SubheadID = Convert.ToInt32(reader["SubheadID"]),
            CurrencyID = reader["CurrencyID"] == DBNull.Value
                ? null
                : Convert.ToInt32(reader["CurrencyID"]),
            Description = reader["Description"] == DBNull.Value
                ? null
                : Convert.ToString(reader["Description"]),
            IsControlAccount = Convert.ToBoolean(reader["IsControlAccount"]),
            AllowDirectPosting = Convert.ToBoolean(reader["AllowDirectPosting"]),
            IsActive = Convert.ToBoolean(reader["IsActive"]),
            OpeningBalance = Convert.ToDecimal(reader["OpeningBalance"]),
            CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
            UpdatedAt = reader["UpdatedAt"] == DBNull.Value
                ? null
                : Convert.ToDateTime(reader["UpdatedAt"])
        };

        await reader.CloseAsync();

        /*
           ========================================================
           2. Resolve Financial Period if supplied
           ========================================================
        */

        if (financialPeriodId.HasValue)
        {
            const string periodSql = """
                SELECT
                    FinancialPeriodID,
                    PeriodCode,
                    PeriodName,
                    StartDate,
                    EndDate
                FROM FIN.FinancialPeriods
                WHERE FinancialPeriodID = @FinancialPeriodID;
                """;

            using var periodCommand = new SqlCommand(periodSql, connection);

            periodCommand.Parameters.Add("@FinancialPeriodID", SqlDbType.Int)
                .Value = financialPeriodId.Value;

            using var periodReader =
                await periodCommand.ExecuteReaderAsync();

            if (!await periodReader.ReadAsync())
            {
                throw new ArgumentException(
                    $"Financial period {financialPeriodId.Value} was not found.");
            }

            periodCode = Convert.ToString(periodReader["PeriodCode"]);
            periodName = Convert.ToString(periodReader["PeriodName"]);

            resolvedStartDate =
                Convert.ToDateTime(periodReader["StartDate"]).Date;

            resolvedEndDate =
                Convert.ToDateTime(periodReader["EndDate"]).Date;
        }

        /*
           ========================================================
           3. Calculate the correct opening balance
           
           No filter:
               OpeningBalance = COA OpeningBalance

           Date/period filter:
               OpeningBalance =
                   COA OpeningBalance
                   + all posted GL movement before StartDate
           ========================================================
        */

        const string openingSql = """
            SELECT
                c.OpeningBalance
                +
                CASE
                    WHEN @StartDate IS NULL THEN 0
                    ELSE ISNULL(
                        (
                            SELECT SUM(gl.NetMovement)
                            FROM FIN.vw_GeneralLedger gl
                            WHERE gl.COAID = c.COAID
                              AND gl.JournalDate < @StartDate
                        ),
                        0
                    )
                END AS OpeningBalance
            FROM GS.ChartOfAccounts c
            WHERE c.COAID = @COAID;
            """;

        decimal openingBalance;

        using (var openingCommand = new SqlCommand(openingSql, connection))
        {
            openingCommand.Parameters.Add("@COAID", SqlDbType.BigInt)
                .Value = coaId;

            openingCommand.Parameters.Add("@StartDate", SqlDbType.Date)
                .Value = resolvedStartDate.HasValue
                    ? resolvedStartDate.Value
                    : DBNull.Value;

            var result = await openingCommand.ExecuteScalarAsync();

            openingBalance = result == null || result == DBNull.Value
                ? 0m
                : Convert.ToDecimal(result);
        }

        /*
           ========================================================
           4. Retrieve statement lines
           ========================================================
        */

        const string linesSql = """
            SELECT
                JournalID,
                JournalNumber,
                TransactionID,
                TransactionNumber,
                TransactionTypeID,
                TransactionTypeCode,
                TransactionTypeName,
                FinancialPeriodID,
                JournalDate,
                PostedAt,
                JournalLineID,
                LineSequence,
                Description,
                COAID,
                COACode,
                COAName,
                MainHeadID,
                MainHeadCode,
                MainHeadName,
                AccountingType,
                NormalBalance,
                SubheadID,
                SubheadCode,
                SubheadName,
                DebitAmount,
                CreditAmount,
                NetMovement
            FROM FIN.vw_GeneralLedger
            WHERE COAID = @COAID
              AND
              (
                  @StartDate IS NULL
                  OR JournalDate >= @StartDate
              )
              AND
              (
                  @EndDate IS NULL
                  OR JournalDate <= @EndDate
              )
            ORDER BY
                JournalDate,
                JournalID,
                LineSequence,
                JournalLineID;
            """;

        var lines = new List<AccountStatementLineResponse>();

        using (var linesCommand = new SqlCommand(linesSql, connection))
        {
            linesCommand.Parameters.Add("@COAID", SqlDbType.BigInt)
                .Value = coaId;

            linesCommand.Parameters.Add("@StartDate", SqlDbType.Date)
                .Value = resolvedStartDate.HasValue
                    ? resolvedStartDate.Value
                    : DBNull.Value;

            linesCommand.Parameters.Add("@EndDate", SqlDbType.Date)
                .Value = resolvedEndDate.HasValue
                    ? resolvedEndDate.Value
                    : DBNull.Value;

            using var linesReader =
                await linesCommand.ExecuteReaderAsync();

            while (await linesReader.ReadAsync())
            {
                lines.Add(new AccountStatementLineResponse
                {
                    JournalID = Convert.ToInt64(linesReader["JournalID"]),
                    JournalNumber =
                        Convert.ToString(linesReader["JournalNumber"])
                        ?? string.Empty,

                    TransactionID =
                        Convert.ToInt64(linesReader["TransactionID"]),

                    TransactionNumber =
                        Convert.ToString(linesReader["TransactionNumber"])
                        ?? string.Empty,

                    TransactionTypeID =
                        Convert.ToInt32(linesReader["TransactionTypeID"]),

                    TransactionTypeCode =
                        Convert.ToInt32(linesReader["TransactionTypeCode"]),

                    TransactionTypeName =
                        Convert.ToString(linesReader["TransactionTypeName"])
                        ?? string.Empty,

                    FinancialPeriodID =
                        Convert.ToInt32(linesReader["FinancialPeriodID"]),

                    JournalDate =
                        Convert.ToDateTime(linesReader["JournalDate"]),

                    PostedAt =
                        linesReader["PostedAt"] == DBNull.Value
                            ? null
                            : Convert.ToDateTime(linesReader["PostedAt"]),

                    JournalLineID =
                        Convert.ToInt64(linesReader["JournalLineID"]),

                    LineSequence =
                        Convert.ToInt32(linesReader["LineSequence"]),

                    Description =
                        linesReader["Description"] == DBNull.Value
                            ? null
                            : Convert.ToString(linesReader["Description"]),

                    COAID =
                        Convert.ToInt64(linesReader["COAID"]),

                    COACode =
                        Convert.ToString(linesReader["COACode"])
                        ?? string.Empty,

                    COAName =
                        Convert.ToString(linesReader["COAName"])
                        ?? string.Empty,

                    MainHeadID =
                        Convert.ToInt32(linesReader["MainHeadID"]),

                    MainHeadCode =
                        Convert.ToString(linesReader["MainHeadCode"])
                        ?? string.Empty,

                    MainHeadName =
                        Convert.ToString(linesReader["MainHeadName"])
                        ?? string.Empty,

                    AccountingType =
                        Convert.ToString(linesReader["AccountingType"])
                        ?? string.Empty,

                    NormalBalance =
                        Convert.ToString(linesReader["NormalBalance"])
                        ?? string.Empty,

                    SubheadID =
                        Convert.ToInt32(linesReader["SubheadID"]),

                    SubheadCode =
                        Convert.ToString(linesReader["SubheadCode"])
                        ?? string.Empty,

                    SubheadName =
                        Convert.ToString(linesReader["SubheadName"])
                        ?? string.Empty,

                    DebitAmount =
                        Convert.ToDecimal(linesReader["DebitAmount"]),

                    CreditAmount =
                        Convert.ToDecimal(linesReader["CreditAmount"]),

                    NetMovement =
                        Convert.ToDecimal(linesReader["NetMovement"])
                });
            }
        }

        /*
           ========================================================
           5. Calculate running balance
           ========================================================
        */

        decimal runningBalance = openingBalance;

        foreach (var line in lines)
        {
            runningBalance += line.NetMovement;
            line.RunningBalance = runningBalance;
        }

        /*
           ========================================================
           6. Calculate totals
           ========================================================
        */

        decimal totalDebit =
            lines.Sum(x => x.DebitAmount);

        decimal totalCredit =
            lines.Sum(x => x.CreditAmount);

        decimal netMovement =
            lines.Sum(x => x.NetMovement);

        decimal closingBalance =
            openingBalance + netMovement;

        /*
           ========================================================
           7. Build final response
           ========================================================
        */

        account.FinancialPeriodID = financialPeriodId;
        account.PeriodCode = periodCode;
        account.PeriodName = periodName;

        account.StartDate = resolvedStartDate;
        account.EndDate = resolvedEndDate;

        account.TotalDebit = totalDebit;
        account.TotalCredit = totalCredit;
        account.NetMovement = netMovement;

        account.StatementOpeningBalance = openingBalance;
        account.ClosingBalance = closingBalance;

        account.Lines = lines;

        return account;
    }

    public async Task<TrialBalanceResponse> GetTrialBalanceAsync(
    int? financialPeriodId,
    DateTime? startDate,
    DateTime? endDate)
{
    if (financialPeriodId.HasValue &&
        (startDate.HasValue || endDate.HasValue))
    {
        throw new ArgumentException(
            "Use either financialPeriodId or startDate/endDate, not both.");
    }

    if (!financialPeriodId.HasValue &&
        (!startDate.HasValue || !endDate.HasValue))
    {
        throw new ArgumentException(
            "Provide either financialPeriodId or both startDate and endDate.");
    }

    if (startDate.HasValue &&
        endDate.HasValue &&
        startDate.Value.Date > endDate.Value.Date)
    {
        throw new ArgumentException(
            "startDate cannot be later than endDate.");
    }

    using var connection = _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    using var command = new SqlCommand(
        "FIN.usp_GetTrialBalance",
        connection);

    command.CommandType = CommandType.StoredProcedure;

    command.Parameters.Add("@FinancialPeriodID", SqlDbType.Int)
        .Value = financialPeriodId.HasValue
            ? financialPeriodId.Value
            : DBNull.Value;

    command.Parameters.Add("@StartDate", SqlDbType.Date)
        .Value = startDate.HasValue
            ? startDate.Value.Date
            : DBNull.Value;

    command.Parameters.Add("@EndDate", SqlDbType.Date)
        .Value = endDate.HasValue
            ? endDate.Value.Date
            : DBNull.Value;

    var response = new TrialBalanceResponse
    {
        FinancialPeriodID = financialPeriodId,
        StartDate = startDate?.Date,
        EndDate = endDate?.Date
    };

    using var reader = await command.ExecuteReaderAsync();

    while (await reader.ReadAsync())
    {
        response.Lines.Add(new TrialBalanceLineResponse
        {
            COAID = Convert.ToInt64(reader["COAID"]),

            COACode =
                Convert.ToString(reader["COACode"])
                ?? string.Empty,

            COAName =
                Convert.ToString(reader["COAName"])
                ?? string.Empty,

            MainHeadID =
                Convert.ToInt32(reader["MainHeadID"]),

            MainHeadCode =
                Convert.ToInt32(reader["MainHeadCode"]),

            MainHeadName =
                Convert.ToString(reader["MainHeadName"])
                ?? string.Empty,

            AccountingType =
                Convert.ToString(reader["AccountingType"])
                ?? string.Empty,

            NormalBalance =
                Convert.ToString(reader["NormalBalance"])
                ?? string.Empty,

            SubheadID =
                Convert.ToInt32(reader["SubheadID"]),

            SubheadCode =
                Convert.ToInt32(reader["SubheadCode"]),

            SubheadName =
                Convert.ToString(reader["SubheadName"])
                ?? string.Empty,

            TotalDebit =
                Convert.ToDecimal(reader["TotalDebit"]),

            TotalCredit =
                Convert.ToDecimal(reader["TotalCredit"]),

            Balance =
                Convert.ToDecimal(reader["Balance"])
        });
    }

    response.TotalDebit =
        response.Lines.Sum(x => x.TotalDebit);

    response.TotalCredit =
        response.Lines.Sum(x => x.TotalCredit);

    response.Difference =
        response.TotalDebit - response.TotalCredit;

    response.Status =
        response.Difference == 0m
            ? "BALANCED"
            : "UNBALANCED";

    return response;
}

    public async Task<IncomeStatementResponse> GetIncomeStatementAsync(
    int? financialPeriodId,
    DateTime? startDate,
    DateTime? endDate)
{
    if (financialPeriodId.HasValue &&
        (startDate.HasValue || endDate.HasValue))
    {
        throw new ArgumentException(
            "Use either financialPeriodId or startDate/endDate, not both.");
    }

    if (!financialPeriodId.HasValue &&
        (!startDate.HasValue || !endDate.HasValue))
    {
        throw new ArgumentException(
            "Provide either financialPeriodId or both startDate and endDate.");
    }

    if (startDate.HasValue &&
        endDate.HasValue &&
        startDate.Value.Date > endDate.Value.Date)
    {
        throw new ArgumentException(
            "startDate cannot be later than endDate.");
    }

    using var connection = _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    using var command = new SqlCommand(
        "FIN.usp_GetIncomeStatement",
        connection);

    command.CommandType = CommandType.StoredProcedure;

    command.Parameters.Add("@FinancialPeriodID", SqlDbType.Int)
        .Value = financialPeriodId.HasValue
            ? financialPeriodId.Value
            : DBNull.Value;

    command.Parameters.Add("@StartDate", SqlDbType.Date)
        .Value = startDate.HasValue
            ? startDate.Value.Date
            : DBNull.Value;

    command.Parameters.Add("@EndDate", SqlDbType.Date)
        .Value = endDate.HasValue
            ? endDate.Value.Date
            : DBNull.Value;

    var response = new IncomeStatementResponse
    {
        FinancialPeriodID = financialPeriodId,
        StartDate = startDate?.Date,
        EndDate = endDate?.Date
    };

    using var reader = await command.ExecuteReaderAsync();

    /* ============================================================
       RESULT SET 1 — ACCOUNT LEVEL
       ============================================================ */

    while (await reader.ReadAsync())
    {
        response.Lines.Add(
            new IncomeStatementLineResponse
            {
                COAID = Convert.ToInt64(reader["COAID"]),

                COACode =
                    Convert.ToString(reader["COACode"])
                    ?? string.Empty,

                COAName =
                    Convert.ToString(reader["COAName"])
                    ?? string.Empty,

                MainHeadID =
                    Convert.ToInt32(reader["MainHeadID"]),

                MainHeadCode =
                    Convert.ToInt32(reader["MainHeadCode"]),

                MainHeadName =
                    Convert.ToString(reader["MainHeadName"])
                    ?? string.Empty,

                AccountingType =
                    Convert.ToString(reader["AccountingType"])
                    ?? string.Empty,

                NormalBalance =
                    Convert.ToString(reader["NormalBalance"])
                    ?? string.Empty,

                SubheadID =
                    Convert.ToInt32(reader["SubheadID"]),

                SubheadCode =
                    Convert.ToInt32(reader["SubheadCode"]),

                SubheadName =
                    Convert.ToString(reader["SubheadName"])
                    ?? string.Empty,

                TotalDebit =
                    Convert.ToDecimal(reader["TotalDebit"]),

                TotalCredit =
                    Convert.ToDecimal(reader["TotalCredit"]),

                NetBalance =
                    Convert.ToDecimal(reader["NetBalance"]),

                StatementBalance =
                    Convert.ToDecimal(reader["StatementBalance"])
            });
    }

    /* ============================================================
       RESULT SET 2 — SUMMARY
       ============================================================ */

    if (await reader.NextResultAsync())
    {
        if (await reader.ReadAsync())
        {
            response.TotalIncome =
                Convert.ToDecimal(reader["TotalIncome"]);

            response.TotalExpenses =
                Convert.ToDecimal(reader["TotalExpenses"]);

            response.NetIncome =
                Convert.ToDecimal(reader["NetIncome"]);

            response.ResultStatus =
                Convert.ToString(reader["ResultStatus"])
                ?? string.Empty;
        }
    }

    return response;
}

    public async Task<BalanceSheetResponse> GetBalanceSheetAsync(
    int? financialPeriodId,
    DateTime? startDate,
    DateTime? endDate)
{
    if (financialPeriodId.HasValue &&
        (startDate.HasValue || endDate.HasValue))
    {
        throw new ArgumentException(
            "Use either financialPeriodId or startDate/endDate, not both.");
    }

    if (!financialPeriodId.HasValue &&
        (!startDate.HasValue || !endDate.HasValue))
    {
        throw new ArgumentException(
            "Provide either financialPeriodId or both startDate and endDate.");
    }

    if (startDate.HasValue &&
        endDate.HasValue &&
        startDate.Value.Date > endDate.Value.Date)
    {
        throw new ArgumentException(
            "startDate cannot be later than endDate.");
    }

    using var connection = _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    using var command = new SqlCommand(
        "FIN.usp_GetBalanceSheet",
        connection);

    command.CommandType = CommandType.StoredProcedure;

    command.Parameters.Add("@FinancialPeriodID", SqlDbType.Int)
        .Value = financialPeriodId.HasValue
            ? financialPeriodId.Value
            : DBNull.Value;

    command.Parameters.Add("@StartDate", SqlDbType.Date)
        .Value = startDate.HasValue
            ? startDate.Value.Date
            : DBNull.Value;

    command.Parameters.Add("@EndDate", SqlDbType.Date)
        .Value = endDate.HasValue
            ? endDate.Value.Date
            : DBNull.Value;

    var response = new BalanceSheetResponse
    {
        FinancialPeriodID = financialPeriodId,
        StartDate = startDate?.Date,
        EndDate = endDate?.Date
    };

    using var reader = await command.ExecuteReaderAsync();

    // ============================================================
    // RESULT SET 1 — BALANCE SHEET ACCOUNTS
    // ============================================================

    while (await reader.ReadAsync())
    {
        response.Lines.Add(
            new BalanceSheetLineResponse
            {
                COAID = Convert.ToInt64(reader["COAID"]),
                COACode =
                    Convert.ToString(reader["COACode"])
                    ?? string.Empty,

                COAName =
                    Convert.ToString(reader["COAName"])
                    ?? string.Empty,

                MainHeadID =
                    Convert.ToInt32(reader["MainHeadID"]),

                MainHeadCode =
                    Convert.ToInt32(reader["MainHeadCode"]),

                MainHeadName =
                    Convert.ToString(reader["MainHeadName"])
                    ?? string.Empty,

                AccountingType =
                    Convert.ToString(reader["AccountingType"])
                    ?? string.Empty,

                NormalBalance =
                    Convert.ToString(reader["NormalBalance"])
                    ?? string.Empty,

                SubheadID =
                    Convert.ToInt32(reader["SubheadID"]),

                SubheadCode =
                    Convert.ToInt32(reader["SubheadCode"]),

                SubheadName =
                    Convert.ToString(reader["SubheadName"])
                    ?? string.Empty,

                TotalDebit =
                    Convert.ToDecimal(reader["TotalDebit"]),

                TotalCredit =
                    Convert.ToDecimal(reader["TotalCredit"]),

                Balance =
                    Convert.ToDecimal(reader["Balance"])
            });
    }

    // ============================================================
    // RESULT SET 2 — BALANCE SHEET SUMMARY
    // ============================================================

    if (await reader.NextResultAsync())
    {
        if (await reader.ReadAsync())
        {
            response.TotalAssets =
                Convert.ToDecimal(reader["TotalAssets"]);

            response.TotalLiabilities =
                Convert.ToDecimal(reader["TotalLiabilities"]);

            response.Capital =
                Convert.ToDecimal(reader["Capital"]);

            response.CurrentPeriodNetIncome =
                Convert.ToDecimal(
                    reader["CurrentPeriodNetIncome"]);

            response.TotalEquity =
                Convert.ToDecimal(reader["TotalEquity"]);

            response.BalanceDifference =
                Convert.ToDecimal(
                    reader["BalanceDifference"]);

            response.BalanceSheetStatus =
                Convert.ToString(
                    reader["BalanceSheetStatus"])
                ?? string.Empty;
        }
    }

    return response;
}

public async Task<CashFlowStatementResponse> GetCashFlowStatementAsync(
    int? financialPeriodId,
    DateTime? startDate,
    DateTime? endDate)
{
    // ============================================================
    // 1. VALIDATE FILTERS
    // ============================================================

    if (financialPeriodId.HasValue &&
        (startDate.HasValue || endDate.HasValue))
    {
        throw new ArgumentException(
            "Use either financialPeriodId or startDate/endDate, not both.");
    }

    if (!financialPeriodId.HasValue &&
        (!startDate.HasValue || !endDate.HasValue))
    {
        throw new ArgumentException(
            "Provide either financialPeriodId or both startDate and endDate.");
    }

    if (startDate.HasValue &&
        endDate.HasValue &&
        startDate.Value.Date > endDate.Value.Date)
    {
        throw new ArgumentException(
            "startDate cannot be later than endDate.");
    }

    // ============================================================
    // 2. OPEN DATABASE CONNECTION
    // ============================================================

    using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    // ============================================================
    // 3. CALL CASH FLOW STORED PROCEDURE
    // ============================================================

    using var command = new SqlCommand(
        "FIN.usp_GetCashFlowStatement",
        connection);

    command.CommandType = CommandType.StoredProcedure;

    command.Parameters.Add(
        "@FinancialPeriodID",
        SqlDbType.Int).Value =
        financialPeriodId.HasValue
            ? financialPeriodId.Value
            : DBNull.Value;

    command.Parameters.Add(
        "@StartDate",
        SqlDbType.Date).Value =
        startDate.HasValue
            ? startDate.Value.Date
            : DBNull.Value;

    command.Parameters.Add(
        "@EndDate",
        SqlDbType.Date).Value =
        endDate.HasValue
            ? endDate.Value.Date
            : DBNull.Value;

    // ============================================================
    // 4. INITIALIZE RESPONSE
    // ============================================================

    var response = new CashFlowStatementResponse
    {
        FinancialPeriodID = financialPeriodId,
        StartDate = startDate?.Date,
        EndDate = endDate?.Date
    };

    using var reader =
        await command.ExecuteReaderAsync();

    // ============================================================
    // RESULT SET 1 — CASH FLOW DETAIL
    // ============================================================

    while (await reader.ReadAsync())
    {
        response.Lines.Add(
            new CashFlowLineResponse
            {
                JournalID =
                    Convert.ToInt64(
                        reader["JournalID"]),

                JournalNumber =
                    Convert.ToString(
                        reader["JournalNumber"])
                    ?? string.Empty,

                TransactionID =
                    Convert.ToInt64(
                        reader["TransactionID"]),

                JournalDate =
                    Convert.ToDateTime(
                        reader["JournalDate"]),

                JournalLineID =
                    Convert.ToInt64(
                        reader["JournalLineID"]),

                LineSequence =
                    Convert.ToInt32(
                        reader["LineSequence"]),

                COAID =
                    Convert.ToInt64(
                        reader["COAID"]),

                COACode =
                    Convert.ToString(
                        reader["COACode"])
                    ?? string.Empty,

                COAName =
                    Convert.ToString(
                        reader["COAName"])
                    ?? string.Empty,

                CashAccountType =
                    Convert.ToString(
                        reader["CashAccountType"])
                    ?? string.Empty,

                DebitAmount =
                    Convert.ToDecimal(
                        reader["DebitAmount"]),

                CreditAmount =
                    Convert.ToDecimal(
                        reader["CreditAmount"]),

                NetCashMovement =
                    Convert.ToDecimal(
                        reader["NetCashMovement"]),

                Description =
                    reader["Description"] == DBNull.Value
                        ? null
                        : Convert.ToString(
                            reader["Description"])
            });
    }

    // ============================================================
    // RESULT SET 2 — CASH FLOW SUMMARY
    // ============================================================

    if (await reader.NextResultAsync())
    {
        if (await reader.ReadAsync())
        {
            response.TotalCashInflows =
                Convert.ToDecimal(
                    reader["TotalCashInflows"]);

            response.TotalCashOutflows =
                Convert.ToDecimal(
                    reader["TotalCashOutflows"]);

            response.NetCashMovement =
                Convert.ToDecimal(
                    reader["NetCashMovement"]);

            response.CashFlowStatus =
                Convert.ToString(
                    reader["CashFlowStatus"])
                ?? string.Empty;
        }
    }

    // ============================================================
    // RESULT SET 3 — CASH ACCOUNT BALANCES
    // ============================================================

    if (await reader.NextResultAsync())
    {
        while (await reader.ReadAsync())
        {
            response.CashAccounts.Add(
                new CashAccountBalanceResponse
                {
                    COAID =
                        Convert.ToInt64(
                            reader["COAID"]),

                    COACode =
                        Convert.ToString(
                            reader["COACode"])
                        ?? string.Empty,

                    COAName =
                        Convert.ToString(
                            reader["COAName"])
                        ?? string.Empty,

                    CashAccountType =
                        Convert.ToString(
                            reader["CashAccountType"])
                        ?? string.Empty,

                    TotalDebit =
                        Convert.ToDecimal(
                            reader["TotalDebit"]),

                    TotalCredit =
                        Convert.ToDecimal(
                            reader["TotalCredit"]),

                    ClosingBalance =
                        Convert.ToDecimal(
                            reader["ClosingBalance"])
                });
        }
    }

    return response;
}

    public async Task<VoidTransactionResponse> VoidAsync(
    long transactionId,
    int voidedByUserId,
    string voidReason)
{
    if (transactionId <= 0)
    {
        throw new ArgumentException(
            "Transaction ID must be greater than zero.");
    }

    if (voidedByUserId <= 0)
    {
        throw new ArgumentException(
            "Voiding user ID must be greater than zero.");
    }

    if (string.IsNullOrWhiteSpace(voidReason))
    {
        throw new ArgumentException(
            "Void reason is required.");
    }

    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    await using var command =
        new SqlCommand(
            "FIN.usp_VoidTransaction",
            connection);

    command.CommandType = CommandType.StoredProcedure;

    command.Parameters.Add(
        "@TransactionID",
        SqlDbType.BigInt).Value =
        transactionId;

    command.Parameters.Add(
        "@VoidedByUserID",
        SqlDbType.Int).Value =
        voidedByUserId;

    command.Parameters.Add(
        "@VoidReason",
        SqlDbType.VarChar,
        500).Value =
        voidReason.Trim();

    await using var reader =
        await command.ExecuteReaderAsync();

    if (!await reader.ReadAsync())
    {
        throw new InvalidOperationException(
            "The void transaction procedure returned no result.");
    }

    return new VoidTransactionResponse
    {
        TransactionID =
            Convert.ToInt64(
                reader["TransactionID"]),

        TransactionNumber =
            Convert.ToString(
                reader["TransactionNumber"])
            ?? string.Empty,

        Status =
            Convert.ToString(
                reader["Status"])
            ?? string.Empty,

        VoidedAt =
            Convert.ToDateTime(
                reader["VoidedAt"]),

        VoidedByUserID =
            Convert.ToInt32(
                reader["VoidedByUserID"]),

        VoidReason =
            Convert.ToString(
                reader["VoidReason"])
            ?? string.Empty,

        OriginalJournalID =
            reader["OriginalJournalID"] == DBNull.Value
                ? null
                : Convert.ToInt64(
                    reader["OriginalJournalID"]),

        ReversalJournalID =
            reader["ReversalJournalID"] == DBNull.Value
                ? null
                : Convert.ToInt64(
                    reader["ReversalJournalID"]),

        ReversalJournalNumber =
            reader["ReversalJournalNumber"] == DBNull.Value
                ? null
                : Convert.ToString(
                    reader["ReversalJournalNumber"]),

        Message =
            Convert.ToString(
                reader["Message"])
            ?? string.Empty
    };
}
}