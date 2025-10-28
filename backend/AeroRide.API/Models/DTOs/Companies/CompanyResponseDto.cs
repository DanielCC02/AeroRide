namespace AeroRide.API.Models.DTOs.Companies
{
    /// <summary>
    /// DTO utilizado para devolver información general de una empresa.
    /// </summary>
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
    }
}
