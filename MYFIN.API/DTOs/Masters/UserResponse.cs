namespace MYFIN.API.DTOs.Masters;

public class UserResponse
{
    public int UserID { get; set; }

    public string Username { get; set; } = string.Empty;

    public string FirstName { get; set; } = string.Empty;

    public string? MiddleName { get; set; }

    public string? LastName { get; set; }

    public string? PhoneNumber { get; set; }

    public string? Email { get; set; }

    public string Status { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }
}