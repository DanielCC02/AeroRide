using AeroRide.API.Models.DTOs.FlightLogs;

namespace AeroRide.API.Services.Interfaces
{
    public interface IFlightLogService
    {
        Task<FlightLogResponseDto> CreateLogAsync(FlightLogCreateDto dto);
        Task<FlightLogResponseDto?> GetLogByFlightAsync(int flightId);
    }
}
