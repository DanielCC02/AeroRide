namespace AeroRide.API.Models.DTOs.Passengers
{
    /// <summary>
    /// Objeto de transferencia utilizado para devolver la información completa de un pasajero.
    /// Incluye los datos personales registrados en la reserva.
    /// </summary>
    public class PassengerResponse
    {
        /// <summary>
        /// Identificador único del pasajero.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Primer nombre del pasajero.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Segundo nombre del pasajero (opcional).
        /// </summary>
        public string? MiddleName { get; set; }

        /// <summary>
        /// Apellido del pasajero.
        /// </summary>
        public string LastName { get; set; } = null!;

        /// <summary>
        /// Número de pasaporte o documento de identidad.
        /// </summary>
        public string Passport { get; set; } = null!;

        /// <summary>
        /// Fecha de nacimiento del pasajero.
        /// </summary>
        public DateTime DateOfBirth { get; set; }

        /// <summary>
        /// Género del pasajero.
        /// </summary>
        public string Gender { get; set; } = null!;
    }
}
