using Microsoft.AspNetCore.Mvc;
using MYFIN.API.DTOs.Masters;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/transaction-types")]
public class TransactionTypesController : ControllerBase
{
    private readonly IMasterDataService _masterDataService;

    public TransactionTypesController(
        IMasterDataService masterDataService)
    {
        _masterDataService = masterDataService;
    }


    // ============================================================
    // GET: api/transaction-types
    // GET: api/transaction-types?isActive=true
    // GET: api/transaction-types?isActive=false
    // ============================================================

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<TransactionTypeResponse>>>
        GetTransactionTypes([FromQuery] bool? isActive = null)
    {
        try
        {
            var result =
                await _masterDataService.GetTransactionTypesAsync(
                    isActive);

            return Ok(result);
        }
        catch (Exception)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An unexpected error occurred while retrieving transaction types."
                });
        }
    }


    // ============================================================
    // GET: api/transaction-types/{transactionTypeId}
    // ============================================================

    [HttpGet("{transactionTypeId:int}")]
    public async Task<ActionResult<TransactionTypeResponse>>
        GetTransactionType(int transactionTypeId)
    {
        try
        {
            var result =
                await _masterDataService.GetTransactionTypeAsync(
                    transactionTypeId);

            if (result == null)
            {
                return NotFound(new
                {
                    message =
                        $"Transaction Type {transactionTypeId} was not found."
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
                    message = "An unexpected error occurred while retrieving the transaction type."
                });
        }
    }


    // ============================================================
    // POST: api/transaction-types
    // ============================================================

    [HttpPost]
    public async Task<ActionResult<TransactionTypeResponse>>
        CreateTransactionType(
            [FromBody] CreateTransactionTypeRequest request)
    {
        try
        {
            var result =
                await _masterDataService.CreateTransactionTypeAsync(
                    request);

            return CreatedAtAction(
                nameof(GetTransactionType),
                new
                {
                    transactionTypeId =
                        result.TransactionTypeID
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
                    message = "An unexpected error occurred while creating the transaction type."
                });
        }
    }


    // ============================================================
    // PUT: api/transaction-types/{transactionTypeId}
    // ============================================================

    [HttpPut("{transactionTypeId:int}")]
    public async Task<ActionResult<TransactionTypeResponse>>
        UpdateTransactionType(
            int transactionTypeId,
            [FromBody] UpdateTransactionTypeRequest request)
    {
        try
        {
            var result =
                await _masterDataService.UpdateTransactionTypeAsync(
                    transactionTypeId,
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
                    message = "An unexpected error occurred while updating the transaction type."
                });
        }
    }


    // ============================================================
    // PATCH: api/transaction-types/{transactionTypeId}/activate
    // ============================================================

    [HttpPatch("{transactionTypeId:int}/activate")]
    public async Task<ActionResult<TransactionTypeResponse>>
        ActivateTransactionType(int transactionTypeId)
    {
        try
        {
            var result =
                await _masterDataService
                    .SetTransactionTypeActiveStatusAsync(
                        transactionTypeId,
                        true);

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
                    message = "An unexpected error occurred while activating the transaction type."
                });
        }
    }


    // ============================================================
    // PATCH: api/transaction-types/{transactionTypeId}/deactivate
    // ============================================================

    [HttpPatch("{transactionTypeId:int}/deactivate")]
    public async Task<ActionResult<TransactionTypeResponse>>
        DeactivateTransactionType(int transactionTypeId)
    {
        try
        {
            var result =
                await _masterDataService
                    .SetTransactionTypeActiveStatusAsync(
                        transactionTypeId,
                        false);

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
                    message = "An unexpected error occurred while deactivating the transaction type."
                });
        }
    }
}
