using Microsoft.Data.SqlClient;
using MYFIN.API.Data;
using MYFIN.API.Services;
using Microsoft.OpenApi;
using Microsoft.AspNetCore.OpenApi;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.Authorization;
using System.Text;


var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddOpenApi(options =>
{
    options.AddDocumentTransformer((document, context, cancellationToken) =>
    {
        document.Components ??= new OpenApiComponents();
        if (document.Components.SecuritySchemes == null)
        {
            document.Components.SecuritySchemes = new Dictionary<string, IOpenApiSecurityScheme>();
        }
        document.Components.SecuritySchemes["Bearer"] = new OpenApiSecurityScheme
        {
            Name = "Authorization",
            Type = SecuritySchemeType.Http,
            Scheme = "bearer",
            BearerFormat = "JWT",
            In = ParameterLocation.Header,
            Description = "Enter your JWT token in the format: Bearer {token}"
        };

        foreach (var operation in document.Paths.Values.SelectMany(path => path.Operations.Values))
        {
            operation.Security ??= new List<OpenApiSecurityRequirement>();
            var requirement = new OpenApiSecurityRequirement();
            var schemeReference = new OpenApiSecuritySchemeReference("Bearer", document, null);
            requirement[schemeReference] = new List<string>();
            operation.Security.Add(requirement);
        }

        return Task.CompletedTask;
    });
});
builder.Services.AddScoped<SqlConnectionFactory>();

builder.Services.AddScoped<ITransactionService, TransactionService>();

builder.Services.AddScoped<IJournalService, JournalService>();

builder.Services.AddScoped<IMasterDataService, MasterDataService>();

builder.Services.AddScoped<ITransactionTypeRuleService, TransactionTypeRuleService>();

builder.Services.AddScoped<
    ITransactionComponentRuleService,
    TransactionComponentRuleService>();

builder.Services.AddScoped<IUserService, UserService>();

builder.Services.AddSingleton<
    Microsoft.AspNetCore.Identity.IPasswordHasher<object>,
    Microsoft.AspNetCore.Identity.PasswordHasher<object>>();

builder.Services.AddScoped<IAuthService, AuthService>();

builder.Services.AddScoped<IFinancialPeriodService, FinancialPeriodService>();

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    var jwtSettings = builder.Configuration.GetSection("Jwt");
    var key = jwtSettings["Key"] ?? string.Empty;

    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key))
    };
});

builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();
});

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi().AllowAnonymous();

    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint(
            "/openapi/v1.json",
            "MYFIN API v1");
    });
}

app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";

        var feature = context.Features.Get<Microsoft.AspNetCore.Diagnostics.IExceptionHandlerFeature>();
        var error = feature?.Error;

        var message = error?.Message ?? "An unexpected error occurred.";

        await context.Response.WriteAsJsonAsync(new
        {
            message = message.Contains("open DataReader")
                ? "A database operation failed. Please try again."
                : message
        });
    });
});

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.MapGet("/api/health", () =>
{
    return Results.Ok(new
    {
        Status = "API is running",
        Application = "MYFIN API"
    });
})
.AllowAnonymous();

app.MapGet("/api/health/database", async (
    IConfiguration configuration) =>
{
    var connectionString =
        configuration.GetConnectionString("MYFIN");

    if (string.IsNullOrWhiteSpace(connectionString))
    {
        return Results.Problem(
            "MYFIN database connection string is not configured.");
    }

    try
    {
        await using var connection =
            new SqlConnection(connectionString);

        await connection.OpenAsync();

        await using var command =
            new SqlCommand(
                "SELECT DB_NAME()",
                connection);

        var databaseName =
            await command.ExecuteScalarAsync();

        return Results.Ok(new
        {
            Status = "Database connection successful",
            Server = connection.DataSource,
            Database = databaseName
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(
            detail: ex.Message,
            title: "Database connection failed");
    }
})
.AllowAnonymous();

app.Run();
