
using Microsoft.AspNetCore.Mvc;
using MYFIN.API.DTOs.Masters;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/subheads")]
public class SubheadsController : ControllerBase
{
    private readonly IMasterDataService _masterDataService;

    public SubheadsController(
        IMasterDataService masterDataService)
    {
        _masterDataService = masterDataService;
    }


    // ============================================================
    // GET: /api/subheads
    // GET: /api/subheads?isActive=true
    // GET: /api/subheads?isActive=false
    // GET: /api/subheads?mainHeadId=1
    // GET: /api/subheads?mainHeadId=1&isActive=true
    // ============================================================

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<SubheadResponse>>> GetSubheads(
        [FromQuery] bool? isActive = null,
        [FromQuery] int? mainHeadId = null)
    {
        try
        {
            var subheads =
                await _masterDataService.GetSubheadsAsync(
                    isActive,
                    mainHeadId);

            return Ok(subheads);
        }
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An error occurred while retrieving subheads.",
                    detail = ex.Message
                });
        }
    }


    // ============================================================
    // GET: /api/subheads/{subheadId}
    // ============================================================

    [HttpGet("{subheadId:int}")]
    public async Task<ActionResult<SubheadResponse>> GetSubhead(
        int subheadId)
    {
        try
        {
            var subhead =
                await _masterDataService.GetSubheadAsync(
                    subheadId);

            if (subhead is null)
            {
                return NotFound(
                    new
                    {
                        message =
                            $"Subhead {subheadId} was not found."
                    });
            }

            return Ok(subhead);
        }
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An error occurred while retrieving the subhead.",
                    detail = ex.Message
                });
        }
    }


    // ============================================================
    // POST: /api/subheads
    // ============================================================

    [HttpPost]
    public async Task<ActionResult<SubheadResponse>> CreateSubhead(
        [FromBody] CreateSubheadRequest request)
    {
        try
        {
            var subhead =
                await _masterDataService.CreateSubheadAsync(
                    request);

            return CreatedAtAction(
                nameof(GetSubhead),
                new
                {
                    subheadId = subhead.SubheadID
                },
                subhead);
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
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An error occurred while creating the subhead.",
                    detail = ex.Message
                });
        }
    }


    // ============================================================
    // PUT: /api/subheads/{subheadId}
    // ============================================================

    [HttpPut("{subheadId:int}")]
    public async Task<ActionResult<SubheadResponse>> UpdateSubhead(
        int subheadId,
        [FromBody] UpdateSubheadRequest request)
    {
        try
        {
            var subhead =
                await _masterDataService.UpdateSubheadAsync(
                    subheadId,
                    request);

            return Ok(subhead);
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
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    message = "An error occurred while updating the subhead.",
                    detail = ex.Message
                });
        }
    }


    // ============================================================
    // PATCH: /api/subheads/{subheadId}/activate
    // ============================================================

    [HttpPatch("{subheadId:int}/activate")]
    public async Task<ActionResult<SubheadResponse>> ActivateSubhead(
        int subheadId)
    {
        try
        {
            var subhead =
                await _masterDataService.SetSubheadActiveStatusAsync(
                    subheadId,
                    true);

            return Ok(subhead);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(
                new
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
                    message = "An error occurred while activating the subhead.",
                    detail = ex.Message
                });
        }
    }


    // ============================================================
    // PATCH: /api/subheads/{subheadId}/deactivate
    // ============================================================

    [HttpPatch("{subheadId:int}/deactivate")]
    public async Task<ActionResult<SubheadResponse>> DeactivateSubhead(
        int subheadId)
    {
        try
        {
            var subhead =
                await _masterDataService.SetSubheadActiveStatusAsync(
                    subheadId,
                    false);

            return Ok(subhead);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(
                new
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
                    message = "An error occurred while deactivating the subhead.",
                    detail = ex.Message
                });
        }
    }
}

