using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Companies
{
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

        // 💰 Tarifas opcionales
        public double? DomesticWaitHourCost { get; set; }
        public double? InternationalWaitHourCost { get; set; }
        public double? DomesticOvernightCost { get; set; }
        public double? InternationalOvernightCost { get; set; }
        public double? AirportTaxPerPassenger { get; set; }
        public double? HandlingPerPassenger { get; set; }
    }
}
