namespace MYFIN.API.DTOs.Auth;

public class LoginResponse
{
    public string AccessToken { get; set; } = string.Empty;

    public DateTime ExpiresAt { get; set; }

    public int UserID { get; set; }

    public string Username { get; set; } = string.Empty;

    public string FirstName { get; set; } = string.Empty;

    public string? LastName { get; set; }

    public string? Email { get; set; }
}