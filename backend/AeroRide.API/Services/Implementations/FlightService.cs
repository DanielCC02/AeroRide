using AeroRide.API.Data;
using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Services.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AeroRide.API.Services.Implementations
{
    /// <summary>
    /// Implementa la lógica para consultar vuelos de una compañía específica.
    /// </summary>
    public class FlightService : IFlightService
    {
        private readonly AeroRideDbContext _db;
        private readonly IMapper _mapper;

        public FlightService(AeroRideDbContext db, IMapper mapper)
        {
            _db = db;
            _mapper = mapper;
        }

        public async Task<IEnumerable<FlightResponseDto>> GetFlightsByCompanyAsync(int companyId)
        {
            var flights = await _db.Flights
                .Include(f => f.DepartureAirport)
                .Include(f => f.ArrivalAirport)
                .Include(f => f.Aircraft)
                .Include(f => f.Company)
                .Include(f => f.Reservation)
                .Where(f => f.CompanyId == companyId)
                .OrderByDescending(f => f.DepartureTime)
                .ToListAsync();

            return _mapper.Map<IEnumerable<FlightResponseDto>>(flights);
        }
    }
}
