namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Objeto de transferencia utilizado para crear una nueva reserva.
    /// Contiene los campos necesarios para registrar la información básica de la reserva.
    /// </summary>
    public class ReservationCreateDto
    {
        /// <summary>
        /// Identificador del usuario que crea la reserva.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Precio total de la reserva, incluyendo impuestos y tasas.
        /// </summary>
        public double Price { get; set; }

        /// <summary>
        /// Indica si se incluye un infante en regazo.
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indica si se incluye un animal de asistencia en la reserva.
        /// </summary>
        public bool AssistanceAnimal { get; set; }
    }
}
