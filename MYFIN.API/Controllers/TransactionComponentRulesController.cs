using Microsoft.AspNetCore.Mvc;
using MYFIN.API.DTOs.Masters;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/transaction-component-rules")]
public class TransactionComponentRulesController : ControllerBase
{
    private readonly ITransactionComponentRuleService _service;

    public TransactionComponentRulesController(
        ITransactionComponentRuleService service)
    {
        _service = service;
    }


    // ============================================================
    // GET /api/transaction-component-rules
    // ============================================================

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int? transactionComponentId = null,
        [FromQuery] string? entrySide = null)
    {
        try
        {
            var results =
                await _service.GetTransactionComponentRulesAsync(
                    transactionComponentId,
                    entrySide);

            return Ok(results);
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
                    message =
                        "An unexpected error occurred while retrieving transaction component rules."
                });
        }
    }


    // ============================================================
    // GET /api/transaction-component-rules/{id}
    // ============================================================

    [HttpGet("{transactionComponentRuleId:int}")]
    public async Task<IActionResult> GetById(
        int transactionComponentRuleId)
    {
        try
        {
            if (transactionComponentRuleId <= 0)
            {
                return BadRequest(new
                {
                    message =
                        "TransactionComponentRuleID must be greater than zero."
                });
            }

            var result =
                await _service.GetTransactionComponentRuleAsync(
                    transactionComponentRuleId);

            if (result == null)
            {
                return NotFound(new
                {
                    message =
                        "Transaction component rule was not found."
                });
            }

            return Ok(result);
        }
        catch (Exception)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message =
                        "An unexpected error occurred while retrieving the transaction component rule."
                });
        }
    }


    // ============================================================
    // POST /api/transaction-component-rules
    // ============================================================

    [HttpPost]
    public async Task<IActionResult> Create(
        [FromBody] CreateTransactionComponentRuleRequest request)
    {
        try
        {
            var result =
                await _service.CreateTransactionComponentRuleAsync(
                    request);

            return CreatedAtAction(
                nameof(GetById),
                new
                {
                    transactionComponentRuleId =
                        result.TransactionComponentRuleID
                },
                result);
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
                    message =
                        "An unexpected error occurred while creating the transaction component rule."
                });
        }
    }


    // ============================================================
    // PUT /api/transaction-component-rules/{id}
    // ============================================================

    [HttpPut("{transactionComponentRuleId:int}")]
    public async Task<IActionResult> Update(
        int transactionComponentRuleId,
        [FromBody] UpdateTransactionComponentRuleRequest request)
    {
        try
        {
            if (transactionComponentRuleId <= 0)
            {
                return BadRequest(new
                {
                    message =
                        "TransactionComponentRuleID must be greater than zero."
                });
            }

            var result =
                await _service.UpdateTransactionComponentRuleAsync(
                    transactionComponentRuleId,
                    request);

            return Ok(result);
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
                    message =
                        "An unexpected error occurred while updating the transaction component rule."
                });
        }
    }
}