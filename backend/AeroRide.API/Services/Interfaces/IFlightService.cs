using AeroRide.API.Models.DTOs.Flights;

namespace AeroRide.API.Services.Interfaces
{
    public interface IFlightService
    {
        /// <summary>
        /// Obtiene todos los vuelos de una compañía específica.
        /// Incluye los vuelos "Empty Leg" y los comerciales.
        /// </summary>
        Task<IEnumerable<FlightResponseDto>> GetFlightsByCompanyAsync(int companyId);
    }
}

