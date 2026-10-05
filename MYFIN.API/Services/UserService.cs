using Microsoft.Data.SqlClient;
using MYFIN.API.Data;
using MYFIN.API.DTOs.Masters;
using Microsoft.AspNetCore.Identity;

namespace MYFIN.API.Services;

public class UserService : IUserService
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly IPasswordHasher<object> _passwordHasher;

    public UserService(
        SqlConnectionFactory connectionFactory,
        IPasswordHasher<object> passwordHasher)
    {
        _connectionFactory = connectionFactory;
        _passwordHasher = passwordHasher;
    }
    /* ============================================================
       GET ALL USERS
       Optional status filter: A / I
       ============================================================ */

    public async Task<IReadOnlyList<UserResponse>> GetUsersAsync(
        string? status = null)
    {
        status = NormalizeStatus(status);

        const string sql = """
            SELECT
                UserID,
                Username,
                FirstName,
                MiddleName,
                LastName,
                PhoneNumber,
                Email,
                Status,
                CreatedAt,
                UpdatedAt
            FROM GS.Users
            WHERE (@Status IS NULL OR Status = @Status)
            ORDER BY UserID;
            """;

        var users = new List<UserResponse>();

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        await using var command = new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@Status", System.Data.SqlDbType.Char, 1)
            {
                Value = (object?)status ?? DBNull.Value
            });

        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            users.Add(MapUser(reader));
        }

        return users;
    }


    /* ============================================================
       GET SINGLE USER
       ============================================================ */

    public async Task<UserResponse?> GetUserAsync(int userId)
    {
        ValidateUserId(userId);

        const string sql = """
            SELECT
                UserID,
                Username,
                FirstName,
                MiddleName,
                LastName,
                PhoneNumber,
                Email,
                Status,
                CreatedAt,
                UpdatedAt
            FROM GS.Users
            WHERE UserID = @UserID;
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

        return MapUser(reader);
    }


    /* ============================================================
       CREATE USER
       ============================================================ */

    public async Task<UserResponse> CreateUserAsync(
        CreateUserRequest request)
    {
        if (request is null)
        {
            throw new ArgumentException(
                "User request is required.");
        }

        var username = NormalizeRequired(
            request.Username,
            "Username");

        var firstName = NormalizeRequired(
            request.FirstName,
            "FirstName");

        var middleName = NormalizeOptional(request.MiddleName);
        var lastName = NormalizeOptional(request.LastName);
        var phoneNumber = NormalizeOptional(request.PhoneNumber);
        var email = NormalizeEmail(request.Email);
        var status = NormalizeStatus(request.Status);

        var password = NormalizeRequired(
            request.Password,
            "Password");

        ValidateLength(username, 50, "Username");
        ValidateLength(firstName, 100, "FirstName");
        ValidateLength(middleName, 100, "MiddleName");
        ValidateLength(lastName, 100, "LastName");
        ValidateLength(phoneNumber, 30, "PhoneNumber");
        ValidateLength(email, 150, "Email");
        ValidateLength(password, 128, "Password");

        var passwordHash =
            _passwordHasher.HashPassword(
                new object(),
                password);

        await EnsureUsernameAvailableAsync(
            username,
            excludedUserId: null);

        if (email is not null)
        {
            await EnsureEmailAvailableAsync(
                email,
                excludedUserId: null);
        }

        const string sql = """
            INSERT INTO GS.Users
            (
                Username,
                FirstName,
                MiddleName,
                LastName,
                PhoneNumber,
                Email,
                PasswordHash,
                Status
            )
            OUTPUT
                INSERTED.UserID,
                INSERTED.Username,
                INSERTED.FirstName,
                INSERTED.MiddleName,
                INSERTED.LastName,
                INSERTED.PhoneNumber,
                INSERTED.Email,
                INSERTED.Status,
                INSERTED.CreatedAt,
                INSERTED.UpdatedAt
            VALUES
            (
                @Username,
                @FirstName,
                @MiddleName,
                @LastName,
                @PhoneNumber,
                @Email,
                @PasswordHash,
                @Status
            );
            """;

        try
        {
            await using var connection =
                _connectionFactory.CreateConnection();

            await connection.OpenAsync();

            await using var command =
                new SqlCommand(sql, connection);

            AddUserParameters(
                command,
                username,
                firstName,
                middleName,
                lastName,
                phoneNumber,
                email,
                status,
                passwordHash);

            await using var reader =
                await command.ExecuteReaderAsync();

            if (!await reader.ReadAsync())
            {
                throw new InvalidOperationException(
                    "User was not created.");
            }

            return MapUser(reader);
        }
        catch (SqlException ex) when (IsUniqueConstraintViolation(ex))
        {
            throw new InvalidOperationException(
                "Username or email already exists.",
                ex);
        }
    }


    /* ============================================================
       UPDATE USER
       ============================================================ */

    public async Task<UserResponse> UpdateUserAsync(
        int userId,
        UpdateUserRequest request)
    {
        ValidateUserId(userId);

        if (request is null)
        {
            throw new ArgumentException(
                "User request is required.");
        }

        var username = NormalizeRequired(
            request.Username,
            "Username");

        var firstName = NormalizeRequired(
            request.FirstName,
            "FirstName");

        var middleName = NormalizeOptional(request.MiddleName);
        var lastName = NormalizeOptional(request.LastName);
        var phoneNumber = NormalizeOptional(request.PhoneNumber);
        var email = NormalizeEmail(request.Email);
        var status = NormalizeStatus(request.Status);

        ValidateLength(username, 50, "Username");
        ValidateLength(firstName, 100, "FirstName");
        ValidateLength(middleName, 100, "MiddleName");
        ValidateLength(lastName, 100, "LastName");
        ValidateLength(phoneNumber, 30, "PhoneNumber");
        ValidateLength(email, 150, "Email");

        var existingUser = await GetUserAsync(userId);

        if (existingUser is null)
        {
            throw new KeyNotFoundException(
                $"User with ID {userId} was not found.");
        }

        await EnsureUsernameAvailableAsync(
            username,
            excludedUserId: userId);

        if (email is not null)
        {
            await EnsureEmailAvailableAsync(
                email,
                excludedUserId: userId);
        }

        const string sql = """
            UPDATE GS.Users
            SET
                Username = @Username,
                FirstName = @FirstName,
                MiddleName = @MiddleName,
                LastName = @LastName,
                PhoneNumber = @PhoneNumber,
                Email = @Email,
                Status = @Status,
                UpdatedAt = SYSDATETIME()
            OUTPUT
                INSERTED.UserID,
                INSERTED.Username,
                INSERTED.FirstName,
                INSERTED.MiddleName,
                INSERTED.LastName,
                INSERTED.PhoneNumber,
                INSERTED.Email,
                INSERTED.Status,
                INSERTED.CreatedAt,
                INSERTED.UpdatedAt
            WHERE UserID = @UserID;
            """;

        try
        {
            await using var connection =
                _connectionFactory.CreateConnection();

            await connection.OpenAsync();

            await using var command =
                new SqlCommand(sql, connection);

            command.Parameters.Add(
                new SqlParameter("@UserID", System.Data.SqlDbType.Int)
                {
                    Value = userId
                });

            AddUserParameters(
                command,
                username,
                firstName,
                middleName,
                lastName,
                phoneNumber,
                email,
                status);

            await using var reader =
                await command.ExecuteReaderAsync();

            if (!await reader.ReadAsync())
            {
                throw new KeyNotFoundException(
                    $"User with ID {userId} was not found.");
            }

            return MapUser(reader);
        }
        catch (SqlException ex) when (IsUniqueConstraintViolation(ex))
        {
            throw new InvalidOperationException(
                "Username or email already exists.",
                ex);
        }
    }


    /* ============================================================
       ACTIVATE USER
       ============================================================ */

    public async Task<UserResponse> ActivateUserAsync(int userId)
    {
        ValidateUserId(userId);

        return await SetUserStatusAsync(
            userId,
            "A");
    }


    /* ============================================================
       DEACTIVATE USER
       ============================================================ */

    public async Task<UserResponse> DeactivateUserAsync(int userId)
    {
        ValidateUserId(userId);

        return await SetUserStatusAsync(
            userId,
            "I");
    }


    /* ============================================================
       SET STATUS
       ============================================================ */

    private async Task<UserResponse> SetUserStatusAsync(
        int userId,
        string status)
    {
        const string sql = """
            UPDATE GS.Users
            SET
                Status = @Status,
                UpdatedAt = SYSDATETIME()
            OUTPUT
                INSERTED.UserID,
                INSERTED.Username,
                INSERTED.FirstName,
                INSERTED.MiddleName,
                INSERTED.LastName,
                INSERTED.PhoneNumber,
                INSERTED.Email,
                INSERTED.Status,
                INSERTED.CreatedAt,
                INSERTED.UpdatedAt
            WHERE UserID = @UserID;
            """;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter("@UserID", System.Data.SqlDbType.Int)
            {
                Value = userId
            });

        command.Parameters.Add(
            new SqlParameter("@Status", System.Data.SqlDbType.Char, 1)
            {
                Value = status
            });

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            throw new KeyNotFoundException(
                $"User with ID {userId} was not found.");
        }

        return MapUser(reader);
    }


    /* ============================================================
       USERNAME AVAILABILITY
       ============================================================ */

    private async Task EnsureUsernameAvailableAsync(
        string username,
        int? excludedUserId)
    {
        const string sql = """
            SELECT TOP (1) UserID
            FROM GS.Users
            WHERE Username = @Username
              AND (@ExcludedUserID IS NULL
                   OR UserID <> @ExcludedUserID);
            """;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter(
                "@Username",
                System.Data.SqlDbType.VarChar,
                50)
            {
                Value = username
            });

        command.Parameters.Add(
            new SqlParameter(
                "@ExcludedUserID",
                System.Data.SqlDbType.Int)
            {
                Value = (object?)excludedUserId ?? DBNull.Value
            });

        var result = await command.ExecuteScalarAsync();

        if (result is not null)
        {
            throw new InvalidOperationException(
                $"Username '{username}' is already in use.");
        }
    }


    /* ============================================================
       EMAIL AVAILABILITY
       ============================================================ */

    private async Task EnsureEmailAvailableAsync(
        string email,
        int? excludedUserId)
    {
        const string sql = """
            SELECT TOP (1) UserID
            FROM GS.Users
            WHERE Email = @Email
              AND (@ExcludedUserID IS NULL
                   OR UserID <> @ExcludedUserID);
            """;

        await using var connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(sql, connection);

        command.Parameters.Add(
            new SqlParameter(
                "@Email",
                System.Data.SqlDbType.VarChar,
                150)
            {
                Value = email
            });

        command.Parameters.Add(
            new SqlParameter(
                "@ExcludedUserID",
                System.Data.SqlDbType.Int)
            {
                Value = (object?)excludedUserId ?? DBNull.Value
            });

        var result = await command.ExecuteScalarAsync();

        if (result is not null)
        {
            throw new InvalidOperationException(
                $"Email '{email}' is already in use.");
        }
    }


    /* ============================================================
       ADD SQL PARAMETERS
       ============================================================ */

    private static void AddUserParameters(
        SqlCommand command,
        string username,
        string firstName,
        string? middleName,
        string? lastName,
        string? phoneNumber,
        string? email,
        string status,
        string? passwordHash = null)
    {
        command.Parameters.Add(
            new SqlParameter(
                "@Username",
                System.Data.SqlDbType.VarChar,
                50)
            {
                Value = username
            });

        command.Parameters.Add(
            new SqlParameter(
                "@FirstName",
                System.Data.SqlDbType.VarChar,
                100)
            {
                Value = firstName
            });

        command.Parameters.Add(
            new SqlParameter(
                "@MiddleName",
                System.Data.SqlDbType.VarChar,
                100)
            {
                Value = (object?)middleName ?? DBNull.Value
            });

        command.Parameters.Add(
            new SqlParameter(
                "@LastName",
                System.Data.SqlDbType.VarChar,
                100)
            {
                Value = (object?)lastName ?? DBNull.Value
            });

        command.Parameters.Add(
            new SqlParameter(
                "@PhoneNumber",
                System.Data.SqlDbType.VarChar,
                30)
            {
                Value = (object?)phoneNumber ?? DBNull.Value
            });

        command.Parameters.Add(
            new SqlParameter(
                "@Email",
                System.Data.SqlDbType.VarChar,
                150)
            {
                Value = (object?)email ?? DBNull.Value
            });

        command.Parameters.Add(
            new SqlParameter(
                "@Status",
                System.Data.SqlDbType.Char,
                1)
            {
                Value = status
            });

        if (passwordHash is not null)
        {
            command.Parameters.Add(
                new SqlParameter(
                    "@PasswordHash",
                    System.Data.SqlDbType.VarChar,
                    500)
                {
                    Value = passwordHash
                });
        }
    }


    /* ============================================================
       MAP DATABASE ROW → RESPONSE DTO
       PasswordHash is intentionally never selected.
       ============================================================ */

    private static UserResponse MapUser(
        SqlDataReader reader)
    {
        return new UserResponse
        {
            UserID = reader.GetInt32(
                reader.GetOrdinal("UserID")),

            Username = reader.GetString(
                reader.GetOrdinal("Username")),

            FirstName = reader.GetString(
                reader.GetOrdinal("FirstName")),

            MiddleName = reader.IsDBNull(
                reader.GetOrdinal("MiddleName"))
                ? null
                : reader.GetString(
                    reader.GetOrdinal("MiddleName")),

            LastName = reader.IsDBNull(
                reader.GetOrdinal("LastName"))
                ? null
                : reader.GetString(
                    reader.GetOrdinal("LastName")),

            PhoneNumber = reader.IsDBNull(
                reader.GetOrdinal("PhoneNumber"))
                ? null
                : reader.GetString(
                    reader.GetOrdinal("PhoneNumber")),

            Email = reader.IsDBNull(
                reader.GetOrdinal("Email"))
                ? null
                : reader.GetString(
                    reader.GetOrdinal("Email")),

            Status = reader.GetString(
                reader.GetOrdinal("Status")),

            CreatedAt = reader.GetDateTime(
                reader.GetOrdinal("CreatedAt")),

            UpdatedAt = reader.IsDBNull(
                reader.GetOrdinal("UpdatedAt"))
                ? null
                : reader.GetDateTime(
                    reader.GetOrdinal("UpdatedAt"))
        };
    }


    /* ============================================================
       NORMALIZATION
       ============================================================ */

    private static string NormalizeRequired(
        string? value,
        string fieldName)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException(
                $"{fieldName} is required.");
        }

        return value.Trim();
    }


    private static string? NormalizeOptional(
        string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        return value.Trim();
    }


    private static string? NormalizeEmail(
        string? email)
    {
        var normalized = NormalizeOptional(email);

        return normalized?.ToLowerInvariant();
    }


    private static string NormalizeStatus(
        string? status)
    {
        if (string.IsNullOrWhiteSpace(status))
        {
            return "A";
        }

        var normalized = status.Trim().ToUpperInvariant();

        if (normalized is not ("A" or "I"))
        {
            throw new ArgumentException(
                "Status must be A or I.");
        }

        return normalized;
    }


    /* ============================================================
       VALIDATION
       ============================================================ */

    private static void ValidateUserId(int userId)
    {
        if (userId <= 0)
        {
            throw new ArgumentException(
                "UserID must be greater than zero.");
        }
    }


    private static void ValidateLength(
        string? value,
        int maxLength,
        string fieldName)
    {
        if (value is not null &&
            value.Length > maxLength)
        {
            throw new ArgumentException(
                $"{fieldName} cannot exceed {maxLength} characters.");
        }
    }


    /* ============================================================
       SQL UNIQUE CONSTRAINT DETECTION
       ============================================================ */

    private static bool IsUniqueConstraintViolation(
        SqlException ex)
    {
        return ex.Number is 2601 or 2627;
    }
}