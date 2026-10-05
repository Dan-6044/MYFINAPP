# MYFIN API - Swagger Login Setup

## 1. Create the Users Table

Run the SQL script below against your `MYFIN` database:

```sql
-- File: sql/create-users-table.sql
CREATE TABLE GS.Users
(
    UserID        INT IDENTITY(1,1) PRIMARY KEY,
    Username      VARCHAR(50)   NOT NULL UNIQUE,
    FirstName     VARCHAR(100)  NOT NULL,
    LastName      VARCHAR(100)  NULL,
    Email         VARCHAR(255)  NULL,
    PasswordHash  VARCHAR(255)  NOT NULL,
    Status        CHAR(1)       NOT NULL DEFAULT 'A',
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt     DATETIME2     NULL
);
```

## 2. Generate a Password Hash

The API uses ASP.NET Identity's `PasswordHasher<object>` to hash passwords. To seed an initial admin user, you need to generate a hash first.

### Option A: Use the included tool

```bash
cd tools/PasswordHashGenerator
dotnet run
```

Enter your desired password when prompted. Copy the generated hash.

### Option B: Use any .NET environment

```csharp
using Microsoft.AspNetCore.Identity;

var hasher = new PasswordHasher<object>();
var hash = hasher.HashPassword(null, "YourPassword123!");
Console.WriteLine(hash);
```

## 3. Seed the Initial User

Replace `REPLACE_WITH_REAL_HASH` in the script below with the hash you generated, then run it:

```sql
DECLARE @PasswordHash VARCHAR(255) = 'AQAAAAEAACcQAAAAE...';

INSERT INTO GS.Users
(
    Username,
    FirstName,
    LastName,
    Email,
    PasswordHash,
    Status
)
VALUES
(
    'admin',
    'System',
    'Administrator',
    'admin@myfin.local',
    @PasswordHash,
    'A'
);
```

## 4. How Swagger Login Works

- Navigate to `/swagger` (Development environment)
- Click the **Authorize** button at the top right
- Enter your username and password in the OAuth2 dialog
- Click **Authorize**

The JavaScript interceptors added to `Program.cs` will:
1. Convert Swagger UI's form-urlencoded login request to JSON
2. Send it to `/api/auth/login`
3. Convert the JSON response to OAuth2 format
4. Store the JWT token automatically

All subsequent API requests will include the `Authorization: Bearer <token>` header.

## Notes

- The `GS.Users` table must exist before you can log in
- Passwords must be at least 8 characters long
- Only users with `Status = 'A'` (Active) can log in
- The `/api/auth/login` endpoint continues to accept JSON for non-Swagger clients
