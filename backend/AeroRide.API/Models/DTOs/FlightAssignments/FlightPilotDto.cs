namespace AeroRide.API.Models.DTOs.FlightAssignments
{
    /// <summary>
    /// Data Transfer Object that represents pilot information
    /// assigned to a flight.
    /// </summary>
    public class FlightPilotDto
    {
        /// <summary>
        /// Unique identifier of the pilot.
        /// </summary>
        public int PilotId { get; set; }

        /// <summary>
        /// Pilot's first name.
        /// </summary>
        public string PilotName { get; set; } = null!;

        /// <summary>
        /// Pilot's last name.
        /// </summary>
        public string PilotLastName { get; set; } = null!;

        /// <summary>
        /// Pilot's email address.
        /// </summary>
        public string Email { get; set; } = null!;

        /// <summary>
        /// Pilot's contact phone number.
        /// </summary>
        public string PhoneNumber { get; set; } = null!;

        /// <summary>
        /// Current status of the pilot's flight assignment
        /// (e.g., Assigned, Accepted, Completed).
        /// </summary>
        public string Status { get; set; } = null!;

        /// <summary>
        /// Crew role assigned to the pilot for the flight
        /// (e.g., Pilot, CoPilot).
        /// </summary>
        public string CrewRole { get; set; } = null!;
    }
}
