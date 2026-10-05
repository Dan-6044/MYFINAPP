using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.Auth;

public class LoginRequest
{
    [Required]
    [StringLength(
        50,
        MinimumLength = 1,
        ErrorMessage = "Username must be between 1 and 50 characters.")]
    public string Username { get; set; } = string.Empty;

    [Required]
    [StringLength(
        128,
        MinimumLength = 8,
        ErrorMessage = "Password must be between 8 and 128 characters.")]
    public string Password { get; set; } = string.Empty;
}