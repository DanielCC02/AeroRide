using System.ComponentModel.DataAnnotations;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Passengers
{
    /// <summary>
    /// DTO utilizado para actualizar la información de un pasajero existente.
    /// </summary>
    public class PassengerUpdateDto
    {
        [Required]
        public int Id { get; set; }

        [StringLength(50)]
        public string? Name { get; set; }

        [StringLength(50)]
        public string? MiddleName { get; set; }

        [StringLength(50)]
        public string? LastName { get; set; }

        [StringLength(30)]
        public string? Passport { get; set; }

        [StringLength(50)]
        public string? Nationality { get; set; }

        public DateTime? DateOfBirth { get; set; }

        public GenderType? Gender { get; set; }
    }
}
