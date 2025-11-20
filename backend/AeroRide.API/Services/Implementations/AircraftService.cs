using AeroRide.API.Data;
using AeroRide.API.Helpers;
using AeroRide.API.Interfaces;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Aircrafts;
using AeroRide.API.Models.Enums;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using System.Text.RegularExpressions;

namespace AeroRide.API.Services
{
    /// <summary>
    /// Servicio que implementa la lógica de negocio para la gestión de aeronaves (avionetas).
    /// Permite realizar operaciones CRUD y filtrado agrupado por modelo y compañía.
    /// </summary>
    public class AircraftService : IAircraftService
    {
        private readonly AeroRideDbContext _db;
        private readonly IMapper _mapper;
        private readonly IImageService _imageService;

        public AircraftService(AeroRideDbContext db, IMapper mapper, IImageService imageService)
        {
            _db = db;
            _mapper = mapper;
            _imageService = imageService;
        }

        // ======================================================
        // 🟢 CREATE
        // ======================================================
        public async Task<AircraftResponseDto> CreateAsync(AircraftCreateDto dto)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "El objeto de creación no puede ser nulo.");

            // 🔹 Validar duplicado de matrícula
            bool exists = await _db.Aircrafts.AnyAsync(a => a.Patent.ToLower() == dto.Patent.ToLower());
            if (exists)
                throw new InvalidOperationException($"Ya existe una aeronave con la matrícula '{dto.Patent}'.");

            // 🔹 Validar compañía
            bool companyExists = await _db.Companies.AnyAsync(c => c.Id == dto.CompanyId);
            if (!companyExists)
                throw new InvalidOperationException($"No se encontró la compañía con ID {dto.CompanyId}.");

            // 🔹 Validar aeropuerto base
            bool baseExists = await _db.Airports.AnyAsync(a => a.Id == dto.BaseAirportId);
            if (!baseExists)
                throw new InvalidOperationException($"No se encontró el aeropuerto base con ID {dto.BaseAirportId}.");

            // 🔹 Validar aeropuerto actual (si se envía)
            if (dto.CurrentAirportId.HasValue)
            {
                bool currentExists = await _db.Airports.AnyAsync(a => a.Id == dto.CurrentAirportId.Value);
                if (!currentExists)
                    throw new InvalidOperationException($"El aeropuerto actual con ID {dto.CurrentAirportId} no existe.");
            }

            // 🔹 Validar estado
            if (!Enum.IsDefined(typeof(AircraftState), dto.State))
                throw new InvalidOperationException($"El estado '{dto.State}' no es válido. Use Disponible, EnMantenimiento o FueraDeServicio.");

            // 🧩 Crear entidad
            var entity = _mapper.Map<Aircraft>(dto);

            // Si no viene aeropuerto actual, se asume igual al base
            if (entity.CurrentAirportId == null)
                entity.CurrentAirportId = entity.BaseAirportId;

            entity.StatusLastUpdated = DateTime.UtcNow;

            await _db.Aircrafts.AddAsync(entity);
            await _db.SaveChangesAsync();

            // 🔗 Cargar relaciones
            await _db.Entry(entity).Reference(a => a.Company).LoadAsync();
            await _db.Entry(entity).Reference(a => a.BaseAirport).LoadAsync();
            if (entity.CurrentAirportId.HasValue)
                await _db.Entry(entity).Reference(a => a.CurrentAirport).LoadAsync();

            return _mapper.Map<AircraftResponseDto>(entity);
        }

        // ======================================================
        // ✏️ UPDATE
        // ======================================================
        public async Task<AircraftResponseDto?> UpdateAsync(int id, AircraftUpdateDto dto)
        {
            var aircraft = await _db.Aircrafts.IgnoreQueryFilters().FirstOrDefaultAsync(a => a.Id == id);
            if (aircraft == null)
                return null;

            // 🔹 Validar estado (solo si viene en el DTO)
            if (dto.State.HasValue)
            {
                if (!Enum.IsDefined(typeof(AircraftState), dto.State.Value))
                    throw new InvalidOperationException($"El estado '{dto.State.Value}' no es válido. Use Disponible, EnMantenimiento o FueraDeServicio.");
            }

            // 🔹 Validar aeropuertos si se cambian
            if (dto.BaseAirportId.HasValue && !await _db.Airports.AnyAsync(a => a.Id == dto.BaseAirportId.Value))
                throw new InvalidOperationException($"El aeropuerto base con ID {dto.BaseAirportId} no existe.");

            if (dto.CurrentAirportId.HasValue && !await _db.Airports.AnyAsync(a => a.Id == dto.CurrentAirportId.Value))
                throw new InvalidOperationException($"El aeropuerto actual con ID {dto.CurrentAirportId} no existe.");

            // 🔹 Manejar cambio de imagen
            if (dto.Image != null && dto.Image != aircraft.Image)
            {
                try
                {
                    if (!string.IsNullOrEmpty(aircraft.Image))
                        await _imageService.DeleteImageAsync(aircraft.Image, "aircraft-images");
                }
                catch
                {
                    // No interrumpir el proceso si falla la eliminación
                }
            }

            // 🔹 Aplicar cambios parciales
            _mapper.Map(dto, aircraft);
            aircraft.StatusLastUpdated = DateTime.UtcNow;

            await _db.SaveChangesAsync();

            // 🔁 Cargar relaciones para devolver nombres correctos
            await _db.Entry(aircraft).Reference(a => a.Company).LoadAsync();
            await _db.Entry(aircraft).Reference(a => a.BaseAirport).LoadAsync();
            if (aircraft.CurrentAirportId.HasValue)
                await _db.Entry(aircraft).Reference(a => a.CurrentAirport).LoadAsync();

            return _mapper.Map<AircraftResponseDto>(aircraft);
        }


        // ======================================================
        // ⚙️ UPDATE STATE DIRECTO
        // ======================================================
        public async Task<(bool Success, string Message)> UpdateStateAsync(int id, AircraftState newState)
        {
            var aircraft = await _db.Aircrafts.FirstOrDefaultAsync(a => a.Id == id);
            if (aircraft == null)
                return (false, "Aeronave no encontrada.");

            if (newState is AircraftState.Disponible or AircraftState.EnMantenimiento or AircraftState.FueraDeServicio)
            {
                aircraft.State = newState;
                aircraft.StatusLastUpdated = DateTime.UtcNow;
                await _db.SaveChangesAsync();
                return (true, $"Estado de la aeronave ID {id} actualizado a '{newState}'.");
            }

            return (false, "Estado no permitido. Use Disponible, EnMantenimiento o FueraDeServicio.");
        }

        // ======================================================
        // ❌ DELETE (SOFT DELETE)
        // ======================================================
        public async Task<bool> DeleteAsync(int id)
        {
            var aircraft = await _db.Aircrafts.FirstOrDefaultAsync(a => a.Id == id);
            if (aircraft == null || !aircraft.IsActive)
                return false;

            aircraft.IsActive = false;
            await _db.SaveChangesAsync();
            return true;
        }

        // ======================================================
        // 🔁 REACTIVATE
        // ======================================================
        public async Task<bool> ReactivateAsync(int id)
        {
            var aircraft = await _db.Aircrafts.IgnoreQueryFilters().FirstOrDefaultAsync(a => a.Id == id);
            if (aircraft == null || aircraft.IsActive)
                return false;

            aircraft.IsActive = true;
            await _db.SaveChangesAsync();
            return true;
        }

        // ======================================================
        // 🔍 GET METHODS
        // ======================================================
        public async Task<IEnumerable<AircraftResponseDto>> GetAllAsync()
        {
            return await _db.Aircrafts
                .AsNoTracking()
                .ProjectTo<AircraftResponseDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }

        public async Task<IEnumerable<AircraftResponseDto>> GetAllIncludingInactiveAsync()
        {
            return await _db.Aircrafts
                .IgnoreQueryFilters()
                .AsNoTracking()
                .ProjectTo<AircraftResponseDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }

        public async Task<AircraftResponseDto?> GetByIdAsync(int id)
        {
            var aircraft = await _db.Aircrafts
                .IgnoreQueryFilters()
                .AsNoTracking()
                .Include(a => a.Company)
                .Include(a => a.BaseAirport)
                .Include(a => a.CurrentAirport)
                .FirstOrDefaultAsync(a => a.Id == id);

            return aircraft == null ? null : _mapper.Map<AircraftResponseDto>(aircraft);
        }

        public async Task<IEnumerable<AircraftCategoryDto>> GetAvailableForCriteriaAsync(
            AircraftAvailabilityCriteriaDto criteria)
        {
            // 1️⃣ Fetch airports
            var depAirport = await _db.Airports.FirstAsync(a => a.Id == criteria.DepartureAirportId);
            var arrAirport = await _db.Airports.FirstAsync(a => a.Id == criteria.ArrivalAirportId);

            bool isInternationalFlight = !string.Equals(
                depAirport.Country.Trim(),
                arrAirport.Country.Trim(),
                StringComparison.OrdinalIgnoreCase
            );

            // 2️⃣ Convert requested departure to UTC
            var requestedStartUtc = TimeHelper.ToUtc(criteria.DepartureTime, depAirport.TimeZone);

            // 3️⃣ PRE-FILTER BY BASIC CONDITIONS
            var aircrafts = await _db.Aircrafts
                .Include(a => a.Company)
                .Include(a => a.BaseAirport)
                .Where(a =>
                    a.IsActive &&
                    a.State == AircraftState.Disponible &&
                    a.Seats >= criteria.MinSeats
                )
                .AsNoTracking()
                .ToListAsync();

            // 4️⃣ NATIONAL: only aircraft based in same *country*
            if (!isInternationalFlight)
            {
                aircrafts = aircrafts
                    .Where(a =>
                        string.Equals(
                            a.BaseAirport.Country.Trim(),
                            depAirport.Country.Trim(),
                            StringComparison.OrdinalIgnoreCase
                        )
                    )
                    .ToList();
            }

            // 5️⃣ FULL VALIDATION PER AIRCRAFT
            var validAircraft = new List<Aircraft>();

            foreach (var aircraft in aircrafts)
            {
                // A. Weight limits
                double mtow = aircraft.EmptyWeight + aircraft.MaxWeight;

                if (mtow > depAirport.MaxAllowedWeight)
                    continue;

                if (mtow > arrAirport.MaxAllowedWeight)
                    continue;

                // B. International capability
                if (isInternationalFlight && !aircraft.CanFlyInternational)
                    continue;

                // C. Calculate estimated duration
                double durationMinutes = FlightMathHelper.CalcularDuracionVuelo(depAirport, arrAirport, aircraft);
                if (durationMinutes < 10)
                    durationMinutes = 10;

                var requestedEndUtc = requestedStartUtc.AddMinutes(durationMinutes);

                // D. Operating hours
                if (!AirportTimeHelper.IsWithinOperatingHours(requestedStartUtc, depAirport))
                    continue;

                if (!AirportTimeHelper.IsWithinOperatingHours(requestedEndUtc, arrAirport))
                    continue;

                // E. Check availability
                bool isFree = await IsAircraftAvailableInRangeAsync(
                    aircraft.Id,
                    requestedStartUtc,
                    requestedEndUtc
                );

                if (isFree)
                    validAircraft.Add(aircraft);
            }

            // 6️⃣ ORDERING (international)
            List<Aircraft> orderedAircraft;

            if (isInternationalFlight)
            {
                var originCountry = depAirport.Country.Trim();
                var destinationCountry = arrAirport.Country.Trim();

                var basedInOrigin = validAircraft
                    .Where(a => a.BaseAirport.Country.Trim().Equals(originCountry, StringComparison.OrdinalIgnoreCase))
                    .ToList();

                var basedInDestination = validAircraft
                    .Where(a =>
                        a.BaseAirport.Country.Trim().Equals(destinationCountry, StringComparison.OrdinalIgnoreCase) &&
                        !a.BaseAirport.Country.Trim().Equals(originCountry, StringComparison.OrdinalIgnoreCase)
                    )
                    .ToList();

                var foreign = validAircraft
                    .Where(a =>
                        !a.BaseAirport.Country.Trim().Equals(originCountry, StringComparison.OrdinalIgnoreCase) &&
                        !a.BaseAirport.Country.Trim().Equals(destinationCountry, StringComparison.OrdinalIgnoreCase)
                    )
                    .ToList();

                orderedAircraft = basedInOrigin.Concat(basedInDestination).Concat(foreign).ToList();
            }
            else
            {
                orderedAircraft = validAircraft.ToList();
            }

            // ======================================================
            // 7️⃣ GROUP BY COMPANY + MODEL  (🔥 Correct for your UI)
            // ======================================================
            var grouped = orderedAircraft
                .GroupBy(a => new { a.CompanyId, a.Model })
                .Select(g =>
                {
                    var first = g.First();

                    return new AircraftCategoryDto
                    {
                        Model = first.Model,
                        Seats = first.Seats,
                        CompanyId = first.CompanyId,
                        CompanyName = first.Company.Name,
                        Image = first.Image, // image per company+model
                        CanFlyInternational = g.Any(a => a.CanFlyInternational),
                        BaseCountry = first.BaseAirport.Country,
                        BaseAirportName = first.BaseAirport.Name,

                        // 🔥 ALL REAL AIRCRAFTS OF THIS CATEGORY
                        AircraftIds = g.Select(a => a.Id).ToList()
                    };
                })
                .ToList();

            // 8️⃣ Sort
            if (isInternationalFlight)
            {
                var originCountry = depAirport.Country.Trim();
                var destinationCountry = arrAirport.Country.Trim();

                grouped = grouped
                    .OrderBy(a =>
                        a.BaseCountry == originCountry ? 0 :
                        a.BaseCountry == destinationCountry ? 1 :
                        2
                    )
                    .ThenBy(a => a.CompanyName)
                    .ThenBy(a => a.Model)
                    .ToList();
            }
            else
            {
                grouped = grouped
                    .OrderBy(a => a.CompanyName)
                    .ThenBy(a => a.Model)
                    .ToList();
            }

            return grouped;
        }




        // ======================================================
        // 🔹 AERONAVES POR EMPRESA
        // ======================================================
        public async Task<IEnumerable<AircraftResponseDto>> GetAllByCompanyAsync(int companyId)
        {
            var aircrafts = await _db.Aircrafts
                .IgnoreQueryFilters()
                .Where(a => a.CompanyId == companyId)
                .Include(a => a.Company)
                .AsNoTracking()
                .ProjectTo<AircraftResponseDto>(_mapper.ConfigurationProvider)
                .ToListAsync();

            return aircrafts;
        }

        public async Task<IEnumerable<AircraftResponseDto>> GetActiveByCompanyAsync(int companyId)
        {
            var aircrafts = await _db.Aircrafts
                .Where(a => a.IsActive && a.CompanyId == companyId)
                .Include(a => a.Company)
                .AsNoTracking()
                .ProjectTo<AircraftResponseDto>(_mapper.ConfigurationProvider)
                .ToListAsync();

            return aircrafts;
        }

        // ======================================================
        // 🔍 VALIDACIÓN DE ESTADO (PARA UPDATE)
        // ======================================================
        private (bool IsValid, string Message) ValidateState(string? state)
        {
            if (string.IsNullOrWhiteSpace(state))
                return (false, "Debe especificar un estado válido.");

            var normalized = Regex.Replace(state, @"\\s+", "").ToLower();
            bool parsed = Enum.TryParse(typeof(AircraftState), normalized, true, out var _);

            if (!parsed)
                return (false, $"El estado '{state}' no es válido. Use: Disponible, EnMantenimiento o FueraDeServicio.");

            return (true, string.Empty);
        }

        private async Task<bool> IsAircraftAvailableInRangeAsync(
            int aircraftId,
            DateTime requestedStart,
            DateTime requestedEnd)
        {
            const int turnaroundMinutes = 30;

            var occupancies = await _db.AircraftAvailabilities
                .Where(av => av.AircraftId == aircraftId && av.Status == "Confirmado")
                .OrderBy(av => av.StartTime)
                .ToListAsync();

            // No reservations → free
            if (!occupancies.Any())
                return true;

            // 1️⃣ Direct conflict with any flight
            bool conflict = occupancies.Any(av =>
                requestedStart < av.EndTime.AddMinutes(turnaroundMinutes) &&
                requestedEnd > av.StartTime.AddMinutes(-turnaroundMinutes)
            );

            if (!conflict)
                return true;

            // 2️⃣ Check gap BEFORE first flight
            var first = occupancies.First();
            if (requestedEnd <= first.StartTime.AddMinutes(-turnaroundMinutes))
                return true;

            // 3️⃣ Check gaps BETWEEN flights
            for (int i = 0; i < occupancies.Count - 1; i++)
            {
                var current = occupancies[i];
                var next = occupancies[i + 1];

                var gapStart = current.EndTime.AddMinutes(turnaroundMinutes);
                var gapEnd = next.StartTime.AddMinutes(-turnaroundMinutes);

                if (requestedStart >= gapStart && requestedEnd <= gapEnd)
                    return true;
            }

            // 4️⃣ Check gap AFTER last flight
            var last = occupancies.Last();
            if (requestedStart >= last.EndTime.AddMinutes(turnaroundMinutes))
                return true;

            return false;
        }

    }
}
