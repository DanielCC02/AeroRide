using AeroRide.API.Models.DTOs.Passengers;

namespace AeroRide.API.Models.DTOs.EmptyLegs
{
    public class EmptyLegReservationCreateDto
    {
        public int UserId { get; set; }
        public int EmptyLegFlightId { get; set; }

        // precio que viene del front (ya calculado)
        public double Price { get; set; }

        public bool LapChild { get; set; }
        public bool AssistanceAnimal { get; set; }
        public string? Notes { get; set; }

        public List<PassengerCreateDto> Passengers { get; set; } = new();
    }
}
