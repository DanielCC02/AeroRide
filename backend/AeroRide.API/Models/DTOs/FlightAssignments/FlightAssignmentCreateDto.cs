namespace AeroRide.API.Models.DTOs.FlightAssignments
{
    public class FlightAssignmentCreateDto
    {
        public int PilotId { get; set; }
        public int? CoPilotId { get; set; }
    }
}
