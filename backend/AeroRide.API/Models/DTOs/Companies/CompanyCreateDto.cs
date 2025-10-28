using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Companies
{
    public class CompanyCreateDto
    {
        [Required(ErrorMessage = "El nombre de la empresa es obligatorio.")]
        [StringLength(100, ErrorMessage = "El nombre no puede exceder los 100 caracteres.")]
        public string Name { get; set; } = null!;

        [Required(ErrorMessage = "El correo de contacto es obligatorio.")]
        [EmailAddress(ErrorMessage = "Debe proporcionar un correo válido.")]
        public string Email { get; set; } = null!;

        [Required(ErrorMessage = "El número de teléfono es obligatorio.")]
        [Phone(ErrorMessage = "Debe ingresar un número de teléfono válido.")]
        public string PhoneNumber { get; set; } = null!;

        [Required(ErrorMessage = "La dirección es obligatoria.")]
        [StringLength(200, ErrorMessage = "La dirección no puede exceder los 200 caracteres.")]
        public string Address { get; set; } = null!;

        [Range(0, 1, ErrorMessage = "El descuento debe estar entre 0 y 1.")]
        public double EmptyLegDiscount { get; set; } = 0.5;
    }
}
