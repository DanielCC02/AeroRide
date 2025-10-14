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
    /// Permite realizar operaciones CRUD sobre la entidad <see cref="Aircraft"/>.
    /// </summary>
    public class AircraftService : IAircraftService
    {
        /// <summary>
        /// Contexto de base de datos principal de la aplicación.
        /// Permite realizar operaciones sobre las tablas mediante Entity Framework Core.
        /// </summary>
        private readonly AeroRideDbContext _db;

        /// <summary>
        /// Instancia de AutoMapper para mapear entidades de dominio hacia DTOs y viceversa.
        /// </summary>
        private readonly IMapper _mapper;

        private readonly IImageService _imageService;

        /// <summary>
        /// Inicializa una nueva instancia del servicio <see cref="AircraftService"/>.
        /// </summary>
        /// <param name="db">Contexto de base de datos inyectado.</param>
        /// <param name="mapper">Instancia de <see cref="IMapper"/> para conversiones entre objetos.</param>
        public AircraftService(AeroRideDbContext db, IMapper mapper, IImageService imageService)
        {
            _db = db;
            _mapper = mapper;
            _imageService = imageService;
        }

        /// <summary>
        /// Crea una nueva aeronave en la base de datos.
        /// </summary>
        /// <param name="dto">Objeto que contiene los datos necesarios para registrar la aeronave.</param>
        /// <returns>
        /// Un objeto <see cref="AircraftResponseDto"/> con los datos de la aeronave recién creada,
        /// incluyendo su identificador asignado por la base de datos.
        /// </returns>
        /// <exception cref="ArgumentNullException">Se lanza si el parámetro <paramref name="dto"/> es nulo.</exception>
        public async Task<AircraftResponseDto> CreateAsync(AircraftCreateDto dto)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "El objeto de creación no puede ser nulo.");

            // 🔹 Validar el estado antes de crear
            var (isValid, message) = ValidateState(dto.State);
            if (!isValid)
                throw new InvalidOperationException(message);

            // Mapeo DTO → Entidad
            var entity = _mapper.Map<Aircraft>(dto);

            // Inserción en la base de datos
            await _db.Aircrafts.AddAsync(entity);
            await _db.SaveChangesAsync();

            // Retorno del DTO de respuesta
            return _mapper.Map<AircraftResponseDto>(entity);
        }

        /// <summary>
        /// Obtiene la lista completa de aeronaves registradas en el sistema.
        /// </summary>
        /// <returns>
        /// Una colección enumerable de objetos <see cref="AircraftResponseDto"/> que representan las aeronaves registradas.
        /// Retorna una lista vacía si no existen registros.
        /// </returns>
        public async Task<IEnumerable<AircraftResponseDto>> GetAllAsync()
        {
            var aircrafts = await _db.Aircrafts.AsNoTracking().ToListAsync();
            return _mapper.Map<IEnumerable<AircraftResponseDto>>(aircrafts);
        }

        /// <summary>
        /// Obtiene todas las aeronaves registradas, sin aplicar el filtro global de estado.
        /// Incluye tanto aeronaves activas como inactivas.
        /// </summary>
        /// <returns>Lista completa de aeronaves (activas e inactivas).</returns>
        public async Task<IEnumerable<AircraftResponseDto>> GetAllIncludingInactiveAsync()
        {
            // Ignorar el filtro global IsActive y traer todos los registros
            var aircrafts = await _db.Aircrafts
                .IgnoreQueryFilters()
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<IEnumerable<AircraftResponseDto>>(aircrafts);
        }

        /// <summary>
        /// Obtiene la información de una aeronave específica según su identificador único.
        /// </summary>
        /// <param name="id">Identificador de la aeronave a consultar.</param>
        /// <returns>
        /// Un objeto <see cref="AircraftResponseDto"/> si la aeronave existe; de lo contrario, <c>null</c>.
        /// </returns>
        public async Task<AircraftResponseDto?> GetByIdAsync(int id)
        {
            var aircraft = await _db.Aircrafts
                .IgnoreQueryFilters() // 👈 Ignora el filtro IsActive
                .AsNoTracking()
                .FirstOrDefaultAsync(a => a.Id == id);

            return aircraft == null
                ? null
                : _mapper.Map<AircraftResponseDto>(aircraft);
        }

        /// <summary>
        /// Actualiza parcialmente los datos de una aeronave existente.
        /// Si se proporciona una nueva imagen, elimina la anterior del contenedor.
        /// </summary>
        /// <param name="id">Identificador único de la aeronave.</param>
        /// <param name="dto">Datos a modificar.</param>
        /// <returns>DTO actualizado de la aeronave, o <c>null</c> si no se encontró.</returns>
        public async Task<AircraftResponseDto?> UpdateAsync(int id, AircraftUpdateDto dto)
        {
            var aircraft = await _db.Aircrafts
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(a => a.Id == id);


            if (aircraft == null)
                return null;

            // 🔹 Validar el estado si se envía en el DTO
            if (!string.IsNullOrWhiteSpace(dto.State))
            {
                var (isValid, message) = ValidateState(dto.State);
                if (!isValid)
                    throw new InvalidOperationException(message);
            }

            // 🔹 Manejo especial para la imagen (antes del mapeo)
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

            // 🔹 Mapeo automático de propiedades no nulas
            _mapper.Map(dto, aircraft);

            await _db.SaveChangesAsync();

            return _mapper.Map<AircraftResponseDto>(aircraft);
        }


        /// <summary>
        /// Desactiva (elimina lógicamente) una aeronave existente en la base de datos.
        /// </summary>
        /// <param name="id">Identificador único de la aeronave.</param>
        /// <returns>
        /// <c>true</c> si la aeronave fue desactivada correctamente;
        /// <c>false</c> si no existe o ya está inactiva.
        /// </returns>
        public async Task<bool> DeleteAsync(int id)
        {
            // Buscar aeronave existente
            var aircraft = await _db.Aircrafts.FirstOrDefaultAsync(a => a.Id == id);

            if (aircraft == null || !aircraft.IsActive)
                return false;

            // Marcar como inactiva
            aircraft.IsActive = false;
            await _db.SaveChangesAsync();

            return true;
        }

        /// <summary>
        /// Reactiva una aeronave previamente desactivada.
        /// </summary>
        /// <param name="id">Identificador único de la aeronave.</param>
        /// <returns>
        /// <c>true</c> si se reactivó correctamente; <c>false</c> si no existe o ya estaba activa.
        /// </returns>
        public async Task<bool> ReactivateAsync(int id)
        {
            // Buscar aeronave ignorando filtro global
            var aircraft = await _db.Aircrafts
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(a => a.Id == id);

            if (aircraft == null || aircraft.IsActive)
                return false;

            // Reactivar aeronave
            aircraft.IsActive = true;
            await _db.SaveChangesAsync();

            return true;
        }


        /// <summary>
        /// Actualiza únicamente el estado operativo de una aeronave.
        /// Valida los estados permitidos y guarda los cambios en la base de datos.
        /// </summary>
        /// <param name="id">Identificador único de la aeronave.</param>
        /// <param name="newState">Nuevo estado operativo (Disponible, En vuelo, En mantenimiento, etc.).</param>
        /// <returns>
        /// Una tupla con un valor booleano indicando éxito, y un mensaje descriptivo.
        /// </returns>
        public async Task<(bool Success, string Message)> UpdateStateAsync(int id, string newState)
        {
            var (isValid, message) = ValidateState(newState);
            if (!isValid)
                return (false, message);

            var aircraft = await _db.Aircrafts.FirstOrDefaultAsync(a => a.Id == id);
            if (aircraft == null)
                return (false, "Aeronave no encontrada.");

            aircraft.State = newState;
            await _db.SaveChangesAsync();

            return (true, $"Estado de la aeronave ID {id} actualizado a '{newState}'.");
        }


        private (bool IsValid, string Message) ValidateState(string? state)
        {
            if (string.IsNullOrWhiteSpace(state))
                return (false, "Debe especificar un estado válido.");

            // 🔹 Normalizar el texto para evitar errores por mayúsculas o espacios
            var normalized = Regex.Replace(state, @"\s+", "").ToLower();

            // 🔹 Intentar convertirlo al enum (ignorando mayúsculas)
            bool parsed = Enum.TryParse(typeof(AircraftState), normalized, true, out var _);

            if (!parsed)
            {
                var validStates = string.Join(", ", Enum.GetNames(typeof(AircraftState)));
                return (false, $"El estado '{state}' no es válido. Estados permitidos: {validStates}.");
            }

            return (true, string.Empty);
        }

        // ======================================================
        // 🔍 FILTER BY SEATS AND STATE = "Disponible"
        // ======================================================

        /// <summary>
        /// Devuelve aeronaves activas y disponibles filtradas por número de asientos.
        /// Ideal para mostrar avionetas listas para reserva según la selección del usuario.
        /// </summary>
        /// <param name="minSeats">Cantidad mínima de asientos requerida.</param>
        /// <param name="maxSeats">Cantidad máxima de asientos (opcional).</param>
        /// <returns>Lista de aeronaves disponibles que cumplen con el filtro.</returns>
        public async Task<IEnumerable<AircraftResponseDto>> FilterBySeatsAsync(int minSeats, int? maxSeats)
        {
            // Base query: aeronaves activas y disponibles
            var query = _db.Aircrafts
                .Where(a => a.IsActive && a.State.ToLower() == "disponible" && a.Seats >= minSeats);

            // Filtro adicional: cantidad máxima de asientos
            if (maxSeats.HasValue)
                query = query.Where(a => a.Seats <= maxSeats.Value);

            // Ordenar por cantidad de asientos
            return await query
                .OrderBy(a => a.Seats)
                .ProjectTo<AircraftResponseDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }



    }
}
