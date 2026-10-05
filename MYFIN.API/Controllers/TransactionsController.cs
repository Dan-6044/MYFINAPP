using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using MYFIN.API.DTOs.Transactions;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/transactions")]
public class TransactionsController : ControllerBase
{
    private readonly ITransactionService _transactionService;

    public TransactionsController(
        ITransactionService transactionService)
    {
        _transactionService = transactionService;
    }

    [HttpPost]
    public async Task<IActionResult> Create(
        [FromBody] CreateTransactionRequest request)
    {
        try
        {
            if (request.Lines == null ||
                request.Lines.Count == 0)
            {
                return BadRequest(new
                {
                    message = "At least one transaction line is required."
                });
            }

            var result =
                await _transactionService.CreateAsync(request);

            return Created(
                $"/api/transactions/{result.TransactionID}",
                result);
        }
        catch (SqlException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred.",
                    detail = ex.Message
                });
        }
    }

    [HttpPost("{transactionId:long}/validate")]
    public async Task<IActionResult> Validate(
        long transactionId)
    {
        try
        {
            var result =
                await _transactionService.ValidateAsync(
                    transactionId);

            return Ok(result);
        }
        catch (SqlException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred.",
                    detail = ex.Message
                });
        }
    }

    [HttpPost("{transactionId:long}/post")]
    public async Task<IActionResult> Post(
        long transactionId,
        [FromQuery] int postedByUserId)
    {
        try
        {
            if (postedByUserId <= 0)
            {
                return BadRequest(new
                {
                    message = "postedByUserId must be greater than zero."
                });
            }

            var result =
                await _transactionService.PostAsync(
                    transactionId,
                    postedByUserId);

            return Ok(result);
        }
        catch (SqlException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred.",
                    detail = ex.Message
                });
        }
    }

    [HttpGet("{transactionId:long}")]
    public async Task<IActionResult> GetDetails(
        long transactionId)
    {
        try
        {
            var result =
                await _transactionService.GetDetailsAsync(
                    transactionId);

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
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred.",
                    detail = ex.Message
                });
        }
    }

    [HttpGet]
    public async Task<IActionResult> GetList(
        [FromQuery] int? financialPeriodId,
        [FromQuery] string? status,
        [FromQuery] int? transactionTypeId,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        try
        {
            var result =
                await _transactionService.GetListAsync(
                    financialPeriodId,
                    status,
                    transactionTypeId,
                    startDate,
                    endDate,
                    page,
                    pageSize);

            return Ok(result);
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
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred.",
                    detail = ex.Message
                });
        }
    }

    [HttpPost("{transactionId:long}/void")]
    public async Task<IActionResult> Void(
        long transactionId,
        [FromQuery] int voidedByUserId,
        [FromQuery] string voidReason)
    {
        try
        {
            if (transactionId <= 0)
            {
                return BadRequest(new
                {
                    message = "transactionId must be greater than zero."
                });
            }

            if (voidedByUserId <= 0)
            {
                return BadRequest(new
                {
                    message = "voidedByUserId must be greater than zero."
                });
            }

            if (string.IsNullOrWhiteSpace(voidReason))
            {
                return BadRequest(new
                {
                    message = "voidReason is required."
                });
            }

            var result =
                await _transactionService.VoidAsync(
                    transactionId,
                    voidedByUserId,
                    voidReason);

            return Ok(result);
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
            return BadRequest(new
            {
                message = ex.Message
            });
        }
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred.",
                    detail = ex.Message
                });
        }
    }
}