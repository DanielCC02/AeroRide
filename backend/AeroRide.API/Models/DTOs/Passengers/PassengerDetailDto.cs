using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Passengers
{
    /// <summary>
    /// Detalle de un pasajero registrado en una reserva.
    /// </summary>
    public class PassengerDetailDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string? MiddleName { get; set; }
        public string LastName { get; set; } = null!;
        public string Passport { get; set; } = null!;
        public string Nationality { get; set; } = null!;
        public DateTime DateOfBirth { get; set; }
        public GenderType Gender { get; set; }

        /// <summary>
        /// Edad calculada dinámicamente.
        /// </summary>
        public int Age => (int)((DateTime.UtcNow - DateOfBirth).TotalDays / 365.25);
    }
}
