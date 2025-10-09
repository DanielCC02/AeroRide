namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa los datos personales de un pasajero asociado a una reserva.
    /// Cada reserva (<see cref="Reservation"/>) puede incluir uno o varios pasajeros.
    /// </summary>
    public class PassengerDetails
    {
        /// <summary>
        /// Identificador único del pasajero dentro del sistema.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Primer nombre del pasajero.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Segundo nombre del pasajero (opcional).
        /// </summary>
        public string MiddleName { get; set; } = null!;

        /// <summary>
        /// Apellido del pasajero.
        /// </summary>
        public string LastName { get; set; } = null!;

        /// <summary>
        /// Número de pasaporte o documento de identidad del pasajero.
        /// </summary>
        public string Passport { get; set; } = null!;

        /// <summary>
        /// Fecha de nacimiento del pasajero (para verificaciones de edad o restricciones legales).
        /// </summary>
        public DateTime DateOfBirth { get; set; }

        /// <summary>
        /// Enumeración que representa los géneros posibles para los pasajeros.
        /// </summary>
        public enum GenderType
        {
            /// <summary>
            /// Género masculino.
            /// </summary>
            Male,

            /// <summary>
            /// Género femenino.
            /// </summary>
            Female,

            /// <summary>
            /// Género no especificado u otra identidad.
            /// </summary>
            Other
        }

        /// <summary>
        /// Género del pasajero (almacenado como texto en la base de datos).
        /// </summary>
        public GenderType Gender { get; set; }

        /// <summary>
        /// Identificador de la reserva a la que pertenece el pasajero.
        /// </summary>
        public int ReservationId { get; set; }

        /// <summary>
        /// Referencia a la reserva asociada a este pasajero.
        /// </summary>
        public Reservation Reservation { get; set; } = null!;
    }
}
