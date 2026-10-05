using Microsoft.Data.SqlClient;
using MYFIN.API.Data;
using MYFIN.API.DTOs.Masters;

namespace MYFIN.API.Services;

public class TransactionComponentRuleService
    : ITransactionComponentRuleService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public TransactionComponentRuleService(
        SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    // ============================================================
    // GET ALL / FILTER
    // ============================================================

    public async Task<IReadOnlyList<TransactionComponentRuleResponse>>
        GetTransactionComponentRulesAsync(
            int? transactionComponentId = null,
            string? entrySide = null)
    {
        var results = new List<TransactionComponentRuleResponse>();

        const string sql = """
            SELECT
                r.TransactionComponentRuleID,
                r.TransactionComponentID,

                tt.TransactionTypeID,
                tt.TransactionTypeCode,
                tt.TransactionTypeName,
                tt.IsSystem AS TransactionTypeIsSystem,
                tt.IsActive AS TransactionTypeIsActive,

                tc.ComponentCode,
                tc.ComponentName,
                tc.IsRequired AS ComponentIsRequired,
                tc.IsActive AS ComponentIsActive,

                r.EntrySide,

                r.MainHeadID,
                mh.MainHeadCode,
                mh.MainHeadName,
                mh.AccountingType,
                mh.NormalBalance,

                r.SubheadID,
                s.SubheadCode,
                s.SubheadName,

                r.COAID,
                coa.COACode,
                coa.COAName,

                r.IsRequired,
                r.SequenceNo,
                r.CreatedAt,
                r.UpdatedAt

            FROM GS.TransactionComponentRules r

            INNER JOIN GS.TransactionComponents tc
                ON tc.TransactionComponentID =
                   r.TransactionComponentID

            INNER JOIN GS.TransactionTypes tt
                ON tt.TransactionTypeID =
                   tc.TransactionTypeID

            INNER JOIN GS.MainHeads mh
                ON mh.MainHeadID =
                   r.MainHeadID

            LEFT JOIN GS.Subheads s
                ON s.SubheadID =
                   r.SubheadID

            LEFT JOIN GS.ChartOfAccounts coa
                ON coa.COAID =
                   r.COAID

            WHERE
                (@TransactionComponentID IS NULL
                 OR r.TransactionComponentID =
                    @TransactionComponentID)

                AND
                (@EntrySide IS NULL
                 OR r.EntrySide =
                    @EntrySide)

            ORDER BY
                tt.TransactionTypeID,
                tc.TransactionComponentID,
                r.SequenceNo,
                r.TransactionComponentRuleID;
            """;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter(
                "@TransactionComponentID",
                System.Data.SqlDbType.Int)
            {
                Value = transactionComponentId.HasValue
                    ? transactionComponentId.Value
                    : DBNull.Value
            });

        command.Parameters.Add(
            new SqlParameter(
                "@EntrySide",
                System.Data.SqlDbType.Char, 1)
            {
                Value = string.IsNullOrWhiteSpace(entrySide)
                    ? DBNull.Value
                    : entrySide.Trim().ToUpperInvariant()
            });

        await using var reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            results.Add(MapResponse(reader));
        }

        return results;
    }


    // ============================================================
    // GET BY ID
    // ============================================================

    public async Task<TransactionComponentRuleResponse?>
        GetTransactionComponentRuleAsync(
            int transactionComponentRuleId)
    {
        const string sql = """
            SELECT
                r.TransactionComponentRuleID,
                r.TransactionComponentID,

                tt.TransactionTypeID,
                tt.TransactionTypeCode,
                tt.TransactionTypeName,
                tt.IsSystem AS TransactionTypeIsSystem,
                tt.IsActive AS TransactionTypeIsActive,

                tc.ComponentCode,
                tc.ComponentName,
                tc.IsRequired AS ComponentIsRequired,
                tc.IsActive AS ComponentIsActive,

                r.EntrySide,

                r.MainHeadID,
                mh.MainHeadCode,
                mh.MainHeadName,
                mh.AccountingType,
                mh.NormalBalance,

                r.SubheadID,
                s.SubheadCode,
                s.SubheadName,

                r.COAID,
                coa.COACode,
                coa.COAName,

                r.IsRequired,
                r.SequenceNo,
                r.CreatedAt,
                r.UpdatedAt

            FROM GS.TransactionComponentRules r

            INNER JOIN GS.TransactionComponents tc
                ON tc.TransactionComponentID =
                   r.TransactionComponentID

            INNER JOIN GS.TransactionTypes tt
                ON tt.TransactionTypeID =
                   tc.TransactionTypeID

            INNER JOIN GS.MainHeads mh
                ON mh.MainHeadID =
                   r.MainHeadID

            LEFT JOIN GS.Subheads s
                ON s.SubheadID =
                   r.SubheadID

            LEFT JOIN GS.ChartOfAccounts coa
                ON coa.COAID =
                   r.COAID

            WHERE
                r.TransactionComponentRuleID =
                @TransactionComponentRuleID;
            """;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            "@TransactionComponentRuleID",
            System.Data.SqlDbType.Int)
            .Value = transactionComponentRuleId;

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        return MapResponse(reader);
    }


    // ============================================================
    // CREATE
    // ============================================================

    public async Task<TransactionComponentRuleResponse>
        CreateTransactionComponentRuleAsync(
            CreateTransactionComponentRuleRequest request)
    {
        var entrySide =
            request.EntrySide.Trim().ToUpperInvariant();

        if (entrySide != "D" && entrySide != "C")
        {
            throw new ArgumentException(
                "EntrySide must be D or C.");
        }

        if (request.SequenceNo < 1)
        {
            throw new ArgumentException(
                "SequenceNo must be greater than or equal to 1.");
        }

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var transaction =
            await connection.BeginTransactionAsync();

        try
        {
            // ----------------------------------------------------
            // 1. Validate transaction component
            // ----------------------------------------------------

            const string componentSql = """
                SELECT
                    tc.TransactionComponentID,
                    tc.TransactionTypeID,
                    tc.IsActive AS ComponentIsActive,
                    tt.IsSystem AS TransactionTypeIsSystem,
                    tt.IsActive AS TransactionTypeIsActive
                FROM GS.TransactionComponents tc
                INNER JOIN GS.TransactionTypes tt
                    ON tt.TransactionTypeID =
                       tc.TransactionTypeID
                WHERE
                    tc.TransactionComponentID =
                    @TransactionComponentID;
                """;

            await using var componentCommand =
                new SqlCommand(
                    componentSql,
                    connection,
                    (SqlTransaction)transaction);

            componentCommand.Parameters.Add(
                "@TransactionComponentID",
                System.Data.SqlDbType.Int)
                .Value = request.TransactionComponentID;

            await using var componentReader =
                await componentCommand.ExecuteReaderAsync();

            if (!await componentReader.ReadAsync())
            {
                await componentReader.DisposeAsync();

                throw new KeyNotFoundException(
                    "Transaction component was not found.");
            }

            var componentIsActive =
                componentReader.GetBoolean(
                    componentReader.GetOrdinal(
                        "ComponentIsActive"));

            var transactionTypeIsSystem =
                componentReader.GetBoolean(
                    componentReader.GetOrdinal(
                        "TransactionTypeIsSystem"));

            var transactionTypeIsActive =
                componentReader.GetBoolean(
                    componentReader.GetOrdinal(
                        "TransactionTypeIsActive"));

            await componentReader.DisposeAsync();

            if (!componentIsActive)
            {
                throw new InvalidOperationException(
                    "The transaction component is inactive.");
            }

            if (!transactionTypeIsActive)
            {
                throw new InvalidOperationException(
                    "The parent transaction type is inactive.");
            }

            if (transactionTypeIsSystem)
            {
                throw new InvalidOperationException(
                    "Transaction component rules for system transaction types cannot be created through the API.");
            }


            // ----------------------------------------------------
            // 2. Validate Main Head
            // ----------------------------------------------------

            const string mainHeadSql = """
                SELECT
                    MainHeadID,
                    IsActive
                FROM GS.MainHeads
                WHERE MainHeadID = @MainHeadID;
                """;

            await using var mainHeadCommand =
                new SqlCommand(
                    mainHeadSql,
                    connection,
                    (SqlTransaction)transaction);

            mainHeadCommand.Parameters.Add(
                "@MainHeadID",
                System.Data.SqlDbType.Int)
                .Value = request.MainHeadID;

            await using var mainHeadReader =
                await mainHeadCommand.ExecuteReaderAsync();

            if (!await mainHeadReader.ReadAsync())
            {
                await mainHeadReader.DisposeAsync();

                throw new KeyNotFoundException(
                    "Main head was not found.");
            }

            var mainHeadIsActive =
                mainHeadReader.GetBoolean(
                    mainHeadReader.GetOrdinal("IsActive"));

            await mainHeadReader.DisposeAsync();

            if (!mainHeadIsActive)
            {
                throw new InvalidOperationException(
                    "The selected main head is inactive.");
            }


            // ----------------------------------------------------
            // 3. Validate hierarchy
            // ----------------------------------------------------

            if (request.SubheadID == null &&
                request.COAID != null)
            {
                throw new ArgumentException(
                    "COAID cannot be supplied without SubheadID.");
            }


            if (request.SubheadID != null)
            {
                const string subheadSql = """
                    SELECT
                        SubheadID,
                        MainHeadID,
                        IsActive
                    FROM GS.Subheads
                    WHERE SubheadID = @SubheadID;
                    """;

                await using var subheadCommand =
                    new SqlCommand(
                        subheadSql,
                        connection,
                        (SqlTransaction)transaction);

                subheadCommand.Parameters.Add(
                    "@SubheadID",
                    System.Data.SqlDbType.Int)
                    .Value = request.SubheadID.Value;

                await using var subheadReader =
                    await subheadCommand.ExecuteReaderAsync();

                if (!await subheadReader.ReadAsync())
                {
                    await subheadReader.DisposeAsync();

                    throw new KeyNotFoundException(
                        "Subhead was not found.");
                }

                var subheadMainHeadID =
                    subheadReader.GetInt32(
                        subheadReader.GetOrdinal(
                            "MainHeadID"));

                var subheadIsActive =
                    subheadReader.GetBoolean(
                        subheadReader.GetOrdinal(
                            "IsActive"));

                await subheadReader.DisposeAsync();

                if (subheadMainHeadID != request.MainHeadID)
                {
                    throw new ArgumentException(
                        "The selected subhead does not belong to the selected main head.");
                }

                if (!subheadIsActive)
                {
                    throw new InvalidOperationException(
                        "The selected subhead is inactive.");
                }
            }


            // ----------------------------------------------------
            // 4. Validate COA
            // ----------------------------------------------------

            if (request.COAID != null)
            {
                const string coaSql = """
                    SELECT
                        coa.COAID,
                        coa.SubheadID,
                        coa.IsActive
                    FROM GS.ChartOfAccounts coa
                    WHERE coa.COAID = @COAID;
                    """;

                await using var coaCommand =
                    new SqlCommand(
                        coaSql,
                        connection,
                        (SqlTransaction)transaction);

                coaCommand.Parameters.Add(
                    "@COAID",
                    System.Data.SqlDbType.BigInt)
                    .Value = request.COAID.Value;

                await using var coaReader =
                    await coaCommand.ExecuteReaderAsync();

                if (!await coaReader.ReadAsync())
                {
                    await coaReader.DisposeAsync();

                    throw new KeyNotFoundException(
                        "Chart of account was not found.");
                }

                var coaSubheadID =
                    coaReader.GetInt32(
                        coaReader.GetOrdinal(
                            "SubheadID"));

                var coaIsActive =
                    coaReader.GetBoolean(
                        coaReader.GetOrdinal(
                            "IsActive"));

                await coaReader.DisposeAsync();

                if (coaSubheadID != request.SubheadID)
                {
                    throw new ArgumentException(
                        "The selected chart of account does not belong to the selected subhead.");
                }

                if (!coaIsActive)
                {
                    throw new InvalidOperationException(
                        "The selected chart of account is inactive.");
                }
            }


            // ----------------------------------------------------
            // 5. Duplicate rule protection
            // ----------------------------------------------------

            const string duplicateSql = """
                SELECT COUNT(1)
                FROM GS.TransactionComponentRules
                WHERE
                    TransactionComponentID =
                    @TransactionComponentID
                    AND EntrySide = @EntrySide
                    AND SequenceNo = @SequenceNo;
                """;

            await using var duplicateCommand =
                new SqlCommand(
                    duplicateSql,
                    connection,
                    (SqlTransaction)transaction);

            duplicateCommand.Parameters.Add(
                "@TransactionComponentID",
                System.Data.SqlDbType.Int)
                .Value = request.TransactionComponentID;

            duplicateCommand.Parameters.Add(
                "@EntrySide",
                System.Data.SqlDbType.Char, 1)
                .Value = entrySide;

            duplicateCommand.Parameters.Add(
                "@SequenceNo",
                System.Data.SqlDbType.Int)
                .Value = request.SequenceNo;

            var duplicateCount =
                Convert.ToInt32(
                    await duplicateCommand.ExecuteScalarAsync());

            if (duplicateCount > 0)
            {
                throw new InvalidOperationException(
                    "A transaction component rule with the same TransactionComponentID, EntrySide, and SequenceNo already exists.");
            }


            // ----------------------------------------------------
            // 6. Insert rule
            // ----------------------------------------------------

            const string insertSql = """
                INSERT INTO GS.TransactionComponentRules
                (
                    TransactionComponentID,
                    EntrySide,
                    MainHeadID,
                    SubheadID,
                    COAID,
                    IsRequired,
                    SequenceNo
                )
                OUTPUT INSERTED.TransactionComponentRuleID
                VALUES
                (
                    @TransactionComponentID,
                    @EntrySide,
                    @MainHeadID,
                    @SubheadID,
                    @COAID,
                    @IsRequired,
                    @SequenceNo
                );
                """;

            await using var insertCommand =
                new SqlCommand(
                    insertSql,
                    connection,
                    (SqlTransaction)transaction);

            insertCommand.Parameters.Add(
                "@TransactionComponentID",
                System.Data.SqlDbType.Int)
                .Value = request.TransactionComponentID;

            insertCommand.Parameters.Add(
                "@EntrySide",
                System.Data.SqlDbType.Char, 1)
                .Value = entrySide;

            insertCommand.Parameters.Add(
                "@MainHeadID",
                System.Data.SqlDbType.Int)
                .Value = request.MainHeadID;

            insertCommand.Parameters.Add(
                "@SubheadID",
                System.Data.SqlDbType.Int)
                .Value = request.SubheadID.HasValue
                    ? request.SubheadID.Value
                    : DBNull.Value;

            insertCommand.Parameters.Add(
                "@COAID",
                System.Data.SqlDbType.BigInt)
                .Value = request.COAID.HasValue
                    ? request.COAID.Value
                    : DBNull.Value;

            insertCommand.Parameters.Add(
                "@IsRequired",
                System.Data.SqlDbType.Bit)
                .Value = request.IsRequired;

            insertCommand.Parameters.Add(
                "@SequenceNo",
                System.Data.SqlDbType.Int)
                .Value = request.SequenceNo;

            var newRuleId =
                Convert.ToInt32(
                    await insertCommand.ExecuteScalarAsync());

            await transaction.CommitAsync();

            var createdRule =
                await GetTransactionComponentRuleAsync(
                    newRuleId);

            if (createdRule == null)
            {
                throw new InvalidOperationException(
                    "The rule was created but could not be retrieved.");
            }

            return createdRule;
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }


    // ============================================================
    // UPDATE
    // ============================================================

    public async Task<TransactionComponentRuleResponse>
        UpdateTransactionComponentRuleAsync(
            int transactionComponentRuleId,
            UpdateTransactionComponentRuleRequest request)
    {
        var entrySide =
            request.EntrySide.Trim().ToUpperInvariant();

        if (entrySide != "D" && entrySide != "C")
        {
            throw new ArgumentException(
                "EntrySide must be D or C.");
        }

        if (request.SequenceNo < 1)
        {
            throw new ArgumentException(
                "SequenceNo must be greater than or equal to 1.");
        }

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var transaction =
            await connection.BeginTransactionAsync();

        try
        {
            // ----------------------------------------------------
            // 1. Get existing rule/component
            // ----------------------------------------------------

            const string existingSql = """
                SELECT
                    r.TransactionComponentRuleID,
                    r.TransactionComponentID,
                    tt.IsSystem AS TransactionTypeIsSystem,
                    tt.IsActive AS TransactionTypeIsActive,
                    tc.IsActive AS ComponentIsActive
                FROM GS.TransactionComponentRules r
                INNER JOIN GS.TransactionComponents tc
                    ON tc.TransactionComponentID =
                       r.TransactionComponentID
                INNER JOIN GS.TransactionTypes tt
                    ON tt.TransactionTypeID =
                       tc.TransactionTypeID
                WHERE
                    r.TransactionComponentRuleID =
                    @TransactionComponentRuleID;
                """;

            await using var existingCommand =
                new SqlCommand(
                    existingSql,
                    connection,
                    (SqlTransaction)transaction);

            existingCommand.Parameters.Add(
                "@TransactionComponentRuleID",
                System.Data.SqlDbType.Int)
                .Value = transactionComponentRuleId;

            await using var existingReader =
                await existingCommand.ExecuteReaderAsync();

            if (!await existingReader.ReadAsync())
            {
                await existingReader.DisposeAsync();

                throw new KeyNotFoundException(
                    "Transaction component rule was not found.");
            }

            var transactionComponentID =
                existingReader.GetInt32(
                    existingReader.GetOrdinal(
                        "TransactionComponentID"));

            var transactionTypeIsSystem =
                existingReader.GetBoolean(
                    existingReader.GetOrdinal(
                        "TransactionTypeIsSystem"));

            var transactionTypeIsActive =
                existingReader.GetBoolean(
                    existingReader.GetOrdinal(
                        "TransactionTypeIsActive"));

            var componentIsActive =
                existingReader.GetBoolean(
                    existingReader.GetOrdinal(
                        "ComponentIsActive"));

            await existingReader.DisposeAsync();

            if (transactionTypeIsSystem)
            {
                throw new InvalidOperationException(
                    "Transaction component rules for system transaction types cannot be modified through the API.");
            }

            if (!transactionTypeIsActive)
            {
                throw new InvalidOperationException(
                    "The parent transaction type is inactive.");
            }

            if (!componentIsActive)
            {
                throw new InvalidOperationException(
                    "The transaction component is inactive.");
            }


            // ----------------------------------------------------
            // 2. Validate Main Head
            // ----------------------------------------------------

            const string mainHeadSql = """
                SELECT IsActive
                FROM GS.MainHeads
                WHERE MainHeadID = @MainHeadID;
                """;

            await using var mainHeadCommand =
                new SqlCommand(
                    mainHeadSql,
                    connection,
                    (SqlTransaction)transaction);

            mainHeadCommand.Parameters.Add(
                "@MainHeadID",
                System.Data.SqlDbType.Int)
                .Value = request.MainHeadID;

            var mainHeadResult =
                await mainHeadCommand.ExecuteScalarAsync();

            if (mainHeadResult == null)
            {
                throw new KeyNotFoundException(
                    "Main head was not found.");
            }

            if (!Convert.ToBoolean(mainHeadResult))
            {
                throw new InvalidOperationException(
                    "The selected main head is inactive.");
            }


            // ----------------------------------------------------
            // 3. Validate hierarchy
            // ----------------------------------------------------

            if (request.SubheadID == null &&
                request.COAID != null)
            {
                throw new ArgumentException(
                    "COAID cannot be supplied without SubheadID.");
            }


            if (request.SubheadID != null)
            {
                const string subheadSql = """
                    SELECT
                        MainHeadID,
                        IsActive
                    FROM GS.Subheads
                    WHERE SubheadID = @SubheadID;
                    """;

                await using var subheadCommand =
                    new SqlCommand(
                        subheadSql,
                        connection,
                        (SqlTransaction)transaction);

                subheadCommand.Parameters.Add(
                    "@SubheadID",
                    System.Data.SqlDbType.Int)
                    .Value = request.SubheadID.Value;

                await using var subheadReader =
                    await subheadCommand.ExecuteReaderAsync();

                if (!await subheadReader.ReadAsync())
                {
                    await subheadReader.DisposeAsync();

                    throw new KeyNotFoundException(
                        "Subhead was not found.");
                }

                var subheadMainHeadID =
                    subheadReader.GetInt32(
                        subheadReader.GetOrdinal(
                            "MainHeadID"));

                var subheadIsActive =
                    subheadReader.GetBoolean(
                        subheadReader.GetOrdinal(
                            "IsActive"));

                await subheadReader.DisposeAsync();

                if (subheadMainHeadID != request.MainHeadID)
                {
                    throw new ArgumentException(
                        "The selected subhead does not belong to the selected main head.");
                }

                if (!subheadIsActive)
                {
                    throw new InvalidOperationException(
                        "The selected subhead is inactive.");
                }
            }


            // ----------------------------------------------------
            // 4. Validate COA
            // ----------------------------------------------------

            if (request.COAID != null)
            {
                const string coaSql = """
                    SELECT
                        SubheadID,
                        IsActive
                    FROM GS.ChartOfAccounts
                    WHERE COAID = @COAID;
                    """;

                await using var coaCommand =
                    new SqlCommand(
                        coaSql,
                        connection,
                        (SqlTransaction)transaction);

                coaCommand.Parameters.Add(
                    "@COAID",
                    System.Data.SqlDbType.BigInt)
                    .Value = request.COAID.Value;

                await using var coaReader =
                    await coaCommand.ExecuteReaderAsync();

                if (!await coaReader.ReadAsync())
                {
                    await coaReader.DisposeAsync();

                    throw new KeyNotFoundException(
                        "Chart of account was not found.");
                }

                var coaSubheadID =
                    coaReader.GetInt32(
                        coaReader.GetOrdinal(
                            "SubheadID"));

                var coaIsActive =
                    coaReader.GetBoolean(
                        coaReader.GetOrdinal(
                            "IsActive"));

                await coaReader.DisposeAsync();

                if (coaSubheadID != request.SubheadID)
                {
                    throw new ArgumentException(
                        "The selected chart of account does not belong to the selected subhead.");
                }

                if (!coaIsActive)
                {
                    throw new InvalidOperationException(
                        "The selected chart of account is inactive.");
                }
            }


            // ----------------------------------------------------
            // 5. Duplicate protection
            // ----------------------------------------------------

            const string duplicateSql = """
                SELECT COUNT(1)
                FROM GS.TransactionComponentRules
                WHERE
                    TransactionComponentID =
                    @TransactionComponentID

                    AND EntrySide =
                    @EntrySide

                    AND SequenceNo =
                    @SequenceNo

                    AND TransactionComponentRuleID <>
                    @TransactionComponentRuleID;
                """;

            await using var duplicateCommand =
                new SqlCommand(
                    duplicateSql,
                    connection,
                    (SqlTransaction)transaction);

            duplicateCommand.Parameters.Add(
                "@TransactionComponentID",
                System.Data.SqlDbType.Int)
                .Value = transactionComponentID;

            duplicateCommand.Parameters.Add(
                "@EntrySide",
                System.Data.SqlDbType.Char, 1)
                .Value = entrySide;

            duplicateCommand.Parameters.Add(
                "@SequenceNo",
                System.Data.SqlDbType.Int)
                .Value = request.SequenceNo;

            duplicateCommand.Parameters.Add(
                "@TransactionComponentRuleID",
                System.Data.SqlDbType.Int)
                .Value = transactionComponentRuleId;

            var duplicateCount =
                Convert.ToInt32(
                    await duplicateCommand.ExecuteScalarAsync());

            if (duplicateCount > 0)
            {
                throw new InvalidOperationException(
                    "A transaction component rule with the same TransactionComponentID, EntrySide, and SequenceNo already exists.");
            }


            // ----------------------------------------------------
            // 6. Update
            // ----------------------------------------------------

            const string updateSql = """
                UPDATE GS.TransactionComponentRules
                SET
                    EntrySide = @EntrySide,
                    MainHeadID = @MainHeadID,
                    SubheadID = @SubheadID,
                    COAID = @COAID,
                    IsRequired = @IsRequired,
                    SequenceNo = @SequenceNo,
                    UpdatedAt = SYSDATETIME()
                WHERE
                    TransactionComponentRuleID =
                    @TransactionComponentRuleID;
                """;

            await using var updateCommand =
                new SqlCommand(
                    updateSql,
                    connection,
                    (SqlTransaction)transaction);

            updateCommand.Parameters.Add(
                "@EntrySide",
                System.Data.SqlDbType.Char, 1)
                .Value = entrySide;

            updateCommand.Parameters.Add(
                "@MainHeadID",
                System.Data.SqlDbType.Int)
                .Value = request.MainHeadID;

            updateCommand.Parameters.Add(
                "@SubheadID",
                System.Data.SqlDbType.Int)
                .Value = request.SubheadID.HasValue
                    ? request.SubheadID.Value
                    : DBNull.Value;

            updateCommand.Parameters.Add(
                "@COAID",
                System.Data.SqlDbType.BigInt)
                .Value = request.COAID.HasValue
                    ? request.COAID.Value
                    : DBNull.Value;

            updateCommand.Parameters.Add(
                "@IsRequired",
                System.Data.SqlDbType.Bit)
                .Value = request.IsRequired;

            updateCommand.Parameters.Add(
                "@SequenceNo",
                System.Data.SqlDbType.Int)
                .Value = request.SequenceNo;

            updateCommand.Parameters.Add(
                "@TransactionComponentRuleID",
                System.Data.SqlDbType.Int)
                .Value = transactionComponentRuleId;

            var rowsAffected =
                await updateCommand.ExecuteNonQueryAsync();

            if (rowsAffected == 0)
            {
                throw new KeyNotFoundException(
                    "Transaction component rule was not found.");
            }

            await transaction.CommitAsync();

            var updatedRule =
                await GetTransactionComponentRuleAsync(
                    transactionComponentRuleId);

            if (updatedRule == null)
            {
                throw new InvalidOperationException(
                    "The rule was updated but could not be retrieved.");
            }

            return updatedRule;
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }


    // ============================================================
    // RESPONSE MAPPER
    // ============================================================

    private static TransactionComponentRuleResponse
        MapResponse(SqlDataReader reader)
    {
        return new TransactionComponentRuleResponse
        {
            TransactionComponentRuleID =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "TransactionComponentRuleID")),

            TransactionComponentID =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "TransactionComponentID")),

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

            ComponentCode =
                reader.GetString(
                    reader.GetOrdinal(
                        "ComponentCode")),

            ComponentName =
                reader.GetString(
                    reader.GetOrdinal(
                        "ComponentName")),

            ComponentIsRequired =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "ComponentIsRequired")),

            ComponentIsActive =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "ComponentIsActive")),

            EntrySide =
                reader.GetString(
                    reader.GetOrdinal(
                        "EntrySide")).Trim(),

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

            SubheadID =
                reader.IsDBNull(
                    reader.GetOrdinal(
                        "SubheadID"))
                    ? null
                    : reader.GetInt32(
                        reader.GetOrdinal(
                            "SubheadID")),

            SubheadCode =
                reader.IsDBNull(
                    reader.GetOrdinal(
                        "SubheadCode"))
                    ? null
                    : reader.GetInt32(
                        reader.GetOrdinal(
                            "SubheadCode")),

            SubheadName =
                reader.IsDBNull(
                    reader.GetOrdinal(
                        "SubheadName"))
                    ? null
                    : reader.GetString(
                        reader.GetOrdinal(
                            "SubheadName")),

            COAID =
                reader.IsDBNull(
                    reader.GetOrdinal(
                        "COAID"))
                    ? null
                    : reader.GetInt64(
                        reader.GetOrdinal(
                            "COAID")),

            COACode =
                reader.IsDBNull(
                    reader.GetOrdinal(
                        "COACode"))
                    ? null
                    : reader.GetString(
                        reader.GetOrdinal(
                            "COACode")),

            COAName =
                reader.IsDBNull(
                    reader.GetOrdinal(
                        "COAName"))
                    ? null
                    : reader.GetString(
                        reader.GetOrdinal(
                            "COAName")),

            IsRequired =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "IsRequired")),

            SequenceNo =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "SequenceNo")),

            CreatedAt =
                reader.GetDateTime(
                    reader.GetOrdinal(
                        "CreatedAt")),

            UpdatedAt =
                reader.IsDBNull(
                    reader.GetOrdinal(
                        "UpdatedAt"))
                    ? null
                    : reader.GetDateTime(
                        reader.GetOrdinal(
                            "UpdatedAt"))
        };
    }
}