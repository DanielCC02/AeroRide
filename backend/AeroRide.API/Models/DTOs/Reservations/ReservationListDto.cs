namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Representa la información resumida de una reserva.
    /// Utilizado para listados o reportes generales.
    /// </summary>
    public class ReservationListDto
    {
        /// <summary>
        /// Identificador único de la reserva.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Identificador del usuario propietario de la reserva.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Precio total de la reserva.
        /// </summary>
        public double Price { get; set; }

        /// <summary>
        /// Indica si la reserva incluye un infante en regazo.
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indica si la reserva incluye un animal de asistencia.
        /// </summary>
        public bool AssistanceAnimal { get; set; }
    }
}
