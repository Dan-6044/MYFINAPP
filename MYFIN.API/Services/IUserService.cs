using MYFIN.API.DTOs.Masters;

namespace MYFIN.API.Services;

public interface IUserService
{
    Task<IReadOnlyList<UserResponse>>
        GetUsersAsync(string? status = null);

    Task<UserResponse?>
        GetUserAsync(int userId);

    Task<UserResponse>
        CreateUserAsync(CreateUserRequest request);

    Task<UserResponse>
        UpdateUserAsync(
            int userId,
            UpdateUserRequest request);

    Task<UserResponse>
        ActivateUserAsync(int userId);

    Task<UserResponse>
        DeactivateUserAsync(int userId);
}