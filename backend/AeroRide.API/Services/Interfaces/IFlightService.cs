using AeroRide.API.Models.DTOs.FlightAssignments;
using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Services.Interfaces
{
    public interface IFlightService
    {
        /// <summary>
        /// Obtiene todos los vuelos de una compañía específica.
        /// Incluye los vuelos "Empty Leg" y los comerciales.
        /// </summary>
        Task<IEnumerable<FlightResponseDto>> GetFlightsByCompanyAsync(int companyId);
        Task AssignPilotsToFlightAsync(int flightId, FlightAssignmentCreateDto dto);
        Task<IEnumerable<FlightResponseDto>> GetFlightsByPilotAsync(int pilotUserId);
        Task<IEnumerable<FlightPilotDto>> GetPilotsByFlightAsync(int flightId);
        Task<bool> UpdateFlightStatusAsync(int flightId, FlightStatus status);

    }
}
