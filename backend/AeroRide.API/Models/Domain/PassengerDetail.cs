using AeroRide.API.Models.Enums;
using System.ComponentModel.DataAnnotations.Schema;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entity that represents the personal information of a passenger
    /// associated with a reservation.
    /// Each reservation (<see cref="Reservation"/>) may include one or more passengers.
    /// </summary>
    public class PassengerDetail
    {
        /// <summary>
        /// Unique identifier of the passenger within the system.
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
        /// Passenger's passport number or identification document.
        /// </summary>
        public string Passport { get; set; } = null!;

        /// <summary>
        /// Passenger's nationality (e.g., "Costa Rica", "United States").
        /// </summary>
        public string Nationality { get; set; } = null!;

        /// <summary>
        /// Passenger's date of birth, used for age verification
        /// and legal or operational restrictions.
        /// </summary>
        public DateTime DateOfBirth { get; set; }

        /// <summary>
        /// Passenger's gender.
        /// </summary>
        public GenderType Gender { get; set; }

        /// <summary>
        /// Identifier of the reservation to which the passenger belongs.
        /// </summary>
        public int ReservationId { get; set; }

        /// <summary>
        /// Reference to the reservation associated with this passenger.
        /// </summary>
        public Reservation Reservation { get; set; } = null!;

        // ======================================================
        // 🧮 DERIVED PROPERTIES
        // ======================================================

        /// <summary>
        /// Calculated age of the passenger.
        /// This value is not stored in the database.
        /// </summary>
        [NotMapped]
        public int Age => (int)((DateTime.UtcNow - DateOfBirth).TotalDays / 365.25);
    }
}
