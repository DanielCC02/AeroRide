using AeroRide.API.Data;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.FlightAssignments;
using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Models.Enums;
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
                .Include(f => f.Assignments) 
                .Where(f => f.CompanyId == companyId)
                .OrderByDescending(f => f.DepartureTime)
                .ToListAsync();

            return _mapper.Map<IEnumerable<FlightResponseDto>>(flights);
        }

        public async Task AssignPilotsToFlightAsync(int flightId, FlightAssignmentCreateDto dto)
        {
            var flight = await _db.Flights
                .Include(f => f.Company)
                .FirstOrDefaultAsync(f => f.Id == flightId);

            if (flight == null)
                throw new Exception("El vuelo no existe.");

            // ===========================
            // Validar piloto principal
            // ===========================
            var pilot = await _db.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.Id == dto.PilotId);

            if (pilot == null || pilot.Role?.Name != "Pilot")
                throw new Exception("El piloto principal no existe o no tiene rol de Piloto.");

            if (pilot.CompanyId != flight.CompanyId)
                throw new Exception("El piloto principal no pertenece a la empresa del vuelo.");

            // ===========================
            // Validar copiloto (opcional)
            // ===========================
            User? coPilot = null;

            if (dto.CoPilotId.HasValue)
            {
                if (dto.CoPilotId.Value == dto.PilotId)
                    throw new Exception("El copiloto no puede ser igual al piloto principal.");

                coPilot = await _db.Users
                    .Include(u => u.Role)
                    .FirstOrDefaultAsync(u => u.Id == dto.CoPilotId.Value);

                if (coPilot == null || coPilot.Role?.Name != "Pilot")
                    throw new Exception("El copiloto no existe o no tiene rol de Piloto.");

                if (coPilot.CompanyId != flight.CompanyId)
                    throw new Exception("El copiloto no pertenece a la empresa del vuelo.");
            }

            // ===========================
            // Eliminar asignaciones anteriores
            // ===========================
            var existingAssignments = await _db.FlightAssignments
                .Where(a => a.FlightId == flightId)
                .ToListAsync();

            _db.FlightAssignments.RemoveRange(existingAssignments);
            await _db.SaveChangesAsync();

            // ===========================
            // Crear asignaciones nuevas (CON CrewRole)
            // ===========================
            var newAssignments = new List<FlightAssignment>()
    {
        new FlightAssignment
        {
            FlightId = flightId,
            PilotUserId = pilot.Id,
            CrewRole = CrewRole.Pilot,
            Status = FlightAssignmentStatus.Assigned
        }
    };

            if (coPilot != null)
            {
                newAssignments.Add(new FlightAssignment
                {
                    FlightId = flightId,
                    PilotUserId = coPilot.Id,
                    CrewRole = CrewRole.CoPilot,
                    Status = FlightAssignmentStatus.Assigned
                });
            }

            await _db.FlightAssignments.AddRangeAsync(newAssignments);
            await _db.SaveChangesAsync();
        }



        // ======================================================
        // 3) OBTENER TODOS LOS VUELOS DE UN PILOTO
        // ======================================================
        public async Task<IEnumerable<FlightResponseDto>> GetFlightsByPilotAsync(int pilotUserId)
        {
            var flights = await _db.FlightAssignments
                .Where(a => a.PilotUserId == pilotUserId)
                .Include(a => a.Flight)
                    .ThenInclude(f => f.DepartureAirport)
                .Include(a => a.Flight)
                    .ThenInclude(f => f.ArrivalAirport)
                .Include(a => a.Flight)
                    .ThenInclude(f => f.Aircraft)
                .Include(a => a.Flight)
                    .ThenInclude(f => f.Company)
                .Select(a => a.Flight)
                .OrderBy(f => f.DepartureTime)
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<IEnumerable<FlightResponseDto>>(flights);
        }
        public async Task<IEnumerable<FlightPilotDto>> GetPilotsByFlightAsync(int flightId)
        {
            var assignments = await _db.FlightAssignments
                .Where(a => a.FlightId == flightId)
                .Include(a => a.PilotUser)
                .OrderBy(a => a.PilotUser.Name)
                .ToListAsync();

            return _mapper.Map<IEnumerable<FlightPilotDto>>(assignments);
        }
        public async Task<bool> UpdateFlightStatusAsync(int flightId, FlightStatus status)
        {
            var flight = await _db.Flights.FirstOrDefaultAsync(f => f.Id == flightId);

            if (flight == null)
                throw new Exception("Flight not found.");

            // ❗ Reglas opcionales: evitar retroceder estados
            if ((int)status < (int)flight.Status && status != FlightStatus.PreFlight)
                throw new Exception("Cannot revert flight status.");

            flight.Status = status;
            flight.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync();
            return true;
        }

    }
}
