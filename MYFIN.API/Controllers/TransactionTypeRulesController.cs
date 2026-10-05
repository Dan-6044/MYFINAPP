using Microsoft.AspNetCore.Mvc;
using MYFIN.API.DTOs.Masters;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/transaction-type-rules")]
public class TransactionTypeRulesController : ControllerBase
{
    private readonly ITransactionTypeRuleService _service;

    public TransactionTypeRulesController(
        ITransactionTypeRuleService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<TransactionTypeRuleResponse>>>
        GetTransactionTypeRules(
            [FromQuery] int? transactionTypeId = null,
            [FromQuery] string? entrySide = null)
    {
        try
        {
            var results =
                await _service.GetTransactionTypeRulesAsync(
                    transactionTypeId,
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
                        "An unexpected error occurred while retrieving transaction type rules."
                });
        }
    }

    [HttpGet("{transactionTypeRuleId:int}")]
    public async Task<ActionResult<TransactionTypeRuleResponse>>
        GetTransactionTypeRule(
            int transactionTypeRuleId)
    {
        try
        {
            var result =
                await _service.GetTransactionTypeRuleAsync(
                    transactionTypeRuleId);

            if (result is null)
            {
                return NotFound(new
                {
                    message =
                        $"Transaction type rule {transactionTypeRuleId} was not found."
                });
            }

            return Ok(result);
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
                        "An unexpected error occurred while retrieving the transaction type rule."
                });
        }
    }

    [HttpPost]
    public async Task<ActionResult<TransactionTypeRuleResponse>>
        CreateTransactionTypeRule(
            [FromBody] CreateTransactionTypeRuleRequest request)
    {
        try
        {
            var result =
                await _service.CreateTransactionTypeRuleAsync(
                    request);

            return CreatedAtAction(
                nameof(GetTransactionTypeRule),
                new
                {
                    transactionTypeRuleId =
                        result.TransactionTypeRuleID
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
                        "An unexpected error occurred while creating the transaction type rule."
                });
        }
    }

    [HttpPut("{transactionTypeRuleId:int}")]
    public async Task<ActionResult<TransactionTypeRuleResponse>>
        UpdateTransactionTypeRule(
            int transactionTypeRuleId,
            [FromBody] UpdateTransactionTypeRuleRequest request)
    {
        try
        {
            var result =
                await _service.UpdateTransactionTypeRuleAsync(
                    transactionTypeRuleId,
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
                        "An unexpected error occurred while updating the transaction type rule."
                });
        }
    }
}