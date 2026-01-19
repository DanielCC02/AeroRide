using AeroRide.API.Models.DTOs.EmptyLegs;
using AeroRide.API.Models.DTOs.Reservations;

namespace AeroRide.API.Services.Interfaces
{
    /// <summary>
    /// Define las operaciones principales del servicio de reservas.
    /// Incluye creación, consulta, cancelación y cálculo estimado de precios.
    /// </summary>
    public interface IReservationService
    {
        /// <summary>
        /// Crea una nueva reserva completa, incluyendo vuelos y pasajeros.
        /// </summary>
        /// <param name="userId">Id del usuario que realiza la reserva.</param>
        /// <param name="dto">Datos de la reserva a crear.</param>
        /// <returns>DTO con la información completa de la reserva creada.</returns>
        Task<ReservationResponseDto> CreateAsync(int userId, ReservationCreateDto dto);

        /// <summary>
        /// Obtiene el detalle completo de una reserva.
        /// </summary>
        Task<ReservationResponseDto?> GetByIdAsync(int id);

        /// <summary>
        /// Obtiene todas las reservas del usuario autenticado.
        /// </summary>
        Task<IEnumerable<ReservationResponseDto>> GetByUserAsync(int userId);

        /// <summary>
        /// Cancela una reserva existente.
        /// </summary>
        Task<bool> CancelAsync(int reservationId);

        // ======================================================
        // 💰 NUEVO MÉTODO — CÁLCULO ESTIMADO DE PRECIO
        // ======================================================

        /// <summary>
        /// Calcula una estimación del precio total de una reserva,
        /// sin almacenarla en la base de datos. Se utiliza para mostrar
        /// al usuario el costo previo al booking.
        /// </summary>
        /// <param name="dto">Datos del itinerario, aeronave y pasajeros.</param>
        /// <returns>Resultado con el costo total, impuestos y duración estimada.</returns>
        Task<ReservationEstimateResponseDto> EstimatePriceAsync(ReservationEstimateDto dto);

        Task<ReservationResponseDto> ReserveEmptyLegAsync(EmptyLegReservationCreateDto dto);
        Task<IEnumerable<ReservationTripItemDto>> GetUpcomingTripsAsync(int userId);
        Task<IEnumerable<ReservationTripItemDto>> GetPastTripsAsync(int userId);

    }
}
