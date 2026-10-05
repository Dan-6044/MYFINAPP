
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Identity;
using Microsoft.Data.SqlClient;
using Microsoft.IdentityModel.Tokens;
using MYFIN.API.Data;
using MYFIN.API.DTOs.Auth;

namespace MYFIN.API.Services;

public class AuthService : IAuthService
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly IPasswordHasher<object> _passwordHasher;
    private readonly IConfiguration _configuration;

    public AuthService(
        SqlConnectionFactory connectionFactory,
        IPasswordHasher<object> passwordHasher,
        IConfiguration configuration)
    {
        _connectionFactory = connectionFactory;
        _passwordHasher = passwordHasher;
        _configuration = configuration;
    }

    public async Task<LoginResponse?> LoginAsync(
        LoginRequest request)
    {
        if (request == null)
        {
            throw new ArgumentNullException(nameof(request));
        }

        var username = request.Username?.Trim();
        var password = request.Password;

        if (string.IsNullOrWhiteSpace(username))
        {
            return null;
        }

        if (string.IsNullOrWhiteSpace(password))
        {
            return null;
        }

        const string sql = """
            SELECT
                UserID,
                Username,
                FirstName,
                LastName,
                Email,
                PasswordHash,
                Status
            FROM GS.Users
            WHERE Username = @Username;
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

        await using var reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        var userId =
            reader.GetInt32(
                reader.GetOrdinal("UserID"));

        var storedUsername =
            reader.GetString(
                reader.GetOrdinal("Username"));

        var firstName =
            reader.GetString(
                reader.GetOrdinal("FirstName"));

        var lastName =
            reader.IsDBNull(
                reader.GetOrdinal("LastName"))
                ? null
                : reader.GetString(
                    reader.GetOrdinal("LastName"));

        var email =
            reader.IsDBNull(
                reader.GetOrdinal("Email"))
                ? null
                : reader.GetString(
                    reader.GetOrdinal("Email"));

        var passwordHash =
            reader.IsDBNull(
                reader.GetOrdinal("PasswordHash"))
                ? null
                : reader.GetString(
                    reader.GetOrdinal("PasswordHash"));

        var status =
            reader.GetString(
                reader.GetOrdinal("Status"));

        // Only active users may log in.
        if (!string.Equals(
                status,
                "A",
                StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        // A user without a password hash cannot authenticate.
        if (string.IsNullOrWhiteSpace(passwordHash))
        {
            return null;
        }

        var verificationResult =
            _passwordHasher.VerifyHashedPassword(
                new object(),
                passwordHash,
                password);

        if (verificationResult ==
            PasswordVerificationResult.Failed)
        {
            return null;
        }

        // ============================================================
        // JWT CONFIGURATION
        // ============================================================

        var jwtKey =
            _configuration["Jwt:Key"];

        var jwtIssuer =
            _configuration["Jwt:Issuer"];

        var jwtAudience =
            _configuration["Jwt:Audience"];

        var expirationMinutes =
            _configuration.GetValue<int>(
                "Jwt:ExpirationMinutes");

        if (string.IsNullOrWhiteSpace(jwtKey))
        {
            throw new InvalidOperationException(
                "JWT signing key is not configured.");
        }

        if (string.IsNullOrWhiteSpace(jwtIssuer))
        {
            throw new InvalidOperationException(
                "JWT issuer is not configured.");
        }

        if (string.IsNullOrWhiteSpace(jwtAudience))
        {
            throw new InvalidOperationException(
                "JWT audience is not configured.");
        }

        if (expirationMinutes <= 0)
        {
            throw new InvalidOperationException(
                "JWT expiration time must be greater than zero.");
        }

        // ============================================================
        // JWT CLAIMS
        // ============================================================

        var claims = new List<Claim>
        {
            new Claim(
                ClaimTypes.NameIdentifier,
                userId.ToString()),

            new Claim(
                ClaimTypes.Name,
                storedUsername),

            new Claim(
                "firstName",
                firstName)
        };

        if (!string.IsNullOrWhiteSpace(lastName))
        {
            claims.Add(
                new Claim(
                    "lastName",
                    lastName));
        }

        if (!string.IsNullOrWhiteSpace(email))
        {
            claims.Add(
                new Claim(
                    ClaimTypes.Email,
                    email));
        }

        // ============================================================
        // JWT TOKEN
        // ============================================================

        var securityKey =
            new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey));

        var credentials =
            new SigningCredentials(
                securityKey,
                SecurityAlgorithms.HmacSha256);

        var expiresAt =
            DateTime.UtcNow.AddMinutes(
                expirationMinutes);

        var token =
            new JwtSecurityToken(
                issuer: jwtIssuer,
                audience: jwtAudience,
                claims: claims,
                expires: expiresAt,
                signingCredentials: credentials);

        var accessToken =
            new JwtSecurityTokenHandler()
                .WriteToken(token);

        return new LoginResponse
        {
            AccessToken = accessToken,

            ExpiresAt = expiresAt,

            UserID = userId,
            Username = storedUsername,
            FirstName = firstName,
            LastName = lastName,
            Email = email
        };
    }
}

