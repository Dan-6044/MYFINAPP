using Microsoft.Data.SqlClient;
using MYFIN.API.Data;
using MYFIN.API.DTOs.Masters;
using System.Data;

namespace MYFIN.API.Services;

public class MasterDataService : IMasterDataService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public MasterDataService(
        SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<AccountResponse>> GetAccountsAsync(
        bool? isActive = null)
    {
        const string sql = """
            SELECT
                coa.COAID,
                coa.COACode,
                coa.COAName,
                coa.SubheadID,
                sh.SubheadCode,
                sh.SubheadName,
                mh.MainHeadID,
                mh.MainHeadCode,
                mh.MainHeadName,
                coa.CurrencyID,
                c.CurrencyCode,
                c.CurrencyName,
                c.CurrencySymbol,
                c.DecimalPlaces,
                coa.Description,
                coa.IsControlAccount,
                coa.AllowDirectPosting,
                coa.IsActive,
                coa.OpeningBalance,
                coa.CreatedAt,
                coa.UpdatedAt
            FROM GS.ChartOfAccounts coa
            INNER JOIN GS.Subheads sh
                ON sh.SubheadID = coa.SubheadID
            INNER JOIN GS.MainHeads mh
                ON mh.MainHeadID = sh.MainHeadID
            LEFT JOIN GS.Currencies c
                ON c.CurrencyID = coa.CurrencyID
            WHERE
                (@IsActive IS NULL OR coa.IsActive = @IsActive)
            ORDER BY
                coa.COACode,
                coa.COAID;
            """;

        var accounts = new List<AccountResponse>();

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@IsActive", SqlDbType.Bit)
            {
                Value = isActive.HasValue
                    ? isActive.Value
                    : DBNull.Value
            });

        await using var reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            accounts.Add(MapAccount(reader));
        }

        return accounts;
    }

    public async Task<AccountResponse?> GetAccountAsync(
        long coaId)
    {
        const string sql = """
            SELECT
                coa.COAID,
                coa.COACode,
                coa.COAName,
                coa.SubheadID,
                sh.SubheadCode,
                sh.SubheadName,
                mh.MainHeadID,
                mh.MainHeadCode,
                mh.MainHeadName,
                coa.CurrencyID,
                c.CurrencyCode,
                c.CurrencyName,
                c.CurrencySymbol,
                c.DecimalPlaces,
                coa.Description,
                coa.IsControlAccount,
                coa.AllowDirectPosting,
                coa.IsActive,
                coa.OpeningBalance,
                coa.CreatedAt,
                coa.UpdatedAt
            FROM GS.ChartOfAccounts coa
            INNER JOIN GS.Subheads sh
                ON sh.SubheadID = coa.SubheadID
            INNER JOIN GS.MainHeads mh
                ON mh.MainHeadID = sh.MainHeadID
            LEFT JOIN GS.Currencies c
                ON c.CurrencyID = coa.CurrencyID
            WHERE coa.COAID = @COAID;
            """;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@COAID", SqlDbType.BigInt)
            {
                Value = coaId
            });

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        return MapAccount(reader);
    }

    public async Task<AccountResponse> CreateAccountAsync(
        CreateAccountRequest request)
    {
        ValidateAccountRequest(request.COACode, request.COAName);

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await ValidateSubheadAsync(
            connection,
            request.SubheadID);

        if (request.CurrencyID.HasValue)
        {
            await ValidateCurrencyAsync(
                connection,
                request.CurrencyID.Value);
        }

        await EnsureCodeIsAvailableAsync(
            connection,
            request.COACode,
            null);

        const string sql = """
            INSERT INTO GS.ChartOfAccounts
            (
                COACode,
                COAName,
                SubheadID,
                CurrencyID,
                Description,
                IsControlAccount,
                AllowDirectPosting,
                IsActive,
                OpeningBalance
            )
            OUTPUT INSERTED.COAID
            VALUES
            (
                @COACode,
                @COAName,
                @SubheadID,
                @CurrencyID,
                @Description,
                @IsControlAccount,
                @AllowDirectPosting,
                1,
                @OpeningBalance
            );
            """;

        await using var command =
            new SqlCommand(sql, connection);

        AddAccountParameters(
            command,
            request.COACode,
            request.COAName,
            request.SubheadID,
            request.CurrencyID,
            request.Description,
            request.IsControlAccount,
            request.AllowDirectPosting,
            request.OpeningBalance);

        var result =
            await command.ExecuteScalarAsync();

        var coaId =
            Convert.ToInt64(result);

        var account =
            await GetAccountAsync(coaId);

        if (account == null)
        {
            throw new InvalidOperationException(
                "The account was created but could not be retrieved.");
        }

        return account;
    }

    public async Task<AccountResponse> UpdateAccountAsync(
        long coaId,
        UpdateAccountRequest request)
    {
        ValidateAccountRequest(request.COACode, request.COAName);

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await EnsureAccountExistsAsync(
            connection,
            coaId);

        await ValidateSubheadAsync(
            connection,
            request.SubheadID);

        if (request.CurrencyID.HasValue)
        {
            await ValidateCurrencyAsync(
                connection,
                request.CurrencyID.Value);
        }

        await EnsureCodeIsAvailableAsync(
            connection,
            request.COACode,
            coaId);

        const string sql = """
            UPDATE GS.ChartOfAccounts
            SET
                COACode = @COACode,
                COAName = @COAName,
                SubheadID = @SubheadID,
                CurrencyID = @CurrencyID,
                Description = @Description,
                IsControlAccount = @IsControlAccount,
                AllowDirectPosting = @AllowDirectPosting,
                OpeningBalance = @OpeningBalance,
                UpdatedAt = SYSDATETIME()
            WHERE COAID = @COAID;
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@COAID", SqlDbType.BigInt)
            {
                Value = coaId
            });

        AddAccountParameters(
            command,
            request.COACode,
            request.COAName,
            request.SubheadID,
            request.CurrencyID,
            request.Description,
            request.IsControlAccount,
            request.AllowDirectPosting,
            request.OpeningBalance);

        await command.ExecuteNonQueryAsync();

        var account =
            await GetAccountAsync(coaId);

        if (account == null)
        {
            throw new InvalidOperationException(
                "The account was updated but could not be retrieved.");
        }

        return account;
    }

    public async Task<AccountResponse> SetAccountActiveStatusAsync(
        long coaId,
        bool isActive)
    {
        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await EnsureAccountExistsAsync(
            connection,
            coaId);

        const string sql = """
            UPDATE GS.ChartOfAccounts
            SET
                IsActive = @IsActive,
                UpdatedAt = SYSDATETIME()
            WHERE COAID = @COAID;
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@COAID", SqlDbType.BigInt)
            {
                Value = coaId
            });

        command.Parameters.Add(
            new SqlParameter("@IsActive", SqlDbType.Bit)
            {
                Value = isActive
            });

        await command.ExecuteNonQueryAsync();

        var account =
            await GetAccountAsync(coaId);

        if (account == null)
        {
            throw new InvalidOperationException(
                "The account status was changed but the account could not be retrieved.");
        }

        return account;
    }

    private static void ValidateAccountRequest(
        string coaCode,
        string coaName)
    {
        if (string.IsNullOrWhiteSpace(coaCode))
        {
            throw new ArgumentException(
                "COACode is required.");
        }

        if (coaCode.Trim().Length > 30)
        {
            throw new ArgumentException(
                "COACode cannot exceed 30 characters.");
        }

        if (string.IsNullOrWhiteSpace(coaName))
        {
            throw new ArgumentException(
                "COAName is required.");
        }

        if (coaName.Trim().Length > 150)
        {
            throw new ArgumentException(
                "COAName cannot exceed 150 characters.");
        }
    }

    private static async Task ValidateSubheadAsync(
        SqlConnection connection,
        int subheadId)
    {
        const string sql = """
            SELECT IsActive
            FROM GS.Subheads
            WHERE SubheadID = @SubheadID;
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@SubheadID", SqlDbType.Int)
            {
                Value = subheadId
            });

        var result =
            await command.ExecuteScalarAsync();

        if (result == null)
        {
            throw new KeyNotFoundException(
                $"Subhead {subheadId} was not found.");
        }

        if (!Convert.ToBoolean(result))
        {
            throw new InvalidOperationException(
                $"Subhead {subheadId} is inactive.");
        }
    }

    private static async Task ValidateCurrencyAsync(
        SqlConnection connection,
        int currencyId)
    {
        const string sql = """
            SELECT IsActive
            FROM GS.Currencies
            WHERE CurrencyID = @CurrencyID;
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@CurrencyID", SqlDbType.Int)
            {
                Value = currencyId
            });

        var result =
            await command.ExecuteScalarAsync();

        if (result == null)
        {
            throw new KeyNotFoundException(
                $"Currency {currencyId} was not found.");
        }

        if (!Convert.ToBoolean(result))
        {
            throw new InvalidOperationException(
                $"Currency {currencyId} is inactive.");
        }
    }

    private static async Task EnsureCodeIsAvailableAsync(
        SqlConnection connection,
        string coaCode,
        long? currentCoaId)
    {
        const string sql = """
            SELECT TOP (1) COAID
            FROM GS.ChartOfAccounts
            WHERE COACode = @COACode
              AND (@CurrentCOAID IS NULL OR COAID <> @CurrentCOAID);
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@COACode", SqlDbType.VarChar, 30)
            {
                Value = coaCode.Trim()
            });

        command.Parameters.Add(
            new SqlParameter("@CurrentCOAID", SqlDbType.BigInt)
            {
                Value = currentCoaId.HasValue
                    ? currentCoaId.Value
                    : DBNull.Value
            });

        var result =
            await command.ExecuteScalarAsync();

        if (result != null)
        {
            throw new InvalidOperationException(
                $"COACode '{coaCode.Trim()}' already exists.");
        }
    }

    private static async Task EnsureAccountExistsAsync(
        SqlConnection connection,
        long coaId)
    {
        const string sql = """
            SELECT 1
            FROM GS.ChartOfAccounts
            WHERE COAID = @COAID;
            """;

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@COAID", SqlDbType.BigInt)
            {
                Value = coaId
            });

        var result =
            await command.ExecuteScalarAsync();

        if (result == null)
        {
            throw new KeyNotFoundException(
                $"Account {coaId} was not found.");
        }
    }

    private static void AddAccountParameters(
        SqlCommand command,
        string coaCode,
        string coaName,
        int subheadId,
        int? currencyId,
        string? description,
        bool isControlAccount,
        bool allowDirectPosting,
        decimal openingBalance)
    {
        command.Parameters.Add(
            new SqlParameter("@COACode", SqlDbType.VarChar, 30)
            {
                Value = coaCode.Trim()
            });

        command.Parameters.Add(
            new SqlParameter("@COAName", SqlDbType.VarChar, 150)
            {
                Value = coaName.Trim()
            });

        command.Parameters.Add(
            new SqlParameter("@SubheadID", SqlDbType.Int)
            {
                Value = subheadId
            });

        command.Parameters.Add(
            new SqlParameter("@CurrencyID", SqlDbType.Int)
            {
                Value = currencyId.HasValue
                    ? currencyId.Value
                    : DBNull.Value
            });

        command.Parameters.Add(
            new SqlParameter("@Description", SqlDbType.VarChar, 500)
            {
                Value = string.IsNullOrWhiteSpace(description)
                    ? DBNull.Value
                    : description.Trim()
            });

        command.Parameters.Add(
            new SqlParameter("@IsControlAccount", SqlDbType.Bit)
            {
                Value = isControlAccount
            });

        command.Parameters.Add(
            new SqlParameter("@AllowDirectPosting", SqlDbType.Bit)
            {
                Value = allowDirectPosting
            });

        command.Parameters.Add(
            new SqlParameter("@OpeningBalance", SqlDbType.Decimal)
            {
                Precision = 19,
                Scale = 4,
                Value = openingBalance
            });
    }

    private static AccountResponse MapAccount(
        SqlDataReader reader)
    {
        var currencyIdOrdinal =
            reader.GetOrdinal("CurrencyID");

        var currency =
            reader.IsDBNull(currencyIdOrdinal)
                ? null
                : new CurrencyInfo
                {
                    CurrencyID =
                        reader.GetInt32(currencyIdOrdinal),

                    CurrencyCode =
                        reader.GetString(
                            reader.GetOrdinal("CurrencyCode")),

                    CurrencyName =
                        reader.GetString(
                            reader.GetOrdinal("CurrencyName")),

                    CurrencySymbol =
                        reader.IsDBNull(
                            reader.GetOrdinal("CurrencySymbol"))
                            ? null
                            : reader.GetString(
                                reader.GetOrdinal("CurrencySymbol")),

                    DecimalPlaces =
                        reader.GetByte(
                            reader.GetOrdinal("DecimalPlaces"))
                };

        return new AccountResponse
        {
            COAID =
                reader.GetInt64(
                    reader.GetOrdinal("COAID")),

            COACode =
                reader.GetString(
                    reader.GetOrdinal("COACode")),

            COAName =
                reader.GetString(
                    reader.GetOrdinal("COAName")),

            Subhead = new SubheadInfo
            {
                SubheadID =
                    reader.GetInt32(
                        reader.GetOrdinal("SubheadID")),

                SubheadCode =
                    reader.GetInt32(
                        reader.GetOrdinal("SubheadCode")),

                SubheadName =
                    reader.GetString(
                        reader.GetOrdinal("SubheadName"))
            },

            MainHead = new MainHeadInfo
            {
                MainHeadID =
                    reader.GetInt32(
                        reader.GetOrdinal("MainHeadID")),

                MainHeadCode =
                    reader.GetInt32(
                        reader.GetOrdinal("MainHeadCode")),

                MainHeadName =
                    reader.GetString(
                        reader.GetOrdinal("MainHeadName")),
            },

            Currency = currency,

            Description =
                reader.IsDBNull(
                    reader.GetOrdinal("Description"))
                    ? null
                    : reader.GetString(
                        reader.GetOrdinal("Description")),

            IsControlAccount =
                reader.GetBoolean(
                    reader.GetOrdinal("IsControlAccount")),

            AllowDirectPosting =
                reader.GetBoolean(
                    reader.GetOrdinal("AllowDirectPosting")),

            IsActive =
                reader.GetBoolean(
                    reader.GetOrdinal("IsActive")),

            OpeningBalance =
                reader.GetDecimal(
                    reader.GetOrdinal("OpeningBalance")),

            CreatedAt =
                reader.GetDateTime(
                    reader.GetOrdinal("CreatedAt")),

            UpdatedAt =
                reader.IsDBNull(
                    reader.GetOrdinal("UpdatedAt"))
                    ? null
                    : reader.GetDateTime(
                        reader.GetOrdinal("UpdatedAt"))
        };
    }

    public async Task<IReadOnlyList<MainHeadResponse>> GetMainHeadsAsync(
    bool? isActive = null)
{
    const string sql = """
        SELECT
            mh.MainHeadID,
            mh.MainHeadCode,
            mh.MainHeadName,
            mh.AccountingType,
            mh.NormalBalance,
            mh.IsActive,
            mh.CreatedAt,
            mh.UpdatedAt,
            COUNT(DISTINCT s.SubheadID) AS SubheadCount,
            COUNT(DISTINCT ttr.TransactionTypeRuleID) AS TransactionTypeRuleCount
        FROM GS.MainHeads mh
        LEFT JOIN GS.Subheads s
            ON s.MainHeadID = mh.MainHeadID
        LEFT JOIN GS.TransactionTypeRules ttr
            ON ttr.MainHeadID = mh.MainHeadID
        WHERE (@IsActive IS NULL OR mh.IsActive = @IsActive)
        GROUP BY
            mh.MainHeadID,
            mh.MainHeadCode,
            mh.MainHeadName,
            mh.AccountingType,
            mh.NormalBalance,
            mh.IsActive,
            mh.CreatedAt,
            mh.UpdatedAt
        ORDER BY
            mh.MainHeadCode,
            mh.MainHeadID;
        """;

    await using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    await using var command = new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@IsActive", SqlDbType.Bit)
        {
            Value = isActive.HasValue
                ? isActive.Value
                : DBNull.Value
        });

    var results = new List<MainHeadResponse>();

    await using var reader = await command.ExecuteReaderAsync();

    while (await reader.ReadAsync())
    {
        results.Add(MapMainHead(reader));
    }

    return results;
}


public async Task<MainHeadResponse?> GetMainHeadAsync(
    int mainHeadId)
{
    const string sql = """
        SELECT
            mh.MainHeadID,
            mh.MainHeadCode,
            mh.MainHeadName,
            mh.AccountingType,
            mh.NormalBalance,
            mh.IsActive,
            mh.CreatedAt,
            mh.UpdatedAt,
            COUNT(DISTINCT s.SubheadID) AS SubheadCount,
            COUNT(DISTINCT ttr.TransactionTypeRuleID) AS TransactionTypeRuleCount
        FROM GS.MainHeads mh
        LEFT JOIN GS.Subheads s
            ON s.MainHeadID = mh.MainHeadID
        LEFT JOIN GS.TransactionTypeRules ttr
            ON ttr.MainHeadID = mh.MainHeadID
        WHERE mh.MainHeadID = @MainHeadID
        GROUP BY
            mh.MainHeadID,
            mh.MainHeadCode,
            mh.MainHeadName,
            mh.AccountingType,
            mh.NormalBalance,
            mh.IsActive,
            mh.CreatedAt,
            mh.UpdatedAt;
        """;

    await using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    await using var command = new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@MainHeadID", SqlDbType.Int)
        {
            Value = mainHeadId
        });

    await using var reader = await command.ExecuteReaderAsync();

    if (!await reader.ReadAsync())
    {
        return null;
    }

    return MapMainHead(reader);
}


public async Task<MainHeadResponse> CreateMainHeadAsync(
    CreateMainHeadRequest request)
{
    var accountingType = request.AccountingType.Trim().ToUpperInvariant();
    var normalBalance = request.NormalBalance.Trim().ToUpperInvariant();
    var mainHeadName = request.MainHeadName.Trim();

    ValidateMainHeadValues(accountingType, normalBalance);

    await using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    const string duplicateCodeSql = """
        SELECT COUNT(1)
        FROM GS.MainHeads
        WHERE MainHeadCode = @MainHeadCode;
        """;

    await using (var command = new SqlCommand(
        duplicateCodeSql,
        connection))
    {
        command.Parameters.Add(
            new SqlParameter("@MainHeadCode", SqlDbType.Int)
            {
                Value = request.MainHeadCode
            });

        var exists = Convert.ToInt32(
            await command.ExecuteScalarAsync());

        if (exists > 0)
        {
            throw new InvalidOperationException(
                $"MainHeadCode '{request.MainHeadCode}' already exists.");
        }
    }

    const string duplicateNameSql = """
        SELECT COUNT(1)
        FROM GS.MainHeads
        WHERE MainHeadName = @MainHeadName;
        """;

    await using (var command = new SqlCommand(
        duplicateNameSql,
        connection))
    {
        command.Parameters.Add(
            new SqlParameter("@MainHeadName", SqlDbType.VarChar, 100)
            {
                Value = mainHeadName
            });

        var exists = Convert.ToInt32(
            await command.ExecuteScalarAsync());

        if (exists > 0)
        {
            throw new InvalidOperationException(
                $"MainHeadName '{mainHeadName}' already exists.");
        }
    }

    const string insertSql = """
        INSERT INTO GS.MainHeads
        (
            MainHeadCode,
            MainHeadName,
            AccountingType,
            NormalBalance,
            IsActive,
            CreatedAt
        )
        VALUES
        (
            @MainHeadCode,
            @MainHeadName,
            @AccountingType,
            @NormalBalance,
            1,
            SYSDATETIME()
        );

        SELECT CAST(SCOPE_IDENTITY() AS int);
        """;

    int mainHeadId;

    await using (var command = new SqlCommand(
        insertSql,
        connection))
    {
        command.Parameters.Add(
            new SqlParameter("@MainHeadCode", SqlDbType.Int)
            {
                Value = request.MainHeadCode
            });

        command.Parameters.Add(
            new SqlParameter("@MainHeadName", SqlDbType.VarChar, 100)
            {
                Value = mainHeadName
            });

        command.Parameters.Add(
            new SqlParameter("@AccountingType", SqlDbType.VarChar, 20)
            {
                Value = accountingType
            });

        command.Parameters.Add(
            new SqlParameter("@NormalBalance", SqlDbType.Char, 1)
            {
                Value = normalBalance
            });

        mainHeadId = Convert.ToInt32(
            await command.ExecuteScalarAsync());
    }

    var created = await GetMainHeadAsync(mainHeadId);

    if (created is null)
    {
        throw new InvalidOperationException(
            "Main Head was created but could not be retrieved.");
    }

    return created;
}


public async Task<MainHeadResponse> UpdateMainHeadAsync(
    int mainHeadId,
    UpdateMainHeadRequest request)
{
    var accountingType = request.AccountingType.Trim().ToUpperInvariant();
    var normalBalance = request.NormalBalance.Trim().ToUpperInvariant();
    var mainHeadName = request.MainHeadName.Trim();

    ValidateMainHeadValues(accountingType, normalBalance);

    await using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    const string existingSql = """
        SELECT MainHeadID
        FROM GS.MainHeads
        WHERE MainHeadID = @MainHeadID;
        """;

    await using (var command = new SqlCommand(
        existingSql,
        connection))
    {
        command.Parameters.Add(
            new SqlParameter("@MainHeadID", SqlDbType.Int)
            {
                Value = mainHeadId
            });

        var exists = await command.ExecuteScalarAsync();

        if (exists is null)
        {
            throw new KeyNotFoundException(
                $"Main Head {mainHeadId} was not found.");
        }
    }

    const string duplicateCodeSql = """
        SELECT COUNT(1)
        FROM GS.MainHeads
        WHERE MainHeadCode = @MainHeadCode
          AND MainHeadID <> @MainHeadID;
        """;

    await using (var command = new SqlCommand(
        duplicateCodeSql,
        connection))
    {
        command.Parameters.Add(
            new SqlParameter("@MainHeadCode", SqlDbType.Int)
            {
                Value = request.MainHeadCode
            });

        command.Parameters.Add(
            new SqlParameter("@MainHeadID", SqlDbType.Int)
            {
                Value = mainHeadId
            });

        var exists = Convert.ToInt32(
            await command.ExecuteScalarAsync());

        if (exists > 0)
        {
            throw new InvalidOperationException(
                $"MainHeadCode '{request.MainHeadCode}' already exists.");
        }
    }

    const string duplicateNameSql = """
        SELECT COUNT(1)
        FROM GS.MainHeads
        WHERE MainHeadName = @MainHeadName
          AND MainHeadID <> @MainHeadID;
        """;

    await using (var command = new SqlCommand(
        duplicateNameSql,
        connection))
    {
        command.Parameters.Add(
            new SqlParameter("@MainHeadName", SqlDbType.VarChar, 100)
            {
                Value = mainHeadName
            });

        command.Parameters.Add(
            new SqlParameter("@MainHeadID", SqlDbType.Int)
            {
                Value = mainHeadId
            });

        var exists = Convert.ToInt32(
            await command.ExecuteScalarAsync());

        if (exists > 0)
        {
            throw new InvalidOperationException(
                $"MainHeadName '{mainHeadName}' already exists.");
        }
    }

    const string updateSql = """
        UPDATE GS.MainHeads
        SET
            MainHeadCode = @MainHeadCode,
            MainHeadName = @MainHeadName,
            AccountingType = @AccountingType,
            NormalBalance = @NormalBalance,
            UpdatedAt = SYSDATETIME()
        WHERE MainHeadID = @MainHeadID;
        """;

    await using (var command = new SqlCommand(
        updateSql,
        connection))
    {
        command.Parameters.Add(
            new SqlParameter("@MainHeadCode", SqlDbType.Int)
            {
                Value = request.MainHeadCode
            });

        command.Parameters.Add(
            new SqlParameter("@MainHeadName", SqlDbType.VarChar, 100)
            {
                Value = mainHeadName
            });

        command.Parameters.Add(
            new SqlParameter("@AccountingType", SqlDbType.VarChar, 20)
            {
                Value = accountingType
            });

        command.Parameters.Add(
            new SqlParameter("@NormalBalance", SqlDbType.Char, 1)
            {
                Value = normalBalance
            });

        command.Parameters.Add(
            new SqlParameter("@MainHeadID", SqlDbType.Int)
            {
                Value = mainHeadId
            });

        await command.ExecuteNonQueryAsync();
    }

    var updated = await GetMainHeadAsync(mainHeadId);

    if (updated is null)
    {
        throw new InvalidOperationException(
            "Main Head was updated but could not be retrieved.");
    }

    return updated;
}


public async Task<MainHeadResponse> SetMainHeadActiveStatusAsync(
    int mainHeadId,
    bool isActive)
{
    await using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    const string sql = """
        UPDATE GS.MainHeads
        SET
            IsActive = @IsActive,
            UpdatedAt = SYSDATETIME()
        WHERE MainHeadID = @MainHeadID;

        SELECT @@ROWCOUNT;
        """;

    await using var command = new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@IsActive", SqlDbType.Bit)
        {
            Value = isActive
        });

    command.Parameters.Add(
        new SqlParameter("@MainHeadID", SqlDbType.Int)
        {
            Value = mainHeadId
        });

    var affected = Convert.ToInt32(
        await command.ExecuteScalarAsync());

    if (affected == 0)
    {
        throw new KeyNotFoundException(
            $"Main Head {mainHeadId} was not found.");
    }

    var result = await GetMainHeadAsync(mainHeadId);

    if (result is null)
    {
        throw new InvalidOperationException(
            "Main Head status was changed but could not be retrieved.");
    }

    return result;
}


private static void ValidateMainHeadValues(
    string accountingType,
    string normalBalance)
{
    var validAccountingTypes = new HashSet<string>(
        StringComparer.OrdinalIgnoreCase)
    {
        "ASSET",
        "LIABILITY",
        "INCOME",
        "EXPENSE",
        "EQUITY"
    };

    if (!validAccountingTypes.Contains(accountingType))
    {
        throw new ArgumentException(
            $"Invalid AccountingType '{accountingType}'. " +
            "Valid values are ASSET, LIABILITY, INCOME, EXPENSE, EQUITY.");
    }

    if (normalBalance is not ("D" or "C"))
    {
        throw new ArgumentException(
            "Invalid NormalBalance. Valid values are D (Debit) or C (Credit).");
    }
}


private static MainHeadResponse MapMainHead(
    SqlDataReader reader)
{
    var normalBalance =
        reader["NormalBalance"]?.ToString()?.Trim() ?? string.Empty;

    return new MainHeadResponse
    {
        MainHeadID = Convert.ToInt32(reader["MainHeadID"]),
        MainHeadCode = Convert.ToInt32(reader["MainHeadCode"]),
        MainHeadName = reader["MainHeadName"].ToString() ?? string.Empty,
        AccountingType = reader["AccountingType"].ToString() ?? string.Empty,
        NormalBalance = normalBalance,
        NormalBalanceName = normalBalance == "D"
            ? "Debit"
            : normalBalance == "C"
                ? "Credit"
                : string.Empty,
        IsActive = Convert.ToBoolean(reader["IsActive"]),
        SubheadCount = Convert.ToInt32(reader["SubheadCount"]),
        TransactionTypeRuleCount =
            Convert.ToInt32(reader["TransactionTypeRuleCount"]),
        CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
        UpdatedAt = reader["UpdatedAt"] == DBNull.Value
            ? null
            : Convert.ToDateTime(reader["UpdatedAt"])
    };
}

public async Task<IReadOnlyList<SubheadResponse>> GetSubheadsAsync(
    bool? isActive = null,
    int? mainHeadId = null)
{
    const string sql = """
        SELECT
            sh.SubheadID,
            sh.SubheadCode,
            sh.SubheadName,
            sh.MainHeadID,
            mh.MainHeadCode,
            mh.MainHeadName,
            mh.AccountingType,
            mh.NormalBalance,
            sh.IsActive,
            sh.CreatedAt,
            sh.UpdatedAt,
            COUNT(DISTINCT coa.COAID) AS AccountCount,
            COUNT(DISTINCT tcr.TransactionComponentRuleID) AS ComponentRuleCount
        FROM GS.Subheads sh
        INNER JOIN GS.MainHeads mh
            ON mh.MainHeadID = sh.MainHeadID
        LEFT JOIN GS.ChartOfAccounts coa
            ON coa.SubheadID = sh.SubheadID
        LEFT JOIN GS.TransactionComponentRules tcr
            ON tcr.SubheadID = sh.SubheadID
        WHERE
            (@IsActive IS NULL OR sh.IsActive = @IsActive)
            AND (@MainHeadID IS NULL OR sh.MainHeadID = @MainHeadID)
        GROUP BY
            sh.SubheadID,
            sh.SubheadCode,
            sh.SubheadName,
            sh.MainHeadID,
            mh.MainHeadCode,
            mh.MainHeadName,
            mh.AccountingType,
            mh.NormalBalance,
            sh.IsActive,
            sh.CreatedAt,
            sh.UpdatedAt
        ORDER BY
            sh.SubheadCode,
            sh.SubheadID;
        """;

    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@IsActive", SqlDbType.Bit)
        {
            Value = isActive.HasValue
                ? isActive.Value
                : DBNull.Value
        });

    command.Parameters.Add(
        new SqlParameter("@MainHeadID", SqlDbType.Int)
        {
            Value = mainHeadId.HasValue
                ? mainHeadId.Value
                : DBNull.Value
        });

    var results = new List<SubheadResponse>();

    await using var reader =
        await command.ExecuteReaderAsync();

    while (await reader.ReadAsync())
    {
        results.Add(MapSubhead(reader));
    }

    return results;
}


public async Task<SubheadResponse?> GetSubheadAsync(
    int subheadId)
{
    const string sql = """
        SELECT
            sh.SubheadID,
            sh.SubheadCode,
            sh.SubheadName,
            sh.MainHeadID,
            mh.MainHeadCode,
            mh.MainHeadName,
            mh.AccountingType,
            mh.NormalBalance,
            sh.IsActive,
            sh.CreatedAt,
            sh.UpdatedAt,
            COUNT(DISTINCT coa.COAID) AS AccountCount,
            COUNT(DISTINCT tcr.TransactionComponentRuleID) AS ComponentRuleCount
        FROM GS.Subheads sh
        INNER JOIN GS.MainHeads mh
            ON mh.MainHeadID = sh.MainHeadID
        LEFT JOIN GS.ChartOfAccounts coa
            ON coa.SubheadID = sh.SubheadID
        LEFT JOIN GS.TransactionComponentRules tcr
            ON tcr.SubheadID = sh.SubheadID
        WHERE sh.SubheadID = @SubheadID
        GROUP BY
            sh.SubheadID,
            sh.SubheadCode,
            sh.SubheadName,
            sh.MainHeadID,
            mh.MainHeadCode,
            mh.MainHeadName,
            mh.AccountingType,
            mh.NormalBalance,
            sh.IsActive,
            sh.CreatedAt,
            sh.UpdatedAt;
        """;

    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@SubheadID", SqlDbType.Int)
        {
            Value = subheadId
        });

    await using var reader =
        await command.ExecuteReaderAsync();

    if (!await reader.ReadAsync())
    {
        return null;
    }

    return MapSubhead(reader);
}


public async Task<SubheadResponse> CreateSubheadAsync(
    CreateSubheadRequest request)
{
    ValidateSubheadRequest(
        request.SubheadCode,
        request.SubheadName);

    var subheadName =
        request.SubheadName.Trim();

    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    await ValidateMainHeadForSubheadAsync(
        connection,
        request.MainHeadID);

    await EnsureSubheadCodeIsAvailableAsync(
        connection,
        request.SubheadCode,
        null);

    await EnsureSubheadNameIsAvailableAsync(
        connection,
        request.MainHeadID,
        subheadName,
        null);

    const string sql = """
        INSERT INTO GS.Subheads
        (
            SubheadCode,
            SubheadName,
            MainHeadID,
            IsActive,
            CreatedAt
        )
        OUTPUT INSERTED.SubheadID
        VALUES
        (
            @SubheadCode,
            @SubheadName,
            @MainHeadID,
            1,
            SYSDATETIME()
        );
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@SubheadCode", SqlDbType.Int)
        {
            Value = request.SubheadCode
        });

    command.Parameters.Add(
        new SqlParameter("@SubheadName", SqlDbType.VarChar, 100)
        {
            Value = subheadName
        });

    command.Parameters.Add(
        new SqlParameter("@MainHeadID", SqlDbType.Int)
        {
            Value = request.MainHeadID
        });

    var result =
        await command.ExecuteScalarAsync();

    var subheadId =
        Convert.ToInt32(result);

    var created =
        await GetSubheadAsync(subheadId);

    if (created is null)
    {
        throw new InvalidOperationException(
            "Subhead was created but could not be retrieved.");
    }

    return created;
}


public async Task<SubheadResponse> UpdateSubheadAsync(
    int subheadId,
    UpdateSubheadRequest request)
{
    ValidateSubheadRequest(
        request.SubheadCode,
        request.SubheadName);

    var subheadName =
        request.SubheadName.Trim();

    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    await EnsureSubheadExistsAsync(
        connection,
        subheadId);

    await ValidateMainHeadForSubheadAsync(
        connection,
        request.MainHeadID);

    await EnsureSubheadCodeIsAvailableAsync(
        connection,
        request.SubheadCode,
        subheadId);

    await EnsureSubheadNameIsAvailableAsync(
        connection,
        request.MainHeadID,
        subheadName,
        subheadId);

    const string sql = """
        UPDATE GS.Subheads
        SET
            SubheadCode = @SubheadCode,
            SubheadName = @SubheadName,
            MainHeadID = @MainHeadID,
            UpdatedAt = SYSDATETIME()
        WHERE SubheadID = @SubheadID;
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@SubheadCode", SqlDbType.Int)
        {
            Value = request.SubheadCode
        });

    command.Parameters.Add(
        new SqlParameter("@SubheadName", SqlDbType.VarChar, 100)
        {
            Value = subheadName
        });

    command.Parameters.Add(
        new SqlParameter("@MainHeadID", SqlDbType.Int)
        {
            Value = request.MainHeadID
        });

    command.Parameters.Add(
        new SqlParameter("@SubheadID", SqlDbType.Int)
        {
            Value = subheadId
        });

    await command.ExecuteNonQueryAsync();

    var updated =
        await GetSubheadAsync(subheadId);

    if (updated is null)
    {
        throw new InvalidOperationException(
            "Subhead was updated but could not be retrieved.");
    }

    return updated;
}


public async Task<SubheadResponse> SetSubheadActiveStatusAsync(
    int subheadId,
    bool isActive)
{
    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    await EnsureSubheadExistsAsync(
        connection,
        subheadId);

    const string sql = """
        UPDATE GS.Subheads
        SET
            IsActive = @IsActive,
            UpdatedAt = SYSDATETIME()
        WHERE SubheadID = @SubheadID;
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@IsActive", SqlDbType.Bit)
        {
            Value = isActive
        });

    command.Parameters.Add(
        new SqlParameter("@SubheadID", SqlDbType.Int)
        {
            Value = subheadId
        });

    await command.ExecuteNonQueryAsync();

    var result =
        await GetSubheadAsync(subheadId);

    if (result is null)
    {
        throw new InvalidOperationException(
            "Subhead status was changed but the subhead could not be retrieved.");
    }

    return result;
}

private static void ValidateSubheadRequest(
    int subheadCode,
    string subheadName)
{
    if (subheadCode <= 0)
    {
        throw new ArgumentException(
            "SubheadCode must be greater than zero.");
    }

    if (string.IsNullOrWhiteSpace(subheadName))
    {
        throw new ArgumentException(
            "SubheadName is required.");
    }

    if (subheadName.Trim().Length > 100)
    {
        throw new ArgumentException(
            "SubheadName cannot exceed 100 characters.");
    }
}


private static async Task ValidateMainHeadForSubheadAsync(
    SqlConnection connection,
    int mainHeadId)
{
    const string sql = """
        SELECT IsActive
        FROM GS.MainHeads
        WHERE MainHeadID = @MainHeadID;
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@MainHeadID", SqlDbType.Int)
        {
            Value = mainHeadId
        });

    var result =
        await command.ExecuteScalarAsync();

    if (result is null)
    {
        throw new KeyNotFoundException(
            $"Main Head {mainHeadId} was not found.");
    }

    if (!Convert.ToBoolean(result))
    {
        throw new InvalidOperationException(
            $"Main Head {mainHeadId} is inactive.");
    }
}


private static async Task EnsureSubheadCodeIsAvailableAsync(
    SqlConnection connection,
    int subheadCode,
    int? currentSubheadId)
{
    const string sql = """
        SELECT TOP (1) SubheadID
        FROM GS.Subheads
        WHERE SubheadCode = @SubheadCode
          AND (
                @CurrentSubheadID IS NULL
                OR SubheadID <> @CurrentSubheadID
              );
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@SubheadCode", SqlDbType.Int)
        {
            Value = subheadCode
        });

    command.Parameters.Add(
        new SqlParameter("@CurrentSubheadID", SqlDbType.Int)
        {
            Value = currentSubheadId.HasValue
                ? currentSubheadId.Value
                : DBNull.Value
        });

    var result =
        await command.ExecuteScalarAsync();

    if (result != null)
    {
        throw new InvalidOperationException(
            $"SubheadCode '{subheadCode}' already exists.");
    }
}


private static async Task EnsureSubheadNameIsAvailableAsync(
    SqlConnection connection,
    int mainHeadId,
    string subheadName,
    int? currentSubheadId)
{
    const string sql = """
        SELECT TOP (1) SubheadID
        FROM GS.Subheads
        WHERE MainHeadID = @MainHeadID
          AND SubheadName = @SubheadName
          AND (
                @CurrentSubheadID IS NULL
                OR SubheadID <> @CurrentSubheadID
              );
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@MainHeadID", SqlDbType.Int)
        {
            Value = mainHeadId
        });

    command.Parameters.Add(
        new SqlParameter("@SubheadName", SqlDbType.VarChar, 100)
        {
            Value = subheadName
        });

    command.Parameters.Add(
        new SqlParameter("@CurrentSubheadID", SqlDbType.Int)
        {
            Value = currentSubheadId.HasValue
                ? currentSubheadId.Value
                : DBNull.Value
        });

    var result =
        await command.ExecuteScalarAsync();

    if (result != null)
    {
        throw new InvalidOperationException(
            $"SubheadName '{subheadName}' already exists under Main Head {mainHeadId}.");
    }
}


private static async Task EnsureSubheadExistsAsync(
    SqlConnection connection,
    int subheadId)
{
    const string sql = """
        SELECT 1
        FROM GS.Subheads
        WHERE SubheadID = @SubheadID;
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@SubheadID", SqlDbType.Int)
        {
            Value = subheadId
        });

    var result =
        await command.ExecuteScalarAsync();

    if (result is null)
    {
        throw new KeyNotFoundException(
            $"Subhead {subheadId} was not found.");
    }
}


private static SubheadResponse MapSubhead(
    SqlDataReader reader)
{
    var normalBalance =
        reader["NormalBalance"]?.ToString()?.Trim()
        ?? string.Empty;

    return new SubheadResponse
    {
        SubheadID =
            Convert.ToInt32(
                reader["SubheadID"]),

        SubheadCode =
            Convert.ToInt32(
                reader["SubheadCode"]),

        SubheadName =
            reader["SubheadName"]?.ToString()
            ?? string.Empty,

        MainHead = new MainHeadInfo
        {
            MainHeadID =
                Convert.ToInt32(
                    reader["MainHeadID"]),

            MainHeadCode =
                Convert.ToInt32(
                    reader["MainHeadCode"]),

            MainHeadName =
                reader["MainHeadName"]?.ToString()
                ?? string.Empty,

            AccountingType =
                reader["AccountingType"]?.ToString()
                ?? string.Empty,

            NormalBalance =
                normalBalance,

            NormalBalanceName =
                normalBalance == "D"
                    ? "Debit"
                    : normalBalance == "C"
                        ? "Credit"
                        : string.Empty
        },

        IsActive =
            Convert.ToBoolean(
                reader["IsActive"]),

        AccountCount =
            Convert.ToInt32(
                reader["AccountCount"]),

        ComponentRuleCount =
            Convert.ToInt32(
                reader["ComponentRuleCount"]),

        CreatedAt =
            Convert.ToDateTime(
                reader["CreatedAt"]),

        UpdatedAt =
            reader["UpdatedAt"] == DBNull.Value
                ? null
                : Convert.ToDateTime(
                    reader["UpdatedAt"])
    };
}

public async Task<IReadOnlyList<CurrencyResponse>> GetCurrenciesAsync(
    bool? isActive = null)
{
    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    const string sql = """
        SELECT
            c.CurrencyID,
            c.CurrencyCode,
            c.CurrencyName,
            c.CurrencySymbol,
            c.DecimalPlaces,
            c.IsBaseCurrency,
            c.IsActive,
            c.CreatedAt,

            (
                SELECT COUNT(*)
                FROM GS.ChartOfAccounts coa
                WHERE coa.CurrencyID = c.CurrencyID
            ) AS AccountCount

        FROM GS.Currencies c
        WHERE
            @IsActive IS NULL
            OR c.IsActive = @IsActive
        ORDER BY
            c.CurrencyCode;
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@IsActive", SqlDbType.Bit)
        {
            Value = isActive.HasValue
                ? isActive.Value
                : DBNull.Value
        });

    var currencies =
        new List<CurrencyResponse>();

    await using var reader =
        await command.ExecuteReaderAsync();

    while (await reader.ReadAsync())
    {
        currencies.Add(
            MapCurrency(reader));
    }

    return currencies;
}


public async Task<CurrencyResponse?> GetCurrencyAsync(
    int currencyId)
{
    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    const string sql = """
        SELECT
            c.CurrencyID,
            c.CurrencyCode,
            c.CurrencyName,
            c.CurrencySymbol,
            c.DecimalPlaces,
            c.IsBaseCurrency,
            c.IsActive,
            c.CreatedAt,

            (
                SELECT COUNT(*)
                FROM GS.ChartOfAccounts coa
                WHERE coa.CurrencyID = c.CurrencyID
            ) AS AccountCount

        FROM GS.Currencies c
        WHERE c.CurrencyID = @CurrencyID;
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@CurrencyID", SqlDbType.Int)
        {
            Value = currencyId
        });

    await using var reader =
        await command.ExecuteReaderAsync();

    if (!await reader.ReadAsync())
    {
        return null;
    }

    return MapCurrency(reader);
}


public async Task<CurrencyResponse> CreateCurrencyAsync(
    CreateCurrencyRequest request)
{
    ValidateCurrencyRequest(
        request.CurrencyCode,
        request.CurrencyName,
        request.CurrencySymbol,
        request.DecimalPlaces);

    var currencyCode =
        request.CurrencyCode.Trim().ToUpperInvariant();

    var currencyName =
        request.CurrencyName.Trim();

    var currencySymbol =
        string.IsNullOrWhiteSpace(request.CurrencySymbol)
            ? null
            : request.CurrencySymbol.Trim();

    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    await EnsureCurrencyCodeIsAvailableAsync(
        connection,
        currencyCode,
        null);

    if (request.IsBaseCurrency)
    {
        await EnsureNoOtherBaseCurrencyAsync(
            connection,
            null);
    }

    const string sql = """
        INSERT INTO GS.Currencies
        (
            CurrencyCode,
            CurrencyName,
            CurrencySymbol,
            DecimalPlaces,
            IsBaseCurrency,
            IsActive
        )
        VALUES
        (
            @CurrencyCode,
            @CurrencyName,
            @CurrencySymbol,
            @DecimalPlaces,
            @IsBaseCurrency,
            1
        );

        SELECT CAST(SCOPE_IDENTITY() AS int);
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@CurrencyCode", SqlDbType.Char, 3)
        {
            Value = currencyCode
        });

    command.Parameters.Add(
        new SqlParameter("@CurrencyName", SqlDbType.VarChar, 100)
        {
            Value = currencyName
        });

    command.Parameters.Add(
        new SqlParameter("@CurrencySymbol", SqlDbType.VarChar, 10)
        {
            Value = currencySymbol is null
                ? DBNull.Value
                : currencySymbol
        });

    command.Parameters.Add(
        new SqlParameter("@DecimalPlaces", SqlDbType.TinyInt)
        {
            Value = request.DecimalPlaces
        });

    command.Parameters.Add(
        new SqlParameter("@IsBaseCurrency", SqlDbType.Bit)
        {
            Value = request.IsBaseCurrency
        });

    var result =
        await command.ExecuteScalarAsync();

    if (result is null)
    {
        throw new InvalidOperationException(
            "Currency could not be created.");
    }

    var currencyId =
        Convert.ToInt32(result);

    var currency =
        await GetCurrencyAsync(currencyId);

    if (currency is null)
    {
        throw new InvalidOperationException(
            "Currency was created but could not be retrieved.");
    }

    return currency;
}


public async Task<CurrencyResponse> UpdateCurrencyAsync(
    int currencyId,
    UpdateCurrencyRequest request)
{
    ValidateCurrencyRequest(
        request.CurrencyCode,
        request.CurrencyName,
        request.CurrencySymbol,
        request.DecimalPlaces);

    var currencyCode =
        request.CurrencyCode.Trim().ToUpperInvariant();

    var currencyName =
        request.CurrencyName.Trim();

    var currencySymbol =
        string.IsNullOrWhiteSpace(request.CurrencySymbol)
            ? null
            : request.CurrencySymbol.Trim();

    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    await EnsureCurrencyExistsAsync(
        connection,
        currencyId);

    await EnsureCurrencyCodeIsAvailableAsync(
        connection,
        currencyCode,
        currencyId);

    if (request.IsBaseCurrency)
    {
        await EnsureNoOtherBaseCurrencyAsync(
            connection,
            currencyId);
    }

    const string sql = """
        UPDATE GS.Currencies
        SET
            CurrencyCode = @CurrencyCode,
            CurrencyName = @CurrencyName,
            CurrencySymbol = @CurrencySymbol,
            DecimalPlaces = @DecimalPlaces,
            IsBaseCurrency = @IsBaseCurrency
        WHERE CurrencyID = @CurrencyID;
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@CurrencyID", SqlDbType.Int)
        {
            Value = currencyId
        });

    command.Parameters.Add(
        new SqlParameter("@CurrencyCode", SqlDbType.Char, 3)
        {
            Value = currencyCode
        });

    command.Parameters.Add(
        new SqlParameter("@CurrencyName", SqlDbType.VarChar, 100)
        {
            Value = currencyName
        });

    command.Parameters.Add(
        new SqlParameter("@CurrencySymbol", SqlDbType.VarChar, 10)
        {
            Value = currencySymbol is null
                ? DBNull.Value
                : currencySymbol
        });

    command.Parameters.Add(
        new SqlParameter("@DecimalPlaces", SqlDbType.TinyInt)
        {
            Value = request.DecimalPlaces
        });

    command.Parameters.Add(
        new SqlParameter("@IsBaseCurrency", SqlDbType.Bit)
        {
            Value = request.IsBaseCurrency
        });

    await command.ExecuteNonQueryAsync();

    var currency =
        await GetCurrencyAsync(currencyId);

    if (currency is null)
    {
        throw new InvalidOperationException(
            "Currency was updated but could not be retrieved.");
    }

    return currency;
}


public async Task<CurrencyResponse> SetCurrencyActiveStatusAsync(
    int currencyId,
    bool isActive)
{
    await using var connection =
        _connectionFactory.CreateConnection();

    await connection.OpenAsync();

    var currency =
        await GetCurrencyForStatusChangeAsync(
            connection,
            currencyId);

    if (currency is null)
    {
        throw new KeyNotFoundException(
            $"Currency {currencyId} was not found.");
    }

    if (!isActive &&
        currency.IsBaseCurrency)
    {
        throw new InvalidOperationException(
            $"Currency {currencyId} is the base currency and cannot be deactivated.");
    }

    const string sql = """
        UPDATE GS.Currencies
        SET
            IsActive = @IsActive
        WHERE CurrencyID = @CurrencyID;
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@CurrencyID", SqlDbType.Int)
        {
            Value = currencyId
        });

    command.Parameters.Add(
        new SqlParameter("@IsActive", SqlDbType.Bit)
        {
            Value = isActive
        });

    await command.ExecuteNonQueryAsync();

    var updatedCurrency =
        await GetCurrencyAsync(currencyId);

    if (updatedCurrency is null)
    {
        throw new InvalidOperationException(
            "Currency status was updated but could not be retrieved.");
    }

    return updatedCurrency;
}

private static void ValidateCurrencyRequest(
    string currencyCode,
    string currencyName,
    string? currencySymbol,
    byte decimalPlaces)
{
    if (string.IsNullOrWhiteSpace(currencyCode))
    {
        throw new ArgumentException(
            "CurrencyCode is required.");
    }

    var normalizedCode =
        currencyCode.Trim();

    if (normalizedCode.Length != 3)
    {
        throw new ArgumentException(
            "CurrencyCode must be exactly 3 characters.");
    }

    if (string.IsNullOrWhiteSpace(currencyName))
    {
        throw new ArgumentException(
            "CurrencyName is required.");
    }

    if (currencyName.Trim().Length > 100)
    {
        throw new ArgumentException(
            "CurrencyName cannot exceed 100 characters.");
    }

    if (!string.IsNullOrWhiteSpace(currencySymbol) &&
        currencySymbol.Trim().Length > 10)
    {
        throw new ArgumentException(
            "CurrencySymbol cannot exceed 10 characters.");
    }

    if (decimalPlaces > 6)
    {
        throw new ArgumentException(
            "DecimalPlaces must be between 0 and 6.");
    }
}


private static async Task EnsureCurrencyExistsAsync(
    SqlConnection connection,
    int currencyId)
{
    const string sql = """
        SELECT 1
        FROM GS.Currencies
        WHERE CurrencyID = @CurrencyID;
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@CurrencyID", SqlDbType.Int)
        {
            Value = currencyId
        });

    var result =
        await command.ExecuteScalarAsync();

    if (result is null)
    {
        throw new KeyNotFoundException(
            $"Currency {currencyId} was not found.");
    }
}


private static async Task EnsureCurrencyCodeIsAvailableAsync(
    SqlConnection connection,
    string currencyCode,
    int? currentCurrencyId)
{
    const string sql = """
        SELECT TOP (1)
            CurrencyID
        FROM GS.Currencies
        WHERE CurrencyCode = @CurrencyCode
          AND
          (
              @CurrentCurrencyID IS NULL
              OR CurrencyID <> @CurrentCurrencyID
          );
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@CurrencyCode", SqlDbType.Char, 3)
        {
            Value = currencyCode
        });

    command.Parameters.Add(
        new SqlParameter("@CurrentCurrencyID", SqlDbType.Int)
        {
            Value = currentCurrencyId.HasValue
                ? currentCurrencyId.Value
                : DBNull.Value
        });

    var result =
        await command.ExecuteScalarAsync();

    if (result != null)
    {
        throw new InvalidOperationException(
            $"CurrencyCode '{currencyCode}' already exists.");
    }
}


private static async Task EnsureNoOtherBaseCurrencyAsync(
    SqlConnection connection,
    int? currentCurrencyId)
{
    const string sql = """
        SELECT TOP (1)
            CurrencyID,
            CurrencyCode
        FROM GS.Currencies
        WHERE IsBaseCurrency = 1
          AND
          (
              @CurrentCurrencyID IS NULL
              OR CurrencyID <> @CurrentCurrencyID
          );
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@CurrentCurrencyID", SqlDbType.Int)
        {
            Value = currentCurrencyId.HasValue
                ? currentCurrencyId.Value
                : DBNull.Value
        });

    await using var reader =
        await command.ExecuteReaderAsync();

    if (await reader.ReadAsync())
    {
        var existingCurrencyId =
            Convert.ToInt32(
                reader["CurrencyID"]);

        var existingCurrencyCode =
            reader["CurrencyCode"]?.ToString()?.Trim()
            ?? string.Empty;

        throw new InvalidOperationException(
            $"Currency '{existingCurrencyCode}' (ID {existingCurrencyId}) is already the base currency.");
    }
}


private static async Task<CurrencyResponse?> GetCurrencyForStatusChangeAsync(
    SqlConnection connection,
    int currencyId)
{
    const string sql = """
        SELECT
            c.CurrencyID,
            c.CurrencyCode,
            c.CurrencyName,
            c.CurrencySymbol,
            c.DecimalPlaces,
            c.IsBaseCurrency,
            c.IsActive,
            c.CreatedAt,

            (
                SELECT COUNT(*)
                FROM GS.ChartOfAccounts coa
                WHERE coa.CurrencyID = c.CurrencyID
            ) AS AccountCount

        FROM GS.Currencies c
        WHERE c.CurrencyID = @CurrencyID;
        """;

    await using var command =
        new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@CurrencyID", SqlDbType.Int)
        {
            Value = currencyId
        });

    await using var reader =
        await command.ExecuteReaderAsync();

    if (!await reader.ReadAsync())
    {
        return null;
    }

    return MapCurrency(reader);
}


private static CurrencyResponse MapCurrency(
    SqlDataReader reader)
{
    return new CurrencyResponse
    {
        CurrencyID =
            Convert.ToInt32(
                reader["CurrencyID"]),

        CurrencyCode =
            reader["CurrencyCode"]?.ToString()?.Trim()
            ?? string.Empty,

        CurrencyName =
            reader["CurrencyName"]?.ToString()
            ?? string.Empty,

        CurrencySymbol =
            reader["CurrencySymbol"] == DBNull.Value
                ? null
                : reader["CurrencySymbol"]?.ToString(),

        DecimalPlaces =
            Convert.ToByte(
                reader["DecimalPlaces"]),

        IsBaseCurrency =
            Convert.ToBoolean(
                reader["IsBaseCurrency"]),

        IsActive =
            Convert.ToBoolean(
                reader["IsActive"]),

        AccountCount =
            Convert.ToInt32(
                reader["AccountCount"]),

        CreatedAt =
            Convert.ToDateTime(
                reader["CreatedAt"])
    };
}

// ============================================================
// 10.9.5 — TRANSACTION TYPES
// ============================================================

public async Task<IReadOnlyList<TransactionTypeResponse>> GetTransactionTypesAsync(
    bool? isActive = null)
{
    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    const string sql = """
        SELECT
            TT.TransactionTypeID,
            TT.TransactionTypeCode,
            TT.TransactionTypeName,
            TT.Description,
            TT.IsSystem,
            TT.IsActive,
            TT.CreatedAt,
            TT.UpdatedAt,

            (
                SELECT COUNT(*)
                FROM GS.TransactionTypeRules TR
                WHERE TR.TransactionTypeID = TT.TransactionTypeID
            ) AS RuleCount,

            (
                SELECT COUNT(*)
                FROM GS.TransactionComponents TC
                WHERE TC.TransactionTypeID = TT.TransactionTypeID
            ) AS ComponentCount,

            (
                SELECT COUNT(*)
                FROM FIN.Transactions T
                WHERE T.TransactionTypeID = TT.TransactionTypeID
            ) AS TransactionCount

        FROM GS.TransactionTypes TT
        WHERE (@IsActive IS NULL OR TT.IsActive = @IsActive)
        ORDER BY
            TT.TransactionTypeCode;
        """;

    using var command = new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@IsActive", SqlDbType.Bit)
        {
            Value = isActive.HasValue
                ? isActive.Value
                : DBNull.Value
        });

    var results = new List<TransactionTypeResponse>();

    using var reader = await command.ExecuteReaderAsync();

    while (await reader.ReadAsync())
    {
        results.Add(MapTransactionType(reader));
    }

    return results;
}


public async Task<TransactionTypeResponse?> GetTransactionTypeAsync(
    int transactionTypeId)
{
    if (transactionTypeId <= 0)
    {
        throw new ArgumentException(
            "TransactionTypeID must be greater than zero.",
            nameof(transactionTypeId));
    }

    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    const string sql = """
        SELECT
            TT.TransactionTypeID,
            TT.TransactionTypeCode,
            TT.TransactionTypeName,
            TT.Description,
            TT.IsSystem,
            TT.IsActive,
            TT.CreatedAt,
            TT.UpdatedAt,

            (
                SELECT COUNT(*)
                FROM GS.TransactionTypeRules TR
                WHERE TR.TransactionTypeID = TT.TransactionTypeID
            ) AS RuleCount,

            (
                SELECT COUNT(*)
                FROM GS.TransactionComponents TC
                WHERE TC.TransactionTypeID = TT.TransactionTypeID
            ) AS ComponentCount,

            (
                SELECT COUNT(*)
                FROM FIN.Transactions T
                WHERE T.TransactionTypeID = TT.TransactionTypeID
            ) AS TransactionCount

        FROM GS.TransactionTypes TT
        WHERE TT.TransactionTypeID = @TransactionTypeID;
        """;

    using var command = new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@TransactionTypeID", SqlDbType.Int)
        {
            Value = transactionTypeId
        });

    using var reader = await command.ExecuteReaderAsync();

    if (!await reader.ReadAsync())
    {
        return null;
    }

    return MapTransactionType(reader);
}


public async Task<TransactionTypeResponse> CreateTransactionTypeAsync(
    CreateTransactionTypeRequest request)
{
    ValidateTransactionTypeRequest(
        request.TransactionTypeCode,
        request.TransactionTypeName,
        request.Description);

    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    await EnsureTransactionTypeCodeIsAvailableAsync(
        connection,
        request.TransactionTypeCode);

    await EnsureTransactionTypeNameIsAvailableAsync(
        connection,
        request.TransactionTypeName);

    const string sql = """
        INSERT INTO GS.TransactionTypes
        (
            TransactionTypeCode,
            TransactionTypeName,
            Description,
            IsSystem,
            IsActive
        )
        OUTPUT INSERTED.TransactionTypeID
        VALUES
        (
            @TransactionTypeCode,
            @TransactionTypeName,
            @Description,
            0,
            1
        );
        """;

    using var command = new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@TransactionTypeCode", SqlDbType.Int)
        {
            Value = request.TransactionTypeCode
        });

    command.Parameters.Add(
        new SqlParameter("@TransactionTypeName", SqlDbType.VarChar, 100)
        {
            Value = request.TransactionTypeName.Trim()
        });

    command.Parameters.Add(
        new SqlParameter("@Description", SqlDbType.VarChar, 500)
        {
            Value = string.IsNullOrWhiteSpace(request.Description)
                ? DBNull.Value
                : request.Description.Trim()
        });

    var transactionTypeId =
        Convert.ToInt32(await command.ExecuteScalarAsync());

    var created =
        await GetTransactionTypeAsync(transactionTypeId);

    if (created == null)
    {
        throw new InvalidOperationException(
            "Transaction Type was created but could not be retrieved.");
    }

    return created;
}


public async Task<TransactionTypeResponse> UpdateTransactionTypeAsync(
    int transactionTypeId,
    UpdateTransactionTypeRequest request)
{
    if (transactionTypeId <= 0)
    {
        throw new ArgumentException(
            "TransactionTypeID must be greater than zero.",
            nameof(transactionTypeId));
    }

    ValidateTransactionTypeRequest(
        request.TransactionTypeCode,
        request.TransactionTypeName,
        request.Description);

    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    const string existingSql = """
        SELECT
            TransactionTypeID,
            TransactionTypeCode,
            TransactionTypeName,
            IsSystem,
            IsActive
        FROM GS.TransactionTypes
        WHERE TransactionTypeID = @TransactionTypeID;
        """;

    using (var existingCommand = new SqlCommand(existingSql, connection))
    {
        existingCommand.Parameters.Add(
            new SqlParameter("@TransactionTypeID", SqlDbType.Int)
            {
                Value = transactionTypeId
            });

        using var reader =
            await existingCommand.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            throw new KeyNotFoundException(
                $"Transaction Type {transactionTypeId} was not found.");
        }

        var isSystem = reader.GetBoolean(
            reader.GetOrdinal("IsSystem"));

        if (isSystem)
        {
            throw new InvalidOperationException(
                "System transaction types cannot be modified.");
        }
    }

    await EnsureTransactionTypeCodeIsAvailableAsync(
        connection,
        request.TransactionTypeCode,
        transactionTypeId);

    await EnsureTransactionTypeNameIsAvailableAsync(
        connection,
        request.TransactionTypeName,
        transactionTypeId);

    const string updateSql = """
        UPDATE GS.TransactionTypes
        SET
            TransactionTypeCode = @TransactionTypeCode,
            TransactionTypeName = @TransactionTypeName,
            Description = @Description,
            UpdatedAt = SYSDATETIME()
        WHERE TransactionTypeID = @TransactionTypeID;
        """;

    using var command = new SqlCommand(updateSql, connection);

    command.Parameters.Add(
        new SqlParameter("@TransactionTypeCode", SqlDbType.Int)
        {
            Value = request.TransactionTypeCode
        });

    command.Parameters.Add(
        new SqlParameter("@TransactionTypeName", SqlDbType.VarChar, 100)
        {
            Value = request.TransactionTypeName.Trim()
        });

    command.Parameters.Add(
        new SqlParameter("@Description", SqlDbType.VarChar, 500)
        {
            Value = string.IsNullOrWhiteSpace(request.Description)
                ? DBNull.Value
                : request.Description.Trim()
        });

    command.Parameters.Add(
        new SqlParameter("@TransactionTypeID", SqlDbType.Int)
        {
            Value = transactionTypeId
        });

    var rowsAffected = await command.ExecuteNonQueryAsync();

    if (rowsAffected == 0)
    {
        throw new KeyNotFoundException(
            $"Transaction Type {transactionTypeId} was not found.");
    }

    var updated =
        await GetTransactionTypeAsync(transactionTypeId);

    if (updated == null)
    {
        throw new InvalidOperationException(
            "Transaction Type was updated but could not be retrieved.");
    }

    return updated;
}


public async Task<TransactionTypeResponse> SetTransactionTypeActiveStatusAsync(
    int transactionTypeId,
    bool isActive)
{
    if (transactionTypeId <= 0)
    {
        throw new ArgumentException(
            "TransactionTypeID must be greater than zero.",
            nameof(transactionTypeId));
    }

    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();

    const string existingSql = """
        SELECT
            TransactionTypeID,
            TransactionTypeCode,
            TransactionTypeName,
            IsSystem,
            IsActive
        FROM GS.TransactionTypes
        WHERE TransactionTypeID = @TransactionTypeID;
        """;

    bool isSystem;
    bool currentIsActive;

    using (var existingCommand = new SqlCommand(existingSql, connection))
    {
        existingCommand.Parameters.Add(
            new SqlParameter("@TransactionTypeID", SqlDbType.Int)
            {
                Value = transactionTypeId
            });

        using var reader =
            await existingCommand.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            throw new KeyNotFoundException(
                $"Transaction Type {transactionTypeId} was not found.");
        }

        isSystem = reader.GetBoolean(
            reader.GetOrdinal("IsSystem"));

        currentIsActive = reader.GetBoolean(
            reader.GetOrdinal("IsActive"));
    }

    if (isSystem && !isActive)
    {
        throw new InvalidOperationException(
            "System transaction types cannot be deactivated.");
    }

    if (currentIsActive == isActive)
    {
        var current =
            await GetTransactionTypeAsync(transactionTypeId);

        if (current == null)
        {
            throw new KeyNotFoundException(
                $"Transaction Type {transactionTypeId} was not found.");
        }

        return current;
    }

    const string updateSql = """
        UPDATE GS.TransactionTypes
        SET
            IsActive = @IsActive,
            UpdatedAt = SYSDATETIME()
        WHERE TransactionTypeID = @TransactionTypeID;
        """;

    using var command = new SqlCommand(updateSql, connection);

    command.Parameters.Add(
        new SqlParameter("@IsActive", SqlDbType.Bit)
        {
            Value = isActive
        });

    command.Parameters.Add(
        new SqlParameter("@TransactionTypeID", SqlDbType.Int)
        {
            Value = transactionTypeId
        });

    await command.ExecuteNonQueryAsync();

    var result =
        await GetTransactionTypeAsync(transactionTypeId);

    if (result == null)
    {
        throw new InvalidOperationException(
            "Transaction Type status was changed but could not be retrieved.");
    }

    return result;
}

private static void ValidateTransactionTypeRequest(
    int transactionTypeCode,
    string transactionTypeName,
    string? description)
{
    if (transactionTypeCode <= 0)
    {
        throw new ArgumentException(
            "TransactionTypeCode must be greater than zero.");
    }

    if (string.IsNullOrWhiteSpace(transactionTypeName))
    {
        throw new ArgumentException(
            "TransactionTypeName is required.");
    }

    if (transactionTypeName.Trim().Length > 100)
    {
        throw new ArgumentException(
            "TransactionTypeName cannot exceed 100 characters.");
    }

    if (description != null &&
        description.Trim().Length > 500)
    {
        throw new ArgumentException(
            "Description cannot exceed 500 characters.");
    }
}


private static async Task EnsureTransactionTypeCodeIsAvailableAsync(
    SqlConnection connection,
    int transactionTypeCode,
    int? excludeTransactionTypeId = null)
{
    const string sql = """
        SELECT COUNT(*)
        FROM GS.TransactionTypes
        WHERE TransactionTypeCode = @TransactionTypeCode
          AND
          (
              @ExcludeTransactionTypeID IS NULL
              OR TransactionTypeID <> @ExcludeTransactionTypeID
          );
        """;

    using var command = new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@TransactionTypeCode", SqlDbType.Int)
        {
            Value = transactionTypeCode
        });

    command.Parameters.Add(
        new SqlParameter("@ExcludeTransactionTypeID", SqlDbType.Int)
        {
            Value = excludeTransactionTypeId.HasValue
                ? excludeTransactionTypeId.Value
                : DBNull.Value
        });

    var count =
        Convert.ToInt32(await command.ExecuteScalarAsync());

    if (count > 0)
    {
        throw new InvalidOperationException(
            $"TransactionTypeCode '{transactionTypeCode}' already exists.");
    }
}


private static async Task EnsureTransactionTypeNameIsAvailableAsync(
    SqlConnection connection,
    string transactionTypeName,
    int? excludeTransactionTypeId = null)
{
    const string sql = """
        SELECT COUNT(*)
        FROM GS.TransactionTypes
        WHERE TransactionTypeName = @TransactionTypeName
          AND
          (
              @ExcludeTransactionTypeID IS NULL
              OR TransactionTypeID <> @ExcludeTransactionTypeID
          );
        """;

    using var command = new SqlCommand(sql, connection);

    command.Parameters.Add(
        new SqlParameter("@TransactionTypeName", SqlDbType.VarChar, 100)
        {
            Value = transactionTypeName.Trim()
        });

    command.Parameters.Add(
        new SqlParameter("@ExcludeTransactionTypeID", SqlDbType.Int)
        {
            Value = excludeTransactionTypeId.HasValue
                ? excludeTransactionTypeId.Value
                : DBNull.Value
        });

    var count =
        Convert.ToInt32(await command.ExecuteScalarAsync());

    if (count > 0)
    {
        throw new InvalidOperationException(
            $"TransactionTypeName '{transactionTypeName.Trim()}' already exists.");
    }
}


private static TransactionTypeResponse MapTransactionType(
    SqlDataReader reader)
{
    return new TransactionTypeResponse
    {
        TransactionTypeID =
            reader.GetInt32(
                reader.GetOrdinal("TransactionTypeID")),

        TransactionTypeCode =
            reader.GetInt32(
                reader.GetOrdinal("TransactionTypeCode")),

        TransactionTypeName =
            reader.GetString(
                reader.GetOrdinal("TransactionTypeName")),

        Description =
            reader.IsDBNull(
                reader.GetOrdinal("Description"))
                ? null
                : reader.GetString(
                    reader.GetOrdinal("Description")),

        IsSystem =
            reader.GetBoolean(
                reader.GetOrdinal("IsSystem")),

        IsActive =
            reader.GetBoolean(
                reader.GetOrdinal("IsActive")),

        RuleCount =
            Convert.ToInt32(
                reader["RuleCount"]),

        ComponentCount =
            Convert.ToInt32(
                reader["ComponentCount"]),

        TransactionCount =
            Convert.ToInt32(
                reader["TransactionCount"]),

        CreatedAt =
            reader.GetDateTime(
                reader.GetOrdinal("CreatedAt")),

        UpdatedAt =
            reader.IsDBNull(
                reader.GetOrdinal("UpdatedAt"))
                ? null
                : reader.GetDateTime(
                    reader.GetOrdinal("UpdatedAt"))
    };
}

// ============================================================
// 10.9.6 — TRANSACTION COMPONENTS
// ============================================================

    public async Task<IReadOnlyList<TransactionComponentResponse>>
        GetTransactionComponentsAsync(
            bool? isActive = null,
            int? transactionTypeId = null)
    {
        const string sql = """
            SELECT
                tc.TransactionComponentID,
                tc.TransactionTypeID,
                tt.TransactionTypeCode,
                tt.TransactionTypeName,
                tc.ComponentCode,
                tc.ComponentName,
                tc.Description,
                tc.IsRequired,
                tc.IsActive,
                tc.SequenceNo,
                tt.IsSystem AS TransactionTypeIsSystem,

                (
                    SELECT COUNT(*)
                    FROM GS.TransactionComponentRules tcr
                    WHERE tcr.TransactionComponentID =
                          tc.TransactionComponentID
                ) AS RuleCount,

                (
                    SELECT COUNT(*)
                    FROM FIN.TransactionLines tl
                    WHERE tl.TransactionComponentID =
                          tc.TransactionComponentID
                ) AS TransactionLineCount,

                tc.CreatedAt,
                tc.UpdatedAt
            FROM GS.TransactionComponents tc
            INNER JOIN GS.TransactionTypes tt
                ON tt.TransactionTypeID = tc.TransactionTypeID
            WHERE
                (@IsActive IS NULL
                 OR tc.IsActive = @IsActive)
                AND
                (@TransactionTypeID IS NULL
                 OR tc.TransactionTypeID = @TransactionTypeID)
            ORDER BY
                tt.TransactionTypeCode,
                tc.SequenceNo,
                tc.TransactionComponentID;
            """;

        var results =
            new List<TransactionComponentResponse>();

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@IsActive", SqlDbType.Bit)
            {
                Value = isActive.HasValue
                    ? isActive.Value
                    : DBNull.Value
            });

        command.Parameters.Add(
            new SqlParameter("@TransactionTypeID", SqlDbType.Int)
            {
                Value = transactionTypeId.HasValue
                    ? transactionTypeId.Value
                    : DBNull.Value
            });

        await using var reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            results.Add(
                MapTransactionComponent(reader));
        }

        return results;
    }


    public async Task<TransactionComponentResponse?>
        GetTransactionComponentAsync(
            int transactionComponentId)
    {
        if (transactionComponentId <= 0)
        {
            throw new ArgumentException(
                "Transaction component ID must be greater than zero.",
                nameof(transactionComponentId));
        }

        const string sql = """
            SELECT
                tc.TransactionComponentID,
                tc.TransactionTypeID,
                tt.TransactionTypeCode,
                tt.TransactionTypeName,
                tc.ComponentCode,
                tc.ComponentName,
                tc.Description,
                tc.IsRequired,
                tc.IsActive,
                tc.SequenceNo,
                tt.IsSystem AS TransactionTypeIsSystem,

                (
                    SELECT COUNT(*)
                    FROM GS.TransactionComponentRules tcr
                    WHERE tcr.TransactionComponentID =
                          tc.TransactionComponentID
                ) AS RuleCount,

                (
                    SELECT COUNT(*)
                    FROM FIN.TransactionLines tl
                    WHERE tl.TransactionComponentID =
                          tc.TransactionComponentID
                ) AS TransactionLineCount,

                tc.CreatedAt,
                tc.UpdatedAt
            FROM GS.TransactionComponents tc
            INNER JOIN GS.TransactionTypes tt
                ON tt.TransactionTypeID = tc.TransactionTypeID
            WHERE
                tc.TransactionComponentID =
                @TransactionComponentID;
            """;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            "@TransactionComponentID",
            SqlDbType.Int).Value =
            transactionComponentId;

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        return MapTransactionComponent(reader);
    }


    public async Task<TransactionComponentResponse>
        CreateTransactionComponentAsync(
            CreateTransactionComponentRequest request)
    {
        ValidateTransactionComponentRequest(request);

        var componentCode =
            request.ComponentCode.Trim().ToUpperInvariant();

        var componentName =
            request.ComponentName.Trim();

        var description =
            string.IsNullOrWhiteSpace(request.Description)
                ? null
                : request.Description.Trim();

        await ValidateTransactionTypeForComponentAsync(
            request.TransactionTypeID);

        await EnsureTransactionComponentCodeIsAvailableAsync(
            request.TransactionTypeID,
            componentCode);

        await EnsureTransactionComponentNameIsAvailableAsync(
            request.TransactionTypeID,
            componentName);

        const string sql = """
            INSERT INTO GS.TransactionComponents
            (
                TransactionTypeID,
                ComponentCode,
                ComponentName,
                Description,
                IsRequired,
                IsActive,
                SequenceNo
            )
            OUTPUT INSERTED.TransactionComponentID
            VALUES
            (
                @TransactionTypeID,
                @ComponentCode,
                @ComponentName,
                @Description,
                @IsRequired,
                1,
                @SequenceNo
            );
            """;

        int transactionComponentId;

        await using (var connection =
            _connectionFactory.CreateConnection())
        {
            await connection.OpenAsync();

            await using var command =
                new SqlCommand(sql, connection);

            command.Parameters.Add(
                "@TransactionTypeID",
                SqlDbType.Int).Value =
                request.TransactionTypeID;

            command.Parameters.Add(
                "@ComponentCode",
                SqlDbType.VarChar, 30).Value =
                componentCode;

            command.Parameters.Add(
                "@ComponentName",
                SqlDbType.VarChar, 100).Value =
                componentName;

            command.Parameters.Add(
                "@Description",
                SqlDbType.VarChar, 500).Value =
                (object?)description ?? DBNull.Value;

            command.Parameters.Add(
                "@IsRequired",
                SqlDbType.Bit).Value =
                request.IsRequired;

            command.Parameters.Add(
                "@SequenceNo",
                SqlDbType.Int).Value =
                request.SequenceNo;

            transactionComponentId =
                Convert.ToInt32(
                    await command.ExecuteScalarAsync());
        }

        return await GetTransactionComponentAsync(
                   transactionComponentId)
               ?? throw new InvalidOperationException(
                   "The transaction component was created but could not be retrieved.");
    }


    public async Task<TransactionComponentResponse>
        UpdateTransactionComponentAsync(
            int transactionComponentId,
            UpdateTransactionComponentRequest request)
    {
        if (transactionComponentId <= 0)
        {
            throw new ArgumentException(
                "Transaction component ID must be greater than zero.",
                nameof(transactionComponentId));
        }

        ValidateTransactionComponentRequest(request);

        var existing =
            await GetTransactionComponentForModificationAsync(
                transactionComponentId);

        if (existing is null)
        {
            throw new KeyNotFoundException(
                $"Transaction component {transactionComponentId} was not found.");
        }

        if (existing.TransactionTypeIsSystem)
        {
            throw new InvalidOperationException(
                "Transaction components belonging to system transaction types cannot be modified.");
        }

        var componentCode =
            request.ComponentCode.Trim().ToUpperInvariant();

        var componentName =
            request.ComponentName.Trim();

        var description =
            string.IsNullOrWhiteSpace(request.Description)
                ? null
                : request.Description.Trim();

        await EnsureTransactionComponentCodeIsAvailableAsync(
            existing.TransactionTypeID,
            componentCode,
            transactionComponentId);

        await EnsureTransactionComponentNameIsAvailableAsync(
            existing.TransactionTypeID,
            componentName,
            transactionComponentId);

        const string sql = """
            UPDATE GS.TransactionComponents
            SET
                ComponentCode = @ComponentCode,
                ComponentName = @ComponentName,
                Description = @Description,
                IsRequired = @IsRequired,
                SequenceNo = @SequenceNo,
                UpdatedAt = SYSDATETIME()
            WHERE
                TransactionComponentID =
                @TransactionComponentID;
            """;

        await using (var connection =
            _connectionFactory.CreateConnection())
        {
            await connection.OpenAsync();

            await using var command =
                new SqlCommand(sql, connection);

            command.Parameters.Add(
                "@TransactionComponentID",
                SqlDbType.Int).Value =
                transactionComponentId;

            command.Parameters.Add(
                "@ComponentCode",
                SqlDbType.VarChar, 30).Value =
                componentCode;

            command.Parameters.Add(
                "@ComponentName",
                SqlDbType.VarChar, 100).Value =
                componentName;

            command.Parameters.Add(
                "@Description",
                SqlDbType.VarChar, 500).Value =
                (object?)description ?? DBNull.Value;

            command.Parameters.Add(
                "@IsRequired",
                SqlDbType.Bit).Value =
                request.IsRequired;

            command.Parameters.Add(
                "@SequenceNo",
                SqlDbType.Int).Value =
                request.SequenceNo;

            await command.ExecuteNonQueryAsync();
        }

        return await GetTransactionComponentAsync(
                   transactionComponentId)
               ?? throw new InvalidOperationException(
                   "The transaction component was updated but could not be retrieved.");
    }


    public async Task<TransactionComponentResponse>
        SetTransactionComponentActiveStatusAsync(
            int transactionComponentId,
            bool isActive)
    {
        if (transactionComponentId <= 0)
        {
            throw new ArgumentException(
                "Transaction component ID must be greater than zero.",
                nameof(transactionComponentId));
        }

        var existing =
            await GetTransactionComponentForModificationAsync(
                transactionComponentId);

        if (existing is null)
        {
            throw new KeyNotFoundException(
                $"Transaction component {transactionComponentId} was not found.");
        }

        if (existing.TransactionTypeIsSystem)
        {
            throw new InvalidOperationException(
                "Transaction components belonging to system transaction types cannot be modified.");
        }

        if (!isActive &&
            existing.IsRequired)
        {
            throw new InvalidOperationException(
                "A required transaction component cannot be deactivated.");
        }

        if (!isActive &&
            !existing.IsActive)
        {
            return await GetTransactionComponentAsync(
                       transactionComponentId)
                   ?? throw new InvalidOperationException(
                       "The transaction component could not be retrieved.");
        }

        if (isActive &&
            existing.IsActive)
        {
            return await GetTransactionComponentAsync(
                       transactionComponentId)
                   ?? throw new InvalidOperationException(
                       "The transaction component could not be retrieved.");
        }

        const string sql = """
            UPDATE GS.TransactionComponents
            SET
                IsActive = @IsActive,
                UpdatedAt = SYSDATETIME()
            WHERE
                TransactionComponentID =
                @TransactionComponentID;
            """;

        await using (var connection =
            _connectionFactory.CreateConnection())
        {
            await connection.OpenAsync();

            await using var command =
                new SqlCommand(sql, connection);

            command.Parameters.Add(
                "@TransactionComponentID",
                SqlDbType.Int).Value =
                transactionComponentId;

            command.Parameters.Add(
                "@IsActive",
                SqlDbType.Bit).Value =
                isActive;

            await command.ExecuteNonQueryAsync();
        }

        return await GetTransactionComponentAsync(
                   transactionComponentId)
               ?? throw new InvalidOperationException(
                   "The transaction component status was changed but could not be retrieved.");
    }


    // ============================================================
    // 10.9.6 TRANSACTION COMPONENT HELPERS
    // ============================================================

    private static void ValidateTransactionComponentRequest(
        CreateTransactionComponentRequest request)
    {
        if (request.TransactionTypeID <= 0)
        {
            throw new ArgumentException(
                "Transaction type ID must be greater than zero.");
        }

        ValidateTransactionComponentValues(
            request.ComponentCode,
            request.ComponentName,
            request.Description,
            request.SequenceNo);
    }


    private static void ValidateTransactionComponentRequest(
        UpdateTransactionComponentRequest request)
    {
        ValidateTransactionComponentValues(
            request.ComponentCode,
            request.ComponentName,
            request.Description,
            request.SequenceNo);
    }


    private static void ValidateTransactionComponentValues(
        string componentCode,
        string componentName,
        string? description,
        int sequenceNo)
    {
        if (string.IsNullOrWhiteSpace(componentCode))
        {
            throw new ArgumentException(
                "Component code is required.");
        }

        if (componentCode.Trim().Length > 30)
        {
            throw new ArgumentException(
                "Component code cannot exceed 30 characters.");
        }

        if (string.IsNullOrWhiteSpace(componentName))
        {
            throw new ArgumentException(
                "Component name is required.");
        }

        if (componentName.Trim().Length > 100)
        {
            throw new ArgumentException(
                "Component name cannot exceed 100 characters.");
        }

        if (description is not null &&
            description.Trim().Length > 500)
        {
            throw new ArgumentException(
                "Description cannot exceed 500 characters.");
        }

        if (sequenceNo <= 0)
        {
            throw new ArgumentException(
                "Sequence number must be greater than zero.");
        }
    }


    private async Task ValidateTransactionTypeForComponentAsync(
        int transactionTypeId)
    {
        const string sql = """
            SELECT
                IsActive,
                IsSystem
            FROM GS.TransactionTypes
            WHERE
                TransactionTypeID =
                @TransactionTypeID;
            """;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            "@TransactionTypeID",
            SqlDbType.Int).Value =
            transactionTypeId;

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            throw new KeyNotFoundException(
                $"Transaction type {transactionTypeId} was not found.");
        }

        var isActive =
            reader.GetBoolean(
                reader.GetOrdinal("IsActive"));

        var isSystem =
            reader.GetBoolean(
                reader.GetOrdinal("IsSystem"));

        if (!isActive)
        {
            throw new InvalidOperationException(
                "A transaction component cannot be created under an inactive transaction type.");
        }

        if (isSystem)
        {
            throw new InvalidOperationException(
                "Components for system transaction types cannot be created through this API.");
        }
    }


    private async Task EnsureTransactionComponentCodeIsAvailableAsync(
        int transactionTypeId,
        string componentCode,
        int? excludingComponentId = null)
    {
        const string sql = """
            SELECT COUNT(*)
            FROM GS.TransactionComponents
            WHERE
                TransactionTypeID = @TransactionTypeID
                AND ComponentCode = @ComponentCode
                AND
                (
                    @ExcludingComponentID IS NULL
                    OR TransactionComponentID <>
                       @ExcludingComponentID
                );
            """;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            "@TransactionTypeID",
            SqlDbType.Int).Value =
            transactionTypeId;

        command.Parameters.Add(
            "@ComponentCode",
            SqlDbType.VarChar, 30).Value =
            componentCode;

        command.Parameters.Add(
            "@ExcludingComponentID",
            SqlDbType.Int).Value =
            excludingComponentId.HasValue
                ? excludingComponentId.Value
                : DBNull.Value;

        var count =
            Convert.ToInt32(
                await command.ExecuteScalarAsync());

        if (count > 0)
        {
            throw new InvalidOperationException(
                $"Component code '{componentCode}' already exists for this transaction type.");
        }
    }


    private async Task EnsureTransactionComponentNameIsAvailableAsync(
        int transactionTypeId,
        string componentName,
        int? excludingComponentId = null)
    {
        const string sql = """
            SELECT COUNT(*)
            FROM GS.TransactionComponents
            WHERE
                TransactionTypeID = @TransactionTypeID
                AND ComponentName = @ComponentName
                AND
                (
                    @ExcludingComponentID IS NULL
                    OR TransactionComponentID <>
                       @ExcludingComponentID
                );
            """;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            "@TransactionTypeID",
            SqlDbType.Int).Value =
            transactionTypeId;

        command.Parameters.Add(
            "@ComponentName",
            SqlDbType.VarChar, 100).Value =
            componentName;

        command.Parameters.Add(
            "@ExcludingComponentID",
            SqlDbType.Int).Value =
            excludingComponentId.HasValue
                ? excludingComponentId.Value
                : DBNull.Value;

        var count =
            Convert.ToInt32(
                await command.ExecuteScalarAsync());

        if (count > 0)
        {
            throw new InvalidOperationException(
                $"Component name '{componentName}' already exists for this transaction type.");
        }
    }


    private async Task<TransactionComponentModificationInfo?>
        GetTransactionComponentForModificationAsync(
            int transactionComponentId)
    {
        const string sql = """
            SELECT
                tc.TransactionComponentID,
                tc.TransactionTypeID,
                tc.IsRequired,
                tc.IsActive,
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

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            "@TransactionComponentID",
            SqlDbType.Int).Value =
            transactionComponentId;

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        return new TransactionComponentModificationInfo
        {
            TransactionComponentID =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "TransactionComponentID")),

            TransactionTypeID =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "TransactionTypeID")),

            IsRequired =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "IsRequired")),

            IsActive =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "IsActive")),

            TransactionTypeIsSystem =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "TransactionTypeIsSystem")),

            TransactionTypeIsActive =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "TransactionTypeIsActive"))
        };
    }


    private sealed class TransactionComponentModificationInfo
    {
        public int TransactionComponentID { get; set; }
        public int TransactionTypeID { get; set; }
        public bool IsRequired { get; set; }
        public bool IsActive { get; set; }
        public bool TransactionTypeIsSystem { get; set; }
        public bool TransactionTypeIsActive { get; set; }
    }


    private static TransactionComponentResponse
        MapTransactionComponent(
            SqlDataReader reader)
    {
        return new TransactionComponentResponse
        {
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

            ComponentCode =
                reader.GetString(
                    reader.GetOrdinal(
                        "ComponentCode")),

            ComponentName =
                reader.GetString(
                    reader.GetOrdinal(
                        "ComponentName")),

            Description =
                reader.IsDBNull(
                    reader.GetOrdinal(
                        "Description"))
                ? null
                : reader.GetString(
                    reader.GetOrdinal(
                        "Description")),

            IsRequired =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "IsRequired")),

            IsActive =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "IsActive")),

            SequenceNo =
                reader.GetInt32(
                    reader.GetOrdinal(
                        "SequenceNo")),

            TransactionTypeIsSystem =
                reader.GetBoolean(
                    reader.GetOrdinal(
                        "TransactionTypeIsSystem")),

            RuleCount =
                Convert.ToInt32(
                    reader["RuleCount"]),

            TransactionLineCount =
                Convert.ToInt32(
                    reader["TransactionLineCount"]),

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
