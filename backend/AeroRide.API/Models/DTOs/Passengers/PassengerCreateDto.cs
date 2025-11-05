using System.ComponentModel.DataAnnotations;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Passengers
{
    /// <summary>
    /// Datos necesarios para registrar un pasajero dentro de una reserva.
    /// </summary>
    public class PassengerCreateDto
    {
        [Required(ErrorMessage = "El nombre del pasajero es obligatorio.")]
        [StringLength(50)]
        public string Name { get; set; } = null!;

        [StringLength(50)]
        public string? MiddleName { get; set; }

        [Required(ErrorMessage = "El apellido del pasajero es obligatorio.")]
        [StringLength(50)]
        public string LastName { get; set; } = null!;

        [Required(ErrorMessage = "El número de pasaporte es obligatorio.")]
        [StringLength(30)]
        public string Passport { get; set; } = null!;

        [Required(ErrorMessage = "La nacionalidad es obligatoria.")]
        [StringLength(50)]
        public string Nationality { get; set; } = null!;

        [Required(ErrorMessage = "La fecha de nacimiento es obligatoria.")]
        public DateTime DateOfBirth { get; set; }

        [Required(ErrorMessage = "Debe especificarse el género del pasajero.")]
        public GenderType Gender { get; set; }
    }
}
