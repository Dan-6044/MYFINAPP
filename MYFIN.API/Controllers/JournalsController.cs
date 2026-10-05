using Microsoft.AspNetCore.Mvc;
using MYFIN.API.DTOs.Journals;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class JournalsController : ControllerBase
{
    private readonly IJournalService _journalService;

    public JournalsController(IJournalService journalService)
    {
        _journalService = journalService;
    }

    [HttpGet]
    public async Task<ActionResult<JournalListResponse>> GetList(
        int? financialPeriodId,
        string? status,
        int? transactionTypeId,
        DateTime? startDate,
        DateTime? endDate,
        int page = 1,
        int pageSize = 20)
    {
        var result = await _journalService.GetListAsync(
            financialPeriodId,
            status,
            transactionTypeId,
            startDate,
            endDate,
            page,
            pageSize);

        return Ok(result);
    }

    [HttpGet("{id:long}")]
    public async Task<ActionResult<JournalDetailsResponse>> GetDetails(long id)
    {
        var result = await _journalService.GetDetailsAsync(id);

        if (result == null)
        {
            return NotFound(new { message = $"Journal {id} was not found." });
        }

        return Ok(result);
    }
}
