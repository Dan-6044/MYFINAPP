using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.Masters;

public class UpdateUserRequest
{
    [Required]
    [StringLength(
        50,
        MinimumLength = 1,
        ErrorMessage = "Username must be between 1 and 50 characters.")]
    public string Username { get; set; } = string.Empty;

    [Required]
    [StringLength(
        100,
        MinimumLength = 1,
        ErrorMessage = "FirstName must be between 1 and 100 characters.")]
    public string FirstName { get; set; } = string.Empty;

    [StringLength(
        100,
        ErrorMessage = "MiddleName cannot exceed 100 characters.")]
    public string? MiddleName { get; set; }

    [StringLength(
        100,
        ErrorMessage = "LastName cannot exceed 100 characters.")]
    public string? LastName { get; set; }

    [StringLength(
        30,
        ErrorMessage = "PhoneNumber cannot exceed 30 characters.")]
    public string? PhoneNumber { get; set; }

    [EmailAddress(
        ErrorMessage = "Email must be a valid email address.")]
    [StringLength(
        150,
        ErrorMessage = "Email cannot exceed 150 characters.")]
    public string? Email { get; set; }

    [RegularExpression(
        "^[AaIi]$",
        ErrorMessage = "Status must be A or I.")]
    public string Status { get; set; } = "A";
}