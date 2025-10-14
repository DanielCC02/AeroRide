using AeroRide.API.Models.DTOs.Airports;

namespace AeroRide.API.Services.Interfaces
{
    /// <summary>
    /// Define las operaciones de negocio para la gestión de aeropuertos.
    /// Incluye creación, actualización, obtención, eliminación y reactivación.
    /// </summary>
    public interface IAirportService
    {
        /// <summary>Obtiene la lista de aeropuertos activos.</summary>
        Task<IEnumerable<AirportListDto>> GetAllActiveAsync();

        /// <summary>Obtiene la lista completa de aeropuertos (activos e inactivos).</summary>
        Task<IEnumerable<AirportListDto>> GetAllAsync();

        /// <summary>Obtiene la información detallada de un aeropuerto por su ID.</summary>
        Task<AirportDetailDto?> GetByIdAsync(int id);

        /// <summary>Crea un nuevo aeropuerto.</summary>
        Task<AirportResponseDto> CreateAsync(AirportCreateDto dto);

        /// <summary>Actualiza la información de un aeropuerto existente.</summary>
        Task<AirportResponseDto?> UpdateAsync(int id, AirportUpdateDto dto);

        /// <summary>Desactiva (elimina lógicamente) un aeropuerto.</summary>
        Task<bool> DeactivateAsync(int id);

        /// <summary>Reactiva un aeropuerto previamente desactivado.</summary>
        Task<bool> ReactivateAsync(int id);

        /// <summary>
        /// Busca aeropuertos que coincidan parcial o totalmente con el nombre,
        /// país o código IATA. Utilizado para autocompletado.
        /// </summary>
        /// <param name="query">Texto parcial a buscar.</param>
        /// <returns>Lista de aeropuertos que coinciden con el texto.</returns>
        Task<IEnumerable<AirportListDto>> SearchAsync(string query);


    }
}
