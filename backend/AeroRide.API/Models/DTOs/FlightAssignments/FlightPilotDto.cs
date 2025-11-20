namespace AeroRide.API.Models.DTOs.FlightAssignments
{
    public class FlightPilotDto
    {
        public int PilotId { get; set; }
        public string PilotName { get; set; } = null!;
        public string PilotLastName { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string PhoneNumber { get; set; } = null!;
        public string Status { get; set; } = null!;
        public string CrewRole { get; set; } = null!;

    }
}
