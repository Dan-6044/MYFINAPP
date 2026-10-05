using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/reports")]
public class ReportsController : ControllerBase
{
    private readonly ITransactionService _transactionService;

    public ReportsController(ITransactionService transactionService)
    {
        _transactionService = transactionService;
    }

    [HttpGet("trial-balance")]
    public async Task<IActionResult> GetTrialBalance(
        [FromQuery] int? financialPeriodId,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        try
        {
            var result =
                await _transactionService.GetTrialBalanceAsync(
                    financialPeriodId,
                    startDate,
                    endDate);

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
        catch (Exception)
        {
            return StatusCode(500, new
            {
                message = "An unexpected error occurred."
            });
        }
    }

    [HttpGet("income-statement")]
    public async Task<IActionResult> GetIncomeStatement(
        [FromQuery] int? financialPeriodId,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        try
        {
            var result =
                await _transactionService.GetIncomeStatementAsync(
                    financialPeriodId,
                    startDate,
                    endDate);

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
        catch (Exception)
        {
            return StatusCode(500, new
            {
                message = "An unexpected error occurred."
            });
        }
    }

    [HttpGet("balance-sheet")]
    public async Task<IActionResult> GetBalanceSheet(
        [FromQuery] int? financialPeriodId,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        try
        {
            var result =
                await _transactionService.GetBalanceSheetAsync(
                    financialPeriodId,
                    startDate,
                    endDate);

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
        catch (Exception)
        {
            return StatusCode(500, new
            {
                message = "An unexpected error occurred."
            });
        }
    }

    [HttpGet("cash-flow")]
    public async Task<IActionResult> GetCashFlowStatement(
        [FromQuery] int? financialPeriodId,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        try
        {
            var result =
                await _transactionService.GetCashFlowStatementAsync(
                    financialPeriodId,
                    startDate,
                    endDate);

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
        catch (Exception)
        {
            return StatusCode(500, new
            {
                message = "An unexpected error occurred."
            });
        }
    }
}