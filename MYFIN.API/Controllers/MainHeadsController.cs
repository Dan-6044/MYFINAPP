using Microsoft.AspNetCore.Mvc;
using MYFIN.API.DTOs.Masters;
using MYFIN.API.Services;

namespace MYFIN.API.Controllers;

[ApiController]
[Route("api/main-heads")]
public class MainHeadsController : ControllerBase
{
    private readonly IMasterDataService _masterDataService;

    public MainHeadsController(
        IMasterDataService masterDataService)
    {
        _masterDataService = masterDataService;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<MainHeadResponse>>> GetMainHeads(
        [FromQuery] bool? isActive = null)
    {
        var result =
            await _masterDataService.GetMainHeadsAsync(isActive);

        return Ok(result);
    }


    [HttpGet("{mainHeadId:int}")]
    public async Task<ActionResult<MainHeadResponse>> GetMainHead(
        int mainHeadId)
    {
        var result =
            await _masterDataService.GetMainHeadAsync(mainHeadId);

        if (result is null)
        {
            return NotFound(new
            {
                message = $"Main Head {mainHeadId} was not found."
            });
        }

        return Ok(result);
    }


    [HttpPost]
    public async Task<ActionResult<MainHeadResponse>> CreateMainHead(
        [FromBody] CreateMainHeadRequest request)
    {
        try
        {
            var result =
                await _masterDataService.CreateMainHeadAsync(request);

            return CreatedAtAction(
                nameof(GetMainHead),
                new { mainHeadId = result.MainHeadID },
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
    }


    [HttpPut("{mainHeadId:int}")]
    public async Task<ActionResult<MainHeadResponse>> UpdateMainHead(
        int mainHeadId,
        [FromBody] UpdateMainHeadRequest request)
    {
        try
        {
            var result =
                await _masterDataService.UpdateMainHeadAsync(
                    mainHeadId,
                    request);

            return Ok(result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new
            {
                message = ex.Message
            });
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


    [HttpPatch("{mainHeadId:int}/activate")]
    public async Task<ActionResult<MainHeadResponse>> ActivateMainHead(
        int mainHeadId)
    {
        try
        {
            var result =
                await _masterDataService.SetMainHeadActiveStatusAsync(
                    mainHeadId,
                    true);

            return Ok(result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new
            {
                message = ex.Message
            });
        }
    }


    [HttpPatch("{mainHeadId:int}/deactivate")]
    public async Task<ActionResult<MainHeadResponse>> DeactivateMainHead(
        int mainHeadId)
    {
        try
        {
            var result =
                await _masterDataService.SetMainHeadActiveStatusAsync(
                    mainHeadId,
                    false);

            return Ok(result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new
            {
                message = ex.Message
            });
        }
    }
}
