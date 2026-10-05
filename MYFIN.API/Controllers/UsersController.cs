using Microsoft.AspNetCore.Mvc;
using MYFIN.API.DTOs.Masters;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    /* ============================================================
       GET /api/users
       GET /api/users?status=A
       GET /api/users?status=I
       ============================================================ */

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<UserResponse>>> GetUsers(
        [FromQuery] string? status = null)
    {
        try
        {
            var users = await _userService.GetUsersAsync(status);

            return Ok(users);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (Exception)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred."
                });
        }
    }


    /* ============================================================
       GET /api/users/{userId}
       ============================================================ */

    [HttpGet("{userId:int}")]
    public async Task<ActionResult<UserResponse>> GetUser(
        int userId)
    {
        try
        {
            var user = await _userService.GetUserAsync(userId);

            if (user is null)
            {
                return NotFound(new
                {
                    message = $"User with ID {userId} was not found."
                });
            }

            return Ok(user);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (Exception)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred."
                });
        }
    }


    /* ============================================================
       POST /api/users
       ============================================================ */

    [HttpPost]
    public async Task<ActionResult<UserResponse>> CreateUser(
        [FromBody] CreateUserRequest request)
    {
        try
        {
            var user =
                await _userService.CreateUserAsync(request);

            return CreatedAtAction(
                nameof(GetUser),
                new
                {
                    userId = user.UserID
                },
                user);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new
            {
                message = ex.Message
            });
        }
        catch (Exception)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred."
                });
        }
    }


    /* ============================================================
       PUT /api/users/{userId}
       ============================================================ */

    [HttpPut("{userId:int}")]
    public async Task<ActionResult<UserResponse>> UpdateUser(
        int userId,
        [FromBody] UpdateUserRequest request)
    {
        try
        {
            var user =
                await _userService.UpdateUserAsync(
                    userId,
                    request);

            return Ok(user);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new
            {
                message = ex.Message
            });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new
            {
                message = ex.Message
            });
        }
        catch (Exception)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred."
                });
        }
    }


    /* ============================================================
       PATCH /api/users/{userId}/activate
       ============================================================ */

    [HttpPatch("{userId:int}/activate")]
    public async Task<ActionResult<UserResponse>> ActivateUser(
        int userId)
    {
        try
        {
            var user =
                await _userService.ActivateUserAsync(userId);

            return Ok(user);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new
            {
                message = ex.Message
            });
        }
        catch (Exception)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred."
                });
        }
    }


    /* ============================================================
       PATCH /api/users/{userId}/deactivate
       ============================================================ */

    [HttpPatch("{userId:int}/deactivate")]
    public async Task<ActionResult<UserResponse>> DeactivateUser(
        int userId)
    {
        try
        {
            var user =
                await _userService.DeactivateUserAsync(userId);

            return Ok(user);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new
            {
                message = ex.Message
            });
        }
        catch (Exception)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred."
                });
        }
    }
}