namespace AeroRide.API.Models.DTOs.Passengers
{
    /// <summary>
    /// Objeto de transferencia utilizado para registrar un nuevo pasajero dentro de una reserva.
    /// 
    /// Este DTO representa los datos personales que el usuario debe proporcionar
    /// al momento de añadir un pasajero a una reserva existente.
    /// </summary>
    public class PassengerCreateDto
    {
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
        /// Número de pasaporte o documento de identidad del pasajero.
        /// </summary>
        public string Passport { get; set; } = null!;

        /// <summary>
        /// Fecha de nacimiento del pasajero.
        /// </summary>
        public DateTime DateOfBirth { get; set; }

        /// <summary>
        /// Género del pasajero. 
        /// Debe ser uno de los valores definidos en la enumeración:
        /// <list type="bullet">
        /// <item><term>Male</term> — Masculino</item>
        /// <item><term>Female</term> — Femenino</item>
        /// <item><term>Other</term> — Otro / No especificado</item>
        /// </list>
        /// </summary>
        public string Gender { get; set; } = null!;
    }
}
