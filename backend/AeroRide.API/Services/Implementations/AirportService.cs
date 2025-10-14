using AeroRide.API.Data;
using AeroRide.API.Interfaces;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Airports;
using AeroRide.API.Services.Interfaces;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace AeroRide.API.Services
{
    /// <summary>
    /// Implementa las operaciones de negocio del módulo de Aeropuertos.
    /// Maneja persistencia, validaciones y conversión de DTOs mediante AutoMapper.
    /// </summary>
    public class AirportService : IAirportService
    {
        private readonly AeroRideDbContext _db;
        private readonly IMapper _mapper;
        private readonly IImageService _imageService;

        public AirportService(AeroRideDbContext db, IMapper mapper, IImageService imageService)
        {
            _db = db;
            _mapper = mapper;
            _imageService = imageService;
        }

        // ======================================================
        // 🔹 OBTENER LISTA DE AEROPUERTOS
        // ======================================================

        public async Task<IEnumerable<AirportListDto>> GetAllActiveAsync()
        {
            return await _db.Airports
                .Where(a => a.IsActive)
                .OrderBy(a => a.Id) // ✅ ordenado por Id ascendente
                .ProjectTo<AirportListDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }

        public async Task<IEnumerable<AirportListDto>> GetAllAsync()
        {
            return await _db.Airports
                .IgnoreQueryFilters()
                .OrderBy(a => a.Id) // ✅ ordenado por Id ascendente
                .ProjectTo<AirportListDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }

        // ======================================================
        // 🔹 OBTENER DETALLE
        // ======================================================
        public async Task<AirportDetailDto?> GetByIdAsync(int id)
        {
            var airport = await _db.Airports
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(a => a.Id == id);

            return airport is null ? null : _mapper.Map<AirportDetailDto>(airport);
        }

        // ======================================================
        // 🔹 CREAR
        // ======================================================
        public async Task<AirportResponseDto> CreateAsync(AirportCreateDto dto)
        {
            var airport = _mapper.Map<Airport>(dto);

            _db.Airports.Add(airport);
            await _db.SaveChangesAsync();

            return _mapper.Map<AirportResponseDto>(airport);
        }

        // ======================================================
        // 🔹 ACTUALIZAR
        // ======================================================
        /// <summary>
        /// Actualiza parcialmente los datos de un aeropuerto existente.
        /// Si se proporciona una nueva imagen, elimina la anterior del contenedor.
        /// </summary>
        /// <param name="id">Identificador único del aeropuerto.</param>
        /// <param name="dto">Datos a modificar.</param>
        /// <returns>DTO actualizado del aeropuerto, o <c>null</c> si no se encontró.</returns>
        public async Task<AirportResponseDto?> UpdateAsync(int id, AirportUpdateDto dto)
        {
            var airport = await _db.Airports
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(a => a.Id == id);

            if (airport == null)
                return null;

            // 🔹 Manejo especial para la imagen (antes del mapeo)
            if (dto.Image != null && dto.Image != airport.Image)
            {
                try
                {
                    // Si existe una imagen anterior, eliminarla del contenedor
                    if (!string.IsNullOrEmpty(airport.Image))
                        await _imageService.DeleteImageAsync(airport.Image, "airport-images");
                }
                catch
                {
                    // No interrumpir el proceso si falla la eliminación
                }
            }

            // 🔹 Mapeo automático de propiedades no nulas
            _mapper.Map(dto, airport);

            await _db.SaveChangesAsync();

            return _mapper.Map<AirportResponseDto>(airport);
        }


        // ======================================================
        // 🔹 DESACTIVAR (soft delete)
        // ======================================================
        public async Task<bool> DeactivateAsync(int id)
        {
            var airport = await _db.Airports.FirstOrDefaultAsync(a => a.Id == id);
            if (airport == null) return false;

            airport.IsActive = false;
            await _db.SaveChangesAsync();
            return true;
        }

        // ======================================================
        // 🔹 REACTIVAR
        // ======================================================
        public async Task<bool> ReactivateAsync(int id)
        {
            var airport = await _db.Airports
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(a => a.Id == id);
            if (airport == null) return false;

            airport.IsActive = true;
            await _db.SaveChangesAsync();
            return true;
        }

        // ======================================================
        // 🔍 SEARCH (AUTOCOMPLETE)
        // ======================================================

        /// <summary>
        /// Busca aeropuertos que coincidan parcial o totalmente con el nombre,
        /// país o código IATA. Ideal para autocompletado en el frontend.
        /// </summary>
        /// <param name="query">Texto parcial ingresado por el usuario.</param>
        /// <returns>Listado de aeropuertos coincidentes (máx. 10 resultados).</returns>
        public async Task<IEnumerable<AirportListDto>> SearchAsync(string query)
        {
            if (string.IsNullOrWhiteSpace(query))
                return Enumerable.Empty<AirportListDto>();

            var normalized = query.Trim().ToLower();

            var results = await _db.Airports
                .Where(a =>
                    a.IsActive && (
                        a.Name.ToLower().Contains(normalized) ||
                        a.Country.ToLower().Contains(normalized) ||
                        a.CodeIATA.ToLower().Contains(normalized)
                    ))
                .OrderBy(a => a.Name)
                .Take(10) // 🔹 límite de resultados para autocompletado
                .ProjectTo<AirportListDto>(_mapper.ConfigurationProvider)
                .ToListAsync();

            return results;
        }

    }
}
