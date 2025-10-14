using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Aircrafts;

namespace AeroRide.API.Interfaces
{
    /// <summary>
    /// Define las operaciones del servicio de aeronaves (avionetas).
    /// </summary>
    public interface IAircraftService
    {
        /// <summary>
        /// Crea una nueva aeronave en el sistema.
        /// </summary>
        /// <param name="dto">Datos de creación de la aeronave.</param>
        /// <returns>DTO con la información de la aeronave creada.</returns>
        Task<AircraftResponseDto> CreateAsync(AircraftCreateDto dto);

        /// <summary>
        /// Obtiene la lista completa de aeronaves registradas.
        /// </summary>
        /// <returns>Lista de aeronaves en formato DTO.</returns>
        Task<IEnumerable<AircraftResponseDto>> GetAllAsync();

        /// <summary>
        /// Obtiene todas las aeronaves registradas, tanto activas como inactivas.
        /// </summary>
        /// <returns>Lista completa de aeronaves en formato DTO.</returns>
        Task<IEnumerable<AircraftResponseDto>> GetAllIncludingInactiveAsync();


        /// <summary>
        /// Obtiene los datos de una aeronave específica según su identificador.
        /// </summary>
        /// <param name="id">Identificador único de la aeronave.</param>
        /// <returns>DTO con la información de la aeronave encontrada, o null si no existe.</returns>
        Task<AircraftResponseDto?> GetByIdAsync(int id);

        /// <summary>
        /// Actualiza los datos de una aeronave existente.
        /// </summary>
        /// <param name="id">Identificador único de la aeronave.</param>
        /// <param name="dto">Datos a actualizar.</param>
        /// <returns>
        /// Un objeto <see cref="AircraftResponseDto"/> con los datos actualizados,
        /// o <c>null</c> si no se encontró la aeronave.
        /// </returns>
        Task<AircraftResponseDto?> UpdateAsync(int id, AircraftUpdateDto dto);

        /// <summary>
        /// Desactiva (elimina lógicamente) una aeronave existente.
        /// </summary>
        /// <param name="id">Identificador de la aeronave a desactivar.</param>
        /// <returns>
        /// <c>true</c> si la aeronave fue desactivada correctamente; 
        /// <c>false</c> si no se encontró o ya estaba inactiva.
        /// </returns>
        Task<bool> DeleteAsync(int id);

        /// <summary>
        /// Reactiva una aeronave previamente desactivada (soft delete).
        /// </summary>
        /// <param name="id">Identificador de la aeronave a reactivar.</param>
        /// <returns>
        /// <c>true</c> si se reactivó correctamente; <c>false</c> si no existe o ya estaba activa.
        /// </returns>
        Task<bool> ReactivateAsync(int id);

        /// <summary>
        /// Actualiza únicamente el estado operativo de una aeronave.
        /// </summary>
        /// <param name="id">Identificador de la aeronave.</param>
        /// <param name="newState">Nuevo estado a asignar.</param>
        /// <returns>
        /// Un mensaje de confirmación si la actualización fue exitosa,
        /// o un mensaje de error si la aeronave no existe o el estado es inválido.
        /// </returns>
        Task<(bool Success, string Message)> UpdateStateAsync(int id, string newState);

        // ======================================================
        // 🔹 FILTERS
        // ======================================================

        /// <summary>
        /// Filtra las aeronaves activas por número de asientos.
        /// Permite establecer un mínimo y un máximo para el filtro.
        /// </summary>
        /// <param name="minSeats">Cantidad mínima de asientos requerida.</param>
        /// <param name="maxSeats">Cantidad máxima de asientos (opcional).</param>
        /// <returns>Lista de aeronaves que cumplen con el filtro.</returns>
        Task<IEnumerable<AircraftResponseDto>> FilterBySeatsAsync(int minSeats, int? maxSeats);

    }
}
