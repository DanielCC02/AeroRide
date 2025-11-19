using Microsoft.AspNetCore.Mvc;
using AeroRide.API.Services.Interfaces;
using AeroRide.API.Models.DTOs.FlightLogs;

[ApiController]
[Route("api/[controller]")]
public class FlightLogsController : ControllerBase
{
    private readonly IFlightLogService _service;

    public FlightLogsController(IFlightLogService service)
    {
        _service = service;
    }

    // POST api/flightlogs
    [HttpPost]
    public async Task<IActionResult> Create([FromForm] FlightLogCreateDto dto)
    {
        var result = await _service.CreateLogAsync(dto);
        return Ok(result);
    }

    // GET api/flightlogs/flight/{flightId}
    [HttpGet("flight/{flightId}")]
    public async Task<IActionResult> GetByFlight(int flightId)
    {
        var log = await _service.GetLogByFlightAsync(flightId);
        return Ok(log);
    }
}
