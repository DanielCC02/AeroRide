namespace AeroRide.API.Models.Enums
{
    /// <summary>
    /// Represents the current status of a reservation
    /// within the AeroRide system.
    /// </summary>
    public enum ReservationStatus
    {
        /// <summary>
        /// The reservation has been created but is still pending confirmation.
        /// </summary>
        Pendiente = 1,

        /// <summary>
        /// The reservation has been confirmed and is considered active.
        /// </summary>
        Confirmada = 2,

        /// <summary>
        /// The reservation has been cancelled and is no longer active.
        /// </summary>
        Cancelada = 3
    }
}
