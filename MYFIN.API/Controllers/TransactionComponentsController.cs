
using Microsoft.AspNetCore.Mvc;
using MYFIN.API.DTOs.Masters;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/transaction-components")]
public class TransactionComponentsController : ControllerBase
{
    private readonly IMasterDataService _masterDataService;

    public TransactionComponentsController(
        IMasterDataService masterDataService)
    {
        _masterDataService = masterDataService;
    }


    // ============================================================
    // GET: /api/transaction-components
    // GET: /api/transaction-components?isActive=true
    // GET: /api/transaction-components?transactionTypeId=5
    // GET: /api/transaction-components?isActive=true&transactionTypeId=5
    // ============================================================

    [HttpGet]
    public async Task<
        ActionResult<IReadOnlyList<TransactionComponentResponse>>>
        Get(
            [FromQuery] bool? isActive = null,
            [FromQuery] int? transactionTypeId = null)
    {
        try
        {
            var results =
                await _masterDataService
                    .GetTransactionComponentsAsync(
                        isActive,
                        transactionTypeId);

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
                        "An unexpected error occurred while retrieving transaction components."
                });
        }
    }


    // ============================================================
    // GET: /api/transaction-components/{id}
    // ============================================================

    [HttpGet("{transactionComponentId:int}")]
    public async Task<
        ActionResult<TransactionComponentResponse>>
        GetById(int transactionComponentId)
    {
        try
        {
            var result =
                await _masterDataService
                    .GetTransactionComponentAsync(
                        transactionComponentId);

            if (result is null)
            {
                return NotFound(new
                {
                    message =
                        $"Transaction component {transactionComponentId} was not found."
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
                        "An unexpected error occurred while retrieving the transaction component."
                });
        }
    }


    // ============================================================
    // POST: /api/transaction-components
    // ============================================================

    [HttpPost]
    public async Task<
        ActionResult<TransactionComponentResponse>>
        Create(
            [FromBody] CreateTransactionComponentRequest request)
    {
        try
        {
            var result =
                await _masterDataService
                    .CreateTransactionComponentAsync(
                        request);

            return CreatedAtAction(
                nameof(GetById),
                new
                {
                    transactionComponentId =
                        result.TransactionComponentID
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
                        "An unexpected error occurred while creating the transaction component."
                });
        }
    }


    // ============================================================
    // PUT: /api/transaction-components/{id}
    // ============================================================

    [HttpPut("{transactionComponentId:int}")]
    public async Task<
        ActionResult<TransactionComponentResponse>>
        Update(
            int transactionComponentId,
            [FromBody] UpdateTransactionComponentRequest request)
    {
        try
        {
            var result =
                await _masterDataService
                    .UpdateTransactionComponentAsync(
                        transactionComponentId,
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
                        "An unexpected error occurred while updating the transaction component."
                });
        }
    }


    // ============================================================
    // PATCH: /api/transaction-components/{id}/activate
    // ============================================================

    [HttpPatch("{transactionComponentId:int}/activate")]
    public async Task<
        ActionResult<TransactionComponentResponse>>
        Activate(int transactionComponentId)
    {
        try
        {
            var result =
                await _masterDataService
                    .SetTransactionComponentActiveStatusAsync(
                        transactionComponentId,
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
                    message =
                        "An unexpected error occurred while activating the transaction component."
                });
        }
    }


    // ============================================================
    // PATCH: /api/transaction-components/{id}/deactivate
    // ============================================================

    [HttpPatch("{transactionComponentId:int}/deactivate")]
    public async Task<
        ActionResult<TransactionComponentResponse>>
        Deactivate(int transactionComponentId)
    {
        try
        {
            var result =
                await _masterDataService
                    .SetTransactionComponentActiveStatusAsync(
                        transactionComponentId,
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
                    message =
                        "An unexpected error occurred while deactivating the transaction component."
                });
        }
    }
}

