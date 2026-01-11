using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Passengers
{
    /// <summary>
    /// Detailed information of a passenger registered within a reservation.
    /// </summary>
    public class PassengerDetailDto
    {
        /// <summary>
        /// Unique identifier of the passenger.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Passenger's first name.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Passenger's middle name (optional).
        /// </summary>
        public string? MiddleName { get; set; }

        /// <summary>
        /// Passenger's last name.
        /// </summary>
        public string LastName { get; set; } = null!;

        /// <summary>
        /// Passenger's passport or identification number.
        /// </summary>
        public string Passport { get; set; } = null!;

        /// <summary>
        /// Passenger's nationality.
        /// </summary>
        public string Nationality { get; set; } = null!;

        /// <summary>
        /// Passenger's date of birth.
        /// </summary>
        public DateTime DateOfBirth { get; set; }

        /// <summary>
        /// Passenger's gender.
        /// </summary>
        public GenderType Gender { get; set; }

        /// <summary>
        /// Passenger's age, dynamically calculated based on the date of birth.
        /// This value is not stored in the database.
        /// </summary>
        public int Age => (int)((DateTime.UtcNow - DateOfBirth).TotalDays / 365.25);
    }
}
