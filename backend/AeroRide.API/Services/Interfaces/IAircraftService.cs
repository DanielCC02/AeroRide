using AeroRide.API.Models.DTOs.Aircrafts;
using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Interfaces
{
    /// <summary>
    /// Define las operaciones del servicio de aeronaves (avionetas).
    /// </summary>
    public interface IAircraftService
    {
        // ======================================================
        // 🔹 CRUD BÁSICO
        // ======================================================

        /// <summary>
        /// Crea una nueva aeronave en el sistema.
        /// </summary>
        /// <param name="dto">Datos de creación de la aeronave.</param>
        /// <returns>DTO con la información de la aeronave creada.</returns>
        Task<AircraftResponseDto> CreateAsync(AircraftCreateDto dto);

        /// <summary>
        /// Obtiene la lista de aeronaves activas registradas en el sistema.
        /// </summary>
        /// <returns>Lista de aeronaves activas en formato DTO.</returns>
        Task<IEnumerable<AircraftResponseDto>> GetAllAsync();

        /// <summary>
        /// Obtiene todas las aeronaves registradas, incluyendo activas e inactivas.
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
        /// <param name="newState">Nuevo estado a asignar (por ejemplo: Disponible, En mantenimiento).</param>
        /// <returns>
        /// Una tupla con un valor booleano indicando éxito y un mensaje descriptivo.
        /// </returns>
        Task<(bool Success, string Message)> UpdateStateAsync(int id, AircraftState newState);

        // ======================================================
        // 🔹 FILTRO Y AGRUPACIÓN (USADO EN RESERVAS)
        // ======================================================

        /// <summary>
        /// Devuelve las aeronaves disponibles agrupadas por modelo y compañía,
        /// aplicando filtros opcionales por número de asientos.
        /// </summary>
        /// <param name="minSeats">Cantidad mínima de asientos (opcional).</param>
        /// <param name="maxSeats">Cantidad máxima de asientos (opcional).</param>
        /// <returns>
        /// Lista agrupada de aeronaves disponibles por modelo y compañía.
        /// </returns>
        Task<IEnumerable<AircraftCategoryDto>> GetAvailableForCriteriaAsync(AircraftAvailabilityCriteriaDto criteria);
        Task<IEnumerable<AircraftResponseDto>> GetAllByCompanyAsync(int companyId);
        Task<IEnumerable<AircraftResponseDto>> GetActiveByCompanyAsync(int companyId);

    }
}
