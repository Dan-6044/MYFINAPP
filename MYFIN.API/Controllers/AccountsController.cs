using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/accounts")]
public class AccountsController : ControllerBase
{
    private readonly ITransactionService _transactionService;
    private readonly IMasterDataService _masterDataService;

    public AccountsController(
        ITransactionService transactionService,
        IMasterDataService masterDataService)
    {
        _transactionService = transactionService;
        _masterDataService = masterDataService;
    }

    // ============================================================
    // MASTER DATA
    // ============================================================

    [HttpGet]
    public async Task<IActionResult> GetAccounts(
        [FromQuery] bool? isActive)
    {
        try
        {
            var result =
                await _masterDataService.GetAccountsAsync(isActive);

            return Ok(result);
        }
        catch (SqlException ex)
        {
            return StatusCode(500, new
            {
                message = "A database error occurred.",
                detail = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new
            {
                message = "An unexpected error occurred.",
                detail = ex.Message
            });
        }
    }

    [HttpGet("{coaId:long}")]
    public async Task<IActionResult> GetAccount(long coaId)
    {
        try
        {
            var result =
                await _masterDataService.GetAccountAsync(coaId);

            if (result == null)
            {
                return NotFound(new
                {
                    message = $"Account {coaId} was not found."
                });
            }

            return Ok(result);
        }
        catch (SqlException ex)
        {
            return StatusCode(500, new
            {
                message = "A database error occurred.",
                detail = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new
            {
                message = "An unexpected error occurred.",
                detail = ex.Message
            });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateAccount(
        [FromBody] DTOs.Masters.CreateAccountRequest request)
    {
        try
        {
            var result =
                await _masterDataService.CreateAccountAsync(request);

            return CreatedAtAction(
                nameof(GetAccount),
                new { coaId = result.COAID },
                result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new
            {
                message = ex.Message
            });
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
        catch (SqlException ex)
        {
            return StatusCode(500, new
            {
                message = "A database error occurred.",
                detail = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new
            {
                message = "An unexpected error occurred.",
                detail = ex.Message
            });
        }
    }

    [HttpPut("{coaId:long}")]
    public async Task<IActionResult> UpdateAccount(
        long coaId,
        [FromBody] DTOs.Masters.UpdateAccountRequest request)
    {
        try
        {
            var result =
                await _masterDataService.UpdateAccountAsync(
                    coaId,
                    request);

            return Ok(result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new
            {
                message = ex.Message
            });
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
        catch (SqlException ex)
        {
            return StatusCode(500, new
            {
                message = "A database error occurred.",
                detail = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new
            {
                message = "An unexpected error occurred.",
                detail = ex.Message
            });
        }
    }

    [HttpPatch("{coaId:long}/activate")]
    public async Task<IActionResult> ActivateAccount(long coaId)
    {
        return await SetAccountStatus(coaId, true);
    }

    [HttpPatch("{coaId:long}/deactivate")]
    public async Task<IActionResult> DeactivateAccount(long coaId)
    {
        return await SetAccountStatus(coaId, false);
    }

    private async Task<IActionResult> SetAccountStatus(
        long coaId,
        bool isActive)
    {
        try
        {
            var result =
                await _masterDataService
                    .SetAccountActiveStatusAsync(
                        coaId,
                        isActive);

            return Ok(result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new
            {
                message = ex.Message
            });
        }
        catch (SqlException ex)
        {
            return StatusCode(500, new
            {
                message = "A database error occurred.",
                detail = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new
            {
                message = "An unexpected error occurred.",
                detail = ex.Message
            });
        }
    }

    // ============================================================
    // EXISTING ACCOUNT STATEMENT
    // ============================================================

    [HttpGet("{coaId:long}/statement")]
    public async Task<IActionResult> GetStatement(
        long coaId,
        [FromQuery] int? financialPeriodId,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        try
        {
            var result =
                await _transactionService.GetAccountStatementAsync(
                    coaId,
                    financialPeriodId,
                    startDate,
                    endDate);

            if (result == null)
            {
                return NotFound(new
                {
                    message = $"Account {coaId} was not found."
                });
            }

            return Ok(result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new
            {
                message = ex.Message
            });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (SqlException ex)
        {
            return StatusCode(500, new
            {
                message = "A database error occurred.",
                detail = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new
            {
                message = "An unexpected error occurred.",
                detail = ex.Message
            });
        }
    }
}