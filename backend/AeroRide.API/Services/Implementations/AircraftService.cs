using AeroRide.API.Data;
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
                .FirstOrDefaultAsync(a => a.Id == id);

            return aircraft == null ? null : _mapper.Map<AircraftResponseDto>(aircraft);
        }

        // ======================================================
        // 🧾 GROUPED BY MODEL + COMPANY
        // ======================================================
        public async Task<IEnumerable<AircraftCategoryDto>> GetAvailableGroupedBySeatsAsync(int? minSeats, int? maxSeats)
        {
            var query = _db.Aircrafts
                .Include(a => a.Company)
                .Where(a => a.IsActive && a.State == AircraftState.Disponible);

            if (minSeats.HasValue)
                query = query.Where(a => a.Seats >= minSeats.Value);

            if (maxSeats.HasValue)
                query = query.Where(a => a.Seats <= maxSeats.Value);

            var projected = await query
                .ProjectTo<AircraftCategoryDto>(_mapper.ConfigurationProvider)
                .ToListAsync();

            return projected
                .GroupBy(a => new { a.Model, a.Seats, a.CompanyName, a.State })
                .Select(g => g.First())
                .OrderBy(x => x.CompanyName)
                .ThenBy(x => x.Model)
                .ToList();
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
    }
}
