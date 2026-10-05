using Microsoft.Data.SqlClient;
using MYFIN.API.Data;
using MYFIN.API.DTOs.Journals;

namespace MYFIN.API.Services;

public class JournalService : IJournalService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public JournalService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<JournalListResponse> GetListAsync(
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
            FROM FIN.Journals AS J
            INNER JOIN FIN.Transactions AS T
                ON T.TransactionID = J.TransactionID
            INNER JOIN GS.TransactionTypes AS TT
                ON TT.TransactionTypeID = T.TransactionTypeID
            WHERE
                (@FinancialPeriodID IS NULL
                    OR J.FinancialPeriodID = @FinancialPeriodID)
                AND
                (@Status IS NULL
                    OR J.Status = @Status)
                AND
                (@TransactionTypeID IS NULL
                    OR T.TransactionTypeID = @TransactionTypeID)
                AND
                (@StartDate IS NULL
                    OR J.JournalDate >= @StartDate)
                AND
                (@EndDate IS NULL
                    OR J.JournalDate <= @EndDate);

            SELECT
                J.JournalID,
                J.JournalNumber,
                T.TransactionID,
                T.TransactionNumber,
                T.TransactionTypeID,
                TT.TransactionTypeCode,
                TT.TransactionTypeName,
                J.FinancialPeriodID,
                J.JournalDate,
                J.Description,
                J.Status,
                J.CreatedAt,
                J.PostedAt,
                ISNULL(SUM(JL.DebitAmount), 0) AS TotalDebit,
                ISNULL(SUM(JL.CreditAmount), 0) AS TotalCredit
            FROM FIN.Journals AS J
            INNER JOIN FIN.Transactions AS T
                ON T.TransactionID = J.TransactionID
            INNER JOIN GS.TransactionTypes AS TT
                ON TT.TransactionTypeID = T.TransactionTypeID
            LEFT JOIN FIN.JournalLines AS JL
                ON JL.JournalID = J.JournalID
            WHERE
                (@FinancialPeriodID IS NULL
                    OR J.FinancialPeriodID = @FinancialPeriodID)
                AND
                (@Status IS NULL
                    OR J.Status = @Status)
                AND
                (@TransactionTypeID IS NULL
                    OR T.TransactionTypeID = @TransactionTypeID)
                AND
                (@StartDate IS NULL
                    OR J.JournalDate >= @StartDate)
                AND
                (@EndDate IS NULL
                    OR J.JournalDate <= @EndDate)
            GROUP BY
                J.JournalID,
                J.JournalNumber,
                T.TransactionID,
                T.TransactionNumber,
                T.TransactionTypeID,
                TT.TransactionTypeCode,
                TT.TransactionTypeName,
                J.FinancialPeriodID,
                J.JournalDate,
                J.Description,
                J.Status,
                J.CreatedAt,
                J.PostedAt
            ORDER BY
                J.JournalDate DESC,
                J.JournalID DESC
            OFFSET @Offset ROWS
            FETCH NEXT @PageSize ROWS ONLY;
            """;

        await using var command =
            new SqlCommand(sql, connection);

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

        command.Parameters.AddWithValue("@Offset", offset);

        command.Parameters.AddWithValue("@PageSize", pageSize);

        await using var reader =
            await command.ExecuteReaderAsync();

        var result = new JournalListResponse
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
            result.Journals.Add(
                new JournalListItemResponse
                {
                    JournalID = Convert.ToInt64(reader["JournalID"]),
                    JournalNumber = Convert.ToString(reader["JournalNumber"]) ?? string.Empty,
                    TransactionID = Convert.ToInt64(reader["TransactionID"]),
                    TransactionNumber = Convert.ToString(reader["TransactionNumber"]) ?? string.Empty,
                    TransactionTypeID = Convert.ToInt32(reader["TransactionTypeID"]),
                    TransactionTypeCode = Convert.ToString(reader["TransactionTypeCode"]) ?? string.Empty,
                    TransactionTypeName = Convert.ToString(reader["TransactionTypeName"]) ?? string.Empty,
                    FinancialPeriodID = Convert.ToInt32(reader["FinancialPeriodID"]),
                    JournalDate = Convert.ToDateTime(reader["JournalDate"]),
                    Description = reader["Description"] == DBNull.Value
                        ? null
                        : Convert.ToString(reader["Description"]),
                    Status = Convert.ToString(reader["Status"]) ?? string.Empty,
                    CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
                    PostedAt = reader["PostedAt"] == DBNull.Value
                        ? null
                        : Convert.ToDateTime(reader["PostedAt"]),
                    TotalDebit = Convert.ToDecimal(reader["TotalDebit"]),
                    TotalCredit = Convert.ToDecimal(reader["TotalCredit"])
                });
        }

        await reader.CloseAsync();

        if (result.Journals.Count > 0)
        {
            var journalIds = result.Journals
                .Select(j => j.JournalID)
                .Distinct()
                .ToList();

            var linesSql = $"""
                SELECT
                    JL.JournalID,
                    JL.JournalLineID,
                    JL.LineSequence,
                    JL.COAID,
                    COA.COACode,
                    COA.COAName,
                    JL.DebitAmount,
                    JL.CreditAmount,
                    JL.Description
                FROM FIN.JournalLines AS JL
                INNER JOIN GS.ChartOfAccounts AS COA
                    ON COA.COAID = JL.COAID
                WHERE JL.JournalID IN ({string.Join(", ", journalIds.Select((id, index) => "@JournalId" + index))})
                ORDER BY JL.JournalID, JL.LineSequence;
                """;

            await using var linesCommand =
                new SqlCommand(linesSql, connection);

            for (var index = 0; index < journalIds.Count; index++)
            {
                linesCommand.Parameters.AddWithValue("@JournalId" + index, journalIds[index]);
            }

            await using var linesReader =
                await linesCommand.ExecuteReaderAsync();

            var linesLookup = new Dictionary<long, List<JournalLineResponse>>();

            while (await linesReader.ReadAsync())
            {
                var journalId = Convert.ToInt64(linesReader["JournalID"]);
                var line = new JournalLineResponse
                {
                    JournalLineID = Convert.ToInt64(linesReader["JournalLineID"]),
                    LineSequence = Convert.ToInt32(linesReader["LineSequence"]),
                    COAID = Convert.ToInt64(linesReader["COAID"]),
                    COACode = Convert.ToString(linesReader["COACode"]) ?? string.Empty,
                    COAName = Convert.ToString(linesReader["COAName"]) ?? string.Empty,
                    DebitAmount = Convert.ToDecimal(linesReader["DebitAmount"]),
                    CreditAmount = Convert.ToDecimal(linesReader["CreditAmount"]),
                    Description = linesReader["Description"] == DBNull.Value
                        ? null
                        : Convert.ToString(linesReader["Description"])
                };

                if (!linesLookup.ContainsKey(journalId))
                {
                    linesLookup[journalId] = new List<JournalLineResponse>();
                }

                linesLookup[journalId].Add(line);
            }

            foreach (var journal in result.Journals)
            {
                if (linesLookup.ContainsKey(journal.JournalID))
                {
                    journal.Lines = linesLookup[journal.JournalID];
                }
            }
        }

        return result;
    }

    public async Task<JournalDetailsResponse?> GetDetailsAsync(long journalId)
    {
        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        const string sql = """
            SELECT
                J.JournalID,
                J.JournalNumber,
                T.TransactionID,
                T.TransactionNumber,
                T.TransactionTypeID,
                TT.TransactionTypeCode,
                TT.TransactionTypeName,
                J.FinancialPeriodID,
                J.JournalDate,
                J.Description,
                J.Status,
                J.CreatedAt,
                J.PostedAt
            FROM FIN.Journals AS J
            INNER JOIN FIN.Transactions AS T
                ON T.TransactionID = J.TransactionID
            INNER JOIN GS.TransactionTypes AS TT
                ON TT.TransactionTypeID = T.TransactionTypeID
            WHERE J.JournalID = @JournalID;

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
            INNER JOIN GS.ChartOfAccounts AS COA
                ON COA.COAID = JL.COAID
            WHERE JL.JournalID = @JournalID
            ORDER BY JL.LineSequence;
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.AddWithValue("@JournalID", journalId);

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        var response = new JournalDetailsResponse
        {
            JournalID = Convert.ToInt64(reader["JournalID"]),
            JournalNumber = Convert.ToString(reader["JournalNumber"]) ?? string.Empty,
            TransactionID = Convert.ToInt64(reader["TransactionID"]),
            TransactionNumber = Convert.ToString(reader["TransactionNumber"]) ?? string.Empty,
            TransactionTypeID = Convert.ToInt32(reader["TransactionTypeID"]),
            TransactionTypeCode = Convert.ToString(reader["TransactionTypeCode"]) ?? string.Empty,
            TransactionTypeName = Convert.ToString(reader["TransactionTypeName"]) ?? string.Empty,
            FinancialPeriodID = Convert.ToInt32(reader["FinancialPeriodID"]),
            JournalDate = Convert.ToDateTime(reader["JournalDate"]),
            Description = reader["Description"] == DBNull.Value
                ? null
                : Convert.ToString(reader["Description"]),
            Status = Convert.ToString(reader["Status"]) ?? string.Empty,
            CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
            PostedAt = reader["PostedAt"] == DBNull.Value
                ? null
                : Convert.ToDateTime(reader["PostedAt"])
        };

        await reader.NextResultAsync();

        while (await reader.ReadAsync())
        {
            var debit = Convert.ToDecimal(reader["DebitAmount"]);
            var credit = Convert.ToDecimal(reader["CreditAmount"]);

            response.TotalDebit += debit;
            response.TotalCredit += credit;

            response.Lines.Add(
                new JournalLineResponse
                {
                    JournalLineID = Convert.ToInt64(reader["JournalLineID"]),
                    LineSequence = Convert.ToInt32(reader["LineSequence"]),
                    COAID = Convert.ToInt64(reader["COAID"]),
                    COACode = Convert.ToString(reader["COACode"]) ?? string.Empty,
                    COAName = Convert.ToString(reader["COAName"]) ?? string.Empty,
                    DebitAmount = debit,
                    CreditAmount = credit,
                    Description = reader["Description"] == DBNull.Value
                        ? null
                        : Convert.ToString(reader["Description"])
                });
        }

        return response;
    }
}
