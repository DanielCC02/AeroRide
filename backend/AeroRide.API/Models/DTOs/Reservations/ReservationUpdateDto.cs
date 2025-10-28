namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Objeto de transferencia utilizado para actualizar una reserva existente.
    /// Permite modificar los datos generales de la reserva.
    /// </summary>
    public class ReservationUpdateDto
    {
        /// <summary>
        /// Precio total actualizado de la reserva.
        /// </summary>
        public double Price { get; set; }

        /// <summary>
        /// Indica si se mantiene o modifica la inclusión de un infante en regazo.
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indica si se mantiene o modifica la inclusión de un animal de asistencia.
        /// </summary>
        public bool AssistanceAnimal { get; set; }
    }
}
