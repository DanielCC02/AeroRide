namespace AeroRide.API.Models.DTOs.FlightAssignments
{
    /// <summary>
    /// Data Transfer Object used to assign flight crew members
    /// to a specific flight.
    /// </summary>
    public class FlightAssignmentCreateDto
    {
        /// <summary>
        /// Identifier of the pilot assigned to the flight.
        /// This pilot will act as the main (captain) pilot.
        /// </summary>
        public int PilotId { get; set; }

        /// <summary>
        /// Identifier of the co-pilot assigned to the flight, if applicable.
        /// </summary>
        public int? CoPilotId { get; set; }
    }
}
