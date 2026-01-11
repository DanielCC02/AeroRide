using System.ComponentModel.DataAnnotations;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Passengers
{
    /// <summary>
    /// Data Transfer Object used to update the information
    /// of an existing passenger.
    /// </summary>
    public class PassengerUpdateDto
    {
        /// <summary>
        /// Unique identifier of the passenger to be updated.
        /// </summary>
        [Required]
        public int Id { get; set; }

        /// <summary>
        /// Updated first name of the passenger (optional).
        /// </summary>
        [StringLength(50)]
        public string? Name { get; set; }

        /// <summary>
        /// Updated middle name of the passenger (optional).
        /// </summary>
        [StringLength(50)]
        public string? MiddleName { get; set; }

        /// <summary>
        /// Updated last name of the passenger (optional).
        /// </summary>
        [StringLength(50)]
        public string? LastName { get; set; }

        /// <summary>
        /// Updated passport or identification number (optional).
        /// </summary>
        [StringLength(30)]
        public string? Passport { get; set; }

        /// <summary>
        /// Updated nationality of the passenger (optional).
        /// </summary>
        [StringLength(50)]
        public string? Nationality { get; set; }

        /// <summary>
        /// Updated date of birth of the passenger (optional).
        /// </summary>
        public DateTime? DateOfBirth { get; set; }

        /// <summary>
        /// Updated gender of the passenger (optional).
        /// </summary>
        public GenderType? Gender { get; set; }
    }
}
