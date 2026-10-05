using MYFIN.API.DTOs.Auth;

namespace MYFIN.API.Services;

public interface IAuthService
{
    Task<LoginResponse?> LoginAsync(
        LoginRequest request);
}