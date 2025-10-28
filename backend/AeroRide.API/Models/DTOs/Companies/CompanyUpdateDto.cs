using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Companies
{
    /// <summary>
    /// DTO utilizado para modificar los datos de una empresa existente.
    /// </summary>
    public class CompanyUpdateDto
    {
        [StringLength(100)]
        public string? Name { get; set; }

        [EmailAddress]
        public string? Email { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        [StringLength(200)]
        public string? Address { get; set; }

        [Range(0, 1)]
        public double? EmptyLegDiscount { get; set; }

        public bool? IsActive { get; set; }
    }
}
