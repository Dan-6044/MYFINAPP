using Microsoft.AspNetCore.Mvc;
using MYFIN.API.DTOs.FinancialPeriods;
using MYFIN.API.Services;
using Microsoft.Data.SqlClient;
using System.Security.Claims;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/financial-periods")]
public class FinancialPeriodsController : ControllerBase
{
    private readonly IFinancialPeriodService _financialPeriodService;

    public FinancialPeriodsController(
        IFinancialPeriodService financialPeriodService)
    {
        _financialPeriodService = financialPeriodService;
    }

    // GET: /api/financial-periods
    // GET: /api/financial-periods?userId=1
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<FinancialPeriodResponse>>> GetFinancialPeriods(
        [FromQuery] int? userId = null)
    {
        var periods =
            await _financialPeriodService.GetFinancialPeriodsAsync(userId);

        return Ok(periods);
    }

    // GET: /api/financial-periods/2
    [HttpGet("{financialPeriodId:int}")]
    public async Task<ActionResult<FinancialPeriodResponse>> GetFinancialPeriod(
        int financialPeriodId)
    {
        var period =
            await _financialPeriodService.GetFinancialPeriodAsync(
                financialPeriodId);

        if (period is null)
        {
            return NotFound(new
            {
                message = "Financial period not found."
            });
        }

        return Ok(period);
    }

    // GET: /api/financial-periods/current?userId=1
    [HttpGet("current")]
    public async Task<ActionResult<FinancialPeriodResponse>> GetCurrentFinancialPeriod(
        [FromQuery] int userId)
    {
        if (userId <= 0)
        {
            return BadRequest(new
            {
                message = "userId must be greater than zero."
            });
        }

        var period =
            await _financialPeriodService.GetCurrentFinancialPeriodAsync(
                userId);

        if (period is null)
        {
            return NotFound(new
            {
                message = "No current financial period exists for this user."
            });
        }

        return Ok(period);
    }

    // POST: /api/financial-periods
    [HttpPost]
    public async Task<ActionResult<FinancialPeriodResponse>> CreateFinancialPeriod(
        [FromBody] CreateFinancialPeriodRequest request)
    {
        try
        {
            var period =
                await _financialPeriodService.CreateFinancialPeriodAsync(
                    request);

            return CreatedAtAction(
                nameof(GetFinancialPeriod),
                new
                {
                    financialPeriodId = period.FinancialPeriodID
                },
                period);
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
    }

    // PUT: /api/financial-periods/2
    [HttpPut("{financialPeriodId:int}")]
    public async Task<ActionResult<FinancialPeriodResponse>> UpdateFinancialPeriod(
        int financialPeriodId,
        [FromBody] UpdateFinancialPeriodRequest request)
    {
        try
        {
            var period =
                await _financialPeriodService.UpdateFinancialPeriodAsync(
                    financialPeriodId,
                    request);

            return Ok(period);
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
    }

    // PATCH: /api/financial-periods/2
    [HttpPatch("{financialPeriodId:int}")]
    public async Task<ActionResult<FinancialPeriodResponse>> CloseFinancialPeriod(
        int financialPeriodId)
    {
        var closedByUserIdString =
            User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (string.IsNullOrWhiteSpace(closedByUserIdString) ||
            !int.TryParse(closedByUserIdString, out var closedByUserId) ||
            closedByUserId <= 0)
        {
            return BadRequest(new
            {
                message = "Authenticated user ID is missing or invalid."
            });
        }

        try
        {
            var period =
                await _financialPeriodService.CloseFinancialPeriodAsync(
                    financialPeriodId,
                    closedByUserId);

            return Ok(period);
        }
        catch (SqlException ex) when (
            ex.Number >= 50101 &&
            ex.Number <= 50104)
        {
            return Conflict(new
            {
                message = ex.Message
            });
        }
    }
}