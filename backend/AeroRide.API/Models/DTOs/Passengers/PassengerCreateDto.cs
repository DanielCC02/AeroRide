using System.ComponentModel.DataAnnotations;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Passengers
{
    /// <summary>
    /// Data required to register a passenger within a reservation.
    /// </summary>
    public class PassengerCreateDto
    {
        /// <summary>
        /// Passenger's first name.
        /// </summary>
        [Required(ErrorMessage = "The passenger's first name is required.")]
        [StringLength(50)]
        public string Name { get; set; } = null!;

        /// <summary>
        /// Passenger's middle name (optional).
        /// </summary>
        [StringLength(50)]
        public string? MiddleName { get; set; }

        /// <summary>
        /// Passenger's last name.
        /// </summary>
        [Required(ErrorMessage = "The passenger's last name is required.")]
        [StringLength(50)]
        public string LastName { get; set; } = null!;

        /// <summary>
        /// Passenger's passport or identification number.
        /// </summary>
        [Required(ErrorMessage = "The passport number is required.")]
        [StringLength(30)]
        public string Passport { get; set; } = null!;

        /// <summary>
        /// Passenger's nationality.
        /// </summary>
        [Required(ErrorMessage = "Nationality is required.")]
        [StringLength(50)]
        public string Nationality { get; set; } = null!;

        /// <summary>
        /// Passenger's date of birth.
        /// </summary>
        [Required(ErrorMessage = "Date of birth is required.")]
        public DateTime DateOfBirth { get; set; }

        /// <summary>
        /// Passenger's gender.
        /// </summary>
        [Required(ErrorMessage = "The passenger's gender must be specified.")]
        public GenderType Gender { get; set; }
    }
}
