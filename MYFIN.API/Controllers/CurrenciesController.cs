using Microsoft.AspNetCore.Mvc;
using MYFIN.API.DTOs.Masters;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/currencies")]
public class CurrenciesController : ControllerBase
{
    private readonly IMasterDataService _masterDataService;

    public CurrenciesController(
        IMasterDataService masterDataService)
    {
        _masterDataService = masterDataService;
    }


// ============================================================
// GET: api/currencies
// GET: api/currencies?isActive=true
// GET: api/currencies?isActive=false
// ============================================================
[HttpGet]
public async Task<ActionResult<IReadOnlyList<CurrencyResponse>>> GetCurrencies(
    [FromQuery] bool? isActive = null)
{
    try
    {
        var currencies =
            await _masterDataService.GetCurrenciesAsync(isActive);

        return Ok(currencies);
    }
    catch (Exception)
    {
        return StatusCode(
            StatusCodes.Status500InternalServerError,
            new
            {
                message = "An unexpected error occurred while retrieving currencies."
            });
    }
}


// ============================================================
// GET: api/currencies/{currencyId}
// ============================================================
[HttpGet("{currencyId:int}")]
public async Task<ActionResult<CurrencyResponse>> GetCurrency(
    int currencyId)
{
    try
    {
        var currency =
            await _masterDataService.GetCurrencyAsync(currencyId);

        if (currency is null)
        {
            return NotFound(
                new
                {
                    message = $"Currency {currencyId} was not found."
                });
        }

        return Ok(currency);
    }
    catch (Exception)
    {
        return StatusCode(
            StatusCodes.Status500InternalServerError,
            new
            {
                message = "An unexpected error occurred while retrieving the currency."
            });
    }
}


// ============================================================
// POST: api/currencies
// ============================================================
[HttpPost]
public async Task<ActionResult<CurrencyResponse>> CreateCurrency(
    [FromBody] CreateCurrencyRequest request)
{
    try
    {
        var currency =
            await _masterDataService.CreateCurrencyAsync(request);

        return CreatedAtAction(
            nameof(GetCurrency),
            new
            {
                currencyId = currency.CurrencyID
            },
            currency);
    }
    catch (ArgumentException ex)
    {
        return BadRequest(
            new
            {
                message = ex.Message
            });
    }
    catch (InvalidOperationException ex)
    {
        return Conflict(
            new
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
                message = "An unexpected error occurred while creating the currency."
            });
    }
}


// ============================================================
// PUT: api/currencies/{currencyId}
// ============================================================
[HttpPut("{currencyId:int}")]
public async Task<ActionResult<CurrencyResponse>> UpdateCurrency(
    int currencyId,
    [FromBody] UpdateCurrencyRequest request)
{
    try
    {
        var currency =
            await _masterDataService.UpdateCurrencyAsync(
                currencyId,
                request);

        return Ok(currency);
    }
    catch (ArgumentException ex)
    {
        return BadRequest(
            new
            {
                message = ex.Message
            });
    }
    catch (KeyNotFoundException ex)
    {
        return NotFound(
            new
            {
                message = ex.Message
            });
    }
    catch (InvalidOperationException ex)
    {
        return Conflict(
            new
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
                message = "An unexpected error occurred while updating the currency."
            });
    }
}


// ============================================================
// PATCH: api/currencies/{currencyId}/activate
// ============================================================
[HttpPatch("{currencyId:int}/activate")]
public async Task<ActionResult<CurrencyResponse>> ActivateCurrency(
    int currencyId)
{
    try
    {
        var currency =
            await _masterDataService.SetCurrencyActiveStatusAsync(
                currencyId,
                true);

        return Ok(currency);
    }
    catch (KeyNotFoundException ex)
    {
        return NotFound(
            new
            {
                message = ex.Message
            });
    }
    catch (InvalidOperationException ex)
    {
        return Conflict(
            new
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
                message = "An unexpected error occurred while activating the currency."
            });
    }
}


// ============================================================
// PATCH: api/currencies/{currencyId}/deactivate
// ============================================================
[HttpPatch("{currencyId:int}/deactivate")]
public async Task<ActionResult<CurrencyResponse>> DeactivateCurrency(
    int currencyId)
{
    try
    {
        var currency =
            await _masterDataService.SetCurrencyActiveStatusAsync(
                currencyId,
                false);

        return Ok(currency);
    }
    catch (KeyNotFoundException ex)
    {
        return NotFound(
            new
            {
                message = ex.Message
            });
    }
    catch (InvalidOperationException ex)
    {
        return Conflict(
            new
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
                message = "An unexpected error occurred while deactivating the currency."
            });
        }
    }
}
