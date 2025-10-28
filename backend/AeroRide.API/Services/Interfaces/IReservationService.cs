using AeroRide.API.Models.DTOs.Passengers;
using AeroRide.API.Models.DTOs.Reservations;

namespace AeroRide.API.Interfaces
{
    /// <summary>
    /// Define las operaciones disponibles para la gestión de reservas.
    /// </summary>
    public interface IReservationService
    {
        Task<IEnumerable<ReservationResponse>> GetAllAsync();
        Task<ReservationResponse?> GetByIdAsync(int id);
        Task<IEnumerable<ReservationResponse>> GetByUserAsync(int userId);
        Task<ReservationResponse> CreateAsync(ReservationCreateDto dto);
        Task<bool> DeleteAsync(int id);

        // 🔹 Acciones de negocio
        Task<bool> CancelAsync(int id);
        Task<bool> ConfirmAsync(int id);
        Task<ReservationResponse?> AddPassengerAsync(int reservationId, PassengerCreateDto dto);
        Task<ReservationResponse?> AssignFlightAsync(int reservationId, int flightId);
    }
}
