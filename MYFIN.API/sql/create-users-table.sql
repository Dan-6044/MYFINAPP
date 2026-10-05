-- ============================================================
-- MYFIN Database - Users Table
-- ============================================================
-- Required by: MYFIN.API.Services.AuthService
-- Queries:   GS.Users (UserID, Username, FirstName, LastName, Email, PasswordHash, Status)
-- ============================================================

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

-- ============================================================
-- Seed an initial Admin user
-- ============================================================
-- IMPORTANT: Replace the placeholder hash below with a real
-- ASP.NET Identity PasswordHasher<object> hash.
--
-- To generate a hash, run the PasswordHashGenerator tool
-- included in this solution, or use the snippet in
-- docs/password-hash-generation.md
-- ============================================================

DECLARE @PasswordHash VARCHAR(255) = 'REPLACE_WITH_REAL_HASH';

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
