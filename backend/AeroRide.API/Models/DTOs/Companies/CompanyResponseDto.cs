namespace AeroRide.API.Models.DTOs.Companies
{
    public class CompanyResponseDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string? Email { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Address { get; set; }
        public double EmptyLegDiscount { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }

        // 💰 Configuración tarifaria
        public double DomesticWaitHourCost { get; set; }
        public double InternationalWaitHourCost { get; set; }
        public double DomesticOvernightCost { get; set; }
        public double InternationalOvernightCost { get; set; }
        public double AirportTaxPerPassenger { get; set; }
        public double HandlingPerPassenger { get; set; }
    }
}
