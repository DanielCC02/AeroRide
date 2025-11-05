using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Companies
{
    public class CompanyCreateDto
    {
        [Required, StringLength(100)]
        public string Name { get; set; } = null!;

        [Required, EmailAddress]
        public string Email { get; set; } = null!;

        [Required, Phone]
        public string PhoneNumber { get; set; } = null!;

        [Required, StringLength(200)]
        public string Address { get; set; } = null!;

        [Range(0, 1)]
        public double EmptyLegDiscount { get; set; } = 0.5;

        // 💰 Tarifas opcionales (si no se envían, se aplican los valores por defecto)
        public double? DomesticWaitHourCost { get; set; }
        public double? InternationalWaitHourCost { get; set; }
        public double? DomesticOvernightCost { get; set; }
        public double? InternationalOvernightCost { get; set; }
        public double? AirportTaxPerPassenger { get; set; }
        public double? HandlingPerPassenger { get; set; }
    }
}
